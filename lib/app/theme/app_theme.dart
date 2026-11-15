import 'package:flutter/material.dart';

/// Palet warna tema glassmorphism (pink, ungu, kuning di atas latar pastel).
class AppColors {
  // Latar
  static const bgTop = Color(0xFFEDE4FF); // lavender
  static const bgMiddle = Color(0xFFFCE4F1); // pink muda
  static const bgBottom = Color(0xFFFFEBDC); // peach

  // Warna utama
  static const purple = Color(0xFF8B5CF6);
  static const pink = Color(0xFFEC4899);
  static const yellow = Color(0xFFFBBF24);
  static const peach = Color(0xFFFB923C);

  // Teks
  static const text = Color(0xFF2D1B4E); // ungu tua
  static const textMuted = Color(0xFF7C6F99);

  // Kaca
  static const glass = Color(0x8CFFFFFF); // putih 55%
  static const glassStrong = Color(0xBFFFFFFF); // putih 75%
  static const glassBorder = Color(0xB3FFFFFF); // putih 70%
  static const shadow = Color(0x1A6D28D9); // bayangan ungu tipis

  // Status (versi pastel agar serasi, tapi artinya tetap mudah dibaca)
  static const alive = Color(0xFF22B07D);
  static const dead = Color(0xFFF0506E);
  static const unknown = Color(0xFF9A93AD);

  static const favorite = Color(0xFFFF4D8D);

  static Color status(String status) {
    switch (status.toLowerCase()) {
      case 'alive':
        return alive;
      case 'dead':
        return dead;
      default:
        return unknown;
    }
  }
}

/// Gradasi yang dipakai berulang di seluruh aplikasi.
class AppGradients {
  /// Gradasi utama: tombol, chip aktif, ikon navbar aktif.
  static const primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.pink, AppColors.purple],
  );

  /// Gradasi aksen hangat: badge episode, sorotan kecil.
  static const warm = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.yellow, AppColors.pink],
  );

  static const background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.bgTop, AppColors.bgMiddle, AppColors.bgBottom],
    stops: [0, 0.55, 1],
  );
}

/// Ukuran sudut yang konsisten.
class AppRadius {
  static const sm = 14.0;
  static const md = 20.0;
  static const lg = 28.0;
}

class AppTheme {
  static const fontFamily = 'PlusJakartaSans';

  static ThemeData get light {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.purple,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.purple,
          onPrimary: Colors.white,
          secondary: AppColors.pink,
          tertiary: AppColors.yellow,
          surface: Colors.white,
          onSurface: AppColors.text,
          error: AppColors.dead,
        );
    final radius = BorderRadius.circular(AppRadius.sm + 2);
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      colorScheme: scheme,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bgMiddle,
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
      ),
      iconTheme: const IconThemeData(color: AppColors.text),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.text,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: AppColors.text,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.glassStrong,
        hintStyle: const TextStyle(color: AppColors.textMuted),
        prefixIconColor: AppColors.textMuted,
        suffixIconColor: AppColors.textMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: AppColors.purple, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: AppColors.dead),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: AppColors.dead, width: 1.5),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.purple,
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.purple,
        linearTrackColor: Colors.transparent,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.text.withValues(alpha: 0.92),
        contentTextStyle: const TextStyle(
          fontFamily: fontFamily,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        actionTextColor: AppColors.yellow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm + 2),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
    );
  }
}
