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
                prefixIcon: const Icon(Icons.search),
                suffixIcon: controller.query.value.isEmpty
                    ? null
                    : IconButton(
                        onPressed: controller.clearSearch,
                        icon: const Icon(Icons.close),
                      ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 56,
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
                        label: entry.key,
                        value: entry.value,
                        selected: controller.status.value == entry.value,
                        onSelected: () => controller.setStatus(entry.value),
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
        iconColor: AppColors.dead,
        title: 'Gagal memuat data',
        message: error,
        onRetry: controller.fetch,
      );
    }
    if (controller.characters.isEmpty) {
      return const MessageView(
        icon: Icons.search_off_rounded,
        title: 'Karakter tidak ditemukan',
        message: 'Coba kata kunci atau filter status yang lain.',
      );
    }
    final showFooter = controller.isLoadingMore.value;
    return RefreshIndicator(
      onRefresh: controller.fetch,
      child: ListView.separated(
        controller: controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        itemCount: controller.characters.length + (showFooter ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (_, index) {
          if (index >= controller.characters.length) {
            return const LoadMoreIndicator();
          }
          final character = controller.characters[index];
          return CharacterTile(
            key: ValueKey(character.id),
            character: character,
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final String value;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onSelected(),
      labelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: selected ? AppColors.background : Colors.white,
      ),
      avatar: value.isEmpty
          ? null
          : CircleAvatar(
              radius: 5,
              backgroundColor:
                  selected ? AppColors.background : AppColors.status(value),
            ),
    );
  }
}
