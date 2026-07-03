import 'dart:math' as math;

import 'package:flutter/material.dart';

/// An ambient lava-lamp surface: soft metaball blobs rise, fall and
/// wobble inside a rounded container, drawn entirely from scheme colors.
///
/// Useful as a decorative loading backdrop, an "app is idle" ambient
/// panel, or a hero surface behind onboarding copy.
///
/// ```dart
/// const MELavaLamp(width: 200, height: 280)
/// ```
class MELavaLamp extends StatefulWidget {
  const MELavaLamp({
    super.key,
    this.width = 200,
    this.height = 280,
    this.blobCount = 5,
    this.borderRadius = 28,
    this.child,
  });

  /// Size of the lamp surface.
  final double width;
  final double height;

  /// Number of rising blobs (2..8 recommended).
  final int blobCount;

  /// Corner rounding of the lamp container.
  final double borderRadius;

  /// Optional foreground content centered on top of the lamp.
  final Widget? child;

  @override
  State<MELavaLamp> createState() => _MELavaLampState();
}

class _MELavaLampState extends State<MELavaLamp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ticker = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  )..repeat();

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Decorative lava lamp animation',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: scheme.surfaceContainerHighest),
              AnimatedBuilder(
                animation: _ticker,
                builder: (context, _) => CustomPaint(
                  painter: _LavaPainter(
                    t: _ticker.value,
                    blobCount: widget.blobCount.clamp(2, 8),
                    primary: scheme.primary,
                    tertiary: scheme.tertiary,
                  ),
                ),
              ),
              if (widget.child != null) Center(child: widget.child),
            ],
          ),
        ),
      ),
    );
  }
}

class _LavaPainter extends CustomPainter {
  _LavaPainter({
    required this.t,
    required this.blobCount,
    required this.primary,
    required this.tertiary,
  });

  final double t;
  final int blobCount;
  final Color primary;
  final Color tertiary;

  @override
  void paint(Canvas canvas, Size size) {
    // Each blob loops on its own phase-offset cycle. Vertical position
    // follows a full rise/sink loop; horizontal drifts with layered sines
    // so the path never looks mechanical.
    for (int i = 0; i < blobCount; i++) {
      final double phase = i / blobCount;
      final double cycle = (t + phase) % 1.0;
      final double angle = cycle * 2 * math.pi;

      // Rise from below the bottom edge to above the top, eased so blobs
      // dwell near the ends like real wax.
      final double y = size.height * (1.1 - 1.2 * _slowEase(cycle));
      final double x = size.width *
          (0.5 +
              0.30 * math.sin(angle * 1.7 + i * 2.1) +
              0.12 * math.sin(angle * 3.3 + i * 0.7));

      // Blob radius breathes as it moves; alternate between the two
      // accent colors for depth.
      final double baseR = size.shortestSide * (0.16 + 0.06 * (i % 3) / 2);
      final double r = baseR * (1.0 + 0.18 * math.sin(angle * 2.4 + i));
      final Color color = (i.isEven ? primary : tertiary);

      final Paint paint = Paint()
        ..color = color.withValues(alpha: 0.55)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.45);
      canvas.drawCircle(Offset(x, y), r, paint);

      // Bright core for a molten center.
      final Paint core = Paint()
        ..color = color.withValues(alpha: 0.75)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.2);
      canvas.drawCircle(Offset(x, y), r * 0.55, core);
    }
  }

  /// Smootherstep-style ease that lingers at both extremes.
  double _slowEase(double x) {
    final double s = x * x * x * (x * (x * 6 - 15) + 10);
    return s;
  }

  @override
  bool shouldRepaint(_LavaPainter oldDelegate) =>
      oldDelegate.t != t ||
      oldDelegate.blobCount != blobCount ||
      oldDelegate.primary != primary ||
      oldDelegate.tertiary != tertiary;
}
