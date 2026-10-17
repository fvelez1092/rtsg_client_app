import 'package:get/get.dart';
import 'package:app_rtsg_client/data/services/push_notification_service.dart';
import 'package:app_rtsg_client/data/services/trip_diagnostics.dart';
import 'dart:async';
import 'dart:convert';

import 'package:app_rtsg_client/core/constants/api_constants.dart';
import 'package:app_rtsg_client/data/services/local_storage_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Mantiene el socket del cliente autenticado y suscrito a su carrera activa.
class TripSocketService {
  io.Socket? _socket;
  String? _activeTripId;
  bool _authenticated = false;

  final _assignmentController =
      StreamController<Map<String, dynamic>>.broadcast(sync: true);
  final _locationController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _statusController = StreamController<Map<String, dynamic>>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  Stream<Map<String, dynamic>> get assignments => _assignmentController.stream;
  Stream<Map<String, dynamic>> get locations => _locationController.stream;
  Stream<Map<String, dynamic>> get statusUpdates => _statusController.stream;
  Stream<String> get errors => _errorController.stream;

  Future<void> connect() async {
    if (_socket != null) {
      if (_socket!.connected && !_authenticated) {
        _authenticate();
      }
      return;
    }

    final token = await LocalStorage().getToken();
    if (token == null || token.trim().isEmpty) {
      _errorController.add('No hay una sesión válida para conectar el socket.');
      return;
    }

    final url = ApiConstants.baseUrl.replaceFirst('/api/', '');
    final socket = io.io(url, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'reconnection': true,
      'auth': {'token': token},
    });
    _socket = socket;

    // Los listeners se instalan antes de conectar/autenticar para no perder
    // una recuperación inmediata de la carrera al entrar a la sala.
    socket.on('conductorSeleccionado', (args) {
      final eventArgs = args is List ? args : <dynamic>[args];
      if (eventArgs.isEmpty) return;

      logTripEvent(
        'socket.conductorSeleccionado',
        eventArgs.first,
        activeTripId: _activeTripId,
      );
      final event = _map(eventArgs.first);
      final confirm = eventArgs.length > 1 && eventArgs[1] is Function
          ? eventArgs[1] as Function
          : null;

      _assignmentController.add(event);
      _notifyForeground(event, 'CONDUCTOR_ASIGNADO');
      try {
        confirm?.call({'ok': true});
      } catch (_) {
        // La sincronización al reconectar puede venir sin callback.
      }
    });
    socket.on('ubicacionConductor', (data) {
      _locationController.add(_map(data));
    });
    socket.on('estadoCarreraActualizado', (data) {
      logTripEvent(
        'socket.estadoCarreraActualizado',
        data,
        activeTripId: _activeTripId,
      );
      final event = _map(data);
      _statusController.add(event);
      _notifyForeground(event, 'ESTADO_CARRERA');
    });
    socket.onConnect((_) => _authenticate());
    socket.onConnectError((error) {
      _authenticated = false;
      _errorController.add(
        'No se pudo conectar al servicio de carreras: $error',
      );
    });
    socket.onError((error) {
      _errorController.add('Error del servicio de carreras: $error');
    });
    socket.onDisconnect((_) => _authenticated = false);

    socket.connect();
  }

  void _authenticate() {
    final socket = _socket;
    if (socket == null || !socket.connected) return;

    LocalStorage()
        .getToken()
        .then((token) {
          if (token == null || token.trim().isEmpty || !socket.connected) {
            _errorController.add(
              'No hay una sesión válida para autenticar el socket.',
            );
            return;
          }

          socket.emitWithAck(
            'autenticarSocket',
            {'token': token},
            ack: (response) {
              final result = _map(response);
              if (result['ok'] != true) {
                _authenticated = false;
                _errorController.add(
                  (result['error'] ??
                          'El servidor rechazó la autenticación del socket.')
                      .toString(),
                );
                return;
              }

              _authenticated = true;
              final tripId = _activeTripId;
              if (tripId != null) {
                _subscribeAndRecover(tripId);
              }
            },
          );
        })
        .catchError((Object error) {
          _errorController.add('No se pudo leer la sesión: $error');
        });
  }

  void listenForTrip(String carreraId) {
    _activeTripId = carreraId;
    if (_authenticated) _subscribeAndRecover(carreraId);
  }

  void _subscribeAndRecover(String carreraId) {
    final socket = _socket;
    if (socket == null || !socket.connected || !_authenticated) return;

    socket.emit('suscribirCarrera', {'carrera_id': carreraId});
    consultarEstado(carreraId);
  }

  void consultarEstado(String carreraId) {
    final socket = _socket;
    if (socket == null || !socket.connected || !_authenticated) return;

    logTripEvent('socket.consultarEstadoCarrera.solicitud', {
      'carrera_id': carreraId,
    }, activeTripId: _activeTripId);
    socket.emitWithAck(
      'consultarEstadoCarrera',
      {'carrera_id': int.tryParse(carreraId) ?? carreraId},
      ack: (response) {
        logTripEvent(
          'socket.consultarEstadoCarrera.respuesta',
          response,
          activeTripId: _activeTripId,
        );
        final result = _map(response);
        if (result['ok'] != true) {
          final error = result['error'];
          if (error != null) _errorController.add(error.toString());
          return;
        }

        final carrera = result['carrera'];
        if (carrera is Map) {
          // Mantiene el mismo formato que conductorSeleccionado para que el
          // controlador procese asignaciones en vivo y recuperadas por igual.
          _assignmentController.add(<String, dynamic>{
            'carrera': Map<String, dynamic>.from(carrera),
            '_recovered': true,
          });
        }
      },
    );
  }

  void _notifyForeground(Map<String, dynamic> event, String type) {
    if (!Get.isRegistered<PushNotificationService>()) return;
    unawaited(
      Get.find<PushNotificationService>().handleForegroundTripEvent({
        'tipo': type,
        ...event,
      }),
    );
  }

  Map<String, dynamic> _map(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {
        return <String, dynamic>{};
      }
    }
    return <String, dynamic>{};
  }

  Future<void> dispose() async {
    _socket?.dispose();
    _socket = null;
    _authenticated = false;
    _activeTripId = null;
    await _assignmentController.close();
    await _locationController.close();
    await _statusController.close();
    await _errorController.close();
  }
}
