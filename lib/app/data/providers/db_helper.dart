import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Local database (SQLite) untuk menyimpan akun pengguna.
class DbHelper {
  static const _dbName = 'rick_morty.db';
  static const _table = 'users';

  Database? _db;

  Future<Database> get _database async {
    return _db ??= await openDatabase(
      p.join(await getDatabasesPath(), _dbName),
      version: 1,
      onCreate: (db, _) => db.execute('''
        CREATE TABLE $_table (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      '''),
    );
  }

  /// Password tidak disimpan sebagai teks asli, tetapi hash SHA-256.
  String _hash(String username, String password) =>
      sha256.convert(utf8.encode('$username:$password')).toString();

  String _normalize(String username) => username.trim().toLowerCase();

  /// Mengembalikan `false` jika username sudah terdaftar.
  Future<bool> register(String username, String password) async {
    final name = _normalize(username);
    final db = await _database;
    final existing = await db.query(
      _table,
      where: 'username = ?',
      whereArgs: [name],
      limit: 1,
    );
    if (existing.isNotEmpty) return false;
    await db.insert(_table, {
      'username': name,
      'password': _hash(name, password),
      'created_at': DateTime.now().toIso8601String(),
    });
    return true;
  }

  /// Mengembalikan `true` jika username dan password cocok.
  Future<bool> login(String username, String password) async {
    final name = _normalize(username);
    final db = await _database;
    final rows = await db.query(
      _table,
      where: 'username = ? AND password = ?',
      whereArgs: [name, _hash(name, password)],
      limit: 1,
    );
    return rows.isNotEmpty;
  }
}
