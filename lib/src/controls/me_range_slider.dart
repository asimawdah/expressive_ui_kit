import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// A Material 3 Expressive range slider.
///
/// Replaces [RangeSlider]. Follows the M3E slider design: a thick track,
/// two narrow vertical bar handles inset in gaps, and stop indicator dots
/// at both ends. The active handle compresses while dragged.
class MERangeSlider extends StatefulWidget {
  const MERangeSlider({
    super.key,
    required this.values,
    required this.onChanged,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.trackHeight = 16,
    this.color,
    this.trackColor,
    this.semanticsLabel,
    this.wavy = false,
  }) : assert(max > min);

  const MERangeSlider.wavy({
    super.key,
    required this.values,
    required this.onChanged,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.trackHeight = 16,
    this.color,
    this.trackColor,
    this.semanticsLabel,
  })  : wavy = true,
        assert(max > min);

  final RangeValues values;
  final ValueChanged<RangeValues>? onChanged;
  final ValueChanged<RangeValues>? onChangeEnd;
  final double min;
  final double max;
  final double trackHeight;
  final Color? color;
  final Color? trackColor;
  final String? semanticsLabel;
  final bool wavy;

  @override
  State<MERangeSlider> createState() => _MERangeSliderState();
}

class _MERangeSliderState extends State<MERangeSlider>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press = AnimationController.unbounded(
    vsync: this,
    value: 0,
  );

  /// Which handle is being dragged: 0 = start, 1 = end, -1 = none.
  int _activeHandle = -1;

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  double get _span => widget.max - widget.min;

  double get _startFraction =>
      ((widget.values.start - widget.min) / _span).clamp(0.0, 1.0);

  double get _endFraction =>
      ((widget.values.end - widget.min) / _span).clamp(0.0, 1.0);

  void _setPressed(bool pressed) {
    springTo(
      _press,
      pressed ? 1 : 0,
      pressed
          ? METheme.of(context).motion.fastSpatial
          : METheme.of(context).motion.defaultSpatial,
    );
  }

  double _fractionAt(Offset localPosition, double width) {
    var fraction = (localPosition.dx / width).clamp(0.0, 1.0);
    if (Directionality.of(context) == TextDirection.rtl) {
      fraction = 1 - fraction;
    }
    return fraction;
  }

  void _startDrag(Offset localPosition, double width) {
    final f = _fractionAt(localPosition, width);
    // Grab whichever handle is closer.
    _activeHandle =
        (f - _startFraction).abs() <= (f - _endFraction).abs() ? 0 : 1;
    _setPressed(true);
    _updateDrag(localPosition, width);
  }

  void _updateDrag(Offset localPosition, double width) {
    if (widget.onChanged == null || _activeHandle == -1) return;
    final f = _fractionAt(localPosition, width);
    final v = widget.min + f * _span;
    if (_activeHandle == 0) {
      widget.onChanged!(
        RangeValues(v.clamp(widget.min, widget.values.end), widget.values.end),
      );
    } else {
      widget.onChanged!(
        RangeValues(
            widget.values.start, v.clamp(widget.values.start, widget.max)),
      );
    }
  }

  void _endDrag() {
    _activeHandle = -1;
    _setPressed(false);
    widget.onChangeEnd?.call(widget.values);
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
      value:
          '${(_startFraction * 100).round()} to ${(_endFraction * 100).round()} percent',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart:
                enabled ? (d) => _startDrag(d.localPosition, width) : null,
            onHorizontalDragUpdate:
                enabled ? (d) => _updateDrag(d.localPosition, width) : null,
            onHorizontalDragEnd: enabled ? (_) => _endDrag() : null,
            child: SizedBox(
              height: 48,
              child: AnimatedBuilder(
                animation: _press,
                builder: (context, _) => CustomPaint(
                  size: Size(width, 48),
                  painter: _MERangeSliderPainter(
                    startFraction: _startFraction,
                    endFraction: _endFraction,
                    press: _press.value.clamp(0.0, 1.0),
                    activeHandle: _activeHandle,
                    trackHeight: widget.trackHeight,
                    activeColor: activeColor,
                    inactiveColor: inactiveColor,
                    textDirection: Directionality.of(context),
                    wavy: widget.wavy,
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

class _MERangeSliderPainter extends CustomPainter {
  _MERangeSliderPainter({
    required this.startFraction,
    required this.endFraction,
    required this.press,
    required this.activeHandle,
    required this.trackHeight,
    required this.activeColor,
    required this.inactiveColor,
    required this.textDirection,
    required this.wavy,
  });

  final double startFraction;
  final double endFraction;
  final double press;
  final int activeHandle;
  final double trackHeight;
  final Color activeColor;
  final Color inactiveColor;
  final TextDirection textDirection;
  final bool wavy;

  static const double _handleGap = 6;
  static const double _handleWidthRest = 4;
  static const double _handleWidthPressed = 2;
  static const double _handleHeight = 44;

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    final rtl = textDirection == TextDirection.rtl;

    double xFor(double fraction) =>
        (rtl ? 1 - fraction : fraction) * size.width;

    final startX = xFor(rtl ? endFraction : startFraction);
    final endX = xFor(rtl ? startFraction : endFraction);

    double handleWidth(int handle) => activeHandle == handle
        ? _handleWidthRest + (_handleWidthPressed - _handleWidthRest) * press
        : _handleWidthRest;

    final wStart = handleWidth(rtl ? 1 : 0);
    final wEnd = handleWidth(rtl ? 0 : 1);

    final innerRadius = Radius.circular(trackHeight * 0.2);
    final outerRadius = Radius.circular(trackHeight / 2);

    // Leading inactive segment.
    final leadEnd = startX - _handleGap - wStart / 2;
    if (leadEnd > trackHeight) {
      canvas.drawRRect(
        RRect.fromLTRBAndCorners(
          0,
          cy - trackHeight / 2,
          leadEnd,
          cy + trackHeight / 2,
          topLeft: outerRadius,
          bottomLeft: outerRadius,
          topRight: innerRadius,
          bottomRight: innerRadius,
        ),
        Paint()..color = inactiveColor,
      );
    }

    // Active middle segment.
    final midStart = startX + _handleGap + wStart / 2;
    final midEnd = endX - _handleGap - wEnd / 2;
    if (midEnd > midStart) {
      final rect = Rect.fromLTRB(
        midStart,
        cy - trackHeight / 2,
        midEnd,
        cy + trackHeight / 2,
      );
      if (wavy) {
        final path = Path();
        final midY = cy;
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
            ..color = activeColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = trackHeight * 0.7
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
      } else {
        canvas.drawRRect(
          RRect.fromLTRBAndCorners(
            midStart,
            cy - trackHeight / 2,
            midEnd,
            cy + trackHeight / 2,
            topLeft: innerRadius,
            bottomLeft: innerRadius,
            topRight: innerRadius,
            bottomRight: innerRadius,
          ),
          Paint()..color = activeColor,
        );
      }
    }

    // Trailing inactive segment.
    final trailStart = endX + _handleGap + wEnd / 2;
    if (trailStart < size.width - trackHeight) {
      canvas.drawRRect(
        RRect.fromLTRBAndCorners(
          trailStart,
          cy - trackHeight / 2,
          size.width,
          cy + trackHeight / 2,
          topLeft: innerRadius,
          bottomLeft: innerRadius,
          topRight: outerRadius,
          bottomRight: outerRadius,
        ),
        Paint()..color = inactiveColor,
      );
    }

    // Stop indicator dots at both ends.
    canvas.drawCircle(
      Offset(trackHeight / 2 + 2, cy),
      2,
      Paint()..color = activeColor,
    );
    canvas.drawCircle(
      Offset(size.width - trackHeight / 2 - 2, cy),
      2,
      Paint()..color = activeColor,
    );

    // Handles: narrow vertical rounded bars.
    for (final (x, w) in [(startX, wStart), (endX, wEnd)]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x, cy),
            width: w,
            height: _handleHeight,
          ),
          Radius.circular(w / 2),
        ),
        Paint()..color = activeColor,
      );
    }
  }

  @override
  bool shouldRepaint(_MERangeSliderPainter oldDelegate) =>
      oldDelegate.startFraction != startFraction ||
      oldDelegate.endFraction != endFraction ||
      oldDelegate.press != press ||
      oldDelegate.activeColor != activeColor;
}
