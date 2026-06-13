import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A configurable [TextFormField] wrapper used across the app's forms
/// (login, sign up, note editing, profile editing). Centralizing it keeps the
/// field styling and behavior consistent, mirroring the configurable approach
/// of `CommonButton`.
class CommonTextField extends StatelessWidget {
  const CommonTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.label,
    this.hint,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.canRequestFocus = true,
    this.autofocus = false,
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.style,
    this.focusNode,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.decoration,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final String? label;
  final String? hint;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final bool canRequestFocus;
  final bool autofocus;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextStyle? style;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;

  /// Escape hatch for a fully custom decoration. When provided, [label],
  /// [hint], [prefixIcon] and [suffixIcon] are ignored.
  final InputDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      obscureText: obscureText,
      readOnly: readOnly,
      enabled: enabled,
      canRequestFocus: canRequestFocus,
      autofocus: autofocus,
      minLines: minLines,
      maxLines: obscureText ? 1 : maxLines,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      style: style,
      focusNode: focusNode,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      decoration:
          decoration ??
          InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
          ),
    );
  }
}
