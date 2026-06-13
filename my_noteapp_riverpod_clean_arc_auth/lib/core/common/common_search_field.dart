import 'package:flutter/material.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/theme/app_theme.dart';

/// A search input with a leading magnifier icon and an optional trailing clear
/// button. Used on the notes homepage. Set [showClear] to reveal the clear
/// button and handle the tap via [onClear].
class CommonSearchField extends StatelessWidget {
  const CommonSearchField({
    super.key,
    this.controller,
    this.hint = 'Search',
    this.onChanged,
    this.onClear,
    this.showClear = false,
  });

  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final bool showClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search, color: AppColors.inkFaint),
        suffixIcon: showClear
            ? IconButton(
                icon: const Icon(Icons.close, color: AppColors.inkFaint),
                onPressed: onClear,
              )
            : null,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }
}
