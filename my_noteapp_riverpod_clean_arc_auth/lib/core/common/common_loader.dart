import 'package:flutter/material.dart';

/// A circular progress indicator used in two ways:
///  * inline inside a button — give it a [size] and white [color];
///  * as a full-area page loader — use the [CommonLoader.page] constructor.
class CommonLoader extends StatelessWidget {
  const CommonLoader({
    super.key,
    this.size,
    this.strokeWidth = 2,
    this.color,
    this.center = false,
  });

  /// A centered, default-sized loader for filling a page or list area.
  const CommonLoader.page({super.key})
    : size = null,
      strokeWidth = 4,
      color = null,
      center = true;

  /// Width/height of the indicator. When null, the indicator uses its natural
  /// size (best for page loaders).
  final double? size;
  final double strokeWidth;
  final Color? color;

  /// Wraps the indicator in a [Center] when true.
  final bool center;

  @override
  Widget build(BuildContext context) {
    Widget indicator = CircularProgressIndicator(
      strokeWidth: strokeWidth,
      color: color,
    );
    if (size != null) {
      indicator = SizedBox(width: size, height: size, child: indicator);
    }
    return center ? Center(child: indicator) : indicator;
  }
}
