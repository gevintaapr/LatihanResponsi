import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/character.dart';
import '../../data/providers/api_provider.dart';
import '../../utils/snack.dart';

class HomeController extends GetxController {
  final ApiProvider _api = Get.find();

  /// Pilihan filter: label yang tampil -> nilai parameter `status` di API.
  static const filters = {
    'All': '',
    'Alive': 'alive',
    'Dead': 'dead',
    'Unknown': 'unknown',
  };

  final characters = <Character>[].obs;
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final errorMessage = RxnString();
  final status = ''.obs;
  final query = ''.obs;

  final scrollController = ScrollController();
  final searchController = TextEditingController();

  int _page = 1;
  bool _hasNext = true;

  // Menandai request terbaru, supaya respons lama yang datang terlambat
  // (misalnya saat filter diganti dengan cepat) tidak menimpa data baru.
  int _requestToken = 0;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    // Tunggu pengguna berhenti mengetik sebelum memanggil API pencarian.
    debounce(query, (_) => fetch(), time: const Duration(milliseconds: 500));
    fetch();
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }

  void _onScroll() {
    final position = scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) loadMore();
  }

  void setStatus(String value) {
    if (status.value == value) return;
    status.value = value;
    fetch();
  }

  void clearSearch() {
    searchController.clear();
    query.value = '';
  }

  /// Memuat halaman pertama sesuai filter dan kata kunci saat ini.
  Future<void> fetch() async {
    final token = ++_requestToken;
    _page = 1;
    _hasNext = true;
    isLoading.value = true;
    isLoadingMore.value = false;
    errorMessage.value = null;
    try {
      final result = await _api.getCharacters(
        page: 1,
        status: status.value,
        name: query.value,
      );
      if (token != _requestToken) return;
      characters.assignAll(result.items);
      _hasNext = result.hasNext;
      _page = 2;
      if (scrollController.hasClients) scrollController.jumpTo(0);
    } on ApiException catch (e) {
      if (token != _requestToken) return;
      characters.clear();
      errorMessage.value = e.message;
    } finally {
      if (token == _requestToken) isLoading.value = false;
    }
  }

  /// Infinite scroll: memuat halaman berikutnya.
  Future<void> loadMore() async {
    if (isLoading.value || isLoadingMore.value || !_hasNext) return;
    final token = _requestToken;
    isLoadingMore.value = true;
    try {
      final result = await _api.getCharacters(
        page: _page,
        status: status.value,
        name: query.value,
      );
      if (token != _requestToken) return;
      characters.addAll(result.items);
      _hasNext = result.hasNext;
      _page++;
    } on ApiException catch (e) {
      if (token == _requestToken) showErrorSnack(e.message);
    } finally {
      if (token == _requestToken) isLoadingMore.value = false;
    }
  }
}
