import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// Visual style for [MESlider].
enum MESliderStyle { standard, wavy, centered }

/// A Material 3 Expressive slider.
///
/// Replaces [Slider]. Renders the M3E design: a thick track, a narrow
/// vertical bar handle inset in a gap, and a stop indicator dot at the
/// end of the track. The handle compresses while dragged.
///
/// Use [MESlider.wavy], [MESlider.centered] or [MESlider.vertical] for
/// the additional M3 Expressive variants.
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
    this.thumbLength = 44,
    this.cornerRadius = 8,
    this.color,
    this.trackColor,
    this.semanticsLabel,
    this.style = MESliderStyle.standard,
    this.orientation = Axis.horizontal,
  }) : assert(max > min);

  const MESlider.wavy({
    super.key,
    required this.value,
    required this.onChanged,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.trackHeight = 16,
    this.thumbLength = 44,
    this.cornerRadius = 8,
    this.color,
    this.trackColor,
    this.semanticsLabel,
    this.orientation = Axis.horizontal,
  })  : style = MESliderStyle.wavy,
        assert(max > min);

  const MESlider.centered({
    super.key,
    required this.value,
    required this.onChanged,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.trackHeight = 16,
    this.thumbLength = 44,
    this.cornerRadius = 8,
    this.color,
    this.trackColor,
    this.semanticsLabel,
    this.orientation = Axis.horizontal,
  })  : style = MESliderStyle.centered,
        assert(max > min);

  const MESlider.vertical({
    super.key,
    required this.value,
    required this.onChanged,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.trackHeight = 16,
    this.thumbLength = 44,
    this.cornerRadius = 8,
    this.color,
    this.trackColor,
    this.semanticsLabel,
    this.style = MESliderStyle.standard,
  })  : orientation = Axis.vertical,
        assert(max > min);

  final double value;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeEnd;
  final double min;
  final double max;
  final int? divisions;
  final double trackHeight;
  final double thumbLength;
  final double cornerRadius;
  final Color? color;
  final Color? trackColor;
  final String? semanticsLabel;
  final MESliderStyle style;
  final Axis orientation;

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

  void _handleDrag(Offset localPosition, Size size) {
    if (widget.onChanged == null) return;
    final vertical = widget.orientation == Axis.vertical;
    var fraction = vertical
        ? (1 - localPosition.dy / size.height).clamp(0.0, 1.0)
        : (localPosition.dx / size.width).clamp(0.0, 1.0);
    if (!vertical && Directionality.of(context) == TextDirection.rtl) {
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
    final vertical = widget.orientation == Axis.vertical;

    return Semantics(
      slider: true,
      label: widget.semanticsLabel,
      value: '${(_fraction * 100).round()} percent',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = vertical
              ? Size(48,
                  constraints.maxHeight.isFinite ? constraints.maxHeight : 160)
              : Size(constraints.maxWidth, 48);
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: !vertical && enabled
                ? (d) {
                    _setPressed(true);
                    _handleDrag(d.localPosition, size);
                  }
                : null,
            onHorizontalDragUpdate: !vertical && enabled
                ? (d) => _handleDrag(d.localPosition, size)
                : null,
            onHorizontalDragEnd: !vertical && enabled
                ? (_) {
                    _setPressed(false);
                    widget.onChangeEnd?.call(widget.value);
                  }
                : null,
            onVerticalDragStart: vertical && enabled
                ? (d) {
                    _setPressed(true);
                    _handleDrag(d.localPosition, size);
                  }
                : null,
            onVerticalDragUpdate: vertical && enabled
                ? (d) => _handleDrag(d.localPosition, size)
                : null,
            onVerticalDragEnd: vertical && enabled
                ? (_) {
                    _setPressed(false);
                    widget.onChangeEnd?.call(widget.value);
                  }
                : null,
            onTapDown:
                enabled ? (d) => _handleDrag(d.localPosition, size) : null,
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: AnimatedBuilder(
                animation: _press,
                builder: (context, _) => CustomPaint(
                  size: size,
                  painter: _MESliderPainter(
                    fraction: _fraction,
                    press: _press.value.clamp(0.0, 1.0),
                    trackHeight: widget.trackHeight,
                    thumbLength: widget.thumbLength,
                    cornerRadius: widget.cornerRadius,
                    activeColor: activeColor,
                    inactiveColor: inactiveColor,
                    handleColor: activeColor,
                    onActiveColor: colors.onPrimary,
                    divisions: widget.divisions,
                    textDirection: Directionality.of(context),
                    style: widget.style,
                    vertical: vertical,
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
    required this.thumbLength,
    required this.cornerRadius,
    required this.activeColor,
    required this.inactiveColor,
    required this.handleColor,
    required this.onActiveColor,
    required this.textDirection,
    required this.style,
    required this.vertical,
    this.divisions,
  });

  final double fraction;
  final double press;
  final double trackHeight;
  final double thumbLength;
  final double cornerRadius;
  final Color activeColor;
  final Color inactiveColor;
  final Color handleColor;
  final Color onActiveColor;
  final int? divisions;
  final TextDirection textDirection;
  final MESliderStyle style;
  final bool vertical;

  static const double _handleGap = 6;
  static const double _handleWidthRest = 4;
  static const double _handleWidthPressed = 2;

  @override
  void paint(Canvas canvas, Size size) {
    if (vertical) {
      canvas.save();
      canvas.translate(size.width, 0);
      canvas.rotate(math.pi / 2);
      _paintTrack(canvas, Size(size.height, size.width));
      canvas.restore();
    } else {
      _paintTrack(canvas, size);
    }
  }

  void _paintTrack(Canvas canvas, Size size) {
    final cy = size.height / 2;
    final rtl = !vertical && textDirection == TextDirection.rtl;
    final f = rtl ? 1 - fraction : fraction;
    final handleX = f * size.width;
    final handleWidth =
        _handleWidthRest + (_handleWidthPressed - _handleWidthRest) * press;

    final innerRadius = Radius.circular(
      math.min(4, trackHeight / 2),
    );
    final outerRadius = Radius.circular(
      math.min(cornerRadius, trackHeight / 2),
    );

    if (style == MESliderStyle.centered) {
      _paintCentered(canvas, size, cy, handleX, handleWidth, outerRadius);
    } else {
      final activeEnd = handleX - _handleGap - handleWidth / 2;
      if (activeEnd > trackHeight) {
        final rect = RRect.fromLTRBAndCorners(
          0,
          cy - trackHeight / 2,
          activeEnd,
          cy + trackHeight / 2,
          topLeft: rtl ? innerRadius : outerRadius,
          bottomLeft: rtl ? innerRadius : outerRadius,
          topRight: rtl ? outerRadius : innerRadius,
          bottomRight: rtl ? outerRadius : innerRadius,
        );
        if (style == MESliderStyle.wavy) {
          _paintWavy(canvas, rect.outerRect, activeColor);
        } else {
          canvas.drawRRect(
              rect, Paint()..color = rtl ? inactiveColor : activeColor);
        }
      }

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
    }

    final dotX = rtl ? trackHeight / 2 + 2 : size.width - trackHeight / 2 - 2;
    canvas.drawCircle(
      Offset(dotX, cy),
      2,
      Paint()..color = rtl ? inactiveColor : activeColor,
    );

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

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(handleX, cy),
          width: handleWidth,
          height: thumbLength,
        ),
        Radius.circular(handleWidth / 2),
      ),
      Paint()..color = handleColor,
    );
  }

  void _paintCentered(
    Canvas canvas,
    Size size,
    double cy,
    double handleX,
    double handleWidth,
    Radius outerRadius,
  ) {
    final mid = size.width / 2;
    canvas.drawRRect(
      RRect.fromLTRBR(
        0,
        cy - trackHeight / 2,
        size.width,
        cy + trackHeight / 2,
        outerRadius,
      ),
      Paint()..color = inactiveColor,
    );
    final left = math.min(handleX, mid);
    final right = math.max(handleX, mid);
    if ((right - left) > _handleGap) {
      final rect = Rect.fromLTRB(
        left + (handleX < mid ? handleWidth / 2 + _handleGap : 0),
        cy - trackHeight / 2,
        right - (handleX > mid ? handleWidth / 2 + _handleGap : 0),
        cy + trackHeight / 2,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, outerRadius),
        Paint()..color = activeColor,
      );
    }
  }

  void _paintWavy(Canvas canvas, Rect rect, Color color) {
    final path = Path();
    final midY = rect.center.dy;
    const wavelength = 18.0;
    final amplitude = trackHeight * 0.28;
    path.moveTo(rect.left, midY);
    for (double x = rect.left; x <= rect.right; x += 1) {
      final y = midY +
          math.sin((x - rect.left) / wavelength * 2 * math.pi) * amplitude;
      path.lineTo(x, y);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = trackHeight * 0.7
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_MESliderPainter oldDelegate) =>
      oldDelegate.fraction != fraction ||
      oldDelegate.press != press ||
      oldDelegate.activeColor != activeColor ||
      oldDelegate.style != style ||
      oldDelegate.vertical != vertical ||
      oldDelegate.thumbLength != thumbLength ||
      oldDelegate.cornerRadius != cornerRadius;
}
