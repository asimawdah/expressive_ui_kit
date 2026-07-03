import 'package:flutter/material.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// A vertical thermometer gauge with a spring-animated mercury column.
///
/// The column springs to its level with the slow spatial spring, so it
/// overshoots slightly like real liquid settling. The mercury color blends
/// from primary (cold) through tertiary (warm) to error (hot) as the value
/// climbs. Tick marks and an optional live readout accompany the tube.
class METhermometer extends StatefulWidget {
  const METhermometer({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 100,
    this.height = 200,
    this.unit = '°',
    this.showReadout = true,
    this.divisions = 5,
    this.semanticLabel,
  })  : assert(max > min, 'max must be greater than min'),
        assert(divisions >= 2, 'divisions must be at least 2');

  /// Current reading, clamped into [min]..[max].
  final double value;

  /// Range of the scale.
  final double min;
  final double max;

  /// Overall height of the tube.
  final double height;

  /// Unit suffix shown in the readout and tick labels.
  final String unit;

  /// Whether to show the live numeric readout beside the tube.
  final bool showReadout;

  /// Number of labeled ticks along the scale.
  final int divisions;

  final String? semanticLabel;

  @override
  State<METhermometer> createState() => _METhermometerState();
}

class _METhermometerState extends State<METhermometer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _level = AnimationController.unbounded(
    vsync: this,
    value: _normalized(widget.value),
  );

  double _normalized(double v) =>
      ((v - widget.min) / (widget.max - widget.min)).clamp(0.0, 1.0);

  @override
  void didUpdateWidget(METhermometer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value ||
        widget.min != oldWidget.min ||
        widget.max != oldWidget.max) {
      springTo(
        _level,
        _normalized(widget.value),
        METheme.of(context).motion.slowSpatial,
      );
    }
  }

  @override
  void dispose() {
    _level.dispose();
    super.dispose();
  }

  Color _mercuryColor(ColorScheme scheme, double t) {
    // primary (cold) -> tertiary (warm) -> error (hot).
    if (t < 0.5) {
      return Color.lerp(scheme.primary, scheme.tertiary, t * 2)!;
    }
    return Color.lerp(scheme.tertiary, scheme.error, (t - 0.5) * 2)!;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final clamped = widget.value.clamp(widget.min, widget.max);

    return Semantics(
      label: widget.semanticLabel ?? 'Thermometer',
      value: '${clamped.toStringAsFixed(1)}${widget.unit}',
      child: AnimatedBuilder(
        animation: _level,
        builder: (context, _) {
          final t = _level.value.clamp(0.0, 1.05);
          final color = _mercuryColor(scheme, t.clamp(0.0, 1.0));
          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 72,
                height: widget.height,
                child: CustomPaint(
                  painter: _ThermometerPainter(
                    level: t,
                    mercury: color,
                    track: scheme.surfaceContainerHighest,
                    outline: scheme.outlineVariant,
                    tickColor: scheme.onSurfaceVariant,
                    divisions: widget.divisions,
                    min: widget.min,
                    max: widget.max,
                    unit: widget.unit,
                    labelStyle: textTheme.labelSmall!
                        .copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
              ),
              if (widget.showReadout) ...[
                const SizedBox(width: 12),
                Text(
                  '${(widget.min + t.clamp(0.0, 1.0) * (widget.max - widget.min)).toStringAsFixed(1)}${widget.unit}',
                  style: textTheme.headlineSmall!.copyWith(
                    color: color,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ThermometerPainter extends CustomPainter {
  _ThermometerPainter({
    required this.level,
    required this.mercury,
    required this.track,
    required this.outline,
    required this.tickColor,
    required this.divisions,
    required this.min,
    required this.max,
    required this.unit,
    required this.labelStyle,
  });

  final double level;
  final Color mercury;
  final Color track;
  final Color outline;
  final Color tickColor;
  final int divisions;
  final double min;
  final double max;
  final String unit;
  final TextStyle labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    const tubeWidth = 18.0;
    final bulbRadius = tubeWidth * 0.95;
    final tubeX = size.width * 0.35;
    final bulbCenter = Offset(tubeX, size.height - bulbRadius);
    final tubeTop = tubeWidth / 2 + 2;
    final tubeBottom = bulbCenter.dy - bulbRadius * 0.4;

    // Track (empty tube).
    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.fill;
    final tubeRect = RRect.fromLTRBR(
      tubeX - tubeWidth / 2,
      tubeTop - tubeWidth / 2,
      tubeX + tubeWidth / 2,
      tubeBottom,
      const Radius.circular(tubeWidth / 2),
    );
    canvas.drawRRect(tubeRect, trackPaint);
    canvas.drawCircle(bulbCenter, bulbRadius, trackPaint);

    // Mercury fill: bulb plus a column rising with [level].
    final mercuryPaint = Paint()..color = mercury;
    canvas.drawCircle(bulbCenter, bulbRadius - 3, mercuryPaint);
    final columnTop =
        tubeBottom - (tubeBottom - tubeTop) * level.clamp(0.0, 1.05);
    final columnRect = RRect.fromLTRBR(
      tubeX - tubeWidth / 2 + 3,
      columnTop,
      tubeX + tubeWidth / 2 - 3,
      bulbCenter.dy,
      const Radius.circular((tubeWidth - 6) / 2),
    );
    canvas.drawRRect(columnRect, mercuryPaint);

    // Outline.
    final outlinePaint = Paint()
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(tubeRect, outlinePaint);
    canvas.drawCircle(bulbCenter, bulbRadius, outlinePaint);

    // Ticks and labels.
    final tickPaint = Paint()
      ..color = tickColor
      ..strokeWidth = 1.5;
    for (int i = 0; i < divisions; i++) {
      final f = i / (divisions - 1);
      final y = tubeBottom - (tubeBottom - tubeTop) * f;
      canvas.drawLine(
        Offset(tubeX + tubeWidth / 2 + 4, y),
        Offset(tubeX + tubeWidth / 2 + 10, y),
        tickPaint,
      );
      final labelValue = min + f * (max - min);
      final tp = TextPainter(
        text: TextSpan(
          text: labelValue.round().toString(),
          style: labelStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(tubeX + tubeWidth / 2 + 13, y - tp.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(_ThermometerPainter oldDelegate) =>
      oldDelegate.level != level || oldDelegate.mercury != mercury;
}
