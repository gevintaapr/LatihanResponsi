// ====================================================================
// FILE    : lib/app/widgets/character_widgets.dart
// LAPISAN : Tampilan / Widget karakter
//
// GUNANYA :
//   CharacterGridCard : kartu di grid Home
//   CharacterTile     : kartu horizontal di Favorite Screen
//   FavoriteButton    : tombol hati; ikonnya berubah sesuai status favorit
//                       karena dibungkus Obx (membaca FavoriteController).
//
// DIPAKAI OLEH: HomeView, FavoriteView.
// ====================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/character.dart';
import '../modules/favorite/favorite_controller.dart';
import '../routes/app_routes.dart';
import '../theme/app_theme.dart';
import 'glass.dart';

/// Foto karakter dengan placeholder saat memuat / gagal.
class CharacterImage extends StatelessWidget {
  const CharacterImage({
    super.key,
    required this.url,
    this.radius = AppRadius.sm,
    this.width,
    this.height,
    this.alignment = Alignment.center,
  });

  final String url;
  final double radius;
  final double? width;
  final double? height;

  /// Bagian foto yang dipertahankan saat dipotong (topCenter = wajah).
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    Widget placeholder(IconData icon) => Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF3E8FF), Color(0xFFFCE7F3)],
        ),
      ),
      child: Icon(icon, color: AppColors.purple.withValues(alpha: 0.5)),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        url,
        width: width,
        height: height,
        fit: BoxFit.cover,
        alignment: alignment,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : placeholder(Icons.image_outlined),
        errorBuilder: (_, _, _) => placeholder(Icons.person_off_outlined),
      ),
    );
  }
}

class StatusLabel extends StatelessWidget {
  const StatusLabel({super.key, required this.status, this.suffix});

  final String status;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.status(status);
    final label = status.capitalizeFirst ?? status;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            suffix == null ? label : '$label · $suffix',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

/// Tombol hati bulat berlatar kaca; ikonnya mengikuti status favorit.
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key, required this.character, this.size = 38});

  final Character character;
  final double size;

  @override
  Widget build(BuildContext context) {
    final favorites = Get.find<FavoriteController>();
    return Obx(() {
      final isFav = favorites.isFavorite(character.id);
      return Tooltip(
        message: isFav ? 'Hapus dari favorit' : 'Tambah ke favorit',
        child: Material(
          color: Colors.white.withValues(alpha: 0.85),
          shape: const CircleBorder(),
          elevation: 0,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => favorites.toggle(character),
            child: SizedBox(
              width: size,
              height: size,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Icon(
                  isFav
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  key: ValueKey(isFav),
                  size: size * 0.52,
                  color: isFav ? AppColors.favorite : AppColors.textMuted,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

/// Kartu karakter untuk grid 2 kolom di Home.
class CharacterGridCard extends StatelessWidget {
  const CharacterGridCard({super.key, required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      radius: AppRadius.md,
      padding: const EdgeInsets.all(6),
      onTap: () => Get.toNamed(Routes.detail, arguments: character),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: CharacterImage(
                    url: character.image,
                    radius: AppRadius.sm,
                    alignment: const Alignment(0, -0.4),
                  ),
                ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: FavoriteButton(character: character, size: 30),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  character.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                StatusLabel(
                  status: character.status,
                  suffix: character.species,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu karakter horizontal untuk Favorite Screen (cocok untuk swipe).
class CharacterTile extends StatelessWidget {
  const CharacterTile({super.key, required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      radius: AppRadius.md,
      padding: const EdgeInsets.all(8),
      onTap: () => Get.toNamed(Routes.detail, arguments: character),
      child: Row(
        children: [
          CharacterImage(url: character.image, width: 52, height: 52),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  character.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                StatusLabel(
                  status: character.status,
                  suffix: character.species,
                ),
              ],
            ),
          ),
          FavoriteButton(character: character, size: 34),
          const SizedBox(width: 2),
        ],
      ),
    );
  }
}
