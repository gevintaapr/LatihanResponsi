import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/services/session_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass.dart';
import '../auth/auth_controller.dart';
import '../episode/episode_view.dart';
import '../favorite/favorite_controller.dart';
import '../favorite/favorite_view.dart';
import '../home/home_view.dart';

class MainController extends GetxController {
  final tabIndex = 0.obs;
}

/// Halaman utama: 3 tab dengan Bottom Navigation Bar kaca yang melayang.
class MainView extends GetView<MainController> {
  const MainView({super.key});

  static const _titles = ['Rick & Morty', 'Favorites', 'Episodes'];

  void _confirmLogout() {
    Get.dialog(
      GlassDialog(
        icon: Icons.logout_rounded,
        title: 'Logout',
        message: 'Yakin ingin keluar dari akun ini?',
        actions: [
          OutlinedButton(
            onPressed: Get.back,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              foregroundColor: AppColors.text,
              side: const BorderSide(color: AppColors.glassBorder, width: 1.5),
              backgroundColor: Colors.white.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm + 4),
              ),
              textStyle: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Text('Batal'),
          ),
          GradientButton(
            key: const Key('confirm_logout'),
            label: 'Logout',
            onPressed: () => Get.find<AuthController>().logout(),
          ),
        ],
      ),
      barrierColor: AppColors.text.withValues(alpha: 0.25),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = Get.find<SessionService>();

    return Obx(
      () => GlassScaffold(
        extendBody: true,
        appBar: AppBar(
          // Header dibuat lebih tinggi agar judul dan sapaan lebih lega.
          toolbarHeight: 92,
          titleSpacing: 20,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_titles[controller.tabIndex.value]),
              const SizedBox(height: 6),
              Text(
                'Halo, ${session.currentUser.value ?? '-'} 👋',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          actions: [
            GlassIconButton(
              key: const Key('logout_button'),
              icon: Icons.logout_rounded,
              tooltip: 'Logout',
              onPressed: _confirmLogout,
            ),
            const SizedBox(width: 16),
          ],
        ),
        // IndexedStack menjaga posisi scroll tiap tab saat berpindah.
        body: IndexedStack(
          index: controller.tabIndex.value,
          children: const [HomeView(), FavoriteView(), EpisodeView()],
        ),
        bottomNavigationBar: _FloatingNavBar(
          index: controller.tabIndex.value,
          onSelected: (i) => controller.tabIndex.value = i,
        ),
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({required this.index, required this.onSelected});

  final int index;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final favorites = Get.find<FavoriteController>();
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: GlassContainer(
            blur: true,
            radius: AppRadius.lg - 4,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.people_alt_rounded,
                  label: 'Characters',
                  selected: index == 0,
                  onTap: () => onSelected(0),
                ),
                Obx(
                  () => _NavItem(
                    icon: Icons.favorite_rounded,
                    label: 'Favorites',
                    selected: index == 1,
                    badge: favorites.favorites.length,
                    onTap: () => onSelected(1),
                  ),
                ),
                _NavItem(
                  icon: Icons.live_tv_rounded,
                  label: 'Episodes',
                  selected: index == 2,
                  onTap: () => onSelected(2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge = 0,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          hoverColor: AppColors.purple.withValues(alpha: 0.05),
          highlightColor: Colors.transparent,
          splashColor: AppColors.pink.withValues(alpha: 0.12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Badge(
                  isLabelVisible: badge > 0,
                  label: Text('$badge'),
                  backgroundColor: AppColors.pink,
                  offset: const Offset(6, -4),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 44,
                    height: 28,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: selected ? AppGradients.primary : null,
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: AppColors.pink.withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      icon,
                      size: 18,
                      color: selected ? Colors.white : AppColors.textMuted,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: selected ? AppColors.purple : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
