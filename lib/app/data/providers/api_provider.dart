// ====================================================================
// FILE    : lib/app/data/providers/api_provider.dart
// LAPISAN : Data / Sumber data dari internet (REST API)
//
// GUNANYA :
//   SATU-SATUNYA file yang menghubungi https://rickandmortyapi.com/api.
//   Endpoint yang dipakai (sesuai soal):
//     GET /character                    -> daftar karakter
//     GET /character?status=alive|dead|unknown -> filter status
//     GET /character?name=...           -> pencarian nama (bonus)
//     GET /character/{id}               -> detail karakter
//     GET /episode                      -> daftar episode
//   Semua kegagalan (tidak ada internet, timeout, server error) diubah menjadi
//   ApiException yang pesannya bisa langsung ditampilkan ke pengguna.
//
// DIPAKAI OLEH: HomeController, DetailController, EpisodeController.
// ====================================================================

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/character.dart';
import '../models/episode.dart';

/// Error yang pesannya aman ditampilkan langsung ke pengguna.
class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

/// Satu halaman hasil dari endpoint yang memakai pagination.
class PagedResult<T> {
  final List<T> items;
  final bool hasNext;
  const PagedResult(this.items, this.hasNext);
}

class ApiProvider {
  ApiProvider([http.Client? client]) : _client = client ?? http.Client();

  // Alamat dasar API. Semua endpoint ditambahkan di belakangnya.
  static const baseUrl = 'https://rickandmortyapi.com/api';
  // Jika server tidak menjawab dalam 15 detik, request dianggap gagal.
  static const _timeout = Duration(seconds: 15);

  final http.Client _client;

  /// GET /character, /character?status=alive|dead|unknown, dan ?name= (bonus).
  Future<PagedResult<Character>> getCharacters({
    int page = 1,
    String status = '',
    String name = '',
  }) async {
    // Parameter yang kosong tidak dikirim, jadi tanpa filter hasilnya
    // GET /character?page=1, dan dengan filter GET /character?page=1&status=alive
    final json = await _get('/character', {
      'page': '$page',
      if (status.isNotEmpty) 'status': status,
      if (name.trim().isNotEmpty) 'name': name.trim(),
    });
    return _paged(json, Character.fromJson);
  }

  /// GET /character/{id}
  Future<Character> getCharacter(int id) async {
    final json = await _get('/character/$id');
    if (json == null) throw const ApiException('Karakter tidak ditemukan.');
    return Character.fromJson(json);
  }

  /// GET /episode
  Future<PagedResult<Episode>> getEpisodes({int page = 1}) async {
    final json = await _get('/episode', {'page': '$page'});
    return _paged(json, Episode.fromJson);
  }

  PagedResult<T> _paged<T>(
    Map<String, dynamic>? json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    // API mengembalikan 404 kalau filter/pencarian tidak punya hasil.
    if (json == null) return PagedResult<T>([], false);
    // Bentuk respons API: { "info": { "next": url|null, ... }, "results": [ ... ] }
    // 'results' diubah satu per satu menjadi objek lewat fromJson.
    final results = (json['results'] as List? ?? [])
        .map((e) => fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    final info = json['info'];
    // Jika info.next bernilai null, berarti ini halaman terakhir.
    return PagedResult<T>(results, info is Map && info['next'] != null);
  }

  /// Mengembalikan `null` untuk 404, melempar [ApiException] untuk error lain.
  Future<Map<String, dynamic>?> _get(
    String path, [
    Map<String, String>? query,
  ]) async {
    // Menyusun URL lengkap, misalnya:
    // https://rickandmortyapi.com/api/character?page=1&status=dead
    final uri = Uri.parse(
      '$baseUrl$path',
    ).replace(queryParameters: (query == null || query.isEmpty) ? null : query);
    try {
      // Kirim request GET dan tunggu jawabannya (maksimal 15 detik).
      final response = await _client.get(uri).timeout(_timeout);
      // 404 = data tidak ditemukan (misalnya hasil pencarian kosong),
      // bukan error koneksi, jadi dikembalikan sebagai 'tidak ada data'.
      if (response.statusCode == 404) return null;
      if (response.statusCode != 200) {
        throw ApiException(
          'Server bermasalah (kode ${response.statusCode}). Coba lagi nanti.',
        );
      }
      // 200 OK: ubah teks JSON menjadi Map Dart.
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException('Koneksi terlalu lama. Periksa internet kamu.');
    } on FormatException {
      throw const ApiException('Data dari server tidak valid.');
    } catch (_) {
      // Error lain, biasanya karena tidak ada koneksi internet.
      throw const ApiException(
        'Gagal terhubung ke server. Periksa koneksi internet kamu.',
      );
    }
  }
}
