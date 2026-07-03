import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A Material 3 Expressive loading indicator.
///
/// A new M3E component intended to replace the indeterminate
/// [CircularProgressIndicator] for short waits (under ~5 seconds).
/// Renders a rotating shape that continuously morphs through a sequence
/// of rounded polygons ("cookies").
class MELoadingIndicator extends StatefulWidget {
  const MELoadingIndicator({
    super.key,
    this.size = 48,
    this.color,
    this.containerColor,
    this.contained = false,
    this.semanticsLabel,
  });

  final double size;
  final Color? color;

  /// Background container color when [contained] is true.
  final Color? containerColor;

  /// Whether to draw the indicator on a filled container, per the M3E
  /// "contained" style.
  final bool contained;
  final String? semanticsLabel;

  @override
  State<MELoadingIndicator> createState() => _MELoadingIndicatorState();
}

class _MELoadingIndicatorState extends State<MELoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4000),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final indicator = Semantics(
      label: widget.semanticsLabel ?? 'Loading',
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            painter: _MorphingShapePainter(
              t: _controller.value,
              color: widget.color ??
                  (widget.contained ? colors.onPrimaryContainer : colors.primary),
            ),
          ),
        ),
      ),
    );

    if (!widget.contained) return indicator;
    return Container(
      width: widget.size * 1.6,
      height: widget.size * 1.6,
      decoration: BoxDecoration(
        color: widget.containerColor ?? colors.primaryContainer,
        borderRadius: BorderRadius.circular(widget.size * 0.5),
      ),
      child: Center(child: indicator),
    );
  }
}

/// Paints a rounded polygon that morphs through the M3E shape sequence
/// (soft triangle -> square -> pentagon -> hexagon -> circle) while
/// rotating.
class _MorphingShapePainter extends CustomPainter {
  _MorphingShapePainter({required this.t, required this.color});

  final double t;
  final Color color;

  // Shape sequence: number of polygon sides (7 reads as near-circle).
  static const List<int> _sequence = [3, 4, 5, 6, 7];

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;

    final steps = _sequence.length;
    final pos = t * steps;
    final index = pos.floor() % steps;
    final frac = pos - pos.floor();
    // Ease the morph so the shape rests briefly at each polygon.
    final morph = Curves.easeInOutCubicEmphasized.transform(frac);

    final fromSides = _sequence[index];
    final toSides = _sequence[(index + 1) % steps];

    final rotation = t * 2 * math.pi * 2;

    final path = _morphedPolygon(
      center,
      radius * 0.92,
      fromSides,
      toSides,
      morph,
      rotation,
    );

    canvas.drawPath(path, Paint()..color = color);
  }

  /// Builds a smooth path interpolating between an m-gon and an n-gon by
  /// sampling both as continuous radius functions.
  Path _morphedPolygon(
    Offset center,
    double radius,
    int fromSides,
    int toSides,
    double t,
    double rotation,
  ) {
    final path = Path();
    const samples = 120;
    for (var i = 0; i <= samples; i++) {
      final angle = i / samples * 2 * math.pi;
      final r1 = _polygonRadius(angle, fromSides);
      final r2 = _polygonRadius(angle, toSides);
      // Soften corners: blend toward a circle by 35%.
      final r = ((r1 + (r2 - r1) * t) * 0.65 + 0.35) * radius;
      final a = angle + rotation;
      final p = center + Offset(math.cos(a), math.sin(a)) * r;
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    return path;
  }

  /// Normalized radius of a regular polygon with [sides] sides at [angle].
  double _polygonRadius(double angle, int sides) {
    final sector = 2 * math.pi / sides;
    final a = angle % sector - sector / 2;
    return math.cos(sector / 2) / math.cos(a);
  }

  @override
  bool shouldRepaint(_MorphingShapePainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.color != color;
}
