import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// An analog VU meter with a spring-loaded needle.
///
/// The needle chases [value] (0..1) with the theme's spatial spring, so
/// spikes overshoot and wobble like a real galvanometer. The face shows
/// an arc scale that shifts to the error color in the "hot" zone above
/// [hotFrom]. Set [active] with no explicit value to run an organic
/// self-animating demo level.
///
/// ```dart
/// MEVuMeter(value: level) // drive it yourself
/// MEVuMeter(active: true) // self-animating demo mode
/// ```
class MEVuMeter extends StatefulWidget {
  const MEVuMeter({
    super.key,
    this.value,
    this.active = false,
    this.width = 220,
    this.hotFrom = 0.78,
    this.label,
    this.semanticLabel,
  });

  /// Level from 0.0 to 1.0. If null and [active] is true, the meter
  /// animates itself with an organic signal.
  final double? value;

  /// Self-animate when [value] is null.
  final bool active;

  /// Width of the meter face. Height derives from a 5:3 ratio.
  final double width;

  /// Normalized position where the hot (red) zone begins.
  final double hotFrom;

  /// Optional label under the needle, e.g. "L" or "VU".
  final String? label;

  final String? semanticLabel;

  @override
  State<MEVuMeter> createState() => _MEVuMeterState();
}

class _MEVuMeterState extends State<MEVuMeter>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _needle = 0; // Sprung needle position.
  double _needleVel = 0;
  double _target = 0;
  double _phase = 0;
  Duration _last = Duration.zero;

  @override
  void initState() {
    super.initState();
    _target = widget.value ?? 0;
    _needle = _target;
    _ticker = createTicker(_tick)..start();
  }

  @override
  void didUpdateWidget(MEVuMeter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != null) _target = widget.value!.clamp(0.0, 1.0);
  }

  void _tick(Duration elapsed) {
    final dt = ((elapsed - _last).inMicroseconds / 1e6).clamp(0.0, 1 / 30);
    _last = elapsed;

    // Demo signal: layered sines resembling program audio.
    if (widget.value == null && widget.active) {
      _phase += dt;
      final s = 0.55 +
          0.28 * math.sin(_phase * 2.1) * math.sin(_phase * 0.47) +
          0.17 * math.sin(_phase * 7.3) * math.cos(_phase * 1.9);
      _target = s.clamp(0.0, 1.0);
    } else if (widget.value == null) {
      _target = 0;
    }

    // Integrate a spring toward the target (galvanometer physics).
    const stiffness = 170.0;
    const damping = 11.0;
    final accel = stiffness * (_target - _needle) - damping * _needleVel;
    _needleVel += accel * dt;
    _needle += _needleVel * dt;

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
    final height = widget.width * 0.6;

    return Semantics(
      label: widget.semanticLabel ?? 'Level meter',
      value: '${(_target * 100).round()} percent',
      child: Container(
        width: widget.width,
        height: height,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: CustomPaint(
          painter: _VuPainter(
            needle: _needle.clamp(-0.04, 1.06),
            hotFrom: widget.hotFrom,
            faceColor: scheme.surfaceContainerHighest,
            scaleColor: scheme.onSurfaceVariant,
            needleColor: scheme.onSurface,
            accentColor: scheme.primary,
            hotColor: scheme.error,
            label: widget.label,
            labelStyle: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ),
      ),
    );
  }
}

class _VuPainter extends CustomPainter {
  _VuPainter({
    required this.needle,
    required this.hotFrom,
    required this.faceColor,
    required this.scaleColor,
    required this.needleColor,
    required this.accentColor,
    required this.hotColor,
    required this.label,
    required this.labelStyle,
  });

  final double needle;
  final double hotFrom;
  final Color faceColor;
  final Color scaleColor;
  final Color needleColor;
  final Color accentColor;
  final Color hotColor;
  final String? label;
  final TextStyle labelStyle;

  // Sweep from 210 deg to 330 deg (a 120 deg arc), pivot near the bottom.
  static const double _start = 210 * math.pi / 180;
  static const double _sweep = 120 * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final pivot = Offset(size.width / 2, size.height * 1.06);
    final radius = size.height * 0.88;

    // Scale arc: normal zone in onSurfaceVariant, hot zone in error.
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: pivot, radius: radius);
    arcPaint.color = scaleColor.withValues(alpha: 0.55);
    canvas.drawArc(rect, _start, _sweep * hotFrom, false, arcPaint);
    arcPaint.color = hotColor;
    canvas.drawArc(
      rect,
      _start + _sweep * hotFrom,
      _sweep * (1 - hotFrom),
      false,
      arcPaint,
    );

    // Tick marks.
    final tickPaint = Paint()..strokeCap = StrokeCap.round;
    for (int i = 0; i <= 10; i++) {
      final f = i / 10;
      final angle = _start + _sweep * f;
      final isMajor = i % 5 == 0;
      final inner = radius - (isMajor ? 14 : 8);
      tickPaint
        ..color = (f >= hotFrom ? hotColor : scaleColor)
            .withValues(alpha: isMajor ? 0.9 : 0.5)
        ..strokeWidth = isMajor ? 2.4 : 1.4;
      canvas.drawLine(
        pivot + Offset(math.cos(angle), math.sin(angle)) * inner,
        pivot + Offset(math.cos(angle), math.sin(angle)) * (radius - 2),
        tickPaint,
      );
    }

    // Needle.
    final needleAngle = _start + _sweep * needle.clamp(-0.04, 1.06);
    final needlePaint = Paint()
      ..color = needleColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      pivot,
      pivot +
          Offset(math.cos(needleAngle), math.sin(needleAngle)) * (radius - 6),
      needlePaint,
    );

    // Pivot cap.
    canvas.drawCircle(pivot, 7, Paint()..color = accentColor);

    // Label.
    if (label != null) {
      final tp = TextPainter(
        text: TextSpan(text: label, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(size.width / 2 - tp.width / 2, size.height * 0.66),
      );
    }
  }

  @override
  bool shouldRepaint(_VuPainter oldDelegate) =>
      oldDelegate.needle != needle || oldDelegate.hotFrom != hotFrom;
}
