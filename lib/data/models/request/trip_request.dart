import 'package:intl/intl.dart';

class TripRequest {
  final int passengerId;
  final int travelCategoryId;
  final int routeId;
  final int routeCategoryCostId;
  final DateTime requestedDate;
  final String departureAddress;
  final String destinationAddress;
  final int passengerCount;
  final int luggageCount;
  final num cost;
  final String? notes;

  TripRequest({
    required this.passengerId,
    required this.travelCategoryId,
    required this.routeId,
    required this.routeCategoryCostId,
    required this.requestedDate,
    required this.departureAddress,
    required this.destinationAddress,
    required this.passengerCount,
    required this.luggageCount,
    required this.cost,
    this.notes,
  });

  /// Formato requerido: "2025-09-28 18:30:32.141 -0500"
  static String formatRequestedDate(DateTime dt) {
    // Asegúrate que dt tenga zona horaria correcta (local con offset)
    final local = dt.toLocal();
    final df = DateFormat("yyyy-MM-dd HH:mm:ss.SSS Z"); // Z -> -0500
    return df.format(local);
  }

  Map<String, dynamic> toJson() {
    return {
      "data": {
        "passenger_id": passengerId,
        "travel_category_id": travelCategoryId,
        "route_id": routeId,
        "route_category_cost_id": routeCategoryCostId,
        "requested_date": formatRequestedDate(requestedDate),
        "departure_address": departureAddress,
        "destination_address": destinationAddress,
        "passenger_count": passengerCount,
        "luggage_count": luggageCount,
        "cost": cost,
        "notes": notes ?? "",
      },
    };
  }
}
