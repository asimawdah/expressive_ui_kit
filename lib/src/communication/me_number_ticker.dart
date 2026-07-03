import 'package:flutter/material.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// An animated number display whose digits roll vertically with a spatial
/// spring when the value changes — the M3 Expressive treatment for
/// counters, prices and scores.
///
/// ```dart
/// MENumberTicker(value: 1024, style: textTheme.displaySmall)
/// ```
class MENumberTicker extends StatelessWidget {
  const MENumberTicker({
    super.key,
    required this.value,
    this.style,
    this.prefix = '',
    this.suffix = '',
    this.padWidth = 0,
  });

  final int value;
  final TextStyle? style;
  final String prefix;
  final String suffix;

  /// Left-pads the number with zeros to at least this many digits
  /// (e.g. `padWidth: 2` renders 7 as "07"). Useful for clocks and
  /// countdowns.
  final int padWidth;

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = (style ?? Theme.of(context).textTheme.titleLarge!)
        .copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
    final text = value.abs().toString().padLeft(padWidth, '0');
    final negative = value < 0;

    return Semantics(
      label: '$prefix$value$suffix',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (prefix.isNotEmpty || negative)
            Text('$prefix${negative ? '-' : ''}', style: effectiveStyle),
          // Digits are keyed right-to-left so appending digits (9 -> 10)
          // keeps existing digit columns stable.
          for (var i = 0; i < text.length; i++)
            _MEDigitColumn(
              key: ValueKey(text.length - i),
              digit: int.parse(text[i]),
              style: effectiveStyle,
            ),
          if (suffix.isNotEmpty) Text(suffix, style: effectiveStyle),
        ],
      ),
    );
  }
}

class _MEDigitColumn extends StatefulWidget {
  const _MEDigitColumn({super.key, required this.digit, required this.style});

  final int digit;
  final TextStyle style;

  @override
  State<_MEDigitColumn> createState() => _MEDigitColumnState();
}

class _MEDigitColumnState extends State<_MEDigitColumn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _position = AnimationController.unbounded(
    vsync: this,
    value: widget.digit.toDouble(),
  );

  @override
  void didUpdateWidget(_MEDigitColumn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.digit != oldWidget.digit) {
      springTo(
        _position,
        widget.digit.toDouble(),
        METheme.of(context).motion.defaultSpatial,
      );
    }
  }

  @override
  void dispose() {
    _position.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Measure one digit cell using the tallest digit.
    final painter = TextPainter(
      text: TextSpan(text: '8', style: widget.style),
      textDirection: TextDirection.ltr,
    )..layout();
    final digitHeight = painter.height;
    final digitWidth = painter.width;

    return ClipRect(
      child: SizedBox(
        width: digitWidth,
        height: digitHeight,
        child: AnimatedBuilder(
          animation: _position,
          builder: (context, _) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                for (var d = 0; d <= 9; d++)
                  Positioned(
                    top: (d - _position.value) * digitHeight,
                    child: Text('$d', style: widget.style),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
