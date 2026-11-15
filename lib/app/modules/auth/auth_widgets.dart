// ====================================================================
// FILE    : lib/app/modules/auth/auth_widgets.dart
// LAPISAN : Tampilan / Kerangka halaman Login & Register
//
// GUNANYA :
//   AuthScaffold: logo, judul, dan panel kaca berisi form. Dipakai bersama
//   agar halaman Login dan Register tampil seragam.
//
// DIPAKAI OLEH: LoginView, RegisterView.
// ====================================================================

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/glass.dart';

/// Kerangka bersama halaman Login dan Register supaya tampilannya konsisten.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.showBack = false,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: showBack
          ? AppBar(
              automaticallyImplyLeading: false,
              leading: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Center(
                  child: GlassIconButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'Kembali',
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
              ),
            )
          : null,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                    child: GradientIcon(icon: Icons.blur_on_rounded, size: 68),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 22),
                  GlassContainer(
                    blur: true,
                    radius: AppRadius.lg,
                    padding: const EdgeInsets.all(18),
                    child: child,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
