import 'package:app_rtsg_client/presentation/dashboard/dashboard_binding.dart';
import 'package:app_rtsg_client/presentation/dashboard/dashboard_page.dart';
import 'package:app_rtsg_client/presentation/pages/auth/forgot_password/forgot_password_binding.dart';
import 'package:app_rtsg_client/presentation/pages/auth/forgot_password/forgot_password_page.dart';
import 'package:app_rtsg_client/presentation/pages/auth/login/login_binding.dart';
import 'package:app_rtsg_client/presentation/pages/auth/login/login_page.dart';
import 'package:app_rtsg_client/presentation/pages/auth/register/register_binding.dart';
import 'package:app_rtsg_client/presentation/pages/auth/register/register_page.dart';
import 'package:app_rtsg_client/presentation/pages/delivery/delivery_page.dart';
import 'package:app_rtsg_client/presentation/pages/partners/partner_detail_page.dart';
import 'package:app_rtsg_client/presentation/pages/partners/partners_page.dart';
import 'package:app_rtsg_client/presentation/pages/profile/profile_binding.dart';
import 'package:app_rtsg_client/presentation/pages/profile/profile_page.dart';
import 'package:app_rtsg_client/presentation/pages/reservation/reservation_page.dart';
import 'package:app_rtsg_client/presentation/pages/splash/splash_binding.dart';
import 'package:app_rtsg_client/presentation/pages/splash/splash_page.dart';
import 'package:app_rtsg_client/presentation/pages/trip/trip_binding.dart';
import 'package:app_rtsg_client/presentation/pages/trip/trip_page.dart';
import 'package:get/get.dart';

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
    GetPage(
      name: AppRoutes.PROFILE,
      page: () => ProfilePage(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.TRIP,
      page: () => TripPage(),
      binding: TripBinding(),
    ),
    GetPage(
      name: AppRoutes.RESERVATION,
      page: () => const ReservationPage(),
    ),
    GetPage(
      name: AppRoutes.DELIVERY,
      page: () => const DeliveryPage(),
    ),
    GetPage(
      name: AppRoutes.PARTNERS,
      page: () => const PartnersPage(),
    ),
    GetPage(
      name: AppRoutes.PARTNER_DETAIL,
      page: () => const PartnerDetailPage(),
    ),

    // Las cuatro rutas principales comparten el mismo shell de Dashboard.
    // DashboardController selecciona la tab correcta a partir de la ruta.
    GetPage(
      name: AppRoutes.HOME,
      page: () => const DashboardPage(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.ACTIVITY,
      page: () => const DashboardPage(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.WALLET,
      page: () => const DashboardPage(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.ACCOUNT,
      page: () => const DashboardPage(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.DASHBOARD,
      page: () => const DashboardPage(),
      binding: DashboardBinding(),
    ),
  ];
}

abstract class AppRoutes {
  static const LOGIN = '/login';
  static const HOME = '/home';
  static const TRIP = '/trip';
  static const RESERVATION = '/reservation';
  static const DELIVERY = '/delivery';
  static const PARTNERS = '/partners';
  static const PARTNER_DETAIL = '/partner-detail';
  static const ACTIVITY = '/activity';
  static const WALLET = '/wallet';
  static const ACCOUNT = '/account';
  static const SPLASH = '/splash';
  static const REGISTER = '/register';
  static const FORGOT_PASSWORD = '/forgot_password';
  static const TRIPS = '/trips';
  static const NEW_TRIP = '/new_trip';
  static const PROFILE = '/profile';
  static const DASHBOARD = '/dashboard';
}
