import 'dart:async';
import 'dart:convert';

import 'package:app_rtsg_client/core/constants/api_constants.dart';
import 'package:app_rtsg_client/data/services/local_storage_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class TripSocketService {
  io.Socket? _socket;
  final _assignmentController = StreamController<Map<String, dynamic>>.broadcast();
  final _locationController = StreamController<Map<String, dynamic>>.broadcast();
  final _statusController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get assignments => _assignmentController.stream;
  Stream<Map<String, dynamic>> get locations => _locationController.stream;
  Stream<Map<String, dynamic>> get statusUpdates => _statusController.stream;

  Future<void> connect() async {
    if (_socket?.connected == true) return;
    final token = await LocalStorage().getToken();
    if (token == null || token.isEmpty) return;

    final url = ApiConstants.baseUrl.replaceFirst('/api/', '');
    final socket = io.io(url, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'reconnection': true,
      'auth': {'token': token},
    });
    _socket = socket;

    socket.on('conductorSeleccionado', (args) {
      final data = args is List && args.isNotEmpty ? args.first : args;
      final confirm = args is List && args.length > 1 && args[1] is Function
          ? args[1] as Function
          : null;
      _assignmentController.add(_map(data));
      confirm?.call({'ok': true});
    });
    socket.on('ubicacionConductor', (data) {
      _locationController.add(_map(data));
    });
    socket.on('estadoCarreraActualizado', (data) {
      _statusController.add(_map(data));
    });
    socket.onConnect((_) {
      socket.emit('autenticarSocket', {'token': token});
    });
    socket.connect();
  }

  void listenForTrip(String carreraId) {
    _socket?.emit('suscribirCarrera', {'carrera_id': carreraId});
  }

  void consultarEstado(String carreraId) {
    _socket?.emit('consultarEstadoCarrera', {'carrera_id': carreraId});
  }

  Map<String, dynamic> _map(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String) {
      final decoded = jsonDecode(data);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    }
    return <String, dynamic>{};
  }

  Future<void> dispose() async {
    _socket?.dispose();
    await _assignmentController.close();
    await _locationController.close();
    await _statusController.close();
  }
}
