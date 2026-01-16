import 'package:app_rtsg_client/core/theme/light_theme.dart';
import 'package:app_rtsg_client/routes/rtsg_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

Future<void> initGlobalServices() async {
  //await Get.putAsync<GpsService>(() async => GpsService().init());
  await GetStorage.init();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initGlobalServices();
  runApp(ManporcarApp());
}

class ManporcarApp extends StatelessWidget {
  const ManporcarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Rtsg Client App',
      initialRoute: AppRoutes.HOME,
      getPages: AppPages.pages,
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
    );
  }
}
