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
  // final String status;
  final TripStatus status;
  final DateTime createdAt;
  final int passengerId;
  final String passenger;
  final String nip;
  final String? cellular;
  final String email;
  final int travelCategoryId;
  final String name; // nombre de la categoría (ej. VIP 1)
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
    return Trip(
      idTravelRequest: json['id_travel_request'] as int,
      tripId: json['trip_id'] as int?,
      requestedDate: DateTime.parse(json['requested_date'] as String),
      departureAddress: (json['departure_address'] ?? '') as String,
      destinationAddress: (json['destination_address'] ?? '') as String,
      departureCoords: json['departure_coords'] as String?,
      destinationCoords: json['destination_coords'] as String?,
      passengerCount: (json['passenger_count'] ?? 0) as int,
      luggageCount: (json['luggage_count'] ?? 0) as int?,
      cost: json['cost'] as num,
      notes: (json['notes'] ?? '') as String,
      status: _statusFrom(json['status']),
      createdAt: DateTime.parse(json['created_at'] as String),
      passengerId: json['passenger_id'] as int,
      passenger: (json['passenger'] ?? '') as String,
      nip: (json['nip'] ?? '') as String,
      cellular: json['cellular'] as String?,
      email: ((json['email'] ?? '') as String).replaceAll(',', '.'),
      travelCategoryId: json['travel_category_id'] as int,
      name: (json['name'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      routeId: json['route_id'] as int,
      route: (json['route'] ?? '') as String,
      distanceKm: json['distance_km'] as num,
      estimatedTime: _parseHMS(json['estimated_time'] as String),
      baseFare: json['base_fare'] as num,
      nameUser: (json['name_user'] ?? '') as String,
    );
  }

  static Duration _parseHMS(String hms) {
    // Formato esperado "HH:MM:SS"
    final parts = hms.split(':').map(int.parse).toList();
    final h = parts.isNotEmpty ? parts[0] : 0;
    final m = parts.length > 1 ? parts[1] : 0;
    final s = parts.length > 2 ? parts[2] : 0;
    return Duration(hours: h, minutes: m, seconds: s);
  }

  static TripStatus _statusFrom(dynamic raw) {
    if (raw == null) return TripStatus.pending;

    // Si viene numérico (ej. desde DB): 0..4
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

    // Si viene como String
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
      case 'canceled': // por si acaso
      case 'cancelado':
        return TripStatus.cancelled;
      default:
        // fallback para no romper la app si el backend manda algo nuevo
        return TripStatus.pending;
    }
  }

  static String priceLabel(Trip t) =>
      t.cost != null ? '\$${t.cost!.toStringAsFixed(0)}' : '--';

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
}
