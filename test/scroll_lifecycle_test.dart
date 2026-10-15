import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:app_rtsg_client/application/dashboard_controller.dart';
import 'package:app_rtsg_client/application/home_controller.dart';
import 'package:app_rtsg_client/application/home_content_controller.dart';
import 'package:app_rtsg_client/application/trips_controller.dart';
import 'package:app_rtsg_client/data/models/partnert_model.dart';
import 'package:app_rtsg_client/data/services/partners_service.dart';
import 'package:app_rtsg_client/data/services/publicidad_service.dart';
import 'package:app_rtsg_client/presentation/pages/home/home_page.dart';
import 'active_trip_return_test.dart' show FakeTrips;

void main() {
  tearDown(() => Get.reset());
  testWidgets(
    'Home carousel remains usable while GetX controller is closed during transition',
    (tester) async {
      Get.testMode = true;
      final content = HomeContentController(
        partnersService: PartnersService(),
        publicidadService: PublicidadService(),
      );
      content.publicidades.assignAll(const [
        PartnerAdModel(
          id: 1,
          title: 'Primero',
          description: '',
          imageUrl: '',
          partnerName: '',
        ),
        PartnerAdModel(
          id: 2,
          title: 'Segundo',
          description: '',
          imageUrl: '',
          partnerName: '',
        ),
      ]);
      Get.put(HomeController(content, TripsController(FakeTrips())));
      await tester.pumpWidget(const GetMaterialApp(home: HomePage()));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(PageView));
      await tester.pumpAndSettle();
      await Get.delete<HomeController>();
      // El widget anterior permanece visible durante la transición de ruta.
      await tester.fling(find.byType(PageView), const Offset(-350, 0), 1000);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Dashboard scroll notifications are harmless after controller closes',
    (tester) async {
      Get.testMode = true;
      final controller = Get.put(DashboardController());
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationListener<ScrollNotification>(
              onNotification: controller.handleTabScroll,
              child: ListView(
                children: List.generate(
                  60,
                  (i) => SizedBox(height: 60, child: Text('$i')),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.fling(find.byType(ListView), const Offset(0, -400), 1200);
      await tester.pumpAndSettle();
      expect(controller.isNavigationVisible.value, isFalse);
      await Get.delete<DashboardController>();
      await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(controller.isNavigationVisible.value, isFalse);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
