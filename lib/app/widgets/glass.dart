import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Latar gradasi pastel dengan "blob" warna lembut seperti referensi.
///
/// Blob dibuat dengan RadialGradient (bukan blur), jadi sangat ringan.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppGradients.background),
      child: Stack(
        children: [
          const _Blob(
            alignment: Alignment(-1.3, -0.95),
            color: AppColors.purple,
            size: 340,
          ),
          const _Blob(
            alignment: Alignment(1.4, -0.2),
            color: AppColors.pink,
            size: 320,
          ),
          const _Blob(
            alignment: Alignment(-1.2, 1.1),
            color: AppColors.yellow,
            size: 300,
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({
    required this.alignment,
    required this.color,
    required this.size,
  });

  final Alignment alignment;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: 0.38),
                color.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Scaffold yang sudah memakai [AppBackground]. Dipakai semua halaman
/// supaya latarnya konsisten.
class GlassScaffold extends StatelessWidget {
  const GlassScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.extendBody = false,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool extendBody;

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar,
        extendBody: extendBody,
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        body: body,
      ),
    );
  }
}

/// Permukaan kaca.
///
/// - `blur: false` (default): kaca "ringan" dari putih transparan + border +
///   bayangan. Dipakai untuk kartu di list/grid agar scroll tetap lancar.
/// - `blur: true`: kaca sungguhan dengan [BackdropFilter]. Hanya dipakai untuk
///   elemen besar yang jumlahnya sedikit (navbar, dialog, panel login/detail).
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.blur = false,
    this.radius = AppRadius.md,
    this.padding,
    this.color,
    this.onTap,
  });

  final Widget child;
  final bool blur;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    Widget content = Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        splashColor: AppColors.purple.withValues(alpha: 0.08),
        highlightColor: AppColors.purple.withValues(alpha: 0.04),
        child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
      ),
    );

    content = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(color: AppColors.glassBorder, width: 1.2),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color ?? (blur ? const Color(0x99FFFFFF) : AppColors.glassStrong),
            (color ?? AppColors.glass).withValues(alpha: blur ? 0.35 : 0.5),
          ],
        ),
      ),
      child: content,
    );

    if (blur) {
      content = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: content,
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(borderRadius: borderRadius, child: content),
    );
  }
}

/// Tombol bulat kaca kecil (kembali, logout, dsb).
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size = 40,
    this.iconColor = AppColors.text,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final double size;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      width: size,
      height: size,
      child: GlassContainer(
        radius: size / 2,
        onTap: onPressed,
        child: Center(
          child: Icon(icon, color: iconColor, size: size * 0.48),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

/// Tombol utama bergradasi pink → ungu.
///
/// Tetap memakai [FilledButton] di dalamnya supaya perilaku (disable, fokus,
/// aksesibilitas) sama dengan tombol Material biasa.
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(AppRadius.sm + 4);
    final enabled = onPressed != null && !loading;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: AppGradients.primary,
        boxShadow: [
          BoxShadow(
            color: AppColors.pink.withValues(alpha: enabled ? 0.35 : 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FilledButton(
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.white.withValues(alpha: 0.25),
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white,
          shadowColor: Colors.transparent,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          textStyle: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(label),
                ],
              ),
      ),
    );
  }
}

/// Lingkaran bergradasi berisi ikon, seperti ikon menu di referensi.
class GradientIcon extends StatelessWidget {
  const GradientIcon({
    super.key,
    required this.icon,
    this.size = 56,
    this.gradient = AppGradients.primary,
  });

  final IconData icon;
  final double size;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(size * 0.32),
        boxShadow: [
          BoxShadow(
            color: AppColors.pink.withValues(alpha: 0.3),
            blurRadius: size * 0.4,
            offset: Offset(0, size * 0.12),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.5),
    );
  }
}

/// Dialog konfirmasi berlatar kaca blur.
class GlassDialog extends StatelessWidget {
  const GlassDialog({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.actions,
  });

  final IconData icon;
  final String title;
  final String message;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: GlassContainer(
        blur: true,
        radius: AppRadius.lg,
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GradientIcon(icon: icon, size: 52),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                for (var i = 0; i < actions.length; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  Expanded(child: actions[i]),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
