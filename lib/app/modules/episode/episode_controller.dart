import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/episode.dart';
import '../../data/providers/api_provider.dart';
import '../../utils/snack.dart';

class EpisodeController extends GetxController {
  final ApiProvider _api = Get.find();

  final episodes = <Episode>[].obs;
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final errorMessage = RxnString();

  final scrollController = ScrollController();

  int _page = 1;
  bool _hasNext = true;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(() {
      final position = scrollController.position;
      if (position.pixels >= position.maxScrollExtent - 300) loadMore();
    });
    fetch();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<void> fetch() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result = await _api.getEpisodes(page: 1);
      episodes.assignAll(result.items);
      _hasNext = result.hasNext;
      _page = 2;
    } on ApiException catch (e) {
      episodes.clear();
      errorMessage.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoading.value || isLoadingMore.value || !_hasNext) return;
    isLoadingMore.value = true;
    try {
      final result = await _api.getEpisodes(page: _page);
      episodes.addAll(result.items);
      _hasNext = result.hasNext;
      _page++;
    } on ApiException catch (e) {
      showErrorSnack(e.message);
    } finally {
      isLoadingMore.value = false;
    }
  }
}
