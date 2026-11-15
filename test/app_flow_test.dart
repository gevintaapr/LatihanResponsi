import 'dart:convert';
import 'dart:io';

import 'package:characterapp/app/data/providers/api_provider.dart';
import 'package:characterapp/app/data/providers/db_helper.dart';
import 'package:characterapp/app/modules/favorite/favorite_view.dart';
import 'package:characterapp/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';

Map<String, dynamic> _character(int id, String name, String status) => {
      'id': id,
      'name': name,
      'status': status,
      'species': 'Human',
      'type': '',
      'gender': 'Male',
      'origin': {'name': 'Earth (C-137)'},
      'location': {'name': 'Citadel of Ricks'},
      'image': 'https://example.com/$id.jpeg',
      'episode': ['e1', 'e2'],
    };

final _all = [
  _character(1, 'Rick Sanchez', 'Alive'),
  _character(2, 'Morty Smith', 'Alive'),
  _character(8, 'Adjudicator Rick', 'Dead'),
];

/// API tiruan yang meniru perilaku rickandmortyapi.com.
class FakeApi {
  bool offline = false;
  final requests = <Uri>[];

  http.Client get client => MockClient((request) async {
        requests.add(request.url);
        if (offline) throw http.ClientException('offline');
        final segments = request.url.pathSegments;
        final query = request.url.queryParameters;
        http.Response ok(Object body) => http.Response(
              jsonEncode(body),
              200,
              headers: {'content-type': 'application/json; charset=utf-8'},
            );

        if (segments.last == 'episode') {
          return ok({
            'info': {'next': null},
            'results': [
              {'id': 1, 'name': 'Pilot', 'air_date': 'December 2, 2013', 'episode': 'S01E01'},
            ],
          });
        }
        if (segments.last == 'character') {
          final results = _all.where((c) {
            final status = query['status'];
            final name = query['name']?.toLowerCase();
            return (status == null ||
                    c['status'].toString().toLowerCase() == status) &&
                (name == null ||
                    c['name'].toString().toLowerCase().contains(name));
          }).toList();
          if (results.isEmpty) {
            return http.Response('{"error":"There is nothing here"}', 404);
          }
          return ok({
            'info': {'next': null},
            'results': results,
          });
        }
        final id = int.parse(segments.last);
        return ok(_all.firstWhere((c) => c['id'] == id));
      });
}

Future<void> _settle(WidgetTester tester) async {
  // Hive melakukan I/O sungguhan, sedangkan widget test memakai jam palsu.
  // Jadi beri waktu nyata dan pump bergantian sampai operasi DB selesai.
  for (var i = 0; i < 8; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 30)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }
  await tester.pumpAndSettle(const Duration(milliseconds: 100));
}

// SnackBar juga memakai Dismissible, jadi batasi pencarian ke FavoriteView.
final favoriteCards = find.descendant(
  of: find.byType(FavoriteView),
  matching: find.byType(Dismissible),
);

