import 'package:flutter/material.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/theme/app_theme.dart';

/// A circular avatar that shows a user's initial(s) over a soft brand tint.
/// Used in the app bar, drawer header and profile screens.
class CommonAvatar extends StatelessWidget {
  const CommonAvatar({
    super.key,
    required this.text,
    this.radius = 24,
    this.backgroundColor = AppColors.primarySoft,
    this.foregroundColor = AppColors.primary,
    this.textStyle,
  });

  final String text;
  final double radius;
  final Color backgroundColor;
  final Color foregroundColor;
  final TextStyle? textStyle;

  /// Builds initials from a [first]/[last] name pair, e.g. "Jane Doe" -> "JD".
  /// Returns "?" when both are empty.
  static String initialsFrom(String first, String last) {
    final f = first.isNotEmpty ? first[0] : '';
    final l = last.isNotEmpty ? last[0] : '';
    final combined = '$f$l'.toUpperCase();
    return combined.isEmpty ? '?' : combined;
  }

  /// First letter of [value] uppercased, or "?" when empty (handy for emails).
  static String initialOf(String value) =>
      value.isNotEmpty ? value[0].toUpperCase() : '?';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: Text(
        text,
        style:
            textStyle ??
            theme.textTheme.titleMedium?.copyWith(color: foregroundColor),
      ),
    );
  }
}
