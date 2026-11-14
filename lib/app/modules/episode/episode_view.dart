import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme/app_theme.dart';
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
          iconColor: AppColors.dead,
          title: 'Gagal memuat episode',
          message: error,
          onRetry: controller.fetch,
        );
      }
      if (controller.episodes.isEmpty) {
        return const MessageView(
          icon: Icons.movie_filter_outlined,
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
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          itemCount: controller.episodes.length + (showFooter ? 1 : 0),
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (_, index) {
            if (index >= controller.episodes.length) {
              return const LoadMoreIndicator();
            }
            final episode = controller.episodes[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 68,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        episode.code,
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
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
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined,
                                  size: 13, color: AppColors.textMuted),
                              const SizedBox(width: 6),
                              Text(
                                episode.airDate,
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
