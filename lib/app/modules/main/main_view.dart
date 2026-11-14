import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/services/session_service.dart';
import '../../theme/app_theme.dart';
import '../auth/auth_controller.dart';
import '../episode/episode_view.dart';
import '../favorite/favorite_controller.dart';
import '../favorite/favorite_view.dart';
import '../home/home_view.dart';

class MainController extends GetxController {
  final tabIndex = 0.obs;
}

/// Halaman utama: Bottom Navigation Bar dengan 3 tab.
class MainView extends GetView<MainController> {
  const MainView({super.key});

  static const _titles = ['Rick & Morty', 'Favorites', 'Episodes'];

  void _confirmLogout() {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Batal')),
          TextButton(
            key: const Key('confirm_logout'),
            onPressed: () => Get.find<AuthController>().logout(),
            child: const Text('Logout', style: TextStyle(color: AppColors.dead)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = Get.find<SessionService>();
    final favorites = Get.find<FavoriteController>();

    return Obx(
      () => Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_titles[controller.tabIndex.value]),
              Text(
                'Halo, ${session.currentUser.value ?? '-'}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              key: const Key('logout_button'),
              tooltip: 'Logout',
              onPressed: _confirmLogout,
              icon: const Icon(Icons.logout),
            ),
            const SizedBox(width: 4),
          ],
        ),
        // IndexedStack menjaga posisi scroll tiap tab saat berpindah.
        body: IndexedStack(
          index: controller.tabIndex.value,
          children: const [HomeView(), FavoriteView(), EpisodeView()],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: controller.tabIndex.value,
          onDestinationSelected: (i) => controller.tabIndex.value = i,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people),
              label: 'Characters',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: favorites.favorites.isNotEmpty,
                label: Text('${favorites.favorites.length}'),
                child: const Icon(Icons.favorite_border),
              ),
              selectedIcon: const Icon(Icons.favorite),
              label: 'Favorites',
            ),
            const NavigationDestination(
              icon: Icon(Icons.live_tv_outlined),
              selectedIcon: Icon(Icons.live_tv),
              label: 'Episodes',
            ),
          ],
        ),
      ),
    );
  }
}
