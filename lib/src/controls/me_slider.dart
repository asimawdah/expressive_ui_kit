import 'package:flutter/material.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// A Material 3 Expressive slider.
///
/// Replaces [Slider]. Renders the M3E design: a thick track, a narrow
/// vertical bar handle inset in a gap, and a stop indicator dot at the
/// end of the track. The handle compresses while dragged.
class MESlider extends StatefulWidget {
  const MESlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.trackHeight = 16,
    this.color,
    this.trackColor,
    this.semanticsLabel,
  }) : assert(max > min);

  final double value;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeEnd;
  final double min;
  final double max;
  final int? divisions;
  final double trackHeight;
  final Color? color;
  final Color? trackColor;
  final String? semanticsLabel;

  @override
  State<MESlider> createState() => _MESliderState();
}

class _MESliderState extends State<MESlider>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press = AnimationController.unbounded(
    vsync: this,
    value: 0,
  );

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  double get _fraction =>
      ((widget.value - widget.min) / (widget.max - widget.min)).clamp(0.0, 1.0);

  void _setPressed(bool pressed) {
    springTo(
      _press,
      pressed ? 1 : 0,
      pressed
          ? METheme.of(context).motion.fastSpatial
          : METheme.of(context).motion.defaultSpatial,
    );
  }

  void _handleDrag(Offset localPosition, double width) {
    if (widget.onChanged == null) return;
    var fraction = (localPosition.dx / width).clamp(0.0, 1.0);
    if (Directionality.of(context) == TextDirection.rtl) {
      fraction = 1 - fraction;
    }
    if (widget.divisions != null) {
      fraction = (fraction * widget.divisions!).round() / widget.divisions!;
    }
    widget.onChanged!(widget.min + fraction * (widget.max - widget.min));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final enabled = widget.onChanged != null;
    final activeColor = enabled
        ? (widget.color ?? colors.primary)
        : colors.onSurface.withValues(alpha: 0.38);
    final inactiveColor = enabled
        ? (widget.trackColor ?? colors.secondaryContainer)
        : colors.onSurface.withValues(alpha: 0.12);

    return Semantics(
      slider: true,
      label: widget.semanticsLabel,
      value: '${(_fraction * 100).round()} percent',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: enabled
                ? (d) {
                    _setPressed(true);
                    _handleDrag(d.localPosition, width);
                  }
                : null,
            onHorizontalDragUpdate:
                enabled ? (d) => _handleDrag(d.localPosition, width) : null,
            onHorizontalDragEnd: enabled
                ? (_) {
                    _setPressed(false);
                    widget.onChangeEnd?.call(widget.value);
                  }
                : null,
            onTapDown:
                enabled ? (d) => _handleDrag(d.localPosition, width) : null,
            child: SizedBox(
              height: 48,
              child: AnimatedBuilder(
                animation: _press,
                builder: (context, _) => CustomPaint(
                  size: Size(width, 48),
                  painter: _MESliderPainter(
                    fraction: _fraction,
                    press: _press.value.clamp(0.0, 1.0),
                    trackHeight: widget.trackHeight,
                    activeColor: activeColor,
                    inactiveColor: inactiveColor,
                    handleColor: activeColor,
                    onActiveColor: colors.onPrimary,
                    divisions: widget.divisions,
                    textDirection: Directionality.of(context),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MESliderPainter extends CustomPainter {
  _MESliderPainter({
    required this.fraction,
    required this.press,
    required this.trackHeight,
    required this.activeColor,
    required this.inactiveColor,
    required this.handleColor,
    required this.onActiveColor,
    required this.textDirection,
    this.divisions,
  });

  final double fraction;
  final double press;
  final double trackHeight;
  final Color activeColor;
  final Color inactiveColor;
  final Color handleColor;
  final Color onActiveColor;
  final int? divisions;
  final TextDirection textDirection;

  static const double _handleGap = 6;
  static const double _handleWidthRest = 4;
  static const double _handleWidthPressed = 2;
  static const double _handleHeight = 44;

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    final rtl = textDirection == TextDirection.rtl;
    final f = rtl ? 1 - fraction : fraction;
    final handleX = f * size.width;
    final handleWidth =
        _handleWidthRest + (_handleWidthPressed - _handleWidthRest) * press;

    final innerRadius = Radius.circular(trackHeight * 0.2);
    final outerRadius = Radius.circular(trackHeight / 2);

    // Active track.
    final activeEnd = handleX - _handleGap - handleWidth / 2;
    if (activeEnd > trackHeight) {
      canvas.drawRRect(
        RRect.fromLTRBAndCorners(
          0,
          cy - trackHeight / 2,
          activeEnd,
          cy + trackHeight / 2,
          topLeft: rtl ? innerRadius : outerRadius,
          bottomLeft: rtl ? innerRadius : outerRadius,
          topRight: rtl ? outerRadius : innerRadius,
          bottomRight: rtl ? outerRadius : innerRadius,
        ),
        Paint()..color = rtl ? inactiveColor : activeColor,
      );
    }

    // Inactive track.
    final inactiveStart = handleX + _handleGap + handleWidth / 2;
    if (inactiveStart < size.width - trackHeight) {
      canvas.drawRRect(
        RRect.fromLTRBAndCorners(
          inactiveStart,
          cy - trackHeight / 2,
          size.width,
          cy + trackHeight / 2,
          topLeft: innerRadius,
          bottomLeft: innerRadius,
          topRight: outerRadius,
          bottomRight: outerRadius,
        ),
        Paint()..color = rtl ? activeColor : inactiveColor,
      );
    }

    // Stop indicator dot near the inactive end.
    final dotX = rtl ? trackHeight / 2 + 2 : size.width - trackHeight / 2 - 2;
    canvas.drawCircle(
      Offset(dotX, cy),
      2,
      Paint()..color = rtl ? inactiveColor : activeColor,
    );

    // Division ticks.
    if (divisions != null && divisions! > 1) {
      for (var i = 1; i < divisions!; i++) {
        final x = i / divisions! * size.width;
        if ((x - handleX).abs() < _handleGap + handleWidth) continue;
        final onActive = rtl ? x > handleX : x < handleX;
        canvas.drawCircle(
          Offset(x, cy),
          1.5,
          Paint()
            ..color = onActive
                ? onActiveColor.withValues(alpha: 0.8)
                : activeColor.withValues(alpha: 0.6),
        );
      }
    }

    // Handle: narrow vertical rounded bar.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(handleX, cy),
          width: handleWidth,
          height: _handleHeight,
        ),
        Radius.circular(handleWidth / 2),
      ),
      Paint()..color = handleColor,
    );
  }

  @override
  bool shouldRepaint(_MESliderPainter oldDelegate) =>
      oldDelegate.fraction != fraction ||
      oldDelegate.press != press ||
      oldDelegate.activeColor != activeColor;
}
