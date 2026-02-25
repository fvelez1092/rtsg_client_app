import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:app_rtsg_client/core/theme/light_theme.dart';
import 'package:app_rtsg_client/data/services/gps_service.dart';
import 'package:app_rtsg_client/data/services/local_storage_service.dart';
import 'package:app_rtsg_client/global_memory.dart';
import 'package:app_rtsg_client/presentation/pages/splash/splash_binding.dart';
import 'package:app_rtsg_client/routes/rtsg_routes.dart';

Future<void> initGlobalServices() async {
  await GetStorage.init();

  // Storage wrapper
  Get.lazyPut<LocalStorage>(() => LocalStorage(), fenix: true);

  // Global memory (depends on LocalStorage)
  Get.put<GlobalMemory>(GlobalMemory(), permanent: true);

  // GPS service
  await Get.putAsync<GpsService>(
    () async => GpsService().init(),
    permanent: true,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initGlobalServices();
  runApp(const RtsgClientApp());
}

class RtsgClientApp extends StatelessWidget {
  const RtsgClientApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'RTSG Client App',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,

      // ✅ Arranque por Splash
      initialRoute: AppRoutes.HOME,
      //initialBinding: SplashBinding(),

      // ✅ Tus páginas
      getPages: AppPages.pages,
    );
  }
}