void main() {
  late FakeApi api;

  late Directory hiveDir;

  setUpAll(() {
    hiveDir = Directory.systemTemp.createTempSync('hive_test');
    Hive.init(hiveDir.path);
  });


  setUp(() async {
    Get.reset();
    SharedPreferences.setMockInitialValues({});
    // Box baru untuk tiap tes, supaya data akun antar-tes tidak tercampur.
    DbHelper.boxName = 'users_${DateTime.now().microsecondsSinceEpoch}';
    api = FakeApi();
  });

  Future<void> startApp(WidgetTester tester) async {
    await tester.runAsync(() => initDependencies(api: ApiProvider(api.client)));
    await tester.pumpWidget(const MainApp());
    await _settle(tester);
  }

  Future<void> registerAndLogin(WidgetTester tester) async {
    await tester.tap(find.text('Daftar'));
    await _settle(tester);
    await tester.enterText(find.byKey(const Key('register_username')), 'Gevin');
    await tester.enterText(find.byKey(const Key('register_password')), 'rahasia1');
    await tester.enterText(find.byKey(const Key('register_confirm')), 'rahasia1');
    await tester.tap(find.widgetWithText(FilledButton, 'Register'));
    await _settle(tester);

    // Kembali ke login dengan username terisi otomatis.
    expect(find.text('Registrasi berhasil, silakan login'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('login_password')), 'rahasia1');
    await tester.tap(find.widgetWithText(FilledButton, 'Login'));
    await _settle(tester);
    await _settle(tester);
  }

  testWidgets('tanpa login, aplikasi terbuka di halaman login', (tester) async {
    await startApp(tester);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Rick Sanchez'), findsNothing);
    expect(api.requests, isEmpty);
  });

  testWidgets('login dengan akun yang salah ditolak', (tester) async {
    await startApp(tester);
    await tester.enterText(find.byKey(const Key('login_username')), 'hantu');
    await tester.enterText(find.byKey(const Key('login_password')), 'salahsalah');
    await tester.tap(find.widgetWithText(FilledButton, 'Login'));
    await _settle(tester);
    expect(find.text('Username atau password salah'), findsOneWidget);
    expect(find.text('Rick Sanchez'), findsNothing);
  });

  testWidgets('username yang sama tidak bisa didaftarkan dua kali', (tester) async {
    await tester.runAsync(() async {
      await (await DbHelper().init()).register('gevin', 'rahasia1');
    });
    await startApp(tester);
    await tester.tap(find.text('Daftar'));
    await _settle(tester);
    await tester.enterText(find.byKey(const Key('register_username')), 'GEVIN');
    await tester.enterText(find.byKey(const Key('register_password')), 'rahasia2');
    await tester.enterText(find.byKey(const Key('register_confirm')), 'rahasia2');
    await tester.tap(find.widgetWithText(FilledButton, 'Register'));
    await _settle(tester);
    expect(find.text('Username sudah terdaftar, gunakan yang lain'), findsOneWidget);
  });

  testWidgets('alur lengkap: register, login, filter, cari, favorit, swipe, logout',
      (tester) async {
    await startApp(tester);
    await registerAndLogin(tester);

    // Home: daftar karakter dari API.
    expect(find.text('Halo, gevin'), findsOneWidget);
    expect(find.text('Rick Sanchez'), findsOneWidget);
    expect(find.text('Adjudicator Rick'), findsOneWidget);

    // Filter status -> endpoint /character?status=dead
    await tester.tap(find.byKey(const Key('filter_dead')));
    await _settle(tester);
    expect(api.requests.last.queryParameters['status'], 'dead');
    expect(find.text('Adjudicator Rick'), findsOneWidget);
    expect(find.text('Rick Sanchez'), findsNothing);
    await tester.tap(find.byKey(const Key('filter_all')));
    await _settle(tester);

    // Pencarian nama (bonus), termasuk hasil kosong (404 dari API).
    await tester.enterText(find.byKey(const Key('search_field')), 'morty');
    await tester.pump(const Duration(milliseconds: 600));
    await _settle(tester);
    expect(api.requests.last.queryParameters['name'], 'morty');
    expect(find.text('Morty Smith'), findsOneWidget);
    expect(find.text('Rick Sanchez'), findsNothing);
    await tester.enterText(find.byKey(const Key('search_field')), 'zzz');
    await tester.pump(const Duration(milliseconds: 600));
    await _settle(tester);
    expect(find.text('Karakter tidak ditemukan'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('search_field')), '');
    await tester.pump(const Duration(milliseconds: 600));
    await _settle(tester);

    // Favorit dari Home.
    await tester.tap(find.byIcon(Icons.favorite_border_rounded).first);
    await _settle(tester);
    expect(find.text('Rick Sanchez ditambahkan ke favorit'), findsOneWidget);

    // Detail Screen -> endpoint /character/2, lalu favoritkan dari sana.
    await tester.tap(find.text('Morty Smith'));
    await _settle(tester);
    expect(api.requests.last.path, endsWith('/character/2'));
    for (final text in ['Spesies', 'Gender', 'Origin', 'Location',
                        'Earth (C-137)', 'Citadel of Ricks']) {
      expect(find.text(text), findsOneWidget);
    }
    expect(find.text('Tambah ke Favorit'), findsOneWidget);
    await tester.tap(find.byKey(const Key('detail_favorite_button')));
    await _settle(tester);
    expect(find.text('Morty Smith ditambahkan ke favorit'), findsOneWidget);
    expect(find.text('Hapus dari Favorit'), findsOneWidget);
    await tester.tap(find.byTooltip('Kembali'));
    await _settle(tester);

    // Favorite Screen langsung berisi 2 karakter.
    await tester.tap(find.text('Favorites'));
    await _settle(tester);
    expect(favoriteCards, findsNWidgets(2));

    // Swipe untuk menghapus + Snackbar.
    await tester.drag(favoriteCards.first, const Offset(-600, 0));
    await _settle(tester);
    expect(find.text('Rick Sanchez berhasil dihapus dari favorit'), findsOneWidget);
    expect(favoriteCards, findsOneWidget);

    // Tersimpan di Shared Preferences (per akun).
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('favorites_gevin')!;
    expect(saved, hasLength(1));
    expect(jsonDecode(saved.single)['name'], 'Morty Smith');

    // Home ikut diperbarui: hanya Morty yang hatinya terisi.
    await tester.tap(find.text('Characters'));
    await _settle(tester);
    expect(
      find.descendant(
        of: find.byType(IndexedStack),
        matching: find.byIcon(Icons.favorite_rounded, skipOffstage: true),
      ),
      findsOneWidget,
    );

    // Episode.
    await tester.tap(find.text('Episodes'));
    await _settle(tester);
    expect(find.text('Pilot'), findsOneWidget);
    expect(find.text('December 2, 2013'), findsOneWidget);

    // Logout kembali ke login, sesi terhapus.
    await tester.tap(find.byKey(const Key('logout_button')));
    await _settle(tester);
    await tester.tap(find.byKey(const Key('confirm_logout')));
    await _settle(tester);
    expect(find.widgetWithText(FilledButton, 'Login'), findsOneWidget);
    expect(prefs.getString('session_username'), isNull);
  });

  testWidgets('sesi dan favorit bertahan setelah aplikasi ditutup', (tester) async {
    SharedPreferences.setMockInitialValues({
      'session_username': 'gevin',
      'favorites_gevin': [jsonEncode(_all[1]..remove('episode'))],
    });
    await startApp(tester);
    expect(find.text('Halo, gevin'), findsOneWidget);
    await tester.tap(find.text('Favorites'));
    await _settle(tester);
    expect(favoriteCards, findsOneWidget);
  });

  testWidgets('favorit kosong menampilkan pesan', (tester) async {
    SharedPreferences.setMockInitialValues({'session_username': 'gevin'});
    await startApp(tester);
    await tester.tap(find.text('Favorites'));
    await _settle(tester);
    expect(find.text('Belum ada karakter favorit'), findsOneWidget);
  });

  testWidgets('API gagal: tampil error, lalu pulih lewat Coba Lagi', (tester) async {
    SharedPreferences.setMockInitialValues({'session_username': 'gevin'});
    api.offline = true;
    await startApp(tester);
    expect(find.text('Gagal memuat data'), findsOneWidget);
    expect(find.text('Coba Lagi'), findsWidgets);

    api.offline = false;
    await tester.tap(find.text('Coba Lagi').first);
    await _settle(tester);
    expect(find.text('Rick Sanchez'), findsOneWidget);
  });
}
