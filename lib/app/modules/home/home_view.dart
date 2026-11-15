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
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Obx(
            () => TextField(
              key: const Key('search_field'),
              controller: controller.searchController,
              onChanged: (v) => controller.query.value = v,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Cari karakter berdasarkan nama...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: controller.query.value.isEmpty
                    ? null
                    : IconButton(
                        onPressed: controller.clearSearch,
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 60,
          child: Obx(
            () => ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (final entry in HomeController.filters.entries)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Center(
                      child: _FilterChip(
                        key: Key('filter_${entry.key.toLowerCase()}'),
                        label: entry.key,
                        value: entry.value,
                        selected: controller.status.value == entry.value,
                        onTap: () => controller.setStatus(entry.value),
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
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 240,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.74,
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
            child: showFooter ? const LoadMoreIndicator() : const SizedBox.shrink(),
          ),
          // Ruang agar kartu terakhir tidak tertutup navbar melayang.
          const SliverToBoxAdapter(child: SizedBox(height: 110)),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    super.key,
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

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
                  ? AppColors.pink.withValues(alpha: 0.3)
                  : AppColors.shadow,
              blurRadius: selected ? 14 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: borderRadius,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (value.isNotEmpty) ...[
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected ? Colors.white : AppColors.status(value),
                      ),
                    ),
                    const SizedBox(width: 7),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      color: selected ? Colors.white : AppColors.text,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
