# Panduan Membuat Rick & Morty Character Explorer

Panduan ini menjelaskan cara aplikasi ini dibuat, **urut dari nol**: membuat project, memasang package, menghubungkan API, sampai semua halaman jadi. Setiap langkah menyebutkan **file mana** yang dibuat dan **apa gunanya**.

Setiap file `.dart` di folder `lib/` juga punya blok komentar di bagian paling atas (FILE, LAPISAN, GUNANYA, DIPAKAI OLEH). Buka file-nya sambil membaca panduan ini.

---

## Daftar isi

1. [Gambaran besar](#1-gambaran-besar)
2. [Membuat project Flutter](#2-membuat-project-flutter)
3. [Memasang package](#3-memasang-package)
4. [Struktur folder](#4-struktur-folder)
5. [Langkah 1: Model data](#5-langkah-1-model-data)
6. [Langkah 2: Menghubungkan API](#6-langkah-2-menghubungkan-api)
7. [Langkah 3: Local database (Hive) untuk akun](#7-langkah-3-local-database-hive-untuk-akun)
8. [Langkah 4: Shared Preferences untuk sesi dan favorit](#8-langkah-4-shared-preferences-untuk-sesi-dan-favorit)
9. [Langkah 5: Tema dan komponen tampilan](#9-langkah-5-tema-dan-komponen-tampilan)
10. [Langkah 6: Routing dan proteksi login](#10-langkah-6-routing-dan-proteksi-login)
11. [Langkah 7: main.dart, menyatukan semuanya](#11-langkah-7-maindart-menyatukan-semuanya)
12. [Langkah 8: Login, Register, Logout](#12-langkah-8-login-register-logout)
13. [Langkah 9: Favorit (dipakai semua halaman)](#13-langkah-9-favorit-dipakai-semua-halaman)
14. [Langkah 10: Home Screen](#14-langkah-10-home-screen)
15. [Langkah 11: Detail Screen](#15-langkah-11-detail-screen)
16. [Langkah 12: Favorite Screen](#16-langkah-12-favorite-screen)
17. [Langkah 13: Halaman Episode](#17-langkah-13-halaman-episode)
18. [Langkah 14: Bottom Navigation Bar](#18-langkah-14-bottom-navigation-bar)
19. [Peta soal ke file](#19-peta-soal-ke-file)
20. [Menjalankan dan mengetes](#20-menjalankan-dan-mengetes)
21. [Pertanyaan yang mungkin ditanya saat responsi](#21-pertanyaan-yang-mungkin-ditanya-saat-responsi)

---

## 1. Gambaran besar

Aplikasi dibagi menjadi tiga lapisan. Setiap fitur selalu melewati rantai yang sama:

```
VIEW (tampilan)  →  CONTROLLER (logika)  →  PROVIDER / SERVICE (data)  →  API / Hive / Shared Preferences
  login_view.dart     auth_controller.dart     db_helper.dart                 Hive
  home_view.dart      home_controller.dart     api_provider.dart              rickandmortyapi.com
```

- **View** hanya menampilkan data dan meneruskan klik ke controller.
- **Controller** menyimpan *state* (data yang sedang tampil, sedang loading atau tidak, pesan error) dan memutuskan apa yang terjadi.
- **Provider/Service** satu-satunya bagian yang berbicara dengan dunia luar: internet, database, penyimpanan.

**GetX** dipakai untuk tiga hal:

| Fitur GetX | Dipakai untuk | Contoh |
| --- | --- | --- |
| State management | Variabel `.obs` + widget `Obx` | `final isLoading = false.obs;` |
| Routing | Pindah halaman tanpa `context` | `Get.toNamed(Routes.detail)` |
| Dependency injection | Membuat objek sekali, dipakai di mana saja | `Get.put(...)`, `Get.find()` |

---

## 2. Membuat project Flutter

### 2.1 Cek Flutter sudah siap

```bash
flutter doctor
```

Pastikan bagian **Flutter** dan **Chrome** (atau **Android toolchain** jika memakai HP/emulator) bercentang hijau.

### 2.2 Buat project baru

```bash
flutter create characterapp
```

Masuk ke folder project:

```bash
cd characterapp
```

Coba jalankan template bawaan untuk memastikan semuanya berfungsi:

```bash
flutter run -d chrome
```

Setelah muncul aplikasi contoh, hentikan dengan `q` di terminal. Isi `lib/main.dart` akan kita ganti seluruhnya.

---

## 3. Memasang package

### 3.1 Package yang dipakai

Jalankan **satu perintah** ini di folder project:

```bash
flutter pub add get http shared_preferences hive hive_flutter crypto
```

| Package | Gunanya di aplikasi ini | Dipakai di file |
| --- | --- | --- |
| `get` | GetX: state management, routing, dependency injection | hampir semua file |
| `http` | Mengirim request GET ke API Rick and Morty | `data/providers/api_provider.dart` |
| `shared_preferences` | Menyimpan sesi login dan daftar favorit | `data/services/session_service.dart` |
| `hive` + `hive_flutter` | Local database untuk akun (Login & Register) | `data/providers/db_helper.dart` |
| `crypto` | Hash password (SHA-256) sebelum disimpan | `data/providers/db_helper.dart` |

Perintah `flutter pub add` otomatis menuliskan package ke `pubspec.yaml` dan mengunduhnya. Hasilnya di `pubspec.yaml`:

```yaml
dependencies:
  crypto: ^3.0.8
  flutter:
    sdk: flutter
  get: ^4.7.3
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  http: ^1.6.0
  shared_preferences: ^2.5.6
```

> **Kenapa Hive, bukan sqflite?** sqflite (SQLite) tidak jalan di Chrome. Hive jalan di Chrome (disimpan di IndexedDB) dan di Android, jadi aplikasi bisa didemokan tanpa emulator.

### 3.2 Font (opsional, untuk tampilan)

File font Plus Jakarta Sans disimpan di `assets/fonts/`, lalu didaftarkan di `pubspec.yaml`:

```yaml
flutter:
  uses-material-design: true

  fonts:
    - family: PlusJakartaSans
      fonts:
        - asset: assets/fonts/PlusJakartaSans_400Regular.ttf
          weight: 400
        # ... 500, 600, 700, 800
```

Font disertakan langsung di aplikasi (bukan diunduh saat runtime), jadi tetap tampil walau tidak ada internet.

### 3.3 Izin internet untuk Android

Di `android/app/src/main/AndroidManifest.xml`, tambahkan baris ini **di atas** `<application`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

Tanpa izin ini, aplikasi versi release di Android tidak bisa mengakses API. Di Chrome tidak diperlukan.

---

## 4. Struktur folder

Buat folder di dalam `lib/` seperti ini:

```
lib/
├── main.dart                          ← titik awal aplikasi
└── app/
    ├── data/                          ← LAPISAN DATA
    │   ├── models/
    │   │   ├── character.dart         ← bentuk data karakter
    │   │   └── episode.dart           ← bentuk data episode
    │   ├── providers/
    │   │   ├── api_provider.dart      ← menghubungi API (http)
    │   │   └── db_helper.dart         ← local database akun (Hive)
    │   └── services/
    │       └── session_service.dart   ← sesi & favorit (Shared Preferences)
    ├── modules/                       ← SATU FOLDER PER FITUR (controller + view)
    │   ├── auth/                      ← login, register, logout
    │   ├── main/                      ← halaman utama + bottom nav
    │   ├── home/                      ← daftar karakter
    │   ├── detail/                    ← detail karakter
    │   ├── favorite/                  ← favorit
    │   └── episode/                   ← daftar episode
    ├── routes/
    │   ├── app_routes.dart            ← nama-nama route
    │   └── app_pages.dart             ← daftar halaman + AuthGuard
    ├── theme/
    │   └── app_theme.dart             ← warna, gradasi, ThemeData
    ├── utils/
    │   └── snack.dart                 ← helper Snackbar
    └── widgets/                       ← widget yang dipakai ulang
        ├── glass.dart                 ← komponen kaca (glassmorphism)
        ├── character_widgets.dart     ← kartu karakter, tombol hati
        └── state_views.dart           ← tampilan loading / error / kosong
```

**Urutan pembuatan** mengikuti satu prinsip: buat dulu yang tidak bergantung pada apa pun, baru yang memakainya. Jadi: **model → data → tampilan dasar → routing → main → fitur per halaman**.

---

## 5. Langkah 1: Model data

Model adalah "cetakan" data. Dibuat pertama karena semua file lain memakainya.

### `lib/app/data/models/character.dart`

Contoh JSON satu karakter dari API:

```json
{
  "id": 1,
  "name": "Rick Sanchez",
  "status": "Alive",
  "species": "Human",
  "gender": "Male",
  "origin": { "name": "Earth (C-137)" },
  "location": { "name": "Citadel of Ricks" },
  "image": "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
  "episode": ["https://.../episode/1", "..."]
}
```

Class `Character` punya dua fungsi penting:

```dart
// JSON dari API  →  objek Character
factory Character.fromJson(Map<String, dynamic> json) { ... }

// objek Character  →  JSON (untuk disimpan sebagai favorit)
Map<String, dynamic> toJson() => { ... };
```

Hal yang perlu diperhatikan:

- `origin` dan `location` di API berbentuk objek `{ "name": ... }`, jadi yang diambil adalah `name`-nya.
- `episode` berupa list URL, dan yang kita simpan hanya **jumlahnya** (`episodeCount`).
- Bentuk `toJson()` sengaja dibuat sama dengan JSON API, sehingga `fromJson()` bisa membaca data dari API **dan** dari favorit yang tersimpan.

### `lib/app/data/models/episode.dart`

Lebih sederhana: `id`, `name`, `airDate` (dari `air_date`), dan `code` (dari `episode`, misalnya `S01E01`).

---

## 6. Langkah 2: Menghubungkan API

### `lib/app/data/providers/api_provider.dart`

Ini **satu-satunya file yang menghubungi internet**. Controller tidak pernah memanggil `http` langsung.

| Fungsi | Endpoint | Dipakai untuk |
| --- | --- | --- |
| `getCharacters()` | `GET /character?page=&status=&name=` | Home: daftar, filter, pencarian |
| `getCharacter(id)` | `GET /character/{id}` | Detail Screen |
| `getEpisodes()` | `GET /episode?page=` | Halaman Episode |

#### a. Alamat dasar dan batas waktu

```dart
// Alamat dasar API. Semua endpoint ditambahkan di belakangnya.
static const baseUrl = 'https://rickandmortyapi.com/api';
// Jika server tidak menjawab dalam 15 detik, request dianggap gagal.
static const _timeout = Duration(seconds: 15);
```

#### b. Mengambil daftar karakter (dengan filter dan pencarian)

```dart
Future<PagedResult<Character>> getCharacters({
  int page = 1,
  String status = '',
  String name = '',
}) async {
  final json = await _get('/character', {
    'page': '$page',
    if (status.isNotEmpty) 'status': status,     // ?status=alive
    if (name.trim().isNotEmpty) 'name': name.trim(), // ?name=rick
  });
  return _paged(json, Character.fromJson);
}
```

`if (...)` di dalam map berarti parameter hanya dikirim kalau ada isinya. Jadi:

- tanpa filter → `GET /character?page=1`
- filter Dead → `GET /character?page=1&status=dead`
- cari "rick" → `GET /character?page=1&name=rick`

#### c. Inti request: fungsi `_get()`

```dart
final uri = Uri.parse('$baseUrl$path').replace(queryParameters: ...);
try {
  final response = await _client.get(uri).timeout(_timeout);  // kirim request
  if (response.statusCode == 404) return null;                // data tidak ada
  if (response.statusCode != 200) throw ApiException('Server bermasalah ...');
  return jsonDecode(response.body) as Map<String, dynamic>;   // teks JSON → Map
} on TimeoutException {
  throw const ApiException('Koneksi terlalu lama. Periksa internet kamu.');
} catch (_) {
  throw const ApiException('Gagal terhubung ke server. Periksa koneksi internet kamu.');
}
```

Ini yang memenuhi **soal 6b (error handling)**. Semua jenis kegagalan diubah menjadi `ApiException` berisi pesan bahasa Indonesia, lalu controller cukup menampilkan `e.message` ke layar.

> **Kenapa 404 dikembalikan sebagai `null`, bukan error?** API Rick and Morty membalas 404 jika pencarian atau filter tidak menemukan apa pun (misalnya mencari "zzz"). Itu bukan masalah koneksi, jadi aplikasi menampilkan "Karakter tidak ditemukan", bukan "Gagal memuat data".

#### d. Membaca hasil dan pagination

API mengirim 20 data per halaman, dengan bentuk:

```json
{ "info": { "next": "https://...?page=2", ... }, "results": [ ... ] }
```

Fungsi `_paged()` mengubah setiap item di `results` menjadi objek (lewat `fromJson`). Kalau `info.next` bernilai `null`, berarti itu halaman terakhir (`hasNext = false`).

---

## 7. Langkah 3: Local database (Hive) untuk akun

### `lib/app/data/providers/db_helper.dart`

Menyimpan akun untuk **soal 1 (Login & Register dengan local database)**.

Hive menyimpan data dalam **box** (mirip tabel). Box `users` berisi:

```
key (username)   value
'gevin'      →   { 'username': 'gevin', 'password': '<hash SHA-256>', 'created_at': '...' }
```

```dart
// Membuka box sekali saat aplikasi dimulai
Future<DbHelper> init() async {
  _box = await Hive.openBox<Map>(boxName);
  return this;
}

// Register: false jika username sudah ada
Future<bool> register(String username, String password) async {
  final name = _normalize(username);          // huruf kecil, tanpa spasi pinggir
  if (_box.containsKey(name)) return false;
  await _box.put(name, { 'username': name, 'password': _hash(name, password), ... });
  return true;
}

// Login: cocokkan hash password
Future<bool> login(String username, String password) async {
  final name = _normalize(username);
  final user = _box.get(name);
  return user != null && user['password'] == _hash(name, password);
}
```

Password **tidak disimpan apa adanya**, tapi di-hash dengan SHA-256 (package `crypto`). Jadi walaupun isi database dibuka, password asli tidak terlihat.

---

## 8. Langkah 4: Shared Preferences untuk sesi dan favorit

### `lib/app/data/services/session_service.dart`

Menyimpan data kecil yang harus **tetap ada setelah aplikasi ditutup**:

| Key | Isi | Untuk soal |
| --- | --- | --- |
| `session_username` | Username yang sedang login | 1 (sesi login), 6d (proteksi halaman) |
| `favorites_<username>` | List JSON karakter favorit | 4a (favorit tersimpan) |

```dart
final currentUser = RxnString();          // reaktif: null = belum login
bool get isLoggedIn => currentUser.value != null;

Future<void> saveSession(String username) async {
  await _prefs.setString(_sessionKey, name);   // simpan ke Shared Preferences
  currentUser.value = name;                    // UI yang membaca ikut berubah
}
```

Favorit disimpan sebagai **list string JSON**, karena Shared Preferences hanya bisa menyimpan tipe sederhana (String, int, bool, List\<String\>):

```dart
// simpan: Character → JSON → String
favorites.map((c) => jsonEncode(c.toJson())).toList()
// baca:   String → JSON → Character
Character.fromJson(jsonDecode(e))
```

> **Beda peran Hive dan Shared Preferences:** Hive menyimpan **data akun** (banyak user, ada password). Shared Preferences menyimpan **pengaturan kecil** (siapa yang sedang login, daftar favorit). Soal meminta keduanya, dan masing-masing dipakai sesuai kegunaannya.

---

## 9. Langkah 5: Tema dan komponen tampilan

Dibuat sebelum halaman, supaya semua halaman tinggal memakai komponen yang sama dan tampil konsisten.

| File | Isi |
| --- | --- |
| `theme/app_theme.dart` | `AppColors` (warna pink, ungu, kuning, status), `AppGradients`, `AppRadius`, dan `ThemeData` |
| `widgets/glass.dart` | `GlassScaffold` (latar gradasi), `GlassContainer` (kartu kaca), `GradientButton`, `GradientIcon`, `GlassIconButton`, `GlassDialog` |
| `widgets/state_views.dart` | `LoadingView`, `MessageView` (error/kosong + tombol Coba Lagi), `LoadMoreIndicator` |
| `widgets/character_widgets.dart` | `CharacterGridCard`, `CharacterTile`, `FavoriteButton`, `StatusLabel` |
| `utils/snack.dart` | `showSnack()`: Snackbar yang bisa dipanggil dari controller |

`GlassContainer(blur: true)` memakai `BackdropFilter` (blur sungguhan) yang cukup berat di Chrome. Karena itu blur hanya dipakai di elemen besar yang sedikit (navbar, dialog, panel login). Kartu di list dan grid memakai kaca "ringan" (putih transparan + border), supaya scroll tetap lancar.

---

## 10. Langkah 6: Routing dan proteksi login

### `lib/app/routes/app_routes.dart`

Nama-nama halaman, supaya tidak salah ketik:

```dart
abstract class Routes {
  static const login = '/login';
  static const register = '/register';
  static const main = '/main';
  static const detail = '/detail';
}
```

### `lib/app/routes/app_pages.dart`

Memasangkan route dengan **halaman** dan **controller**-nya:

```dart
GetPage(
  name: Routes.main,
  page: () => const MainView(),
  middlewares: [AuthGuard()],               // ← cek login dulu
  binding: BindingsBuilder(() {             // ← controller dibuat saat halaman dibuka
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => EpisodeController());
    ...
  }),
),
```

**AuthGuard** memenuhi **soal 6d (halaman utama hanya bisa diakses setelah login)**:

```dart
class AuthGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) =>
      Get.find<SessionService>().isLoggedIn
          ? null                                   // sudah login: lanjut
          : const RouteSettings(name: Routes.login); // belum: lempar ke login
}
```

---

## 11. Langkah 7: `main.dart`, menyatukan semuanya

### `lib/main.dart`

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();  // wajib sebelum memakai plugin
  await Hive.initFlutter();                   // siapkan Hive
  await initDependencies();                   // daftarkan service ke GetX
  runApp(const MainApp());
}

Future<void> initDependencies({ApiProvider? api}) async {
  await Get.putAsync(() => SessionService().init(), permanent: true); // baca sesi
  await Get.putAsync(() => DbHelper().init(), permanent: true);       // buka box Hive
  Get.put(api ?? ApiProvider(), permanent: true);                     // koneksi API
  Get.put(FavoriteController(), permanent: true);                     // favorit global
}
```

- `Get.put(...)` mendaftarkan objek, lalu file lain cukup memanggil `Get.find()` untuk mengambilnya.
- `permanent: true` berarti objek hidup selama aplikasi berjalan.
- Sesi harus dibaca **sebelum** `runApp`, karena menentukan halaman pertama: `/main` kalau sudah login, `/login` kalau belum (`AppPages.initial`).

`MainApp` memakai **`GetMaterialApp`** (bukan `MaterialApp`) agar `Get.toNamed`, `Get.back`, dan `Get.dialog` bisa dipakai.

---

## 12. Langkah 8: Login, Register, Logout

| File | Isi |
| --- | --- |
| `modules/auth/auth_controller.dart` | Logika: validasi, `login()`, `register()`, `logout()` |
| `modules/auth/login_view.dart` | Form username + password |
| `modules/auth/register_view.dart` | Form username, password, konfirmasi |
| `modules/auth/auth_widgets.dart` | Kerangka tampilan bersama (logo, judul, panel kaca) |

### Alur login

```dart
Future<void> login(String username, String password) async {
  isLoading.value = true;                       // tombol jadi spinner
  final ok = await _db.login(username, password); // 1. cek ke Hive
  if (!ok) { showErrorSnack('Username atau password salah'); return; }
  await _session.saveSession(username);         // 2. simpan sesi (Shared Preferences)
  Get.offAllNamed(Routes.main);                 // 3. ke halaman utama
}
```

`Get.offAllNamed()` **menghapus semua halaman sebelumnya**, jadi setelah login pengguna tidak bisa menekan "back" untuk kembali ke halaman login.

### Logout

```dart
Future<void> logout() async {
  await _session.clearSession();   // hapus sesi
  Get.offAllNamed(Routes.login);   // kembali ke login
}
```

Tombol logout ada di pojok kanan atas halaman utama (`main_view.dart`), dengan dialog konfirmasi.

---

## 13. Langkah 9: Favorit (dipakai semua halaman)

### `lib/app/modules/favorite/favorite_controller.dart`

Dibuat **sebelum** Home, Detail, dan Favorite Screen, karena ketiganya memakainya.

**Kunci soal 6c (favorit langsung diperbarui di Home dan Favorite Screen):** hanya ada **satu** `FavoriteController` untuk seluruh aplikasi (didaftarkan `permanent` di `main.dart`). Semua halaman membaca list yang sama:

```dart
final favorites = <Character>[].obs;   // satu list reaktif untuk semua halaman

void toggle(Character character) {
  if (isFavorite(character.id)) {
    favorites.removeWhere((c) => c.id == character.id);
    showSnack('${character.name} dihapus dari favorit');      // soal 3c
  } else {
    favorites.add(character);
    showSnack('${character.name} ditambahkan ke favorit');    // soal 3c
  }
  _session.writeFavorites(favorites);   // simpan ke Shared Preferences (soal 4a)
}
```

Karena `favorites` adalah `.obs`, setiap widget yang dibungkus `Obx` dan membaca `favorites` (tombol hati di Home, tombol di Detail, list di Favorite Screen, badge di navbar) **menggambar ulang sendiri** saat list berubah.

Tombol hati (`widgets/character_widgets.dart`):

```dart
return Obx(() {
  final isFav = favorites.isFavorite(character.id);
  return Icon(isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded); // soal 3d
});
```

---

## 14. Langkah 10: Home Screen

| File | Isi |
| --- | --- |
| `modules/home/home_controller.dart` | Ambil data, filter, pencarian, pagination |
| `modules/home/home_view.dart` | Kolom cari, chip filter, grid kartu |

### State di controller

```dart
final characters = <Character>[].obs;   // data yang tampil
final isLoading = true.obs;             // soal 6b: loading state
final errorMessage = RxnString();       // soal 6b: pesan error
final selectedStatuses = <String>{}.obs; // filter aktif (kosong = All)
final query = ''.obs;                   // kata kunci pencarian
```

### Menampilkan sesuai state (`home_view.dart`)

```dart
Widget _buildBody() {
  if (controller.isLoading.value) return const LoadingView(...);       // loading
  if (error != null) return MessageView(..., onRetry: controller.fetch); // error + Coba Lagi
  if (controller.characters.isEmpty) return const MessageView(...);    // kosong
  return CustomScrollView(... SliverGrid ...);                         // data
}
```

Seluruh bagian ini dibungkus `Obx(_buildBody)`, jadi otomatis berganti tampilan saat `isLoading`, `errorMessage`, atau `characters` berubah.

### Filter status (soal 2b), bisa lebih dari satu

```dart
void toggleStatus(String status) {
  if (selectedStatuses.contains(status)) {
    selectedStatuses.remove(status);          // tap chip aktif (ada ×) = lepas
  } else {
    selectedStatuses.add(status);
    if (selectedStatuses.length == statusFilters.length) {
      selectedStatuses.clear();               // ketiganya dipilih = sama dengan All
    }
  }
  fetch();
}
```

API hanya menerima **satu** status per request. Untuk Alive + Dead, aplikasi memanggil `?status=alive` dan `?status=dead` **bersamaan** dengan `Future.wait`, lalu hasilnya digabung dan diurutkan berdasarkan id (fungsi `_loadBatch`).

### Pencarian nama (bonus 1)

```dart
debounce(query, (_) => fetch(), time: const Duration(milliseconds: 500));
```

`debounce` menunggu pengguna **berhenti mengetik 500 ms** sebelum memanggil API. Tanpa ini, mengetik "rick" mengirim 4 request.

### Infinite scroll

`scrollController` memantau posisi scroll. Saat mendekati bawah (300 px dari akhir), `loadMore()` mengambil halaman berikutnya dan **menambahkannya** ke `characters`.

### Ke Detail (soal 2c)

Di `CharacterGridCard`:

```dart
onTap: () => Get.toNamed(Routes.detail, arguments: character),
```

---

## 15. Langkah 11: Detail Screen

| File | Isi |
| --- | --- |
| `modules/detail/detail_controller.dart` | Terima karakter dari Home, ambil data terbaru dari API |
| `modules/detail/detail_view.dart` | Foto, nama, identitas, tombol favorit |

```dart
@override
void onInit() {
  super.onInit();
  final args = Get.arguments;          // karakter yang dikirim dari Home
  if (args is Character) {
    character.value = args;            // langsung tampil, tanpa menunggu
    _id = args.id;
  }
  fetch();                             // lalu GET /character/{id}
}
```

Data dari Home langsung ditampilkan, jadi pengguna tidak melihat layar kosong. Setelah itu data terbaru diambil dari endpoint `/character/{id}` sesuai soal.

**Soal 3a** dipenuhi oleh tampilan: foto, nama, status (pill), lalu kartu Status, Spesies, Gender, Episode, Origin, dan Location.

**Soal 3b–3d** dipenuhi oleh `_FavoriteAction`: tombolnya memanggil `favorites.toggle()`, Snackbar muncul dari controller, dan ikon serta teksnya berubah lewat `Obx`.

---

## 16. Langkah 12: Favorite Screen

### `lib/app/modules/favorite/favorite_view.dart`

```dart
if (controller.favorites.isEmpty) {
  return const MessageView(title: 'Belum ada karakter favorit', ...);   // soal 4d
}
...
return Dismissible(                                                     // soal 4b: swipe
  key: ValueKey('favorite_${character.id}'),
  direction: DismissDirection.endToStart,                               // geser ke kiri
  onDismissed: (_) => controller.removeBySwipe(character),              // hapus + Snackbar (4c)
  child: CharacterTile(character: character),
);
```

`removeBySwipe()` menghapus dari list, menyimpan ke Shared Preferences, dan menampilkan Snackbar dengan tombol **BATAL** untuk mengembalikan karakter yang terhapus.

---

## 17. Langkah 13: Halaman Episode

| File | Isi |
| --- | --- |
| `modules/episode/episode_controller.dart` | `GET /episode` + pagination (pola sama dengan Home) |
| `modules/episode/episode_view.dart` | Kartu berisi kode episode, nama, dan air_date (soal 5) |

---

## 18. Langkah 14: Bottom Navigation Bar

### `lib/app/modules/main/main_view.dart`

```dart
class MainController extends GetxController {
  final tabIndex = 0.obs;               // tab yang aktif
}

body: IndexedStack(
  index: controller.tabIndex.value,
  children: const [HomeView(), FavoriteView(), EpisodeView()],
),
bottomNavigationBar: _FloatingNavBar(
  index: controller.tabIndex.value,
  onSelected: (i) => controller.tabIndex.value = i,   // soal 6a
),
```

`IndexedStack` menjaga ketiga tab tetap hidup, jadi posisi scroll di Home tidak hilang saat pindah ke Favorites lalu kembali.

---

## 19. Peta soal ke file

| No | Ketentuan soal | File utama |
| --- | --- | --- |
| 1 | Login & Register, Shared Preferences + local database, logout | `auth/auth_controller.dart`, `data/providers/db_helper.dart`, `data/services/session_service.dart`, `main/main_view.dart` |
| 2a | List karakter (foto, nama, status) + tombol favorit | `home/home_view.dart`, `widgets/character_widgets.dart` |
| 2b | Filter Alive / Dead / Unknown | `home/home_controller.dart` (`toggleStatus`), `data/providers/api_provider.dart` |
| 2c | Pilih karakter → Detail | `widgets/character_widgets.dart` (`Get.toNamed`) |
| 3a | Foto, nama, status, spesies, gender, origin, location | `detail/detail_view.dart` |
| 3b–3d | Tombol favorit, Snackbar, ikon berubah | `detail/detail_view.dart` (`_FavoriteAction`), `favorite/favorite_controller.dart` |
| 4a | Favorit disimpan di Shared Preferences | `data/services/session_service.dart` (`writeFavorites`) |
| 4b–4c | Hapus dengan swipe + Snackbar | `favorite/favorite_view.dart` (`Dismissible`), `favorite_controller.dart` (`removeBySwipe`) |
| 4d | Pesan jika favorit kosong | `favorite/favorite_view.dart` |
| 5 | List episode (nama, air_date) | `episode/episode_controller.dart`, `episode/episode_view.dart` |
| 6a | Bottom Navigation Bar | `main/main_view.dart` |
| 6b | Loading state + error handling | `data/providers/api_provider.dart` (`ApiException`), `widgets/state_views.dart` |
| 6c | Favorit langsung sinkron di semua halaman | `favorite/favorite_controller.dart` (satu instance global + `.obs`) |
| 6d | Halaman utama hanya setelah login | `routes/app_pages.dart` (`AuthGuard`) |
| Bonus 1 | Pencarian nama | `home/home_controller.dart` (`debounce`), `api_provider.dart` (`?name=`) |
| Bonus 2 | Desain menarik dan konsisten | `theme/app_theme.dart`, `widgets/glass.dart` |

---

## 20. Menjalankan dan mengetes

Ambil package:

```bash
flutter pub get
```

Jalankan di Chrome:

```bash
flutter run -d chrome
```

Saat aplikasi berjalan, tekan `r` di terminal untuk **hot reload** setelah mengubah tampilan, atau `R` untuk **hot restart** setelah mengubah controller atau `main.dart`.

Jalankan tes otomatis:

```bash
flutter test
```

`test/app_flow_test.dart` menjalankan alur lengkap dengan API tiruan: register, login salah, username ganda, filter (termasuk filter ganda), pencarian, favorit dari Home dan Detail, swipe, logout, data tetap ada setelah aplikasi dibuka ulang, dan tampilan error saat API gagal.

> **Catatan Chrome:** data Hive dan Shared Preferences disimpan di browser. Kalau `flutter run -d chrome` membuka profil browser baru, akun yang sudah didaftarkan bisa hilang. Daftar ulang sebelum demo.

---

## 21. Pertanyaan yang mungkin ditanya saat responsi

**Kenapa favorit di Home langsung berubah saat diubah di Detail?**
Karena hanya ada satu `FavoriteController` (dibuat `permanent` di `main.dart`) dan list `favorites`-nya bertipe `.obs`. Semua widget yang membacanya dibungkus `Obx`, jadi ikut menggambar ulang saat list berubah.

**Apa beda Hive dan Shared Preferences di aplikasi ini?**
Hive adalah local database untuk akun (banyak user, password di-hash). Shared Preferences menyimpan data kecil: siapa yang sedang login dan daftar favorit.

**Bagaimana halaman utama diproteksi?**
`AuthGuard` di `app_pages.dart` mengecek `SessionService.isLoggedIn` sebelum halaman `/main` dan `/detail` dibuka. Kalau belum login, pengguna dialihkan ke `/login`.

**Bagaimana kalau internet mati?**
`ApiProvider` menangkap error (tidak ada koneksi, timeout, server error) dan mengubahnya menjadi `ApiException`. Controller menyimpan pesannya di `errorMessage`, lalu halaman menampilkan `MessageView` dengan tombol **Coba Lagi**.

**Kenapa memakai `Get.offAllNamed` saat login dan logout?**
Supaya riwayat halaman dihapus: setelah login tidak bisa "back" ke halaman login, dan setelah logout tidak bisa "back" ke halaman utama.

**Bagaimana filter Alive + Dead bekerja padahal API hanya menerima satu status?**
Aplikasi mengirim dua request (`?status=alive` dan `?status=dead`) bersamaan dengan `Future.wait`, lalu menggabungkan dan mengurutkan hasilnya.

**Apa gunanya `debounce` di pencarian?**
Menunggu pengguna berhenti mengetik 500 ms sebelum memanggil API, supaya tidak mengirim request di setiap huruf.

**Kenapa password di-hash?**
Supaya password asli tidak tersimpan di perangkat. Saat login, password yang diketik di-hash dengan cara yang sama lalu dibandingkan hasilnya.
