import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/theme/app_theme.dart';

/// Inline text ending in a tappable link, e.g.
/// "Don't have an account?  Sign up". Used to switch between the login and
/// sign-up screens. It owns and disposes its own [TapGestureRecognizer], so
/// callers only provide an [onTap] callback.
class CommonRichLinkText extends StatefulWidget {
  const CommonRichLinkText({
    super.key,
    required this.text,
    required this.linkText,
    required this.onTap,
    this.textAlign = TextAlign.center,
  });

  /// Leading, non-interactive copy.
  final String text;

  /// The trailing, tappable portion.
  final String linkText;
  final VoidCallback onTap;
  final TextAlign textAlign;

  @override
  State<CommonRichLinkText> createState() => _CommonRichLinkTextState();
}

class _CommonRichLinkTextState extends State<CommonRichLinkText> {
  late final TapGestureRecognizer _recognizer;

  @override
  void initState() {
    super.initState();
    _recognizer = TapGestureRecognizer()..onTap = widget.onTap;
  }

  @override
  void didUpdateWidget(CommonRichLinkText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onTap != widget.onTap) {
      _recognizer.onTap = widget.onTap;
    }
  }

  @override
  void dispose() {
    _recognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text.rich(
      TextSpan(
        text: widget.text,
        style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.inkSub),
        children: [
          TextSpan(
            text: widget.linkText,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
            recognizer: _recognizer,
          ),
        ],
      ),
      textAlign: widget.textAlign,
    );
  }
}
