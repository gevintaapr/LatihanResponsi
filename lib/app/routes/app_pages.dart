import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/services/session_service.dart';
import '../modules/auth/auth_controller.dart';
import '../modules/auth/login_view.dart';
import '../modules/auth/register_view.dart';
import '../modules/detail/detail_controller.dart';
import '../modules/detail/detail_view.dart';
import '../modules/episode/episode_controller.dart';
import '../modules/home/home_controller.dart';
import '../modules/main/main_view.dart';
import 'app_routes.dart';

/// Halaman utama hanya bisa dibuka setelah login.
class AuthGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) =>
      Get.find<SessionService>().isLoggedIn
      ? null
      : const RouteSettings(name: Routes.login);
}

/// Pengguna yang sudah login tidak perlu melihat halaman login lagi.
class GuestGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) =>
      Get.find<SessionService>().isLoggedIn
      ? const RouteSettings(name: Routes.main)
      : null;
}

class AppPages {
  static String get initial =>
      Get.find<SessionService>().isLoggedIn ? Routes.main : Routes.login;

  static final pages = <GetPage>[
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      middlewares: [GuestGuard()],
      binding: BindingsBuilder(() => Get.lazyPut(() => AuthController())),
    ),
    GetPage(
      name: Routes.register,
      page: () => const RegisterView(),
      middlewares: [GuestGuard()],
      binding: BindingsBuilder(() => Get.lazyPut(() => AuthController())),
    ),
    GetPage(
      name: Routes.main,
      page: () => const MainView(),
      middlewares: [AuthGuard()],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => MainController());
        Get.lazyPut(() => AuthController());
        Get.lazyPut(() => HomeController());
        Get.lazyPut(() => EpisodeController());
      }),
    ),
    GetPage(
      name: Routes.detail,
      page: () => const DetailView(),
      middlewares: [AuthGuard()],
      binding: BindingsBuilder(() => Get.lazyPut(() => DetailController())),
    ),
  ];
}
