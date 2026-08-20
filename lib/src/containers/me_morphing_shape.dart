import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// The Material 3 Expressive decorative shape library, generated
/// procedurally as polar curves.
enum MEExpressiveShape {
  /// A plain circle.
  circle(lobes: 0, amplitude: 0),

  /// Four-lobed clover.
  clover(lobes: 4, amplitude: 0.18),

  /// Six-petal flower.
  flower(lobes: 6, amplitude: 0.16),

  /// Nine-scallop cookie.
  cookie(lobes: 9, amplitude: 0.1),

  /// Twelve-scallop sunny burst.
  sunny(lobes: 12, amplitude: 0.08),

  /// Softly squashed oval blob.
  blob(lobes: 2, amplitude: 0.12);

  const MEExpressiveShape({required this.lobes, required this.amplitude});

  final int lobes;
  final double amplitude;
}

/// A decorative animated surface that morphs through the M3 Expressive
/// shape library with spring physics and a slow continuous rotation.
///
/// Use it as a hero ornament, avatar backdrop, or empty-state visual:
///
/// ```dart
/// MEMorphingShape(
///   size: 160,
///   child: Icon(Icons.music_note),
/// )
/// ```
class MEMorphingShape extends StatefulWidget {
  const MEMorphingShape({
    super.key,
    this.size = 120,
    this.color,
    this.shapes = const [
      MEExpressiveShape.cookie,
      MEExpressiveShape.clover,
      MEExpressiveShape.flower,
      MEExpressiveShape.sunny,
    ],
    this.interval = const Duration(seconds: 3),
    this.rotate = true,
    this.child,
  });

  final double size;

  /// Fill color. Defaults to the theme's primary container.
  final Color? color;

  /// The sequence of shapes to cycle through. Must not be empty.
  final List<MEExpressiveShape> shapes;

  /// Time each shape is held before morphing to the next.
  final Duration interval;

  /// Slowly rotates the shape for extra liveliness.
  final bool rotate;

  /// Optional child centered on the shape.
  final Widget? child;

  @override
  State<MEMorphingShape> createState() => _MEMorphingShapeState();
}

class _MEMorphingShapeState extends State<MEMorphingShape>
    with TickerProviderStateMixin {
  late final AnimationController _morph = AnimationController.unbounded(
    vsync: this,
    value: 0,
  );
  late final AnimationController _rotation = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 40),
  );
  int _index = 0;
  int _target = 0;
  Timer? _cycle;

  @override
  void initState() {
    super.initState();
    if (widget.rotate) _rotation.repeat();
    _scheduleNext();
  }

  void _scheduleNext() {
    _cycle?.cancel();
    _cycle = Timer(widget.interval, () {
      if (!mounted) return;
      setState(() {
        _index = _target;
        _target = (_target + 1) % widget.shapes.length;
      });
      _morph.value = 0;
      springTo(_morph, 1, METheme.of(context).motion.slowSpatial);
      _scheduleNext();
    });
  }

  @override
  void dispose() {
    _cycle?.cancel();
    _morph.dispose();
    _rotation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color =
        widget.color ?? Theme.of(context).colorScheme.primaryContainer;

    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: Listenable.merge([_morph, _rotation]),
          builder: (context, child) {
            return CustomPaint(
              painter: _MEShapePainter(
                from: widget.shapes[_index],
                to: widget.shapes[_target],
                t: _morph.value.clamp(0.0, 1.2),
                rotation: _rotation.value * 2 * math.pi,
                color: color,
              ),
              child: Center(child: child),
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}

class _MEShapePainter extends CustomPainter {
  _MEShapePainter({
    required this.from,
    required this.to,
    required this.t,
    required this.rotation,
    required this.color,
  });

  final MEExpressiveShape from;
  final MEExpressiveShape to;
  final double t;
  final double rotation;
  final Color color;

  static const int _samples = 180;

  double _radiusAt(MEExpressiveShape shape, double theta) {
    if (shape.lobes == 0 || shape.amplitude == 0) return 1.0;
    return 1.0 + shape.amplitude * math.cos(shape.lobes * theta);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    // Base radius leaves headroom for the largest lobe amplitude.
    final base = size.shortestSide / 2 / 1.2;

    final path = Path();
    for (var i = 0; i <= _samples; i++) {
      final theta = 2 * math.pi * i / _samples;
      final rFrom = _radiusAt(from, theta);
      final rTo = _radiusAt(to, theta);
      final r = base * (rFrom + (rTo - rFrom) * t);
      final point = center +
          Offset(
            r * math.cos(theta + rotation),
            r * math.sin(theta + rotation),
          );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_MEShapePainter oldDelegate) =>
      oldDelegate.t != t ||
      oldDelegate.rotation != rotation ||
      oldDelegate.from != from ||
      oldDelegate.to != to ||
      oldDelegate.color != color;
}
