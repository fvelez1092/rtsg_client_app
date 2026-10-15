import 'package:app_rtsg_client/application/dashboard_controller.dart';
import 'package:app_rtsg_client/application/home_controller.dart';
import 'package:app_rtsg_client/application/home_content_controller.dart';
import 'package:app_rtsg_client/application/trips_controller.dart';
import 'package:app_rtsg_client/data/services/partners_service.dart';
import 'package:app_rtsg_client/data/services/publicidad_service.dart';
import 'package:app_rtsg_client/data/services/local_storage_service.dart';
import 'package:app_rtsg_client/global_memory.dart';
import 'package:app_rtsg_client/presentation/dashboard/dashboard_page.dart';
import 'package:app_rtsg_client/routes/rtsg_routes.dart';
import 'dashboard_navigation_test.dart' show QuietTrips, FakeStorage;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:app_rtsg_client/application/trip_controller.dart';
import 'package:app_rtsg_client/data/services/gps_service.dart';
import 'package:app_rtsg_client/data/services/trip_service.dart';
import 'package:app_rtsg_client/data/services/trip_socket_service.dart';
import 'package:app_rtsg_client/presentation/pages/trip/trip_page.dart';
import 'package:app_rtsg_client/presentation/widgets/map_widget.dart';
import 'active_trip_return_test.dart' show FakeTrips;
import 'trip_contract_test.dart' show ContractSocket;

void main() {
  tearDown(() => Get.reset());
  testWidgets(
    'Mounted tracking map transitions to completed trip without inherited widget errors',
    (tester) async {
      Get.testMode = true;
      Get.put(GpsService());
      Get.put<TripService>(FakeTrips());
      final socket = ContractSocket();
      Get.put<TripSocketService>(socket);
      final controller = Get.put(TripController());
      controller.recoverAssignedTrip(42);
      socket.states.add({
        'carrera_id': 42,
        'estado_codigo': 'I',
        'coordenadaspartida': {'lat': -0.2, 'lng': -78.5},
        'distancia': 4.5,
        'costo': 6.25,
      });
      await tester.pumpWidget(const GetMaterialApp(home: TripPage()));
      await tester.pumpAndSettle();
      expect(find.byType(MapPicker), findsOneWidget);
      expect(tester.takeException(), isNull);
      socket.states.add({
        'carrera_id': 42,
        'estado_codigo': 'F',
        'costo': 7.25,
      });
      await tester.pumpAndSettle();
      expect(find.byType(MapPicker), findsNothing);
      expect(find.text('Viaje finalizado'), findsOneWidget);
      expect(find.text(r'$7.25'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Finish while moving the map then return to the mounted dashboard',
    (tester) async {
      Get.testMode = true;
      void bindDashboard() {
        Get.put<LocalStorage>(FakeStorage());
        Get.put(GlobalMemory());
        Get.put(DashboardController());
        final trips = Get.put<TripsController>(QuietTrips());
        Get.put(
          HomeController(
            HomeContentController(
              partnersService: PartnersService(),
              publicidadService: PublicidadService(),
            ),
            trips,
          ),
        );
      }

      Get.put(GpsService());
      Get.put<TripService>(FakeTrips());
      final socket = ContractSocket();
      Get.put<TripSocketService>(socket);
      final controller = Get.put(TripController());
      controller.recoverAssignedTrip(42);
      socket.states.add({
        'carrera_id': 42,
        'estado_codigo': 'I',
        'distancia': 4.5,
        'costo': 6.25,
      });
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: AppRoutes.DASHBOARD,
          getPages: [
            GetPage(
              name: AppRoutes.DASHBOARD,
              page: () => const DashboardPage(),
              binding: BindingsBuilder(bindDashboard),
            ),
            GetPage(name: AppRoutes.TRIP, page: () => const TripPage()),
          ],
        ),
      );
      await tester.pumpAndSettle();
      Get.toNamed(AppRoutes.TRIP);
      await tester.pumpAndSettle();
      await tester.fling(find.byType(MapPicker), const Offset(80, 40), 1000);
      await tester.pump(const Duration(milliseconds: 16));
      socket.states.add({
        'carrera_id': 42,
        'estado_codigo': 'F',
        'costo': 7.25,
      });
      await tester.pumpAndSettle();
      expect(find.text('Viaje finalizado'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Volver al inicio'));
      await tester.pumpAndSettle();
      expect(find.byType(DashboardPage), findsOneWidget);
      expect(find.text('Volver al mapa'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
