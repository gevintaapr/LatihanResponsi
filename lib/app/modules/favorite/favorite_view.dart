import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme/app_theme.dart';
import '../../widgets/character_widgets.dart';
import '../../widgets/state_views.dart';
import 'favorite_controller.dart';

class FavoriteView extends GetView<FavoriteController> {
  const FavoriteView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.favorites.isEmpty) {
        return const MessageView(
          icon: Icons.favorite_border,
          title: 'Belum ada karakter favorit',
          message:
              'Tekan ikon hati pada karakter untuk menambahkannya ke daftar ini.',
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        itemCount: controller.favorites.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (_, index) {
          if (index == 0) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Row(
                children: [
                  Icon(Icons.swipe_left_outlined,
                      size: 16, color: AppColors.textMuted),
                  SizedBox(width: 8),
                  Text(
                    'Geser kartu ke kiri untuk menghapus',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                ],
              ),
            );
          }
          final character = controller.favorites[index - 1];
          return Dismissible(
            key: ValueKey('favorite_${character.id}'),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => controller.removeBySwipe(character),
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              decoration: BoxDecoration(
                color: AppColors.dead,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Hapus',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.delete_outline, color: Colors.white),
                ],
              ),
            ),
            child: CharacterTile(character: character),
          );
        },
      );
    });
  }
}
