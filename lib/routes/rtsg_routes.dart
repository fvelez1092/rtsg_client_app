import 'package:app_rtsg_client/presentation/pages/auth/forgot_password/forgot_password_binding.dart';
import 'package:app_rtsg_client/presentation/pages/auth/forgot_password/forgot_password_page.dart';
import 'package:app_rtsg_client/presentation/pages/auth/login/login_binding.dart';
import 'package:app_rtsg_client/presentation/pages/auth/login/login_page.dart';
import 'package:app_rtsg_client/presentation/pages/auth/register/register_binding.dart';
import 'package:app_rtsg_client/presentation/pages/auth/register/register_page.dart';
import 'package:app_rtsg_client/presentation/pages/home/home_binding.dart';
import 'package:app_rtsg_client/presentation/pages/profile/profile_binding.dart';
import 'package:app_rtsg_client/presentation/pages/profile/profile_page.dart';
import 'package:app_rtsg_client/presentation/pages/splash/splash_binding.dart';
import 'package:app_rtsg_client/presentation/pages/splash/splash_page.dart';
import 'package:get/get.dart';

import 'package:app_rtsg_client/presentation/pages/home/home_page.dart';

abstract class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => SplashPage(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.REGISTER,
      page: () => RegisterPage(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: AppRoutes.FORGOT_PASSWORD,
      page: () => ForgotPasswordPage(),
      binding: ForgotPasswordBinding(),
    ),
    // GetPage(
    //   name: AppRoutes.DASHBOARD,
    //   page: () => DashboardPage(),
    //   binding: DashboardBinding(),
    // ),
    // GetPage(
    //   name: AppRoutes.NEW_TRIP,
    //   page: () => TripScreen(),
    //   binding: TripBinding(initial: const LatLng(-0.18065, -78.46783)),
    // ),
    // GetPage(
    //   name: AppRoutes.TRIPS,
    //   page: () => const TripsScreen(),
    //   binding: TripBinding(initial: const LatLng(-0.18065, -78.46783)),
    // ),
    GetPage(
      name: AppRoutes.PROFILE,
      page: () => ProfilePage(),
      binding: ProfileBinding(),
    ),
    // GetPage(
    //   name: AppRoutes.EDIT_PROFILE,
    //   page: () => const EditProfileScreen(),
    // ),
    // GetPage(
    //   name: AppRoutes.PROFILE_ADD_ADDRESS,
    //   page: () => const AddressScreen(),
    //   binding: AddressBinding(),
    // ),
    GetPage(
      name: AppRoutes.HOME,
      page: () => HomePage(),
      binding: HomeBinding(),
    ),
  ];
}

abstract class AppRoutes {
  static const LOGIN = '/login';
  static const HOME = '/home';
  static const SPLASH = '/splash';
  static const REGISTER = '/register';
  static const FORGOT_PASSWORD = '/forgot_password';
  static const TRIPS = '/trips';
  static const NEW_TRIP = '/new_trip';
  static const PROFILE = '/profile';
}
