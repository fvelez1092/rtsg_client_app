import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:app_rtsg_client/data/models/trip_model.dart';

/// Mantiene el viaje entre pantallas durante la sesión del cliente.
class ActiveTripSession extends GetxService {
  static ActiveTripSession get instance => Get.isRegistered<ActiveTripSession>()
      ? Get.find<ActiveTripSession>()
      : Get.put(ActiveTripSession(), permanent: true);

  final Rx<TripModel?> trip = Rx<TripModel?>(null);
  LatLng? driverPosition;

  void clear() {
    driverPosition = null;
    trip.value = null;
  }
}
