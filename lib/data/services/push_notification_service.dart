import 'package:flutter/widgets.dart';
import 'package:app_rtsg_client/application/trip_controller.dart';
import 'package:app_rtsg_client/data/models/trip_notification_event.dart';
import 'package:app_rtsg_client/data/services/trip_notification_ledger.dart';
import 'dart:async';
import 'dart:developer';

import 'package:app_rtsg_client/data/services/auth_service.dart';
import 'package:app_rtsg_client/data/services/local_storage_service.dart';
import 'package:app_rtsg_client/firebase_options.dart';
import 'package:app_rtsg_client/routes/rtsg_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

/// notification + data: el sistema presenta el aviso fuera de primer plano.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  // No crear otra notificación local: FCM ya presenta notification.
}

class PushNotificationService extends GetxService with WidgetsBindingObserver {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final AuthService _authService = AuthService();
  final LocalStorage _storage = LocalStorage();

  late final TripNotificationLedger _ledger = TripNotificationLedger(
    read: _storage.recentTripEvents,
    write: _storage.saveTripEvents,
  );
  bool _openingTrip = false;

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

    WidgetsBinding.instance.addObserver(this);

    final localLaunch = await _localNotifications
        .getNotificationAppLaunchDetails();
    if (localLaunch?.didNotificationLaunchApp == true) {
      _handleLocalNotificationTap(localLaunch?.notificationResponse?.payload);
    }

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );

    _messageSubscription = FirebaseMessaging.onMessage.listen(
      _handleForegroundMessage,
    );
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
      _updatePermissionStatus(settings);
    } catch (error) {
      _notificationsEnabled.value = false;
      log('[FCM] no se pudo solicitar permiso de notificaciones: $error');
    }
    return notificationsEnabled;
  }

  void _updatePermissionStatus(NotificationSettings settings) {
    _notificationsEnabled.value =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
    debugPrint(
      '[RTSG][AVISOS] permisos=${settings.authorizationStatus.name} '
      'alerta=${settings.alert.name} sonido=${settings.sound.name}',
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshPermissionStatus());
    }
  }

  Future<void> _refreshPermissionStatus() async {
    try {
      _updatePermissionStatus(await _messaging.getNotificationSettings());
    } catch (error) {
      debugPrint(
        '[RTSG][AVISOS] No se pudieron consultar los permisos: $error',
      );
    }
  }

  Future<bool> showTestNotification() async {
    await init();
    if (!await requestPermission()) return false;
    await _localNotifications.show(
      id: 2147483000,
      title: 'RTSG: aviso de prueba',
      body: 'Las notificaciones locales de este teléfono están configuradas.',
      notificationDetails: _tripNotificationDetails,
    );
    debugPrint('[RTSG][AVISOS] Prueba local solicitada al sistema operativo');
    return true;
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

  Future<void> _handleForegroundMessage(RemoteMessage message) =>
      handleForegroundTripEvent(
        message.data,
        title: message.notification?.title,
        body: message.notification?.body,
      );

  Future<void> handleForegroundTripEvent(
    Map<String, dynamic> data, {
    String? title,
    String? body,
  }) async {
    if (!_sessionReady ||
        !notificationsEnabled ||
        WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      debugPrint(
        '[RTSG][AVISOS] Evento omitido: sesión=$_sessionReady '
        'permiso=$notificationsEnabled app=${WidgetsBinding.instance.lifecycleState}',
      );
      return;
    }
    final event = TripNotificationEvent.fromData(data);
    if (event == null) {
      debugPrint(
        '[RTSG][AVISOS] Evento omitido: tipo o carrera no reconocidos',
      );
      return;
    }
    debugPrint(
      '[RTSG][AVISOS] Recibido: carrera=${event.tripId} '
      'estado=${event.stateCode} evento=${event.eventId}',
    );
    if (event.eventId == null) {
      log('[FCM] aviso omitido: falta evento_id para carrera ${event.tripId}');
      return;
    }
    try {
      final sent = await _ledger.runOnce(
        event.eventId!,
        () => _showLocalNotification(
          title ?? event.title,
          body ?? event.body,
          event,
        ),
      );
      debugPrint(
        '[RTSG][AVISOS] evento=${event.eventId}: '
        '${sent ? "aviso solicitado al sistema" : "duplicado omitido"}',
      );
    } catch (error) {
      log('[FCM] no se pudo mostrar el aviso de carrera: $error');
    }
  }

  void _handleOpenedMessage(RemoteMessage message) {
    final event = TripNotificationEvent.fromData(message.data);
    if (event != null) _queueTrip(event);
  }

  Future<void> _showLocalNotification(
    String title,
    String body,
    TripNotificationEvent event,
  ) async {
    await _localNotifications.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(2147483647),
      title: title,
      body: body,
      notificationDetails: _tripNotificationDetails,
      payload: event.payload,
    );
  }

  static const _tripNotificationDetails = NotificationDetails(
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
      presentBanner: true,
      presentList: true,
    ),
  );

  void _handleLocalNotificationTap(String? payload) {
    final event = TripNotificationEvent.fromPayload(payload);
    if (event != null) _queueTrip(event);
  }

  void _queueTrip(TripNotificationEvent event) {
    // Tocar una notificación siempre permite recuperar el estado, incluso
    // cuando ese evento ya produjo un aviso por otro canal.
    requestedAssignmentTripId.value = event.tripId;
    if (event.eventId != null) {
      unawaited(
        _ledger.runOnce(event.eventId!, () async {}).catchError((Object error) {
          log('[FCM] no se pudo registrar el evento abierto: $error');
          return false;
        }),
      );
    }
    unawaited(_openPendingAssignment());
  }

  Future<void> _openPendingAssignment() async {
    if (_openingTrip || !_sessionReady || Get.key.currentState == null) return;
    final tripId = requestedAssignmentTripId.value;
    if (tripId == null) return;
    _openingTrip = true;
    requestedAssignmentTripId.value = null;
    try {
      if (Get.currentRoute == AppRoutes.TRIP &&
          Get.isRegistered<TripController>()) {
        Get.find<TripController>().recoverAssignedTrip(tripId);
      } else {
        Get.toNamed<void>(
          AppRoutes.TRIP,
          arguments: {'assignedTripId': tripId},
        );
      }
    } finally {
      _openingTrip = false;
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _tokenRefreshSubscription?.cancel();
    _messageSubscription?.cancel();
    _openedSubscription?.cancel();
    super.onClose();
  }
}
