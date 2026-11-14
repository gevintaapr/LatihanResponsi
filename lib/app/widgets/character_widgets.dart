import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/character.dart';
import '../modules/favorite/favorite_controller.dart';
import '../routes/app_routes.dart';
import '../theme/app_theme.dart';

class CharacterAvatar extends StatelessWidget {
  const CharacterAvatar({super.key, required this.url, this.size = 64});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    Widget placeholder(IconData icon) => Container(
          width: size,
          height: size,
          color: AppColors.surfaceHigh,
          child: Icon(icon, color: AppColors.textMuted, size: size * 0.45),
        );

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
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
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            suffix == null ? label : '$label · $suffix',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

/// Tombol hati yang ikonnya otomatis mengikuti status favorit.
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key, required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    final favorites = Get.find<FavoriteController>();
    return Obx(() {
      final isFav = favorites.isFavorite(character.id);
      return IconButton(
        tooltip: isFav ? 'Hapus dari favorit' : 'Tambah ke favorit',
        onPressed: () => favorites.toggle(character),
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, anim) =>
              ScaleTransition(scale: anim, child: child),
          child: Icon(
            isFav ? Icons.favorite : Icons.favorite_border,
            key: ValueKey(isFav),
            color: isFav ? AppColors.favorite : AppColors.textMuted,
          ),
        ),
      );
    });
  }
}

/// Kartu karakter yang dipakai di Home dan Favorite Screen.
class CharacterTile extends StatelessWidget {
  const CharacterTile({super.key, required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Get.toNamed(Routes.detail, arguments: character),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              CharacterAvatar(url: character.image),
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
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    StatusLabel(
                      status: character.status,
                      suffix: character.species,
                    ),
                  ],
                ),
              ),
              FavoriteButton(character: character),
            ],
          ),
        ),
      ),
    );
  }
}
