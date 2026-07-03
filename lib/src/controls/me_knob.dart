import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// A Material 3 Expressive rotary knob.
///
/// New in the expressive idiom — a circular dial for volume-style values.
/// Drag vertically (or in a circle around the center) to change the value.
/// The value arc sweeps around the knob, the knob face morphs squarer
/// while dragging (the M3E "grabbed" shape signal), and detents tick with
/// haptics every [detents]th of the range. On release the face springs
/// back round with a bounce.
///
/// ```dart
/// MEKnob(
///   value: volume,
///   onChanged: (v) => setState(() => volume = v),
///   label: Icon(Icons.volume_up),
/// )
/// ```
class MEKnob extends StatefulWidget {
  const MEKnob({
    super.key,
    required this.value,
    this.onChanged,
    this.onChangeEnd,
    this.size = 96,
    this.label,
    this.detents = 10,
    this.semanticLabel,
  }) : assert(value >= 0 && value <= 1, 'value must be within 0..1');

  /// Current value, 0..1.
  final double value;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeEnd;

  /// Diameter of the knob.
  final double size;

  /// Optional center content (an icon or value readout).
  final Widget? label;

  /// Number of haptic detents across the range. 0 disables haptics.
  final int detents;

  final String? semanticLabel;

  @override
  State<MEKnob> createState() => _MEKnobState();
}

class _MEKnobState extends State<MEKnob> with TickerProviderStateMixin {
  late final AnimationController _grab = AnimationController.unbounded(
    vsync: this,
    value: 0,
  );
  int _lastDetent = -1;
  bool _dragging = false;

  // The arc spans 270 degrees, from 135deg to 405deg.
  static const double _startAngle = 3 * math.pi / 4;
  static const double _sweepAngle = 3 * math.pi / 2;

  @override
  void dispose() {
    _grab.dispose();
    super.dispose();
  }

  bool get _enabled => widget.onChanged != null;

  void _setGrabbed(bool grabbed) {
    _dragging = grabbed;
    springTo(
      _grab,
      grabbed ? 1 : 0,
      grabbed
          ? METheme.of(context).motion.fastSpatial
          : METheme.of(context).motion.defaultSpatial,
    );
  }

  void _update(double newValue) {
    final v = newValue.clamp(0.0, 1.0);
    if (widget.detents > 0) {
      final detent = (v * widget.detents).round();
      if (detent != _lastDetent) {
        _lastDetent = detent;
        HapticFeedback.selectionClick();
      }
    }
    widget.onChanged?.call(v);
  }

  void _onPanUpdate(DragUpdateDetails details, Offset center) {
    final local = details.localPosition - center;
    // Blend two gestures: circular drag when away from the center,
    // vertical drag otherwise.
    if (local.distance > widget.size * 0.2) {
      var angle = math.atan2(local.dy, local.dx);
      // Normalize into the arc's range.
      angle -= _startAngle;
      while (angle < 0) angle += 2 * math.pi;
      if (angle <= _sweepAngle) {
        _update(angle / _sweepAngle);
        return;
      }
    }
    _update(widget.value - details.delta.dy / (widget.size * 2));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final center = Offset(widget.size / 2, widget.size / 2);

    return Semantics(
      slider: true,
      label: widget.semanticLabel,
      value: '${(widget.value * 100).round()}%',
      child: GestureDetector(
        onPanStart: _enabled ? (_) => _setGrabbed(true) : null,
        onPanUpdate: _enabled ? (d) => _onPanUpdate(d, center) : null,
        onPanEnd: _enabled
            ? (_) {
                _setGrabbed(false);
                widget.onChangeEnd?.call(widget.value);
              }
            : null,
        child: AnimatedBuilder(
          animation: _grab,
          builder: (context, child) {
            final grabT = _grab.value.clamp(0.0, 1.2);
            return SizedBox(
              width: widget.size,
              height: widget.size,
              child: CustomPaint(
                painter: _KnobPainter(
                  value: widget.value,
                  grab: grabT,
                  trackColor: scheme.surfaceContainerHighest,
                  arcColor: scheme.primary,
                  faceColor: Color.lerp(
                    scheme.surfaceContainerHigh,
                    scheme.primaryContainer,
                    grabT.clamp(0.0, 1.0),
                  )!,
                  dotColor: _dragging || grabT > 0.05
                      ? scheme.onPrimaryContainer
                      : scheme.onSurfaceVariant,
                  startAngle: _startAngle,
                  sweepAngle: _sweepAngle,
                ),
                child: Center(
                  child: IconTheme.merge(
                    data: IconThemeData(
                      size: widget.size * 0.28,
                      color: scheme.onSurfaceVariant,
                    ),
                    child: DefaultTextStyle.merge(
                      style:
                          Theme.of(context).textTheme.labelMedium!.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                      child: widget.label ?? const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _KnobPainter extends CustomPainter {
  const _KnobPainter({
    required this.value,
    required this.grab,
    required this.trackColor,
    required this.arcColor,
    required this.faceColor,
    required this.dotColor,
    required this.startAngle,
    required this.sweepAngle,
  });

  final double value;
  final double grab;
  final Color trackColor;
  final Color arcColor;
  final Color faceColor;
  final Color dotColor;
  final double startAngle;
  final double sweepAngle;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final stroke = size.shortestSide * 0.06;
    final radius = (size.shortestSide - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Track.
    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = trackColor,
    );
    // Value arc.
    if (value > 0.001) {
      canvas.drawArc(
        rect,
        startAngle,
        sweepAngle * value,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..color = arcColor,
      );
    }

    // Knob face: a rounded polygon that morphs squarer while grabbed.
    // We approximate the circle -> rounded-square morph with an RRect
    // whose corner radius shrinks as grab increases.
    final faceRadius = radius - stroke * 1.6;
    final cornerT = grab.clamp(0.0, 1.0);
    final rrect = RRect.fromRectAndRadius(
      Rect.fromCircle(center: center, radius: faceRadius),
      Radius.circular(faceRadius * (1.0 - 0.35 * cornerT)),
    );
    canvas.drawRRect(rrect, Paint()..color = faceColor);

    // Indicator dot at the current angle.
    final angle = startAngle + sweepAngle * value;
    final dotCenter = center +
        Offset(math.cos(angle), math.sin(angle)) * (faceRadius * 0.7);
    canvas.drawCircle(
      dotCenter,
      stroke * (0.9 + 0.3 * grab.clamp(0.0, 1.0)),
      Paint()..color = dotColor,
    );
  }

  @override
  bool shouldRepaint(_KnobPainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.grab != grab ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.arcColor != arcColor ||
      oldDelegate.faceColor != faceColor ||
      oldDelegate.dotColor != dotColor;
}
