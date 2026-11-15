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

  static const baseUrl = 'https://rickandmortyapi.com/api';
  static const _timeout = Duration(seconds: 15);

  final http.Client _client;

  /// GET /character, /character?status=alive|dead|unknown, dan ?name= (bonus).
  Future<PagedResult<Character>> getCharacters({
    int page = 1,
    String status = '',
    String name = '',
  }) async {
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
    final results = (json['results'] as List? ?? [])
        .map((e) => fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    final info = json['info'];
    return PagedResult<T>(results, info is Map && info['next'] != null);
  }

  /// Mengembalikan `null` untuk 404, melempar [ApiException] untuk error lain.
  Future<Map<String, dynamic>?> _get(
    String path, [
    Map<String, String>? query,
  ]) async {
    final uri = Uri.parse(
      '$baseUrl$path',
    ).replace(queryParameters: (query == null || query.isEmpty) ? null : query);
    try {
      final response = await _client.get(uri).timeout(_timeout);
      if (response.statusCode == 404) return null;
      if (response.statusCode != 200) {
        throw ApiException(
          'Server bermasalah (kode ${response.statusCode}). Coba lagi nanti.',
        );
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException('Koneksi terlalu lama. Periksa internet kamu.');
    } on FormatException {
      throw const ApiException('Data dari server tidak valid.');
    } catch (_) {
      throw const ApiException(
        'Gagal terhubung ke server. Periksa koneksi internet kamu.',
      );
    }
  }
}
