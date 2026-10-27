import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/me_theme.dart';

/// A Material 3 Expressive radial gauge.
///
/// A rounded arc sweeps from empty to [value] with a spatial spring, so it
/// slightly overshoots and settles. The center shows the value as a large
/// emphasized number (or any custom [center] widget).
class MEGauge extends StatelessWidget {
  const MEGauge({
    super.key,
    required this.value,
    this.size = 160,
    this.thickness = 14,
    this.color,
    this.trackColor,
    this.startAngle = 135,
    this.sweepAngle = 270,
    this.center,
    this.label,
    this.semanticLabel,
  }) : assert(value >= 0 && value <= 1, 'value must be within 0...1');

  /// Progress within 0.0 ... 1.0.
  final double value;
  final double size;
  final double thickness;

  /// Arc color. Defaults to the color scheme primary.
  final Color? color;

  /// Track color. Defaults to `surfaceContainerHighest`.
  final Color? trackColor;

  /// Where the arc begins, in degrees (0 = right, clockwise).
  final double startAngle;

  /// Total sweep of the track in degrees.
  final double sweepAngle;

  /// Custom center content. Defaults to the percentage as emphasized text.
  final Widget? center;

  /// Small label under the center value.
  final Widget? label;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final motion = METheme.of(context).motion;
    final arcColor = color ?? scheme.primary;
    final track = trackColor ?? scheme.surfaceContainerHighest;

    return Semantics(
      label: semanticLabel ?? 'Gauge',
      value: '${(value * 100).round()}%',
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
        duration: motion.slowSpatial.approximateDuration,
        curve: motion.slowSpatial.curve,
        builder: (context, t, child) => SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _GaugePainter(
              progress: t,
              color: arcColor,
              trackColor: track,
              thickness: thickness,
              startAngle: startAngle,
              sweepAngle: sweepAngle,
            ),
            child: Center(
              child: center ??
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(t * 100).round()}%',
                        style: METypography.emphasize(
                          text.headlineMedium!.copyWith(
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                      if (label != null)
                        DefaultTextStyle.merge(
                          style: text.labelMedium!.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                          child: label!,
                        ),
                    ],
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.thickness,
    required this.startAngle,
    required this.sweepAngle,
  });

  final double progress;
  final Color color;
  final Color trackColor;
  final double thickness;
  final double startAngle;
  final double sweepAngle;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(thickness / 2);
    final start = startAngle * math.pi / 180;
    final sweep = sweepAngle * math.pi / 180;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..color = trackColor;
    canvas.drawArc(arcRect, start, sweep, false, trackPaint);

    // The spring can overshoot past the target; clamp to the track so the
    // arc never escapes the gauge.
    final t = progress.clamp(0.0, 1.0);
    if (t > 0) {
      final arcPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round
        ..color = color;
      canvas.drawArc(arcRect, start, sweep * t, false, arcPaint);
    }
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) =>
      progress != oldDelegate.progress ||
      color != oldDelegate.color ||
      trackColor != oldDelegate.trackColor ||
      thickness != oldDelegate.thickness;
}
