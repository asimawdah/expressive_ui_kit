import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// A blip on an [MESonar] display.
@immutable
class MESonarBlip {
  const MESonarBlip({required this.angle, required this.distance});

  /// Bearing in degrees, 0 = up, clockwise.
  final double angle;

  /// Normalized distance from center, 0.0 (center) to 1.0 (edge).
  final double distance;
}

/// A sonar/radar display with a rotating sweep that lights up blips.
///
/// The sweep rotates continuously; each [MESonarBlip] flares to full
/// brightness as the beam passes over it, then decays until the next
/// pass — the classic radar afterglow. Ranged rings and cross-hairs are
/// drawn from scheme colors, so the whole display adapts to theming.
///
/// ```dart
/// MESonar(
///   blips: const [
///     MESonarBlip(angle: 40, distance: 0.55),
///     MESonarBlip(angle: 210, distance: 0.8),
///   ],
/// )
/// ```
class MESonar extends StatefulWidget {
  const MESonar({
    super.key,
    this.blips = const [],
    this.size = 200,
    this.period = const Duration(seconds: 3),
    this.semanticLabel,
  });

  /// Targets shown on the display.
  final List<MESonarBlip> blips;

  /// Diameter of the display.
  final double size;

  /// Time for one full sweep rotation.
  final Duration period;

  final String? semanticLabel;

  @override
  State<MESonar> createState() => _MESonarState();
}

class _MESonarState extends State<MESonar> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _sweep = 0; // Radians, 0 = up.

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
  }

  void _tick(Duration elapsed) {
    final periodUs = widget.period.inMicroseconds;
    _sweep = (elapsed.inMicroseconds % periodUs) / periodUs * 2 * math.pi;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: widget.semanticLabel ??
          'Sonar display, ${widget.blips.length} contacts',
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _SonarPainter(
            sweep: _sweep,
            blips: widget.blips,
            surface: scheme.surfaceContainerHighest,
            grid: scheme.onSurfaceVariant,
            beam: scheme.primary,
            blip: scheme.tertiary,
          ),
        ),
      ),
    );
  }
}

class _SonarPainter extends CustomPainter {
  _SonarPainter({
    required this.sweep,
    required this.blips,
    required this.surface,
    required this.grid,
    required this.beam,
    required this.blip,
  });

  final double sweep;
  final List<MESonarBlip> blips;
  final Color surface;
  final Color grid;
  final Color beam;
  final Color blip;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;

    // Face.
    canvas.drawCircle(center, radius, Paint()..color = surface);

    // Range rings and cross-hairs.
    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = grid.withValues(alpha: 0.35);
    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(center, radius * i / 3, gridPaint);
    }
    canvas.drawLine(
        center - Offset(radius, 0), center + Offset(radius, 0), gridPaint);
    canvas.drawLine(
        center - Offset(0, radius), center + Offset(0, radius), gridPaint);

    // Sweep beam: a fading wedge trailing behind the leading edge.
    // Angle convention: 0 = up, clockwise -> canvas angle = sweep - pi/2.
    final beamAngle = sweep - math.pi / 2;
    const trail = math.pi * 0.6;
    final beamShader = SweepGradient(
      startAngle: 0,
      endAngle: trail,
      colors: [
        beam.withValues(alpha: 0),
        beam.withValues(alpha: 0.35),
      ],
      transform: GradientRotation(beamAngle - trail),
    ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawPath(
      Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius),
          beamAngle - trail,
          trail,
          false,
        )
        ..close(),
      Paint()..shader = beamShader,
    );

    // Leading edge line.
    canvas.drawLine(
      center,
      center + Offset(math.cos(beamAngle), math.sin(beamAngle)) * radius,
      Paint()
        ..color = beam
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    // Blips: brightness decays with angular distance behind the beam.
    for (final b in blips) {
      final blipAngle = b.angle * math.pi / 180;
      // Angular distance the beam has traveled past this blip (0..2pi).
      double behind = (sweep - blipAngle) % (2 * math.pi);
      if (behind < 0) behind += 2 * math.pi;
      final double glow = (1.0 - behind / (2 * math.pi)).clamp(0.0, 1.0);
      final intensity = glow * glow; // Sharper decay.
      if (intensity <= 0.02) continue;

      final pos = center +
          Offset(
                math.sin(blipAngle),
                -math.cos(blipAngle),
              ) *
              (radius * b.distance.clamp(0.0, 0.96));

      // Halo + core.
      canvas.drawCircle(
        pos,
        6 + 6 * intensity,
        Paint()..color = blip.withValues(alpha: 0.25 * intensity),
      );
      canvas.drawCircle(
        pos,
        3.5,
        Paint()..color = blip.withValues(alpha: intensity),
      );
    }

    // Rim.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = grid.withValues(alpha: 0.5),
    );
  }

  @override
  bool shouldRepaint(_SonarPainter oldDelegate) =>
      oldDelegate.sweep != sweep || oldDelegate.blips != blips;
}
