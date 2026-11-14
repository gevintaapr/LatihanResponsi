import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/character.dart';
import '../../modules/favorite/favorite_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/state_views.dart';
import 'detail_controller.dart';

class DetailView extends GetView<DetailController> {
  const DetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final character = controller.character.value;
      final error = controller.errorMessage.value;

      // Belum ada data sama sekali: tampilkan loading / error satu layar penuh.
      if (character == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Detail Karakter')),
          body: error != null
              ? MessageView(
                  icon: Icons.wifi_off_rounded,
                  iconColor: AppColors.dead,
                  title: 'Gagal memuat detail',
                  message: error,
                  onRetry: controller.fetch,
                )
              : const LoadingView(label: 'Memuat detail...'),
        );
      }

      return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: _FavoriteFab(character: character),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 340,
              title: const Text('Detail Karakter'),
              flexibleSpace: FlexibleSpaceBar(
                background: _HeaderImage(url: character.image),
              ),
            ),
            if (controller.isLoading.value)
              const SliverToBoxAdapter(
                child: LinearProgressIndicator(minHeight: 2),
              ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 110),
              sliver: SliverList.list(
                children: [
                  Text(
                    character.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
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
                  Card(
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: Icons.monitor_heart_outlined,
                          label: 'Status',
                          value: character.status.capitalizeFirst ?? '-',
                        ),
                        _InfoRow(
                          icon: Icons.pets_outlined,
                          label: 'Spesies',
                          value: character.type.isEmpty
                              ? character.species
                              : '${character.species} (${character.type})',
                        ),
                        _InfoRow(
                          icon: Icons.wc_outlined,
                          label: 'Gender',
                          value: character.gender,
                        ),
                        _InfoRow(
                          icon: Icons.public_outlined,
                          label: 'Origin',
                          value: character.origin,
                        ),
                        _InfoRow(
                          icon: Icons.location_on_outlined,
                          label: 'Location',
                          value: character.location,
                        ),
                        _InfoRow(
                          icon: Icons.movie_outlined,
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
          ],
        ),
      );
    });
  }
}

class _HeaderImage extends StatelessWidget {
  const _HeaderImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const ColoredBox(
            color: AppColors.surfaceHigh,
            child: Icon(
              Icons.person_off_outlined,
              size: 96,
              color: AppColors.textMuted,
            ),
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x990B1220), Colors.transparent, AppColors.background],
              stops: [0, 0.4, 1],
            ),
          ),
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            status.capitalizeFirst ?? status,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 14),
              Text(label, style: const TextStyle(color: AppColors.textMuted)),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 1, indent: 52, color: AppColors.surfaceHigh),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
      decoration: BoxDecoration(
        color: AppColors.dead.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.dead, size: 20),
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

class _FavoriteFab extends StatelessWidget {
  const _FavoriteFab({required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    final favorites = Get.find<FavoriteController>();
    return Obx(() {
      final isFav = favorites.isFavorite(character.id);
      return FloatingActionButton.extended(
        key: const Key('detail_favorite_button'),
        onPressed: () => favorites.toggle(character),
        backgroundColor: isFav ? AppColors.surfaceHigh : AppColors.favorite,
        foregroundColor: Colors.white,
        icon: Icon(
          isFav ? Icons.favorite : Icons.favorite_border,
          color: isFav ? AppColors.favorite : Colors.white,
        ),
        label: Text(isFav ? 'Hapus dari Favorit' : 'Tambah ke Favorit'),
      );
    });
  }
}
