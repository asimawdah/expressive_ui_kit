import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

/// A segment of an [MESpinWheel].
@immutable
class MESpinSegment {
  const MESpinSegment({required this.label, this.color});

  final String label;

  /// Optional explicit color. When null, colors are derived from the
  /// Material color scheme in an alternating tonal pattern.
  final Color? color;
}

/// A prize/spinner wheel with Material 3 Expressive fling physics.
///
/// Fling the wheel (or call spin via [MESpinWheelController]) and it
/// decelerates with friction physics, ticking a haptic every time a
/// segment boundary passes the pointer. When it settles, [onSettled]
/// reports the winning segment index.
class MESpinWheel extends StatefulWidget {
  const MESpinWheel({
    super.key,
    required this.segments,
    this.onSettled,
    this.size = 260,
    this.controller,
    this.semanticLabel,
  }) : assert(segments.length >= 2, 'Provide at least 2 segments');

  final List<MESpinSegment> segments;

  /// Called with the index of the segment under the pointer once the
  /// wheel stops.
  final ValueChanged<int>? onSettled;

  final double size;

  final MESpinWheelController? controller;

  final String? semanticLabel;

  @override
  State<MESpinWheel> createState() => _MESpinWheelState();
}

/// Programmatic control for [MESpinWheel].
class MESpinWheelController {
  _MESpinWheelState? _state;

  /// Spins the wheel with a random strong impulse.
  void spin() => _state?._spinRandom();
}

class _MESpinWheelState extends State<MESpinWheel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotation = AnimationController.unbounded(
    vsync: this,
    value: 0,
  );
  int _lastTickSegment = 0;
  bool _settleScheduled = false;
  final math.Random _random = math.Random();

  double get _segmentAngle => 2 * math.pi / widget.segments.length;

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
    _rotation.addListener(_onRotationTick);
  }

  @override
  void didUpdateWidget(MESpinWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?._state = null;
      widget.controller?._state = this;
    }
  }

  @override
  void dispose() {
    widget.controller?._state = null;
    _rotation.dispose();
    super.dispose();
  }

  void _onRotationTick() {
    // Haptic tick when a segment boundary crosses the top pointer.
    final segment = _segmentAtPointer();
    if (segment != _lastTickSegment) {
      _lastTickSegment = segment;
      HapticFeedback.selectionClick();
    }
  }

  int _segmentAtPointer() {
    // The pointer sits at the top (-pi/2). Segment 0 starts at angle 0
    // (3 o'clock) and segments proceed clockwise.
    final pointerAngle = -math.pi / 2 - _rotation.value;
    final normalized = ((pointerAngle % (2 * math.pi)) + 2 * math.pi) %
        (2 * math.pi);
    return (normalized / _segmentAngle).floor() % widget.segments.length;
  }

  void _spinRandom() {
    final velocity = 14.0 + _random.nextDouble() * 12.0;
    _fling(velocity);
  }

  void _fling(double velocity) {
    _settleScheduled = false;
    final simulation = FrictionSimulation(0.12, _rotation.value, velocity);
    _rotation.animateWith(simulation).whenComplete(_reportSettled);
  }

  void _reportSettled() {
    if (_settleScheduled) return;
    _settleScheduled = true;
    HapticFeedback.mediumImpact();
    widget.onSettled?.call(_segmentAtPointer());
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final center = Offset(widget.size / 2, widget.size / 2);
    final position = details.localPosition - center;
    // Convert the drag delta into angular movement around the center.
    final angle = math.atan2(position.dy, position.dx);
    final previous = position - details.delta;
    final previousAngle = math.atan2(previous.dy, previous.dx);
    var delta = angle - previousAngle;
    // Unwrap across the -pi/pi seam.
    if (delta > math.pi) delta -= 2 * math.pi;
    if (delta < -math.pi) delta += 2 * math.pi;
    _rotation.value += delta;
  }

  void _onPanEnd(DragEndDetails details) {
    final center = Offset(widget.size / 2, widget.size / 2);
    final position = details.localPosition - center;
    final radius = position.distance.clamp(1.0, widget.size / 2);
    // Tangential velocity -> angular velocity.
    final tangent =
        Offset(-position.dy / radius, position.dx / radius);
    final angularVelocity = (details.velocity.pixelsPerSecond.dx * tangent.dx +
            details.velocity.pixelsPerSecond.dy * tangent.dy) /
        radius;
    if (angularVelocity.abs() > 0.5) {
      _fling(angularVelocity);
    } else {
      _reportSettled();
    }
  }

  List<Color> _resolveColors(ColorScheme scheme) {
    return [
      for (int i = 0; i < widget.segments.length; i++)
        widget.segments[i].color ??
            [
              scheme.primaryContainer,
              scheme.secondaryContainer,
              scheme.tertiaryContainer,
              scheme.surfaceContainerHigh,
            ][i % 4],
    ];
  }

  List<Color> _resolveTextColors(ColorScheme scheme) {
    return [
      for (int i = 0; i < widget.segments.length; i++)
        widget.segments[i].color != null
            ? scheme.onSurface
            : [
                scheme.onPrimaryContainer,
                scheme.onSecondaryContainer,
                scheme.onTertiaryContainer,
                scheme.onSurface,
              ][i % 4],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: widget.semanticLabel ?? 'Spin wheel',
      child: SizedBox(
        width: widget.size,
        height: widget.size + 20,
        child: Column(
          children: [
            Icon(Icons.arrow_drop_down, size: 28, color: scheme.primary),
            Expanded(
              child: GestureDetector(
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: AnimatedBuilder(
                  animation: _rotation,
                  builder: (context, _) {
                    return Transform.rotate(
                      angle: _rotation.value,
                      child: CustomPaint(
                        size: Size.square(widget.size - 8),
                        painter: _WheelPainter(
                          segments: widget.segments,
                          colors: _resolveColors(scheme),
                          textColors: _resolveTextColors(scheme),
                          outline: scheme.outlineVariant,
                          hub: scheme.surface,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  _WheelPainter({
    required this.segments,
    required this.colors,
    required this.textColors,
    required this.outline,
    required this.hub,
  });

  final List<MESpinSegment> segments;
  final List<Color> colors;
  final List<Color> textColors;
  final Color outline;
  final Color hub;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final segmentAngle = 2 * math.pi / segments.length;

    for (int i = 0; i < segments.length; i++) {
      final start = i * segmentAngle;
      final paint = Paint()..color = colors[i];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        segmentAngle,
        true,
        paint,
      );
      // Segment divider.
      final borderPaint = Paint()
        ..color = outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawLine(
        center,
        center +
            Offset(math.cos(start), math.sin(start)) * radius,
        borderPaint,
      );

      // Label along the segment's mid-angle.
      final mid = start + segmentAngle / 2;
      final textPainter = TextPainter(
        text: TextSpan(
          text: segments[i].label,
          style: TextStyle(
            color: textColors[i],
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      )..layout(maxWidth: radius * 0.62);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(mid);
      textPainter.paint(
        canvas,
        Offset(radius * 0.32, -textPainter.height / 2),
      );
      canvas.restore();
    }

    // Outer rim.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    // Hub.
    canvas.drawCircle(center, radius * 0.12, Paint()..color = hub);
    canvas.drawCircle(
      center,
      radius * 0.12,
      Paint()
        ..color = outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_WheelPainter oldDelegate) =>
      oldDelegate.segments != segments || oldDelegate.colors != colors;
}
