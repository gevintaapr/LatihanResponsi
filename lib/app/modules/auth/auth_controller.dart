import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/providers/db_helper.dart';
import '../../data/services/session_service.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../utils/snack.dart';

class AuthController extends GetxController {
  final DbHelper _db = Get.find();
  final SessionService _session = Get.find();

  final isLoading = false.obs;
  final obscurePassword = true.obs;

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
      final ok = await _db.login(username, password);
      if (!ok) {
        showErrorSnack('Username atau password salah');
        return;
      }
      await _session.saveSession(username);
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
      final ok = await _db.register(username, password);
      if (!ok) {
        showErrorSnack('Username sudah terdaftar, gunakan yang lain');
        return;
      }
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
    await _session.clearSession();
    Get.offAllNamed(Routes.login);
  }
}
