// ====================================================================
// FILE    : lib/app/data/services/session_service.dart
// LAPISAN : Data / Shared Preferences
//
// GUNANYA :
//   Menyimpan dua hal yang harus tetap ada walau aplikasi ditutup:
//     1. Sesi login  -> key 'session_username'
//     2. Favorit     -> key 'favorites_<username>' (list JSON karakter)
//   currentUser adalah variabel reaktif (Rx): saat berubah, UI yang membacanya
//   ikut diperbarui otomatis.
//
// DIPAKAI OLEH: AuthController, FavoriteController, AuthGuard, MainView.
// ====================================================================

import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/character.dart';

/// Pembungkus Shared Preferences: sesi login dan data favorit.
class SessionService extends GetxService {
  static const _sessionKey = 'session_username';

  late final SharedPreferences _prefs;

  /// Username yang sedang login, `null` jika belum login.
  final currentUser = RxnString();

  bool get isLoggedIn => currentUser.value != null;

  Future<SessionService> init() async {
    _prefs = await SharedPreferences.getInstance();
    currentUser.value = _prefs.getString(_sessionKey);
    return this;
  }

  Future<void> saveSession(String username) async {
    final name = username.trim().toLowerCase();
    await _prefs.setString(_sessionKey, name);
    currentUser.value = name;
  }

  Future<void> clearSession() async {
    await _prefs.remove(_sessionKey);
    currentUser.value = null;
  }

  // Favorit disimpan per akun, supaya tiap pengguna punya daftarnya sendiri.
  String? get _favoritesKey =>
      currentUser.value == null ? null : 'favorites_${currentUser.value}';

  List<Character> readFavorites() {
    final key = _favoritesKey;
    if (key == null) return [];
    try {
      return (_prefs.getStringList(key) ?? [])
          .map((e) => Character.fromJson(jsonDecode(e) as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> writeFavorites(List<Character> favorites) async {
    final key = _favoritesKey;
    if (key == null) return;
    await _prefs.setStringList(
      key,
      favorites.map((c) => jsonEncode(c.toJson())).toList(),
    );
  }
}
