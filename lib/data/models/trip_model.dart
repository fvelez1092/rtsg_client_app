import 'package:latlong2/latlong.dart';
import 'trip_status.dart';

class TripModel {
  final String id;
  final LatLng origin;
  final String originName;
  final LatLng destination;
  final String destinationName;

  final double distanceKm;
  final int durationMin;
  final double fare;
  final bool hasDistance;
  final bool hasFare;

  final TripStatus status;

  /// Datos vigentes de la asignación enviados por el backend.
  final Map<String, dynamic>? assignment;

  const TripModel({
    required this.id,
    required this.origin,
    required this.originName,
    required this.destination,
    required this.destinationName,
    required this.distanceKm,
    required this.durationMin,
    required this.fare,
    required this.status,
    this.hasDistance = true,
    this.hasFare = true,
    this.assignment,
  });

  TripModel copyWith({
    TripStatus? status,
    LatLng? origin,
    String? originName,
    LatLng? destination,
    String? destinationName,
    double? distanceKm,
    int? durationMin,
    double? fare,
    bool? hasDistance,
    bool? hasFare,
    Map<String, dynamic>? assignment,
  }) {
    return TripModel(
      id: id,
      origin: origin ?? this.origin,
      originName: originName ?? this.originName,
      destination: destination ?? this.destination,
      destinationName: destinationName ?? this.destinationName,
      distanceKm: distanceKm ?? this.distanceKm,
      durationMin: durationMin ?? this.durationMin,
      fare: fare ?? this.fare,
      hasDistance: hasDistance ?? this.hasDistance,
      hasFare: hasFare ?? this.hasFare,
      status: status ?? this.status,
      assignment: assignment ?? this.assignment,
    );
  }
}
