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
  });

  TripModel copyWith({TripStatus? status}) {
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
    );
  }
}
