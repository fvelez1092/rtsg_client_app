import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:app_rtsg_client/application/dashboard_controller.dart';
import 'package:app_rtsg_client/application/trip_controller.dart';
import 'package:app_rtsg_client/application/trips_controller.dart';
import 'package:app_rtsg_client/data/models/trips/trip_model.dart' as history;
import 'package:app_rtsg_client/data/services/gps_service.dart';
import 'package:app_rtsg_client/data/services/trip_service.dart';
import 'package:app_rtsg_client/data/services/trip_socket_service.dart';
import 'package:app_rtsg_client/presentation/pages/activity/activity_page.dart';
import 'package:app_rtsg_client/presentation/widgets/trip_metrics.dart';
import 'package:app_rtsg_client/routes/rtsg_routes.dart';
import 'active_trip_return_test.dart' show FakeTrips;
import 'trip_contract_test.dart' show ContractSocket;

class HistoryService extends FakeTrips {
  int calls = 0;
  @override
  Future<List<history.Trip>> getUserTrips() async {
    calls++;
    return [
      history.Trip.fromJson({
        'id': 42,
        'distancia': '5,25',
        'costo': '8.50',
        'estado_codigo': 'F',
        'fecha': '2026-10-15',
        'direccionpartida': 'Origen',
        'direcciondestino': 'Destino',
      }),
    ];
  }
}

void main() {
  setUpAll(() => initializeDateFormatting('es'));
  tearDown(() => Get.reset());

  test(
    'Recovered metrics survive partial updates and reopening tracking',
    () async {
      Get.testMode = true;
      Get.put(GpsService());
      Get.put<TripService>(FakeTrips());
      final socket = ContractSocket();
      Get.put<TripSocketService>(socket);
      final controller = Get.put(TripController());
      controller.recoverAssignedTrip(42);
      expect(controller.activeTrip.value!.hasFare, isFalse);
      socket.assignmentEvents.add({
        'carrera_id': 42,
        'estado_codigo': 'E',
        'distancia': '5,25',
        'costo': '8.50',
        'duracion_min': 11,
      });
      socket.states.add({'carrera_id': 42, 'estado_codigo': 'L'});
      expect(controller.activeTrip.value!.distanceKm, 5.25);
      expect(controller.activeTrip.value!.fare, 8.50);
      await Get.delete<TripController>();
      await Get.delete<TripSocketService>();
      Get.put<TripSocketService>(ContractSocket());
      final restored = Get.put(TripController());
      expect(restored.activeTrip.value!.hasDistance, isTrue);
      expect(restored.activeTrip.value!.hasFare, isTrue);
      expect(restored.activeTrip.value!.distanceKm, 5.25);
      expect(restored.activeTrip.value!.fare, 8.50);
      expect(restored.distanceKm.value, 5.25);
      expect(restored.durationMin.value, 11);
    },
  );

  testWidgets(
    'Missing metrics are pending and confirmed zero is shown as zero',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: TripMetrics())),
      );
      expect(find.text('Por confirmar'), findsNWidgets(2));
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: TripMetrics(distanceKm: 0, fare: 0)),
        ),
      );
      expect(find.text('0.00 km'), findsOneWidget);
      expect(find.text(r'$0.00'), findsOneWidget);
      final trip = history.Trip.fromJson({'id': 42});
      expect(trip.hasFare, isFalse);
      expect(trip.hasDistance, isFalse);
    },
  );

  testWidgets(
    'Activity displays labelled metrics and refreshes when selected',
    (tester) async {
      Get.testMode = true;
      final service = HistoryService();
      final trips = Get.put(TripsController(service));
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: AppRoutes.ACTIVITY,
          getPages: [
            GetPage(
              name: AppRoutes.ACTIVITY,
              page: () => const Scaffold(body: ActivityPage()),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('5.25 km'), findsOneWidget);
      expect(find.text(r'$8.50'), findsWidgets);
      expect(find.text('Costo'), findsOneWidget);
      final controller = Get.put(DashboardController());
      controller.changePage(1);
      await tester.pumpAndSettle();
      expect(service.calls, 2);
      expect(trips.trips.single.cost, 8.50);
      expect(tester.takeException(), isNull);
    },
  );
}
