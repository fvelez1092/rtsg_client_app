class TripCost {
  final int idRouteCategoryCost;
  final num baseFare;
  final num extraPerPassenger;
  final num extraPerLuggage;
  final String currency;
  final DateTime effectiveFrom;
  final DateTime? effectiveTo;
  final String status; // "active"
  final int idRoute;
  final String originCity;
  final String destinationCity;
  final num distanceKm;
  final Duration estimatedTime;
  final int idTravelCategory;
  final String name; // p. ej. VIP 1
  final String description; // descripción categoría

  TripCost({
    required this.idRouteCategoryCost,
    required this.baseFare,
    required this.extraPerPassenger,
    required this.extraPerLuggage,
    required this.currency,
    required this.effectiveFrom,
    required this.effectiveTo,
    required this.status,
    required this.idRoute,
    required this.originCity,
    required this.destinationCity,
    required this.distanceKm,
    required this.estimatedTime,
    required this.idTravelCategory,
    required this.name,
    required this.description,
  });

  factory TripCost.fromJson(Map<String, dynamic> json) {
    return TripCost(
      idRouteCategoryCost: json['id_route_category_cost'] as int,
      baseFare: json['base_fare'] as num,
      extraPerPassenger: json['extra_per_passenger'] as num,
      extraPerLuggage: json['extra_per_luggage'] as num,
      currency: (json['currency'] ?? '') as String,
      effectiveFrom: DateTime.parse(json['effective_from'] as String),
      effectiveTo: json['effective_to'] != null
          ? DateTime.parse(json['effective_to'] as String)
          : null,
      status: (json['status'] ?? '').toString(),
      idRoute: json['id_route'] as int,
      originCity: (json['origin_city'] ?? '') as String,
      destinationCity: (json['destination_city'] ?? '') as String,
      distanceKm: json['distance_km'] as num,
      estimatedTime: _hmsToDuration(json['estimated_time'] as String),
      idTravelCategory: json['id_travel_category'] as int,
      name: (json['name'] ?? '') as String,
      description: (json['description'] ?? '') as String,
    );
  }

  static Duration _hmsToDuration(String hms) {
    final p = hms.split(':').map(int.parse).toList();
    final h = p.isNotEmpty ? p[0] : 0;
    final m = p.length > 1 ? p[1] : 0;
    final s = p.length > 2 ? p[2] : 0;
    return Duration(hours: h, minutes: m, seconds: s);
  }
}
