import 'dart:convert';

class TripNotificationEvent {
  final int tripId;
  final String? eventId;
  final String stateCode;
  final String type;
  const TripNotificationEvent({
    required this.tripId,
    required this.type,
    required this.stateCode,
    this.eventId,
  });

  static TripNotificationEvent? fromData(Map<String, dynamic> source) {
    var data = Map<String, dynamic>.from(source);
    for (final key in ['data', 'carrera']) {
      dynamic nested = data[key];
      if (nested is String) {
        try {
          nested = jsonDecode(nested);
        } catch (_) {
          return null;
        }
      }
      if (nested is Map) data = {...data, ...Map<String, dynamic>.from(nested)};
    }
    final type = (data['tipo'] ?? data['type'] ?? '')
        .toString()
        .trim()
        .toUpperCase();
    if (!const {
      'CONDUCTOR_ASIGNADO',
      'CARRERA_ASIGNADA',
      'ESTADO_CARRERA',
      'ACTUALIZACION_CARRERA',
    }.contains(type)) {
      return null;
    }
    final id = int.tryParse(
      (data['carrera_id'] ?? data['trip_id'] ?? '').toString(),
    );
    if (id == null || id <= 0) return null;
    final eventId = data['evento_id']?.toString().trim();
    return TripNotificationEvent(
      tripId: id,
      type: type,
      stateCode: (data['estado_codigo'] ?? data['estado'] ?? '')
          .toString()
          .trim()
          .toUpperCase(),
      eventId: eventId == null || eventId.isEmpty ? null : eventId,
    );
  }

  String get title => switch (stateCode) {
    'S' || 'B' => 'Buscando conductor',
    'R' => 'Hay conductores disponibles',
    'E' || 'EN_CAMINO' => 'Tu conductor viene en camino',
    'L' => 'Tu conductor ha llegado',
    'I' => 'Tu viaje ha comenzado',
    'F' => 'Tu viaje ha finalizado',
    'C' || 'P' => 'Tu viaje fue cancelado',
    _ =>
      type == 'CONDUCTOR_ASIGNADO'
          ? 'Conductor asignado'
          : 'Tu viaje se ha actualizado',
  };
  String get body => 'Toca para consultar el estado actual de tu viaje.';
  String get payload => jsonEncode({
    'tipo': type,
    'carrera_id': tripId,
    'estado_codigo': stateCode,
    if (eventId != null) 'evento_id': eventId,
  });

  static TripNotificationEvent? fromPayload(String? payload) {
    if (payload == null) return null;
    final oldId = int.tryParse(payload);
    if (oldId != null && oldId > 0) {
      return TripNotificationEvent(
        tripId: oldId,
        type: 'CONDUCTOR_ASIGNADO',
        stateCode: '',
      );
    }
    try {
      final value = jsonDecode(payload);
      return value is Map ? fromData(Map<String, dynamic>.from(value)) : null;
    } catch (_) {
      return null;
    }
  }
}
