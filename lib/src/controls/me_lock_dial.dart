import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// A rotary combination-lock dial.
///
/// Drag around the dial to rotate it; each numbered detent ticks with a
/// selection haptic. Releasing snaps the dial to the nearest detent with
/// the fast spatial spring. [onEntry] reports each detent the pointer
/// settles on, letting callers assemble a combination; a correct
/// combination is celebrated by the caller (e.g. with a success haptic).
class MELockDial extends StatefulWidget {
  const MELockDial({
    super.key,
    this.positions = 40,
    this.size = 180,
    this.onEntry,
    this.semanticLabel,
  }) : assert(positions >= 10);

  /// Number of detents around the dial.
  final int positions;

  /// Diameter of the dial.
  final double size;

  /// Called with the detent number the dial settles on after each drag.
  final ValueChanged<int>? onEntry;

  final String? semanticLabel;

  @override
  State<MELockDial> createState() => _MELockDialState();
}

class _MELockDialState extends State<MELockDial>
    with SingleTickerProviderStateMixin {
  /// Dial rotation in detent units (continuous while dragging).
  late final AnimationController _rotation = AnimationController.unbounded(
    vsync: this,
    value: 0,
  );
  int _lastTicked = 0;
  double? _dragAngle;

  @override
  void dispose() {
    _rotation.dispose();
    super.dispose();
  }

  double _pointerAngle(Offset local) {
    final center = Offset(widget.size / 2, widget.size / 2);
    final v = local - center;
    return math.atan2(v.dy, v.dx);
  }

  void _onPanStart(DragStartDetails details) {
    _rotation.stop();
    _dragAngle = _pointerAngle(details.localPosition);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final angle = _pointerAngle(details.localPosition);
    var delta = angle - (_dragAngle ?? angle);
    // Unwrap across the -pi/pi seam.
    if (delta > math.pi) delta -= 2 * math.pi;
    if (delta < -math.pi) delta += 2 * math.pi;
    _dragAngle = angle;

    final detentDelta = delta / (2 * math.pi) * widget.positions;
    _rotation.value += detentDelta;

    final detent = _rotation.value.round();
    if (detent != _lastTicked) {
      _lastTicked = detent;
      HapticFeedback.selectionClick();
    }
  }

  void _onPanEnd(DragEndDetails details) {
    _dragAngle = null;
    final target = _rotation.value.roundToDouble();
    springTo(
      _rotation,
      target,
      METheme.of(context).motion.fastSpatial,
    );
    final position =
        ((target.round() % widget.positions) + widget.positions) %
            widget.positions;
    widget.onEntry?.call(position);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      label: widget.semanticLabel ?? 'Combination dial',
      child: GestureDetector(
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: _rotation,
            builder: (context, _) {
              return CustomPaint(
                painter: _MELockDialPainter(
                  rotationDetents: _rotation.value,
                  positions: widget.positions,
                  faceColor: scheme.surfaceContainerHigh,
                  ringColor: scheme.primaryContainer,
                  tickColor: scheme.onSurfaceVariant,
                  numberColor: scheme.onSurface,
                  markerColor: scheme.primary,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MELockDialPainter extends CustomPainter {
  _MELockDialPainter({
    required this.rotationDetents,
    required this.positions,
    required this.faceColor,
    required this.ringColor,
    required this.tickColor,
    required this.numberColor,
    required this.markerColor,
  });

  final double rotationDetents;
  final int positions;
  final Color faceColor;
  final Color ringColor;
  final Color tickColor;
  final Color numberColor;
  final Color markerColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;

    // Outer ring.
    canvas.drawCircle(center, radius, Paint()..color = ringColor);
    // Face.
    canvas.drawCircle(center, radius * 0.86, Paint()..color = faceColor);

    // Fixed top marker.
    final marker = Path()
      ..moveTo(center.dx - 7, center.dy - radius + 2)
      ..lineTo(center.dx + 7, center.dy - radius + 2)
      ..lineTo(center.dx, center.dy - radius + 16)
      ..close();
    canvas.drawPath(marker, Paint()..color = markerColor);

    // Rotating ticks and numbers. Rotation is negative so dragging
    // clockwise increases the detent number at the top marker.
    final rotation = -rotationDetents / positions * 2 * math.pi;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    final tick = Paint()
      ..strokeCap = StrokeCap.round
      ..color = tickColor;
    final textStyle = TextStyle(
      color: numberColor,
      fontSize: radius * 0.14,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    for (var i = 0; i < positions; i++) {
      final angle = i / positions * 2 * math.pi - math.pi / 2;
      final dir = Offset(math.cos(angle), math.sin(angle));
      final isMajor = i % 5 == 0;
      tick.strokeWidth = isMajor ? 2.5 : 1.2;
      canvas.drawLine(
        dir * radius * 0.86,
        dir * radius * (isMajor ? 0.72 : 0.78),
        tick,
      );
      if (isMajor) {
        final tp = TextPainter(
          text: TextSpan(text: '$i', style: textStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        final pos = dir * radius * 0.58 -
            Offset(tp.width / 2, tp.height / 2);
        tp.paint(canvas, pos);
      }
    }
    canvas.restore();

    // Center hub.
    canvas.drawCircle(center, radius * 0.1, Paint()..color = markerColor);
  }

  @override
  bool shouldRepaint(_MELockDialPainter oldDelegate) =>
      oldDelegate.rotationDetents != rotationDetents;
}
