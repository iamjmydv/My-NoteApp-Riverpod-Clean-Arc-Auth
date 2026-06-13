import 'package:flutter/material.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/common/common_loader.dart';

/// The app's primary call-to-action button: a themed [FilledButton] that shows
/// an inline spinner — and disables itself — while [isLoading] is true. Used for
/// the submit actions on the auth, note and profile screens. Pass [style] to
/// override the themed defaults (e.g. a destructive "Log out" button).
class CommonPrimaryButton extends StatelessWidget {
  const CommonPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.style,
    this.spinnerColor = Colors.white,
    this.spinnerSize = 20,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonStyle? style;
  final Color? spinnerColor;
  final double spinnerSize;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: style,
      child: isLoading
          ? CommonLoader(size: spinnerSize, color: spinnerColor)
          : Text(label),
    );
  }
}
