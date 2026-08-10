import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// A single series in an [MELineChart].
class MELineSeries {
  const MELineSeries({
    required this.values,
    this.label,
    this.color,
  });

  final List<double> values;
  final String? label;

  /// Series color. Defaults to a color-scheme role by series index
  /// (primary, tertiary, secondary).
  final Color? color;
}

/// A Material 3 Expressive multi-series line chart.
///
/// Lines draw themselves in with the slow spatial spring. Touch and drag
/// to scrub: a vertical guide with a value bubble follows the pointer,
/// snapping to the nearest data point on each series.
///
/// ```dart
/// MELineChart(series: [
///   MELineSeries(values: revenue, label: 'Revenue'),
///   MELineSeries(values: costs, label: 'Costs'),
/// ])
/// ```
class MELineChart extends StatefulWidget {
  const MELineChart({
    super.key,
    required this.series,
    this.height = 180,
    this.gridLines = 4,
    this.showLegend = true,
  });

  final List<MELineSeries> series;
  final double height;

  /// Number of horizontal grid lines behind the chart.
  final int gridLines;

  /// Whether to show a legend row under the chart (uses series labels).
  final bool showLegend;

  @override
  State<MELineChart> createState() => _MELineChartState();
}

class _MELineChartState extends State<MELineChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter = AnimationController.unbounded(
    vsync: this,
    value: 0,
  );

  /// Scrub position as a fraction of chart width, or null when idle.
  double? _scrub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      springTo(_enter, 1, METheme.of(context).motion.slowSpatial);
    });
  }

  @override
  void didUpdateWidget(MELineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.series, oldWidget.series)) {
      _enter.value = 0;
      springTo(_enter, 1, METheme.of(context).motion.slowSpatial);
    }
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  Color _seriesColor(int index, ColorScheme scheme) {
    final defaults = [scheme.primary, scheme.tertiary, scheme.secondary];
    return widget.series[index].color ?? defaults[index % defaults.length];
  }

  void _updateScrub(Offset local, double width) {
    setState(() => _scrub = (local.dx / width).clamp(0.0, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: widget.height,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return GestureDetector(
                onHorizontalDragStart: (d) =>
                    _updateScrub(d.localPosition, width),
                onHorizontalDragUpdate: (d) =>
                    _updateScrub(d.localPosition, width),
                onHorizontalDragEnd: (_) => setState(() => _scrub = null),
                onTapDown: (d) => _updateScrub(d.localPosition, width),
                onTapUp: (_) => setState(() => _scrub = null),
                child: AnimatedBuilder(
                  animation: _enter,
                  builder: (context, _) => CustomPaint(
                    size: Size(width, widget.height),
                    painter: _LineChartPainter(
                      series: widget.series,
                      colors: [
                        for (int i = 0; i < widget.series.length; i++)
                          _seriesColor(i, scheme),
                      ],
                      progress: _enter.value.clamp(0.0, 1.0),
                      scrub: _scrub,
                      gridColor: scheme.outlineVariant.withValues(alpha: 0.6),
                      gridLines: widget.gridLines,
                      bubbleColor: scheme.inverseSurface,
                      bubbleTextColor: scheme.onInverseSurface,
                      bubbleTextStyle: text.labelSmall!,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.showLegend && widget.series.any((s) => s.label != null)) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              for (int i = 0; i < widget.series.length; i++)
                if (widget.series[i].label != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _seriesColor(i, scheme),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.series[i].label!,
                        style: text.labelMedium!
                            .copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
            ],
          ),
        ],
      ],
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.series,
    required this.colors,
    required this.progress,
    required this.scrub,
    required this.gridColor,
    required this.gridLines,
    required this.bubbleColor,
    required this.bubbleTextColor,
    required this.bubbleTextStyle,
  });

  final List<MELineSeries> series;
  final List<Color> colors;
  final double progress;
  final double? scrub;
  final Color gridColor;
  final int gridLines;
  final Color bubbleColor;
  final Color bubbleTextColor;
  final TextStyle bubbleTextStyle;

  @override
  void paint(Canvas canvas, Size size) {
    double minV = double.infinity;
    double maxV = double.negativeInfinity;
    for (final s in series) {
      for (final v in s.values) {
        minV = math.min(minV, v);
        maxV = math.max(maxV, v);
      }
    }
    if (!minV.isFinite || maxV - minV < 1e-9) {
      minV = 0;
      maxV = math.max(1, maxV.isFinite ? maxV : 1);
    }

    // Grid.
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (int i = 0; i <= gridLines; i++) {
      final y = size.height * i / gridLines;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    Offset pointAt(List<double> values, int i) {
      final x = values.length <= 1 ? 0.0 : size.width * i / (values.length - 1);
      final t = (values[i] - minV) / (maxV - minV);
      return Offset(x, size.height * (1 - t));
    }

    // Series lines, revealed left-to-right by [progress].
    for (int s = 0; s < series.length; s++) {
      final values = series[s].values;
      if (values.length < 2) continue;
      final path = Path()..moveTo(pointAt(values, 0).dx, pointAt(values, 0).dy);
      for (int i = 1; i < values.length; i++) {
        final p0 = pointAt(values, i - 1);
        final p1 = pointAt(values, i);
        final cx = (p0.dx + p1.dx) / 2;
        path.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
      }

      final linePaint = Paint()
        ..color = colors[s]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

      if (progress >= 1.0) {
        canvas.drawPath(path, linePaint);
      } else {
        for (final metric in path.computeMetrics()) {
          canvas.drawPath(
            metric.extractPath(0, metric.length * progress),
            linePaint,
          );
        }
      }
    }

    // Scrub guide + value bubble.
    if (scrub != null && series.isNotEmpty) {
      final x = size.width * scrub!;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        Paint()
          ..color = gridColor
          ..strokeWidth = 2,
      );

      final first = series.first.values;
      if (first.length >= 2) {
        final index =
            (scrub! * (first.length - 1)).round().clamp(0, first.length - 1);
        for (int s = 0; s < series.length; s++) {
          final values = series[s].values;
          if (index >= values.length) continue;
          final p = pointAt(values, index);
          canvas.drawCircle(p, 5, Paint()..color = colors[s]);
        }

        // Bubble with the first series' value at the snapped index.
        final label = first[index].toStringAsFixed(
          first[index].truncateToDouble() == first[index] ? 0 : 1,
        );
        final tp = TextPainter(
          text: TextSpan(
            text: label,
            style: bubbleTextStyle.copyWith(color: bubbleTextColor),
          ),
          textDirection: ui.TextDirection.ltr,
        )..layout();
        const pad = 8.0;
        final bubbleWidth = tp.width + pad * 2;
        final bx = (x - bubbleWidth / 2).clamp(0.0, size.width - bubbleWidth);
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(bx, 0, bubbleWidth, tp.height + pad),
          Radius.circular((tp.height + pad) / 2),
        );
        canvas.drawRRect(rect, Paint()..color = bubbleColor);
        tp.paint(canvas, Offset(bx + pad, pad / 2));
      }
    }
  }

  @override
  bool shouldRepaint(_LineChartPainter old) =>
      old.progress != progress ||
      old.scrub != scrub ||
      !identical(old.series, series);
}
