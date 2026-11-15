import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/character.dart';
import '../../data/providers/api_provider.dart';
import '../../utils/snack.dart';

class HomeController extends GetxController {
  final ApiProvider _api = Get.find();

  /// Pilihan filter status: label yang tampil -> nilai parameter `status` API.
  static const statusFilters = {
    'Alive': 'alive',
    'Dead': 'dead',
    'Unknown': 'unknown',
  };

  final characters = <Character>[].obs;
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final errorMessage = RxnString();
  final query = ''.obs;

  /// Status yang sedang dipilih. Kosong = "All" (tanpa filter).
  final selectedStatuses = <String>{}.obs;

  final scrollController = ScrollController();
  final searchController = TextEditingController();

  // API hanya menerima satu status per request. Untuk filter ganda
  // (misalnya Alive + Dead) tiap status dimuat terpisah, jadi halaman dan
  // sisa data dicatat per status.
  final _pages = <String, int>{};
  final _hasNext = <String, bool>{};

  // Menandai request terbaru, supaya respons lama yang datang terlambat
  // (misalnya saat filter diganti dengan cepat) tidak menimpa data baru.
  int _requestToken = 0;

  bool get isAll => selectedStatuses.isEmpty;

  /// Status yang perlu diminta ke API. '' berarti tanpa filter.
  List<String> get _targets => isAll
      ? ['']
      : statusFilters.values.where(selectedStatuses.contains).toList();

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

  /// Menambah / melepas satu status. Jika semua status terpilih,
  /// hasilnya sama dengan "All", jadi pilihan dikosongkan.
  void toggleStatus(String status) {
    if (selectedStatuses.contains(status)) {
      selectedStatuses.remove(status);
    } else {
      selectedStatuses.add(status);
      if (selectedStatuses.length == statusFilters.length) {
        selectedStatuses.clear();
      }
    }
    fetch();
  }

  /// Kembali ke "All".
  void clearStatuses() {
    if (isAll) return;
    selectedStatuses.clear();
    fetch();
  }

  void clearSearch() {
    searchController.clear();
    query.value = '';
  }

  /// Memuat halaman pertama sesuai filter dan kata kunci saat ini.
  Future<void> fetch() async {
    final token = ++_requestToken;
    final targets = _targets;
    _pages
      ..clear()
      ..addEntries(targets.map((s) => MapEntry(s, 1)));
    _hasNext
      ..clear()
      ..addEntries(targets.map((s) => MapEntry(s, true)));
    isLoading.value = true;
    isLoadingMore.value = false;
    errorMessage.value = null;
    try {
      final items = await _loadBatch(targets);
      if (token != _requestToken) return;
      characters.assignAll(items);
      if (scrollController.hasClients) scrollController.jumpTo(0);
    } on ApiException catch (e) {
      if (token != _requestToken) return;
      characters.clear();
      errorMessage.value = e.message;
    } finally {
      if (token == _requestToken) isLoading.value = false;
    }
  }

  /// Infinite scroll: memuat halaman berikutnya dari status yang masih ada.
  Future<void> loadMore() async {
    final targets = _hasNext.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    if (isLoading.value || isLoadingMore.value || targets.isEmpty) return;
    final token = _requestToken;
    isLoadingMore.value = true;
    try {
      final items = await _loadBatch(targets);
      if (token != _requestToken) return;
      characters.addAll(items);
    } on ApiException catch (e) {
      if (token == _requestToken) showErrorSnack(e.message);
    } finally {
      if (token == _requestToken) isLoadingMore.value = false;
    }
  }

  /// Mengambil halaman berikutnya untuk tiap status secara bersamaan,
  /// lalu menggabungkannya dan mengurutkan berdasarkan id.
  Future<List<Character>> _loadBatch(List<String> targets) async {
    final results = await Future.wait(
      targets.map(
        (status) => _api.getCharacters(
          page: _pages[status]!,
          status: status,
          name: query.value,
        ),
      ),
    );
    final merged = <Character>[];
    for (var i = 0; i < targets.length; i++) {
      merged.addAll(results[i].items);
      _hasNext[targets[i]] = results[i].hasNext;
      _pages[targets[i]] = _pages[targets[i]]! + 1;
    }
    merged.sort((a, b) => a.id.compareTo(b.id));
    return merged;
  }
}
