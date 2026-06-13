import 'package:flutter/material.dart';

/// A label/value row used in the read-only profile details card. Set
/// [monospace] to render the value in a monospace font (e.g. for IDs). Pair
/// with `CommonSectionCard` and `Divider`s to build a settings-style list.
class CommonInfoRow extends StatelessWidget {
  const CommonInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.monospace = false,
  });

  final String label;
  final String value;
  final bool monospace;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: theme.textTheme.titleSmall?.copyWith(
                fontFamily: monospace ? 'monospace' : null,
                fontWeight: monospace ? FontWeight.w500 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
