import 'package:flutter/material.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/theme/app_theme.dart';

/// A small form-field caption shown above inputs (e.g. on the edit-profile
/// screen). Uses the muted "ink sub" color for a quiet, secondary look.
class CommonLabel extends StatelessWidget {
  const CommonLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.labelMedium?.copyWith(color: AppColors.inkSub),
    );
  }
}
