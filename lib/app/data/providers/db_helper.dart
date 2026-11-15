import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Local database (Hive) untuk menyimpan akun pengguna.
///
/// Hive berjalan di Android/iOS (disimpan sebagai file) dan juga di Chrome
/// (disimpan di IndexedDB browser), jadi aplikasi bisa dijalankan di keduanya.
///
/// Setiap akun disimpan di box `users` dengan key = username:
///   'gevin' -> {'username': 'gevin', 'password': '<hash>', 'created_at': '...'}
class DbHelper {
  /// Nama box Hive. Hanya diganti oleh tes supaya tiap tes memakai box baru.
  static String boxName = 'users';

  late Box<Map> _box;

  /// Membuka box. Dipanggil sekali saat aplikasi dimulai (lihat main.dart).
  Future<DbHelper> init() async {
    _box = await Hive.openBox<Map>(boxName);
    return this;
  }

  /// Password tidak disimpan sebagai teks asli, tetapi hash SHA-256.
  String _hash(String username, String password) =>
      sha256.convert(utf8.encode('$username:$password')).toString();

  String _normalize(String username) => username.trim().toLowerCase();

  /// Mengembalikan `false` jika username sudah terdaftar.
  Future<bool> register(String username, String password) async {
    final name = _normalize(username);
    if (_box.containsKey(name)) return false;
    await _box.put(name, {
      'username': name,
      'password': _hash(name, password),
      'created_at': DateTime.now().toIso8601String(),
    });
    return true;
  }

  /// Mengembalikan `true` jika username dan password cocok.
  Future<bool> login(String username, String password) async {
    final name = _normalize(username);
    final user = _box.get(name);
    return user != null && user['password'] == _hash(name, password);
  }
}
