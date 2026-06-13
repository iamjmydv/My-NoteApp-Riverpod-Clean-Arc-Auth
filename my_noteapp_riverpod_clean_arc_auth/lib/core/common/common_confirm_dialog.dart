import 'package:flutter/material.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/theme/app_theme.dart';

/// A reusable yes/no confirmation dialog. Resolves to `true` when the user
/// confirms and `false` (the default) when they cancel or dismiss it. Set
/// [isDestructive] to style the confirm button as a danger action — used for
/// note deletion.
class CommonConfirmDialog {
  CommonConfirmDialog._();

  static Future<bool> show(
    BuildContext context, {
    required String title,
    String? message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title),
        content: message == null ? null : Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(cancelText),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: isDestructive
                ? FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                    minimumSize: const Size(88, 44),
                  )
                : FilledButton.styleFrom(minimumSize: const Size(88, 44)),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
