// ====================================================================
// FILE    : lib/app/modules/home/home_view.dart
// LAPISAN : Tampilan / Home Screen
//
// GUNANYA :
//   Kolom pencarian, chip filter status, dan grid kartu karakter.
//   Obx(...) membuat bagian UI menggambar ulang otomatis setiap kali
//   variabel .obs di HomeController berubah.
//
// DIPAKAI OLEH: Tab pertama di MainView.
// ====================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme/app_theme.dart';
import '../../widgets/character_widgets.dart';
import '../../widgets/state_views.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Obx(
            () => TextField(
              key: const Key('search_field'),
              controller: controller.searchController,
              // Setiap ketikan mengubah query; controller menunggu 500 ms
              // (debounce) sebelum memanggil API pencarian.
              onChanged: (v) => controller.query.value = v,
              textInputAction: TextInputAction.search,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Cari karakter berdasarkan nama...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: controller.query.value.isEmpty
                    ? null
                    : IconButton(
                        onPressed: controller.clearSearch,
                        icon: const Icon(Icons.close_rounded, size: 18),
                      ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 52,
          child: Obx(
            () => ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Center(
                  child: _FilterChip(
                    key: const Key('filter_all'),
                    label: 'All',
                    selected: controller.isAll,
                    onTap: controller.clearStatuses,
                  ),
                ),
                for (final entry in HomeController.statusFilters.entries)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Center(
                      child: _FilterChip(
                        key: Key('filter_${entry.value}'),
                        label: entry.key,
                        dotColor: AppColors.status(entry.value),
                        selected: controller.selectedStatuses.contains(
                          entry.value,
                        ),
                        // Chip aktif menampilkan × untuk melepas filter.
                        removable: true,
                        onTap: () => controller.toggleStatus(entry.value),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Expanded(child: Obx(_buildBody)),
      ],
    );
  }

  // Memilih tampilan sesuai state: loading -> error -> kosong -> grid data.
  Widget _buildBody() {
    if (controller.isLoading.value) {
      return const LoadingView(label: 'Memuat karakter...');
    }
    final error = controller.errorMessage.value;
    if (error != null) {
      return MessageView(
        icon: Icons.wifi_off_rounded,
        title: 'Gagal memuat data',
        message: error,
        onRetry: controller.fetch,
      );
    }
    if (controller.characters.isEmpty) {
      return const MessageView(
        icon: Icons.search_off_rounded,
        gradient: AppGradients.warm,
        title: 'Karakter tidak ditemukan',
        message: 'Coba kata kunci atau filter status yang lain.',
      );
    }
    final showFooter = controller.isLoadingMore.value;
    return RefreshIndicator(
      onRefresh: controller.fetch,
      child: CustomScrollView(
        controller: controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                // Tinggi kartu tetap, foto mengisi sisa ruang.
                mainAxisExtent: 172,
              ),
              itemCount: controller.characters.length,
              itemBuilder: (_, index) {
                final character = controller.characters[index];
                return CharacterGridCard(
                  key: ValueKey(character.id),
                  character: character,
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: showFooter
                ? const LoadMoreIndicator()
                : const SizedBox.shrink(),
          ),
          // Ruang agar kartu terakhir tidak tertutup navbar melayang.
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.dotColor,
    this.removable = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? dotColor;
  final bool removable;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(999);
    return Semantics(
      button: true,
      selected: selected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: selected ? AppGradients.primary : null,
          color: selected ? null : AppColors.glassStrong,
          border: Border.all(
            color: selected ? Colors.transparent : AppColors.glassBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? AppColors.pink.withValues(alpha: 0.28)
                  : AppColors.shadow,
              blurRadius: selected ? 12 : 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: borderRadius,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                14,
                7,
                selected && removable ? 8 : 14,
                7,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (dotColor != null) ...[
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected ? Colors.white : dotColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                      color: selected ? Colors.white : AppColors.text,
                    ),
                  ),
                  if (selected && removable) ...[
                    const SizedBox(width: 6),
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
