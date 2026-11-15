// ====================================================================
// FILE    : lib/app/modules/detail/detail_view.dart
// LAPISAN : Tampilan / Detail Screen
//
// GUNANYA :
//   Menampilkan foto, nama, status, spesies, gender, origin, location (soal 3a)
//   dan tombol favorit yang ikon & teksnya berubah sesuai status (soal 3b-3d).
//
// DIPAKAI OLEH: Route /detail.
// ====================================================================

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
        const Text('Detail Karakter', style: TextStyle(fontSize: 18)),
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
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: SizedBox(
                        width: 220,
                        child: _Photo(character: character),
                      ),
                    ),
                    if (controller.isLoading.value)
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: LinearProgressIndicator(
                          minHeight: 3,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      character.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${character.species} · ${character.gender}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(child: _StatusPill(status: character.status)),
                    if (error != null) ...[
                      const SizedBox(height: 16),
                      _ErrorBanner(message: error, onRetry: controller.fetch),
                    ],
                    const SizedBox(height: 20),
                    const _SectionTitle('Identitas'),
                    const SizedBox(height: 10),
                    // Info pendek: grid 2 kolom.
                    Row(
                      children: [
                        Expanded(
                          child: _InfoTile(
                            icon: Icons.monitor_heart_rounded,
                            label: 'Status',
                            value: character.status.capitalizeFirst ?? '-',
                            valueColor: AppColors.status(character.status),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoTile(
                            icon: Icons.pets_rounded,
                            label: 'Spesies',
                            value: character.type.isEmpty
                                ? character.species
                                : '${character.species} (${character.type})',
                            gradient: AppGradients.warm,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _InfoTile(
                            icon: Icons.wc_rounded,
                            label: 'Gender',
                            value: character.gender,
                            gradient: AppGradients.warm,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoTile(
                            icon: Icons.movie_rounded,
                            label: 'Episode',
                            value: '${character.episodeCount} episode',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const _SectionTitle('Asal & Lokasi'),
                    const SizedBox(height: 10),
                    // Info panjang: kartu selebar layar.
                    _WideInfoTile(
                      icon: Icons.public_rounded,
                      label: 'Origin',
                      value: character.origin,
                    ),
                    const SizedBox(height: 12),
                    _WideInfoTile(
                      icon: Icons.location_on_rounded,
                      label: 'Location',
                      value: character.location,
                      gradient: AppGradients.warm,
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
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
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
        child: CharacterImage(url: character.image, radius: AppRadius.md),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 8),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            status.capitalizeFirst ?? status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

/// Kartu info kecil untuk grid 2 kolom: ikon di atas, label, lalu nilai.
class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.gradient = AppGradients.primary,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Gradient gradient;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      radius: AppRadius.md - 2,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          GradientIcon(icon: icon, size: 34, gradient: gradient),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: valueColor ?? AppColors.text,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu info selebar layar untuk nilai yang panjang (origin, location).
class _WideInfoTile extends StatelessWidget {
  const _WideInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.gradient = AppGradients.primary,
  });

  final IconData icon;
  final String label;
  final String value;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      radius: AppRadius.md - 2,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          GradientIcon(icon: icon, size: 34, gradient: gradient),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.dead,
            size: 20,
          ),
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
            color: isFav
                ? AppColors.favorite.withValues(alpha: 0.4)
                : Colors.transparent,
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
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isFav
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isFav ? AppColors.favorite : Colors.white,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isFav ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
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
