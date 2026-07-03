import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// A compass dial that springs toward a heading.
///
/// The dial rotates so the given [heading] (degrees clockwise from north)
/// points at the fixed top index. Changes are driven by the theme's slow
/// spatial spring, so the needle overshoots and settles like a physical
/// compass. The dial always takes the shortest rotational path, unwrapping
/// across the 0/360 boundary.
///
/// ```dart
/// MECompass(heading: bearingDegrees, size: 180)
/// ```
class MECompass extends StatefulWidget {
  const MECompass({
    super.key,
    required this.heading,
    this.size = 180,
    this.showDegrees = true,
    this.semanticLabel,
  });

  /// Heading in degrees, clockwise from north. Values outside 0..360 wrap.
  final double heading;

  final double size;

  /// Show the numeric readout under the needle.
  final bool showDegrees;

  final String? semanticLabel;

  @override
  State<MECompass> createState() => _MECompassState();
}

class _MECompassState extends State<MECompass>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotation = AnimationController.unbounded(
    vsync: this,
    value: _normalize(widget.heading),
  );

  static double _normalize(double degrees) {
    final d = degrees % 360;
    return d < 0 ? d + 360 : d;
  }

  @override
  void didUpdateWidget(MECompass oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.heading != oldWidget.heading) {
      // Unwrap so the spring takes the shortest path (e.g. 350 -> 10 goes
      // +20 degrees, not -340).
      final current = _rotation.value;
      var target = _normalize(widget.heading);
      final currentNorm = _normalize(current);
      var delta = target - currentNorm;
      if (delta > 180) delta -= 360;
      if (delta < -180) delta += 360;
      target = current + delta;
      springTo(_rotation, target, METheme.of(context).motion.slowSpatial);
    }
  }

  @override
  void dispose() {
    _rotation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label: widget.semanticLabel ??
          'Compass, heading ${_normalize(widget.heading).round()} degrees',
      child: AnimatedBuilder(
        animation: _rotation,
        builder: (context, _) {
          final heading = _rotation.value;
          return SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Rotating dial with cardinal marks.
                Transform.rotate(
                  angle: -heading * math.pi / 180,
                  child: CustomPaint(
                    size: Size.square(widget.size),
                    painter: _MECompassDialPainter(
                      ring: scheme.surfaceContainerHigh,
                      tick: scheme.onSurfaceVariant,
                      north: scheme.error,
                      cardinal: scheme.onSurface,
                      textStyle: textTheme.labelLarge!,
                    ),
                  ),
                ),
                // Fixed top index marker.
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.arrow_drop_down,
                      color: scheme.primary,
                      size: widget.size * 0.16,
                    ),
                  ),
                ),
                if (widget.showDegrees)
                  Text(
                    '${_normalize(heading).round()}°',
                    style: textTheme.headlineSmall!.copyWith(
                      color: scheme.onSurface,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MECompassDialPainter extends CustomPainter {
  _MECompassDialPainter({
    required this.ring,
    required this.tick,
    required this.north,
    required this.cardinal,
    required this.textStyle,
  });

  final Color ring;
  final Color tick;
  final Color north;
  final Color cardinal;
  final TextStyle textStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()..color = ring,
    );

    // Tick marks every 15 degrees; longer every 45.
    final tickPaint = Paint()
      ..color = tick
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (int deg = 0; deg < 360; deg += 15) {
      final isMajor = deg % 45 == 0;
      final angle = (deg - 90) * math.pi / 180;
      final outer = center + Offset.fromDirection(angle, radius * 0.92);
      final inner = center +
          Offset.fromDirection(angle, radius * (isMajor ? 0.78 : 0.86));
      canvas.drawLine(inner, outer, tickPaint);
    }

    // Cardinal letters.
    const cardinals = ['N', 'E', 'S', 'W'];
    for (int i = 0; i < 4; i++) {
      final angle = (i * 90 - 90) * math.pi / 180;
      final pos = center + Offset.fromDirection(angle, radius * 0.62);
      final painter = TextPainter(
        text: TextSpan(
          text: cardinals[i],
          style: textStyle.copyWith(
            color: i == 0 ? north : cardinal,
            fontWeight: i == 0 ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        pos - Offset(painter.width / 2, painter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(_MECompassDialPainter oldDelegate) =>
      ring != oldDelegate.ring ||
      tick != oldDelegate.tick ||
      north != oldDelegate.north ||
      cardinal != oldDelegate.cardinal;
}
