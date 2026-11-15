import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/character.dart';
import '../../modules/favorite/favorite_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/character_widgets.dart';
import '../../widgets/glass.dart';
import '../../widgets/state_views.dart';
import 'detail_controller.dart';

class DetailView extends GetView<DetailController> {
  const DetailView({super.key});

  PreferredSizeWidget _appBar() => AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          children: [
            GlassIconButton(
              icon: Icons.arrow_back_rounded,
              tooltip: 'Kembali',
              onPressed: Get.back,
            ),
            const SizedBox(width: 14),
            const Text('Detail Karakter', style: TextStyle(fontSize: 20)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final character = controller.character.value;
      final error = controller.errorMessage.value;

      // Belum ada data sama sekali: tampilkan loading / error satu layar penuh.
      if (character == null) {
        return GlassScaffold(
          appBar: _appBar(),
          body: error != null
              ? MessageView(
                  icon: Icons.wifi_off_rounded,
                  title: 'Gagal memuat detail',
                  message: error,
                  onRetry: controller.fetch,
                )
              : const LoadingView(label: 'Memuat detail...'),
        );
      }

      return GlassScaffold(
        appBar: _appBar(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: _FavoriteAction(character: character),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Photo(character: character),
                    if (controller.isLoading.value)
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: LinearProgressIndicator(
                          minHeight: 3,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                      ),
                    const SizedBox(height: 20),
                    Text(
                      character.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _StatusPill(status: character.status),
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 16),
                      _ErrorBanner(message: error, onRetry: controller.fetch),
                    ],
                    const SizedBox(height: 20),
                    GlassContainer(
                      blur: true,
                      radius: AppRadius.lg,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        children: [
                          _InfoRow(
                            icon: Icons.monitor_heart_rounded,
                            label: 'Status',
                            value: character.status.capitalizeFirst ?? '-',
                          ),
                          _InfoRow(
                            icon: Icons.pets_rounded,
                            label: 'Spesies',
                            value: character.type.isEmpty
                                ? character.species
                                : '${character.species} (${character.type})',
                          ),
                          _InfoRow(
                            icon: Icons.wc_rounded,
                            label: 'Gender',
                            value: character.gender,
                          ),
                          _InfoRow(
                            icon: Icons.public_rounded,
                            label: 'Origin',
                            value: character.origin,
                          ),
                          _InfoRow(
                            icon: Icons.location_on_rounded,
                            label: 'Location',
                            value: character.location,
                          ),
                          _InfoRow(
                            icon: Icons.movie_rounded,
                            label: 'Jumlah episode',
                            value: '${character.episodeCount}',
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _Photo extends StatelessWidget {
  const _Photo({required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg + 4),
        color: AppColors.glass,
        border: Border.all(color: AppColors.glassBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withValues(alpha: 0.18),
            blurRadius: 40,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: CharacterImage(url: character.image, radius: AppRadius.lg - 4),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.status(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 8)],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            status.capitalizeFirst ?? status,
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              GradientIcon(icon: icon, size: 36),
              const SizedBox(width: 14),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 66,
            endIndent: 16,
            color: AppColors.purple.withValues(alpha: 0.08),
          ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      radius: AppRadius.sm,
      color: const Color(0xCCFFF1F3),
      padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.dead, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Data terbaru gagal dimuat. $message',
              style: const TextStyle(fontSize: 13),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Coba lagi')),
        ],
      ),
    );
  }
}

/// Tombol favorit di bawah layar. Gradasi saat belum favorit,
/// kaca putih dengan hati pink saat sudah favorit.
class _FavoriteAction extends StatelessWidget {
  const _FavoriteAction({required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    final favorites = Get.find<FavoriteController>();
    return Obx(() {
      final isFav = favorites.isFavorite(character.id);
      final borderRadius = BorderRadius.circular(999);
      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: isFav ? null : AppGradients.primary,
          color: isFav ? Colors.white.withValues(alpha: 0.9) : null,
          border: Border.all(
            color: isFav ? AppColors.favorite.withValues(alpha: 0.4) : Colors.transparent,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.pink.withValues(alpha: isFav ? 0.2 : 0.4),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            key: const Key('detail_favorite_button'),
            borderRadius: borderRadius,
            onTap: () => favorites.toggle(character),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isFav ? AppColors.favorite : Colors.white,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isFav ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: isFav ? AppColors.favorite : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
