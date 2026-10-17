import 'package:app_rtsg_client/data/services/gps_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
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
import 'active_trip_return_test.dart' show FakeTrips;

class QuietTrips extends TripsController {
  QuietTrips() : super(FakeTrips());
  @override
  Future<void> fetchTrips() async {}
}

class FakeStorage implements LocalStorage {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  tearDown(() => Get.reset());
  testWidgets('Rapid navigation collapse and expansion do not duplicate keys', (
    tester,
  ) async {
    Get.testMode = true;
    late DashboardController controller;
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.DASHBOARD,
        getPages: [
          GetPage(
            name: AppRoutes.DASHBOARD,
            binding: BindingsBuilder(() {
              Get.put(GpsService());
              Get.put<LocalStorage>(FakeStorage());
              Get.put(GlobalMemory());
              controller = Get.put(DashboardController());
              final trips = Get.put<TripsController>(QuietTrips());
              final content = HomeContentController(
                partnersService: PartnersService(),
                publicidadService: PublicidadService(),
              );
              Get.put(HomeController(content, trips));
            }),
            page: () => const DashboardPage(),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    for (var i = 0; i < 20; i++) {
      controller.hideNavigation();
      await tester.pump(const Duration(milliseconds: 20));
      expect(tester.takeException(), isNull);
      controller.showNavigation();
      await tester.pump(const Duration(milliseconds: 20));
      expect(tester.takeException(), isNull);
    }
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
    controller.hideNavigation();
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Mostrar navegación'));
    await tester.pumpAndSettle();
    expect(controller.isNavigationVisible.value, isTrue);
    expect(find.byType(NavigationBar), findsOneWidget);
    await tester.tap(find.text('Actividad'));
    await tester.pumpAndSettle();
    expect(controller.selectedIndex.value, 1);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
