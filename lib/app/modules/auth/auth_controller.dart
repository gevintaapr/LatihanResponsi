// ====================================================================
// FILE    : lib/app/modules/auth/auth_controller.dart
// LAPISAN : Logika / Login, Register, Logout
//
// GUNANYA :
//   Validasi input, memanggil DbHelper (Hive) untuk cek/simpan akun, lalu
//   menyimpan sesi ke Shared Preferences lewat SessionService.
//   Get.offAllNamed() menghapus semua halaman sebelumnya, jadi setelah login
//   pengguna tidak bisa 'back' ke halaman login, dan sebaliknya saat logout.
//
// DIPAKAI OLEH: LoginView, RegisterView, MainView (tombol logout).
// ====================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/providers/db_helper.dart';
import '../../data/services/session_service.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../utils/snack.dart';

class AuthController extends GetxController {
  // Get.find() mengambil objek yang sudah didaftarkan di main.dart.
  final DbHelper _db = Get.find(); // akun (Hive)
  final SessionService _session = Get.find(); // sesi (Shared Preferences)

  // .obs = variabel reaktif. UI yang dibungkus Obx ikut berubah otomatis.
  final isLoading = false.obs; // true saat proses login/register berjalan
  final obscurePassword = true.obs; // sembunyikan / tampilkan password

  String? validateUsername(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Username wajib diisi';
    if (v.length < 3) return 'Username minimal 3 karakter';
    if (v.contains(' ')) return 'Username tidak boleh mengandung spasi';
    return null;
  }

  String? validatePassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Password wajib diisi';
    if (v.length < 6) return 'Password minimal 6 karakter';
    return null;
  }

  Future<void> login(String username, String password) async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      // 1. Cek username & password ke local database (Hive).
      final ok = await _db.login(username, password);
      if (!ok) {
        showErrorSnack('Username atau password salah');
        return;
      }
      // 2. Simpan sesi ke Shared Preferences agar tetap login saat app dibuka lagi.
      await _session.saveSession(username);
      // 3. Pindah ke halaman utama dan hapus riwayat halaman login.
      Get.offAllNamed(Routes.main);
    } catch (_) {
      showErrorSnack('Terjadi kesalahan pada database lokal');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(String username, String password) async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      // Simpan akun baru ke Hive; false jika username sudah dipakai.
      final ok = await _db.register(username, password);
      if (!ok) {
        showErrorSnack('Username sudah terdaftar, gunakan yang lain');
        return;
      }
      // Kembali ke halaman login sambil mengirim username yang baru dibuat.
      Get.back(result: username.trim());
      showSnack(
        'Registrasi berhasil, silakan login',
        icon: Icons.check_circle_outline,
        iconColor: AppColors.alive,
      );
    } catch (_) {
      showErrorSnack('Terjadi kesalahan pada database lokal');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    // Hapus sesi, lalu kembali ke login tanpa bisa 'back' ke halaman utama.
    await _session.clearSession();
    Get.offAllNamed(Routes.login);
  }
}
