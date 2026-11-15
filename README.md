# Rick & Morty Character Explorer

Latihan responsi mobile — Flutter + Dart dengan GetX (state management, routing, dependency injection).

## Menjalankan

```bash
flutter pub get
flutter run
```

Bisa dijalankan di Chrome (`flutter run -d chrome`) maupun di Android/iOS.

## Fitur

| Soal | Implementasi |
| --- | --- |
| Login & Register | Akun disimpan di Hive (password di-hash SHA-256); sesi login disimpan di Shared Preferences |
| Logout | Tombol di AppBar, kembali ke halaman login dan menghapus sesi |
| Home | List karakter (foto, nama, status), tombol favorit, filter All/Alive/Dead/Unknown, infinite scroll, pull-to-refresh |
| Detail | Foto, nama, status, spesies, gender, origin, location; tombol favorit dengan ikon yang berubah + Snackbar |
| Favorite | Disimpan di Shared Preferences (per akun), hapus dengan swipe + Snackbar (bisa dibatalkan), pesan saat kosong |
| Episode | List episode (nama, air_date, kode episode) |
| Ketentuan tambahan | Bottom Navigation Bar, loading state, error handling + tombol Coba Lagi, favorit reaktif antar halaman, route guard |
| Bonus | Pencarian karakter berdasarkan nama (debounce 500 ms), desain glassmorphism pink–ungu–kuning yang konsisten |

## Struktur

```
lib/
├── main.dart                      # inisialisasi dependency + GetMaterialApp
└── app/
    ├── data/
    │   ├── models/                # Character, Episode
    │   ├── providers/             # ApiProvider (http), DbHelper (Hive)
    │   └── services/              # SessionService (Shared Preferences)
    ├── modules/
    │   ├── auth/                  # login, register, AuthController
    │   ├── main/                  # Bottom Navigation Bar
    │   ├── home/                  # list + filter + pencarian
    │   ├── detail/
    │   ├── favorite/              # FavoriteController (sumber data favorit global)
    │   └── episode/
    ├── routes/                    # nama route, GetPage, AuthGuard middleware
    ├── theme/                     # warna, gradasi, radius, ThemeData
    ├── utils/                     # helper Snackbar
    └── widgets/                   # widget yang dipakai ulang (glass.dart = komponen kaca)
```

## Tes

```bash
flutter test
```

`test/app_flow_test.dart` menjalankan alur lengkap aplikasi dengan API tiruan dan Hive sungguhan.

## Desain

Tema glassmorphism terang: latar gradasi lavender → pink → peach dengan blob warna lembut, kartu kaca putih transparan, aksen gradasi pink → ungu dan kuning → pink, font Plus Jakarta Sans (dibundel di `assets/fonts`, lisensi OFL).

Blur sungguhan (`BackdropFilter`) hanya dipakai di elemen besar yang sedikit (navbar, dialog, panel login, panel info detail). Kartu di list/grid memakai kaca ringan tanpa blur agar scroll tetap lancar di Chrome.
