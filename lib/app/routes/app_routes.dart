// ====================================================================
// FILE    : lib/app/routes/app_routes.dart
// LAPISAN : Navigasi / Nama route
//
// GUNANYA :
//   Daftar nama halaman. Dipakai dengan Get.toNamed(Routes.detail) dsb,
//   supaya tidak salah ketik string route di banyak tempat.
//
// DIPAKAI OLEH: app_pages.dart dan semua tempat yang berpindah halaman.
// ====================================================================

abstract class Routes {
  static const login = '/login';
  static const register = '/register';
  static const main = '/main';
  static const detail = '/detail';
}
