// ====================================================================
// FILE    : lib/app/modules/favorite/favorite_view.dart
// LAPISAN : Tampilan / Favorite Screen
//
// GUNANYA :
//   Daftar karakter favorit. Dismissible = hapus dengan swipe (soal 4b),
//   Snackbar setelah dihapus (4c), pesan jika daftar kosong (4d).
//
// DIPAKAI OLEH: Tab kedua di MainView.
// ====================================================================

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
          icon: Icons.favorite_rounded,
          title: 'Belum ada karakter favorit',
          message: 'Tekan ikon hati pada karakter untuk menambahkannya ke daftar ini.',
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
        itemCount: controller.favorites.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (_, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.swipe_left_rounded,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${controller.favorites.length} karakter · geser ke kiri untuk menghapus',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          final character = controller.favorites[index - 1];
          // Dismissible membuat kartu bisa digeser (swipe) untuk dihapus.
          return Dismissible(
            key: ValueKey('favorite_${character.id}'),
            direction: DismissDirection.endToStart,
            // Dipanggil setelah kartu selesai digeser: hapus + tampilkan Snackbar.
            onDismissed: (_) => controller.removeBySwipe(character),
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0x00F0506E), AppColors.dead],
                ),
                borderRadius: BorderRadius.circular(AppRadius.md),
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
                  Icon(Icons.delete_rounded, color: Colors.white),
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
