import 'dart:ui';

enum TripStatus { pending, verified, inProgress, completed, cancelled }

class Trip {
  final int idTravelRequest;
  final int? tripId;
  final DateTime requestedDate;
  final String departureAddress;
  final String destinationAddress;
  final String? departureCoords;
  final String? destinationCoords;
  final int passengerCount;
  final int? luggageCount;
  final num cost;
  final String notes;
  final TripStatus status;
  final DateTime createdAt;
  final int passengerId;
  final String passenger;
  final String nip;
  final String? cellular;
  final String email;
  final int travelCategoryId;
  final String name;
  final String description;
  final int routeId;
  final String route;
  final num distanceKm;
  final Duration estimatedTime;
  final num baseFare;
  final String nameUser;

  Trip({
    required this.idTravelRequest,
    this.tripId,
    required this.requestedDate,
    required this.departureAddress,
    required this.destinationAddress,
    required this.departureCoords,
    required this.destinationCoords,
    required this.passengerCount,
    this.luggageCount,
    required this.cost,
    required this.notes,
    required this.status,
    required this.createdAt,
    required this.passengerId,
    required this.passenger,
    required this.nip,
    required this.cellular,
    required this.email,
    required this.travelCategoryId,
    required this.name,
    required this.description,
    required this.routeId,
    required this.route,
    required this.distanceKm,
    required this.estimatedTime,
    required this.baseFare,
    required this.nameUser,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    final requestedDate = _date(
      json['requested_date'] ?? json['fecha_solicitud'] ?? json['fecha'],
    );
    final createdAt = _date(
      json['created_at'] ?? json['fecha_registro'],
      fallback: requestedDate,
    );

    return Trip(
      idTravelRequest: _int(
        json['id_travel_request'] ?? json['id_solicitud'] ?? json['id'],
      ),
      tripId: _nullableInt(json['trip_id'] ?? json['id_viaje']),
      requestedDate: requestedDate,
      departureAddress: _string(
        json['departure_address'] ?? json['direccion_origen'],
      ),
      destinationAddress: _string(
        json['destination_address'] ?? json['direccion_destino'],
      ),
      departureCoords: _nullableString(
        json['departure_coords'] ?? json['coordenadas_origen'],
      ),
      destinationCoords: _nullableString(
        json['destination_coords'] ?? json['coordenadas_destino'],
      ),
      passengerCount: _int(json['passenger_count'], fallback: 1),
      luggageCount: _nullableInt(json['luggage_count']),
      cost: _num(json['cost'] ?? json['costo']),
      notes: _string(json['notes'] ?? json['observacion']),
      status: _statusFrom(json['status'] ?? json['estado_viaje']),
      createdAt: createdAt,
      passengerId: _int(json['passenger_id'] ?? json['pasajero_id']),
      passenger: _string(json['passenger'] ?? json['pasajero']),
      nip: _string(json['nip']),
      cellular: _nullableString(json['cellular'] ?? json['celular']),
      email: _string(json['email'] ?? json['correo']).replaceAll(',', '.'),
      travelCategoryId: _int(
        json['travel_category_id'] ?? json['categoria_viaje_id'],
      ),
      name: _string(json['name'] ?? json['categoria']),
      description: _string(json['description'] ?? json['descripcion']),
      routeId: _int(json['route_id'] ?? json['ruta_id']),
      route: _string(json['route'] ?? json['ruta']),
      distanceKm: _num(json['distance_km'] ?? json['distancia_km']),
      estimatedTime: _duration(
        json['estimated_time'] ?? json['tiempo_estimado'],
      ),
      baseFare: _num(json['base_fare'] ?? json['tarifa_base']),
      nameUser: _string(json['name_user'] ?? json['nombre_usuario']),
    );
  }

  static Duration _duration(dynamic value) {
    if (value == null) return Duration.zero;
    if (value is num) return Duration(seconds: value.toInt());

    final text = value.toString().trim();
    if (text.isEmpty) return Duration.zero;

    final parts = text.split(':');
    if (parts.length >= 2) {
      final h = int.tryParse(parts[0]) ?? 0;
      final m = int.tryParse(parts[1]) ?? 0;
      final secondsPart = parts.length > 2 ? parts[2].split('.').first : '0';
      final s = int.tryParse(secondsPart) ?? 0;
      return Duration(hours: h, minutes: m, seconds: s);
    }

    final seconds = int.tryParse(text);
    return seconds == null ? Duration.zero : Duration(seconds: seconds);
  }

  static TripStatus _statusFrom(dynamic raw) {
    if (raw == null) return TripStatus.pending;

    if (raw is num) {
      switch (raw.toInt()) {
        case 0:
          return TripStatus.pending;
        case 1:
          return TripStatus.verified;
        case 2:
          return TripStatus.inProgress;
        case 3:
          return TripStatus.completed;
        case 4:
          return TripStatus.cancelled;
        default:
          return TripStatus.pending;
      }
    }

    final v = raw.toString().trim().toLowerCase();
    switch (v) {
      case 'pending':
      case 'pendiente':
        return TripStatus.pending;
      case 'verified':
      case 'verificado':
        return TripStatus.verified;
      case 'inprogress':
      case 'in_progress':
      case 'en_progreso':
      case 'enprogreso':
        return TripStatus.inProgress;
      case 'completed':
      case 'completado':
      case 'complete':
        return TripStatus.completed;
      case 'cancelled':
      case 'canceled':
      case 'cancelado':
        return TripStatus.cancelled;
      default:
        return TripStatus.pending;
    }
  }

  static String priceLabel(Trip t) => '\$${t.cost.toStringAsFixed(2)}';

  static Color leftBorder(TripStatus s) {
    switch (s) {
      case TripStatus.pending:
        return const Color(0xFFF59E0B);
      case TripStatus.verified:
        return const Color(0xFF10B981);
      case TripStatus.inProgress:
        return const Color(0xFF3B82F6);
      case TripStatus.completed:
        return const Color(0xFF6B7280);
      case TripStatus.cancelled:
        return const Color(0xFFEF4444);
    }
  }

  static int _int(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static int? _nullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static num _num(dynamic value) {
    if (value is num) return value;
    return num.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _string(dynamic value) => value?.toString() ?? '';

  static String? _nullableString(dynamic value) {
    if (value == null) return null;
    final text = value.toString();
    return text.isEmpty ? null : text;
  }

  static DateTime _date(dynamic value, {DateTime? fallback}) {
    if (value is DateTime) return value;
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    return parsed ?? fallback ?? DateTime.fromMillisecondsSinceEpoch(0);
  }
}
