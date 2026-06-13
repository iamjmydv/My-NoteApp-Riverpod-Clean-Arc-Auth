import 'package:flutter/material.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/theme/app_theme.dart';

/// A white, rounded, bordered container used to group related content — such as
/// the profile details rows. Pass [padding] to inset the [child]; leave it null
/// when the child manages its own padding (e.g. a column of `CommonInfoRow`s).
class CommonSectionCard extends StatelessWidget {
  const CommonSectionCard({
    super.key,
    required this.child,
    this.padding,
    this.color = AppColors.background,
    this.borderRadius = 16,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color color;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}
