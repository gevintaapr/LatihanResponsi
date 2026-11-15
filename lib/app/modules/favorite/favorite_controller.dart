// ====================================================================
// FILE    : lib/app/modules/favorite/favorite_controller.dart
// LAPISAN : Logika / Favorit (sumber data favorit global)
//
// GUNANYA :
//   Hanya ADA SATU FavoriteController untuk seluruh aplikasi (permanent).
//   Home, Detail, dan Favorite Screen membaca list 'favorites' yang sama
//   lewat Obx, sehingga perubahan di satu halaman langsung terlihat di halaman
//   lain (soal 6c). Setiap perubahan disimpan ke Shared Preferences (soal 4a).
//
// DIPAKAI OLEH: FavoriteButton, DetailView, FavoriteView, MainView (badge).
// ====================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/character.dart';
import '../../data/services/session_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/snack.dart';

/// Satu-satunya sumber data favorit untuk seluruh aplikasi.
///
/// Home, Detail, dan Favorite Screen sama-sama membaca [favorites] lewat Obx,
/// sehingga perubahan di satu halaman langsung terlihat di halaman lain.
class FavoriteController extends GetxController {
  final SessionService _session = Get.find();

  final favorites = <Character>[].obs;

  @override
  void onInit() {
    super.onInit();
    _load();
    // Muat ulang favorit setiap kali akun yang login berganti.
    ever(_session.currentUser, (_) => _load());
  }

  void _load() => favorites.assignAll(_session.readFavorites());

  bool isFavorite(int id) => favorites.any((c) => c.id == id);

  /// Menambah atau menghapus favorit, lalu menampilkan Snackbar.
  void toggle(Character character) {
    if (isFavorite(character.id)) {
      favorites.removeWhere((c) => c.id == character.id);
      showSnack(
        '${character.name} dihapus dari favorit',
        icon: Icons.heart_broken_outlined,
        iconColor: AppColors.unknown,
      );
    } else {
      favorites.add(character);
      showSnack(
        '${character.name} ditambahkan ke favorit',
        icon: Icons.favorite,
        iconColor: AppColors.favorite,
      );
    }
    _session.writeFavorites(favorites);
  }

  /// Dipakai oleh swipe di Favorite Screen. Snackbar punya aksi "Batal".
  void removeBySwipe(Character character) {
    final index = favorites.indexWhere((c) => c.id == character.id);
    if (index < 0) return;
    favorites.removeAt(index);
    _session.writeFavorites(favorites);
    showSnack(
      '${character.name} berhasil dihapus dari favorit',
      icon: Icons.delete_outline,
      iconColor: AppColors.dead,
      actionLabel: 'BATAL',
      onAction: () {
        if (isFavorite(character.id)) return;
        favorites.insert(index.clamp(0, favorites.length), character);
        _session.writeFavorites(favorites);
      },
    );
  }
}
