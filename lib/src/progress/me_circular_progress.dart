import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/me_theme.dart';

/// A Material 3 Expressive circular progress indicator.
///
/// Replaces [CircularProgressIndicator]. Renders the M3E wavy circular
/// active arc with a flat remaining track and a gap between them. Pass
/// `value: null` for the indeterminate variant.
class MECircularProgressIndicator extends StatefulWidget {
  const MECircularProgressIndicator({
    super.key,
    this.value,
    this.size = 48,
    this.strokeWidth = 4,
    this.amplitude = 2.5,
    this.waves = 8,
    this.color,
    this.trackColor,
    this.wavy = true,
    this.semanticsLabel,
  });

  /// Progress from 0.0 to 1.0, or null for indeterminate.
  final double? value;
  final double size;
  final double strokeWidth;
  final double amplitude;

  /// Number of wave cycles around the circle.
  final int waves;
  final Color? color;
  final Color? trackColor;
  final bool wavy;
  final String? semanticsLabel;

  @override
  State<MECircularProgressIndicator> createState() =>
      _MECircularProgressIndicatorState();
}

class _MECircularProgressIndicatorState
    extends State<MECircularProgressIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = METheme.of(context).motion.defaultSpatial.instant;
    if (reduced) {
      _controller.stop();
      _controller.value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final reduced = METheme.of(context).motion.defaultSpatial.instant;
    return Semantics(
      label: widget.semanticsLabel ?? 'Progress indicator',
      value: widget.value == null
          ? null
          : '${(widget.value! * 100).round()} percent',
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            painter: _WavyCircularPainter(
              value: widget.value,
              phase: reduced ? 0 : _controller.value,
              amplitude: widget.wavy && !reduced ? widget.amplitude : 0,
              waves: widget.waves,
              strokeWidth: widget.strokeWidth,
              color: widget.color ?? colors.primary,
              trackColor: widget.trackColor ?? colors.secondaryContainer,
            ),
          ),
        ),
      ),
    );
  }
}

class _WavyCircularPainter extends CustomPainter {
  _WavyCircularPainter({
    required this.value,
    required this.phase,
    required this.amplitude,
    required this.waves,
    required this.strokeWidth,
    required this.color,
    required this.trackColor,
  });

  final double? value;
  final double phase;
  final double amplitude;
  final int waves;
  final double strokeWidth;
  final Color color;
  final Color trackColor;

  static const double _gapRadians = 0.35;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - strokeWidth / 2 - amplitude;
    final activePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const top = -math.pi / 2;

    if (value != null) {
      final v = value!.clamp(0.0, 1.0);
      final sweep = v * 2 * math.pi;

      // Active wavy arc.
      if (sweep > 0.05) {
        _paintWavyArc(canvas, activePaint, center, radius, top, sweep);
      }
      // Remaining flat track.
      final remaining = 2 * math.pi - sweep - 2 * _gapRadians;
      if (remaining > 0.05) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          top + sweep + _gapRadians,
          remaining,
          false,
          trackPaint,
        );
      }
    } else {
      // Indeterminate: rotating wavy arc with a breathing sweep.
      final rotation = phase * 2 * math.pi * 2;
      final sweep =
          math.pi * 0.5 + math.sin(phase * 2 * math.pi) * math.pi * 0.35;
      _paintWavyArc(canvas, activePaint, center, radius, top + rotation, sweep);
    }
  }

  void _paintWavyArc(
    Canvas canvas,
    Paint paint,
    Offset center,
    double radius,
    double start,
    double sweep,
  ) {
    if (amplitude <= 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        paint,
      );
      return;
    }
    final path = Path();
    const step = 0.04;
    for (double a = 0; a <= sweep; a += step) {
      final angle = start + a;
      final r = radius +
          math.sin(angle * waves + phase * 2 * math.pi * waves / 2) * amplitude;
      final p = center + Offset(math.cos(angle), math.sin(angle)) * r;
      if (a == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavyCircularPainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.phase != phase ||
      oldDelegate.color != color;
}
