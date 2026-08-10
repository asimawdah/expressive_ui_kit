import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// A speedometer-style gauge with a spring-driven needle.
///
/// The needle sweeps a 240-degree arc and chases [value] with the slow
/// spatial spring, so rapid changes overshoot and wobble like a real
/// instrument. The arc is painted in three zones (normal, caution, hot)
/// derived from the color scheme, and the current value is shown in a
/// large rolling readout beneath the pivot.
class MESpeedometer extends StatefulWidget {
  const MESpeedometer({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 100,
    this.cautionFrom = 0.6,
    this.hotFrom = 0.85,
    this.size = 180,
    this.unit,
    this.semanticLabel,
  })  : assert(max > min),
        assert(cautionFrom >= 0 && cautionFrom <= 1),
        assert(hotFrom >= 0 && hotFrom <= 1);

  /// Current reading, clamped into [min]..[max].
  final double value;

  final double min;
  final double max;

  /// Fraction of the range where the caution (tertiary) zone begins.
  final double cautionFrom;

  /// Fraction of the range where the hot (error) zone begins.
  final double hotFrom;

  /// Diameter of the gauge.
  final double size;

  /// Optional unit label rendered under the readout (e.g. 'km/h').
  final String? unit;

  final String? semanticLabel;

  @override
  State<MESpeedometer> createState() => _MESpeedometerState();
}

class _MESpeedometerState extends State<MESpeedometer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _needle = AnimationController.unbounded(
    vsync: this,
    value: _fraction(widget.value),
  );

  double _fraction(double v) =>
      ((v - widget.min) / (widget.max - widget.min)).clamp(0.0, 1.0);

  @override
  void didUpdateWidget(MESpeedometer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value ||
        widget.min != oldWidget.min ||
        widget.max != oldWidget.max) {
      springTo(
        _needle,
        _fraction(widget.value),
        METheme.of(context).motion.slowSpatial,
      );
    }
  }

  @override
  void dispose() {
    _needle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label: widget.semanticLabel ?? 'Gauge',
      value: widget.value.round().toString(),
      child: SizedBox(
        width: widget.size,
        height: widget.size * 0.82,
        child: AnimatedBuilder(
          animation: _needle,
          builder: (context, _) {
            final t = _needle.value;
            return Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(widget.size, widget.size * 0.82),
                  painter: _MESpeedometerPainter(
                    fraction: t,
                    trackColor: scheme.surfaceContainerHighest,
                    normalColor: scheme.primary,
                    cautionColor: scheme.tertiary,
                    hotColor: scheme.error,
                    needleColor: scheme.onSurface,
                    pivotColor: scheme.onSurface,
                    tickColor: scheme.outlineVariant,
                    cautionFrom: widget.cautionFrom,
                    hotFrom: widget.hotFrom,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        (widget.min +
                                t.clamp(0.0, 1.0) * (widget.max - widget.min))
                            .round()
                            .toString(),
                        style: textTheme.headlineSmall!.copyWith(
                          fontFeatures: const [
                            FontFeature.tabularFigures(),
                          ],
                          color: scheme.onSurface,
                        ),
                      ),
                      if (widget.unit != null)
                        Text(
                          widget.unit!,
                          style: textTheme.labelSmall!.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MESpeedometerPainter extends CustomPainter {
  _MESpeedometerPainter({
    required this.fraction,
    required this.trackColor,
    required this.normalColor,
    required this.cautionColor,
    required this.hotColor,
    required this.needleColor,
    required this.pivotColor,
    required this.tickColor,
    required this.cautionFrom,
    required this.hotFrom,
  });

  final double fraction;
  final Color trackColor;
  final Color normalColor;
  final Color cautionColor;
  final Color hotColor;
  final Color needleColor;
  final Color pivotColor;
  final Color tickColor;
  final double cautionFrom;
  final double hotFrom;

  // 240-degree sweep starting at 150 degrees (7:30 -> 4:30 positions).
  static const double _start = 150 * math.pi / 180;
  static const double _sweep = 240 * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.62);
    final radius = size.width / 2 - 8;
    final stroke = size.width * 0.075;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Track.
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = trackColor;
    canvas.drawArc(rect, _start, _sweep, false, track);

    // Colored zones. Drawn as three arcs; butt caps so they abut cleanly.
    final zone = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    zone.color = normalColor;
    canvas.drawArc(rect, _start, _sweep * cautionFrom, false, zone);
    zone.color = cautionColor;
    canvas.drawArc(
      rect,
      _start + _sweep * cautionFrom,
      _sweep * (hotFrom - cautionFrom),
      false,
      zone,
    );
    zone.color = hotColor;
    canvas.drawArc(
      rect,
      _start + _sweep * hotFrom,
      _sweep * (1 - hotFrom),
      false,
      zone,
    );

    // Ticks.
    final tick = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = tickColor;
    for (var i = 0; i <= 12; i++) {
      final angle = _start + _sweep * (i / 12);
      final dir = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(
        center + dir * (radius - stroke * 1.2),
        center + dir * (radius - stroke * 1.8),
        tick,
      );
    }

    // Needle. The unclamped spring fraction lets the needle physically
    // overshoot past the zone ends before settling.
    final angle = _start + _sweep * fraction.clamp(-0.04, 1.04);
    final dir = Offset(math.cos(angle), math.sin(angle));
    final needle = Paint()
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..color = needleColor;
    canvas.drawLine(
      center - dir * (radius * 0.12),
      center + dir * (radius * 0.72),
      needle,
    );

    // Pivot.
    canvas.drawCircle(center, 6, Paint()..color = pivotColor);
  }

  @override
  bool shouldRepaint(_MESpeedometerPainter oldDelegate) =>
      oldDelegate.fraction != fraction ||
      oldDelegate.normalColor != normalColor;
}
