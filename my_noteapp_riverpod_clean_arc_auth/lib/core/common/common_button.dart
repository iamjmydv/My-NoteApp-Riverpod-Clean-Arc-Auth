import 'package:flutter/material.dart';

class CommonButton extends StatelessWidget {
  const CommonButton({
    super.key,
    this.text,
    this.height = 60,
    this.width,
    this.borderRadius = 10,
    this.fontSize = 16,
    this.fontWeight,
    this.padding,
    this.disabledForegroundColor = Colors.white,
    this.foregroundColor = Colors.white,
    this.backgroundColor = Colors.orange,
    this.borderColor,
    this.overlayColor,
    this.hasBorder = false,
    this.child,
    this.onPressed,
    this.textColor,
    this.fontFamily = "Roboto",
    this.decoration,
    this.borderWidth,
  }) : assert(
         (text == null && child != null) || (child == null && text != null),
       );

  final String? text;
  final double height;
  final double? width;
  final double borderRadius;
  final double fontSize;
  final FontWeight? fontWeight;
  final EdgeInsets? padding;
  final Color disabledForegroundColor;
  final Color foregroundColor;
  final Color backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final Color? overlayColor;
  final Color? textColor;
  final bool hasBorder;
  final Widget? child;
  final String fontFamily;
  final VoidCallback? onPressed;
  final TextDecoration? decoration;

  @override
  Widget build(Object context) {
    return SizedBox(
      height: height,
      width: width,
      child: TextButton(
        style: ButtonStyle(
          overlayColor: ButtonStyleButton.allOrNull<Color>(
            overlayColor ?? Colors.black12,
          ),
          shape: ButtonStyleButton.allOrNull<OutlinedBorder>(
            RoundedRectangleBorder(
              side: hasBorder
                  ? BorderSide(
                      color: borderColor ?? foregroundColor,
                      width: borderWidth ?? 1.0,
                    )
                  : BorderSide.none,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          padding: ButtonStyleButton.allOrNull<EdgeInsets>(padding),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return disabledForegroundColor;
            } else {
              return foregroundColor;
            }
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return Colors.grey.shade700.withValues();
            } else {
              return backgroundColor;
            }
          }),
          textStyle: ButtonStyleButton.allOrNull<TextStyle>(
            TextStyle(
              color: textColor,
              fontSize: fontSize,
              fontWeight: fontWeight,
              fontFamily: fontFamily,
              decoration: decoration,
            ),
          ),
        ),
        onPressed: onPressed,
        child: child ?? Text(text!, textAlign: TextAlign.center),
      ),
    );
  }
}