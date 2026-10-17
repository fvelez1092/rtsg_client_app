import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:app_rtsg_client/application/profile_controller.dart';
import 'package:app_rtsg_client/data/models/user_model.dart';
import 'package:app_rtsg_client/data/services/local_storage_service.dart';
import 'package:app_rtsg_client/global_memory.dart';
import 'package:app_rtsg_client/presentation/pages/profile/profile_page.dart';
import 'profile_photo_test.dart'
    show PhotoStorage, PhotoAddresses, PhotoPicker, PhotoUsers;

void main() {
  tearDown(() => Get.reset());
  testWidgets(
    'Personal information fits a small screen and offers camera and gallery',
    (tester) async {
      Get.testMode = true;
      tester.view.physicalSize = const Size(320, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      Get.put<LocalStorage>(PhotoStorage());
      final memory = Get.put(GlobalMemory());
      memory.userRx.value = const User(
        idUser: 1,
        customerCode: 1234,
        email: 'cliente@example.test',
      );
      final picker = PhotoPicker();
      Get.put(
        ProfileController(
          PhotoAddresses(),
          userService: PhotoUsers(),
          picker: picker,
        ),
      );
      await tester.pumpWidget(const GetMaterialApp(home: ProfilePage()));
      await tester.pumpAndSettle();
      expect(find.text('1234'), findsOneWidget);
      expect(find.text('Información del Vehículo'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Cambiar foto de perfil'));
      await tester.pumpAndSettle();
      expect(find.text('Tomar foto'), findsOneWidget);
      expect(find.text('Elegir de galería'), findsOneWidget);
      await tester.tap(find.text('Elegir de galería'));
      await tester.pumpAndSettle();
      expect(picker.calls, 1);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );
}
