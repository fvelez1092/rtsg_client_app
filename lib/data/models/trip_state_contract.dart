import 'trip_status.dart';

/// estado_codigo tiene prioridad sobre los nombres de compatibilidad del ACK.
TripStatus? tripStatusFromBackend(Map<String, dynamic> trip) {
  final state =
      (trip['estado_codigo'] ??
              trip['estado'] ??
              trip['estadocarrera'] ??
              trip['estado_carrera'] ??
              trip['status'] ??
              '')
          .toString()
          .trim()
          .toUpperCase();
  return switch (state) {
    'E' || 'EN_CAMINO' => TripStatus.accepted,
    'L' || 'CLIENTE_NOTIFICADO_LLEGADA' => TripStatus.arrived,
    'I' || 'INICIADO' || 'EN_PROGRESO' => TripStatus.started,
    'F' || 'FINALIZADA' || 'FINALIZADO' => TripStatus.completed,
    _ => null,
  };
}
