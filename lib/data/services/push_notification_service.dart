import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:app_rtsg_client/data/services/auth_service.dart';
import 'package:app_rtsg_client/data/services/local_storage_service.dart';
import 'package:app_rtsg_client/firebase_options.dart';
import 'package:app_rtsg_client/routes/rtsg_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

/// El FCM solo avisa que el conductor fue asignado.
/// La información vigente de la carrera se recupera por Socket.IO.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  final tripId = _assignmentTripIdFromData(message.data);
  if (tripId == null) return;

  final notifications = FlutterLocalNotificationsPlugin();
  await notifications.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
  );
  await notifications.show(
    id: tripId,
    title: message.notification?.title ?? 'Conductor asignado',
    body: message.notification?.body ??
        'Abre RTSG para consultar los datos de tu carrera.',
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        'rtsg_trip_updates',
        'Actualizaciones de carrera',
        channelDescription: 'Avisos sobre el estado de tus carreras RTSG.',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
    payload: tripId.toString(),
  );
  log('[FCM] asignación mostrada en segundo plano: carrera_id=$tripId');
}

int? _assignmentTripIdFromData(Map<String, dynamic> source) {
  var data = Map<String, dynamic>.from(source);
  final nested = data['data'];
  if (nested is String) {
    try {
      final decoded = jsonDecode(nested);
      if (decoded is Map) data = {...data, ...Map<String, dynamic>.from(decoded)};
    } catch (_) {
      return null;
    }
  } else if (nested is Map) {
    data = {...data, ...Map<String, dynamic>.from(nested)};
  }

  final type = (data['tipo'] ?? data['type'] ?? data['evento'] ?? data['event'])
      ?.toString()
      .trim()
      .toUpperCase();
  if (type != 'CONDUCTOR_ASIGNADO') return null;

  final rawId = data['carrera_id'] ?? data['trip_id'];
  final tripId = int.tryParse(rawId?.toString() ?? '');
  return tripId != null && tripId > 0 ? tripId : null;
}

