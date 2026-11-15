import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme/app_theme.dart';
import '../../widgets/glass.dart';
import '../../widgets/state_views.dart';
import 'episode_controller.dart';

class EpisodeView extends GetView<EpisodeController> {
  const EpisodeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const LoadingView(label: 'Memuat episode...');
      }
      final error = controller.errorMessage.value;
      if (error != null) {
        return MessageView(
          icon: Icons.wifi_off_rounded,
          title: 'Gagal memuat episode',
          message: error,
          onRetry: controller.fetch,
        );
      }
      if (controller.episodes.isEmpty) {
        return const MessageView(
          icon: Icons.movie_filter_rounded,
          gradient: AppGradients.warm,
          title: 'Belum ada episode',
          message: 'Daftar episode kosong.',
        );
      }
      final showFooter = controller.isLoadingMore.value;
      return RefreshIndicator(
        onRefresh: controller.fetch,
        child: ListView.separated(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
          itemCount: controller.episodes.length + (showFooter ? 1 : 0),
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (_, index) {
            if (index >= controller.episodes.length) {
              return const LoadMoreIndicator();
            }
            final episode = controller.episodes[index];
            return GlassContainer(
              radius: AppRadius.md - 2,
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Container(
                    width: 62,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: AppGradients.warm,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.yellow.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Text(
                      episode.code,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          episode.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_rounded,
                              size: 14,
                              color: AppColors.purple,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              episode.airDate,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }
}
