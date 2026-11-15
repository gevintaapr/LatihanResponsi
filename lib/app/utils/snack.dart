import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Key global supaya Snackbar bisa dipanggil dari controller (tanpa context).
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void showSnack(
  String message, {
  IconData icon = Icons.info_outline,
  Color iconColor = AppColors.yellow,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final messenger = scaffoldMessengerKey.currentState;
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        action: actionLabel == null
            ? null
            : SnackBarAction(label: actionLabel, onPressed: onAction ?? () {}),
      ),
    );
}

void showErrorSnack(String message) =>
    showSnack(message, icon: Icons.error_outline, iconColor: AppColors.dead);
