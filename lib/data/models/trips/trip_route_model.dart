class LatLng {
  final double lat;
  final double lng;
  LatLng({required this.lat, required this.lng});

  factory LatLng.fromJson(Map<String, dynamic> json) {
    return LatLng(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }
}

class TripRoute {
  final int idRoute;
  final String originCity;
  final String destinationCity;
  final num distanceKm;
  final Duration estimatedTime;
  final num baseFare;
  final bool status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int? userId;
  final int? companyId;
  final LatLng? originCityCoords;
  final LatLng? destinationCityCoords;

  TripRoute({
    required this.idRoute,
    required this.originCity,
    required this.destinationCity,
    required this.distanceKm,
    required this.estimatedTime,
    required this.baseFare,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    required this.companyId,
    required this.originCityCoords,
    required this.destinationCityCoords,
  });

  factory TripRoute.fromJson(Map<String, dynamic> json) {
    return TripRoute(
      idRoute: json['id_route'] as int,
      originCity: (json['origin_city'] ?? '') as String,
      destinationCity: (json['destination_city'] ?? '') as String,
      distanceKm: json['distance_km'] as num,
      estimatedTime: _hmsToDuration(json['estimated_time'] as String),
      baseFare: json['base_fare'] as num,
      status: (json['status'] is bool)
          ? json['status'] as bool
          : json['status'].toString() == 'true',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      userId: json['user_id'] as int?,
      companyId: json['company_id'] as int?,
      originCityCoords: json['origin_city_coords'] != null
          ? LatLng.fromJson(json['origin_city_coords'] as Map<String, dynamic>)
          : null,
      destinationCityCoords: json['destination_city_coords'] != null
          ? LatLng.fromJson(
              json['destination_city_coords'] as Map<String, dynamic>,
            )
          : null,
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
