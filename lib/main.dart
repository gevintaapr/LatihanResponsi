import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/data/providers/api_provider.dart';
import 'app/data/providers/db_helper.dart';
import 'app/data/services/session_service.dart';
import 'app/modules/favorite/favorite_controller.dart';
import 'app/routes/app_pages.dart';
import 'app/theme/app_theme.dart';
import 'app/utils/snack.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const MainApp());
}

/// Mendaftarkan dependency global (hidup selama aplikasi berjalan).
Future<void> initDependencies({ApiProvider? api}) async {
  // Sesi harus selesai dibaca dulu, karena menentukan halaman pertama.
  await Get.putAsync(() => SessionService().init(), permanent: true);
  Get.put(DbHelper(), permanent: true);
  Get.put(api ?? ApiProvider(), permanent: true);
  Get.put(FavoriteController(), permanent: true);
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Rick & Morty Explorer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      scaffoldMessengerKey: scaffoldMessengerKey,
      initialRoute: AppPages.initial,
      getPages: AppPages.pages,
      defaultTransition: Transition.cupertino,
    );
  }
}
