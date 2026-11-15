// ====================================================================
// FILE    : lib/main.dart
// LAPISAN : Titik awal aplikasi
//
// GUNANYA :
//   Fungsi main() adalah yang pertama kali dijalankan Flutter.
//   Urutannya: siapkan Hive -> daftarkan service global ke GetX -> jalankan app.
//   MainApp memakai GetMaterialApp (bukan MaterialApp) agar fitur GetX aktif:
//   routing Get.toNamed, dependency injection Get.find, dan snackbar/dialog.
//
// DIPAKAI OLEH: Dijalankan oleh Flutter. initDependencies() juga dipakai oleh file tes.
// ====================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/data/providers/api_provider.dart';
import 'app/data/providers/db_helper.dart';
import 'app/data/services/session_service.dart';
import 'app/modules/favorite/favorite_controller.dart';
import 'app/routes/app_pages.dart';
import 'app/theme/app_theme.dart';
import 'app/utils/snack.dart';

Future<void> main() async {
  // Wajib dipanggil sebelum memakai plugin (Hive, Shared Preferences) di main().
  WidgetsFlutterBinding.ensureInitialized();
  // Siapkan Hive (file di Android/iOS, IndexedDB di Chrome).
  await Hive.initFlutter();
  await initDependencies();
  runApp(const MainApp());
}

/// Mendaftarkan dependency global (hidup selama aplikasi berjalan).
Future<void> initDependencies({ApiProvider? api}) async {
  // Sesi harus selesai dibaca dulu, karena menentukan halaman pertama.
  await Get.putAsync(() => SessionService().init(), permanent: true);
  await Get.putAsync(() => DbHelper().init(), permanent: true); // buka box Hive
  // Parameter api hanya diisi oleh tes (API tiruan). Di aplikasi asli: ApiProvider().
  Get.put(api ?? ApiProvider(), permanent: true);
  // Favorit dibuat global agar semua halaman berbagi data yang sama.
  Get.put(FavoriteController(), permanent: true);
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Rick & Morty Explorer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // Agar Snackbar bisa dipanggil dari controller (lihat utils/snack.dart).
      scaffoldMessengerKey: scaffoldMessengerKey,
      // Halaman pertama: /main jika sudah login, /login jika belum.
      initialRoute: AppPages.initial,
      getPages: AppPages.pages,
      defaultTransition: Transition.cupertino,
    );
  }
}
