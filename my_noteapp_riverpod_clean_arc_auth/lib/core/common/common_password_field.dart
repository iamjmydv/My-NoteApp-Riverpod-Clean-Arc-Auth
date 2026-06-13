import 'package:flutter/material.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/theme/app_theme.dart';

/// A password [TextFormField] with a built-in show/hide visibility toggle.
/// Used on the login and sign up screens. It manages its own obscure state so
/// callers no longer need a local `bool _obscurePassword` + `setState`.
class CommonPasswordField extends StatefulWidget {
  const CommonPasswordField({
    super.key,
    this.controller,
    this.label = 'Password',
    this.hint,
    this.enabled = true,
    this.readOnly = false,
    this.canRequestFocus = true,
    this.textInputAction = TextInputAction.done,
    this.validator,
    this.onFieldSubmitted,
    this.focusNode,
  });

  final TextEditingController? controller;
  final String label;
  final String? hint;
  final bool enabled;
  final bool readOnly;
  final bool canRequestFocus;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final FocusNode? focusNode;

  @override
  State<CommonPasswordField> createState() => _CommonPasswordFieldState();
}

class _CommonPasswordFieldState extends State<CommonPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.readOnly || !widget.enabled;
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      canRequestFocus: widget.canRequestFocus,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      onFieldSubmitted: widget.onFieldSubmitted,
      focusNode: widget.focusNode,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        suffixIcon: IconButton(
          icon: Icon(
            _obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: AppColors.inkSub,
          ),
          onPressed: disabled
              ? null
              : () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}
