import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// One axis of an [MERadarChart].
@immutable
class MERadarAxis {
  const MERadarAxis({required this.label, required this.value});

  /// Axis label drawn outside the web.
  final String label;

  /// Value from 0.0 to 1.0.
  final double value;
}

/// A radar (spider) chart whose polygon inflates from the center with a
/// spring on first build, and springs between shapes when values change.
///
/// The web (grid rings + spokes) uses outline colors; the data polygon is
/// filled with translucent primary and stroked with primary, with a dot
/// at each vertex.
class MERadarChart extends StatefulWidget {
  const MERadarChart({
    super.key,
    required this.axes,
    this.size = 220,
    this.ringCount = 4,
    this.color,
  }) : assert(axes.length >= 3, 'A radar chart needs at least 3 axes');

  final List<MERadarAxis> axes;

  /// Width and height of the chart (labels included).
  final double size;

  /// Number of concentric grid rings.
  final int ringCount;

  /// Polygon color. Defaults to the scheme primary.
  final Color? color;

  @override
  State<MERadarChart> createState() => _MERadarChartState();
}

class _MERadarChartState extends State<MERadarChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sweep =
      AnimationController.unbounded(vsync: this, value: 0);
  List<double> _fromValues = [];
  List<double> _toValues = [];

  @override
  void initState() {
    super.initState();
    _fromValues = List.filled(widget.axes.length, 0);
    _toValues = [for (final a in widget.axes) a.value.clamp(0.0, 1.0)];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      springTo(_sweep, 1, METheme.of(context).motion.slowSpatial);
    });
  }

  @override
  void didUpdateWidget(MERadarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = [for (final a in widget.axes) a.value.clamp(0.0, 1.0)];
    if (next.toString() != _toValues.toString() ||
        widget.axes.length != oldWidget.axes.length) {
      // Capture the polygon where it currently is, then spring to the new
      // shape (interruptible).
      final t = _sweep.value.clamp(0.0, 1.0);
      _fromValues = [
        for (var i = 0; i < next.length; i++)
          i < _fromValues.length && i < _toValues.length
              ? _fromValues[i] + (_toValues[i] - _fromValues[i]) * t
              : 0.0,
      ];
      _toValues = next;
      _sweep.value = 0;
      springTo(_sweep, 1, METheme.of(context).motion.defaultSpatial);
    }
  }

  @override
  void dispose() {
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final color = widget.color ?? scheme.primary;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _sweep,
        builder: (context, _) {
          final t = _sweep.value;
          return CustomPaint(
            painter: _RadarPainter(
              labels: [for (final a in widget.axes) a.label],
              values: [
                for (var i = 0; i < _toValues.length; i++)
                  (_fromValues.length > i ? _fromValues[i] : 0.0) +
                      ((_toValues[i]) -
                              (_fromValues.length > i
                                  ? _fromValues[i]
                                  : 0.0)) *
                          t,
              ],
              ringCount: widget.ringCount,
              webColor: scheme.outlineVariant,
              fillColor: color.withValues(alpha: 0.18),
              strokeColor: color,
              labelStyle: text.labelSmall!
                  .copyWith(color: scheme.onSurfaceVariant),
            ),
          );
        },
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter({
    required this.labels,
    required this.values,
    required this.ringCount,
    required this.webColor,
    required this.fillColor,
    required this.strokeColor,
    required this.labelStyle,
  });

  final List<String> labels;
  final List<double> values;
  final int ringCount;
  final Color webColor;
  final Color fillColor;
  final Color strokeColor;
  final TextStyle labelStyle;

  static const double _labelReserve = 28;

  Offset _point(Offset center, double radius, int i, int count) {
    final angle = -math.pi / 2 + (math.pi * 2 / count) * i;
    return center + Offset(math.cos(angle), math.sin(angle)) * radius;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - _labelReserve;
    final count = labels.length;

    final web = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = webColor;

    // Grid rings.
    for (var r = 1; r <= ringCount; r++) {
      final path = Path();
      for (var i = 0; i < count; i++) {
        final p = _point(center, radius * r / ringCount, i, count);
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      path.close();
      canvas.drawPath(path, web);
    }

    // Spokes and labels.
    for (var i = 0; i < count; i++) {
      final edge = _point(center, radius, i, count);
      canvas.drawLine(center, edge, web);

      final painter = TextPainter(
        text: TextSpan(text: labels[i], style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      final labelPos = _point(center, radius + 14, i, count);
      painter.paint(
        canvas,
        labelPos - Offset(painter.width / 2, painter.height / 2),
      );
    }

    // Data polygon.
    final path = Path();
    for (var i = 0; i < count; i++) {
      final v = (i < values.length ? values[i] : 0.0).clamp(0.0, 1.0);
      final p = _point(center, radius * v, i, count);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();

    canvas.drawPath(path, Paint()..color = fillColor);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..color = strokeColor,
    );

    // Vertex dots.
    for (var i = 0; i < count; i++) {
      final v = (i < values.length ? values[i] : 0.0).clamp(0.0, 1.0);
      final p = _point(center, radius * v, i, count);
      canvas.drawCircle(p, 3.5, Paint()..color = strokeColor);
    }
  }

  @override
  bool shouldRepaint(_RadarPainter oldDelegate) =>
      oldDelegate.values.toString() != values.toString() ||
      oldDelegate.labels != labels;
}