class PushNotificationService extends GetxService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final AuthService _authService = AuthService();
  final LocalStorage _storage = LocalStorage();

  final RxBool _notificationsEnabled = false.obs;
  final RxBool isDeviceRegistered = false.obs;
  final RxnInt requestedAssignmentTripId = RxnInt();

  Future<void>? _initialization;
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _messageSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;
  String? _registeredFcmToken;
  String? _registeredSessionToken;
  bool _sessionReady = false;

  bool get notificationsEnabled => _notificationsEnabled.value;

  Future<void> init() => _initialization ??= _initialize();

  Future<void> _initialize() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        _handleLocalNotificationTap(response.payload);
      },
    );

    final localLaunch = await _localNotifications.getNotificationAppLaunchDetails();
    if (localLaunch?.didNotificationLaunchApp == true) {
      _handleLocalNotificationTap(
        localLaunch?.notificationResponse?.payload,
      );
    }

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );

    _messageSubscription =
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    _openedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      _handleOpenedMessage,
    );

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) _handleOpenedMessage(initialMessage);

    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen((token) {
      log('[FCM] token renovado; actualizando registro del dispositivo');
      unawaited(_registerDeviceToken(token));
    });
  }

  Future<void> onAuthenticated() async {
    _sessionReady = true;
    await requestPermission();
    if (notificationsEnabled) {
      await _registerCurrentDeviceToken();
    }
    await _openPendingAssignment();
  }

  void onSignedOut() {
    _sessionReady = false;
    requestedAssignmentTripId.value = null;
    isDeviceRegistered.value = false;
    _registeredFcmToken = null;
    _registeredSessionToken = null;
  }

  Future<bool> requestPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      _notificationsEnabled.value =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (error) {
      _notificationsEnabled.value = false;
      log('[FCM] no se pudo solicitar permiso de notificaciones: $error');
    }
    return notificationsEnabled;
  }

  Future<void> registerDeviceForCurrentSession() async {
    if (!notificationsEnabled && !await requestPermission()) return;
    await _registerCurrentDeviceToken();
  }

  Future<void> _registerCurrentDeviceToken() async {
    final sessionToken = (await _storage.getToken())?.trim();
    if (sessionToken == null || sessionToken.isEmpty) {
      log('[FCM] registro pendiente: no hay una sesión de cliente activa');
      return;
    }

    try {
      final token = await _messaging.getToken();
      if (token == null || token.trim().isEmpty) {
        log('[FCM] registro pendiente: Firebase todavía no entrega el token');
        return;
      }
      await _registerDeviceToken(token);
    } catch (error) {
      isDeviceRegistered.value = false;
      log('[FCM] no se pudo obtener el token FCM: $error');
    }
  }

  Future<void> _registerDeviceToken(String token) async {
    final sessionToken = (await _storage.getToken())?.trim();
    if (sessionToken == null || sessionToken.isEmpty) {
      isDeviceRegistered.value = false;
      return;
    }
    if (isDeviceRegistered.value &&
        _registeredFcmToken == token &&
        _registeredSessionToken == sessionToken) {
      return;
    }

    try {
      // ApiInterceptor añade x-access-token con el JWT del cliente.
      // El backend identifica al cliente desde ese JWT.
      await _authService.registerDeviceToken(token);
      _registeredFcmToken = token;
      _registeredSessionToken = sessionToken;
      isDeviceRegistered.value = true;
      log('[FCM] token del dispositivo registrado para la sesión activa');
    } catch (error) {
      isDeviceRegistered.value = false;
      log('[FCM] no se pudo registrar el dispositivo: $error');
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final tripId = _assignmentTripId(message.data);
    if (tripId == null) return;

    final title = message.notification?.title ?? 'Conductor asignado';
    final body = message.notification?.body ??
        'Abre RTSG para consultar los datos de tu carrera.';
    await _showLocalNotification(title, body, tripId);
  }

  void _handleOpenedMessage(RemoteMessage message) {
    final tripId = _assignmentTripId(message.data);
    if (tripId == null) {
      log('[FCM] se ignoró una push que no corresponde a una asignación de cliente');
      return;
    }
    log('[FCM] asignación abierta: carrera_id=$tripId');
    _queueAssignment(tripId);
  }

  Future<void> _showLocalNotification(
    String title,
    String body,
    int tripId,
  ) async {
    await _localNotifications.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(2147483647),
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'rtsg_trip_updates',
          'Actualizaciones de carrera',
          channelDescription: 'Avisos sobre el estado de tus carreras RTSG.',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: tripId.toString(),
    );
  }

  void _handleLocalNotificationTap(String? payload) {
    final tripId = int.tryParse(payload ?? '');
    if (tripId == null || tripId <= 0) return;
    log('[FCM] notificación local abierta: carrera_id=$tripId');
    _queueAssignment(tripId);
  }

  void _queueAssignment(int tripId) {
    requestedAssignmentTripId.value = tripId;
    unawaited(_openPendingAssignment());
  }

  Future<void> _openPendingAssignment() async {
    final tripId = requestedAssignmentTripId.value;
    if (!_sessionReady || tripId == null || Get.key.currentState == null) {
      return;
    }

    final arguments = <String, dynamic>{'assignedTripId': tripId};
    if (Get.currentRoute == AppRoutes.TRIP) {
      await Get.offNamed<void>(AppRoutes.TRIP, arguments: arguments);
    } else {
      await Get.toNamed<void>(AppRoutes.TRIP, arguments: arguments);
    }
    if (requestedAssignmentTripId.value == tripId) {
      requestedAssignmentTripId.value = null;
    }
  }

  int? _assignmentTripId(Map<String, dynamic> source) {
    var data = Map<String, dynamic>.from(source);
    final nested = data['data'];
    if (nested is String) {
      try {
        final decoded = jsonDecode(nested);
        if (decoded is Map) data = {...data, ...Map<String, dynamic>.from(decoded)};
      } catch (_) {
        return null;
      }
    } else if (nested is Map) {
      data = {...data, ...Map<String, dynamic>.from(nested)};
    }

    final type = (data['tipo'] ?? data['type'] ?? data['evento'] ?? data['event'])
        ?.toString()
        .trim()
        .toUpperCase();
    if (type != 'CONDUCTOR_ASIGNADO') return null;

    final rawId = data['carrera_id'] ?? data['trip_id'];
    final tripId = int.tryParse(rawId?.toString() ?? '');
    return tripId != null && tripId > 0 ? tripId : null;
  }

  @override
  void onClose() {
    _tokenRefreshSubscription?.cancel();
    _messageSubscription?.cancel();
    _openedSubscription?.cancel();
    super.onClose();
  }
}
