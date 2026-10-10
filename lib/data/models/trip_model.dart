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
    this.assignment,
  });

  TripModel copyWith({
    TripStatus? status,
    Map<String, dynamic>? assignment,
  }) {
    return TripModel(
      id: id,
      origin: origin,
      originName: originName,
      destination: destination,
      destinationName: destinationName,
      distanceKm: distanceKm,
      durationMin: durationMin,
      fare: fare,
      status: status ?? this.status,
      assignment: assignment ?? this.assignment,
    );
  }
}
