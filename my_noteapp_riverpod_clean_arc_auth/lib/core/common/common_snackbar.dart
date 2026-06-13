import 'package:flutter/material.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/theme/app_theme.dart';

/// Helpers for the success / error / info snackbars shown after auth, note and
/// profile actions. Keeps the styling (background color, white text, leading
/// icon) consistent everywhere and always replaces the current snackbar.
class CommonSnackBar {
  CommonSnackBar._();

  static void showSuccess(BuildContext context, String message) => _show(
    context,
    message: message,
    backgroundColor: AppColors.success,
    icon: Icons.check_circle,
  );

  static void showError(BuildContext context, String message) => _show(
    context,
    message: message,
    backgroundColor: AppColors.error,
    icon: Icons.error_outline,
  );

  static void showInfo(BuildContext context, String message) =>
      _show(context, message: message);

  static void _show(
    BuildContext context, {
    required String message,
    Color? backgroundColor,
    IconData? icon,
  }) {
    final onColor = backgroundColor != null;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: backgroundColor,
          content: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  message,
                  style: onColor ? const TextStyle(color: Colors.white) : null,
                ),
              ),
            ],
          ),
        ),
      );
  }
}
