import 'package:app_rtsg_client/data/models/trips/trip_model.dart';
import 'package:app_rtsg_client/data/services/trip_service.dart';
import 'package:get/get.dart';

class TripsController extends GetxController {
  TripsController(this._tripService);

  final TripService _tripService;

  final RxList<Trip> trips = <Trip>[].obs;
  final RxBool loading = false.obs;
  final RxString error = ''.obs;
  final showActive = true.obs; // por si filtras activos/histórico

  @override
  void onInit() {
    super.onInit();
    fetchTrips();
  }

  Future<void> fetchTrips() async {
    loading.value = true;
    error.value = '';
    try {
      final result = await _tripService.getUserTrips();
      trips.assignAll(result);
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }
}
