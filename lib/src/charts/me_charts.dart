import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// A Material 3 Expressive sparkline (mini line chart).
///
/// The line draws itself in with a spring curve on first build and whenever
/// [values] change, optionally filling the area beneath with a soft wash of
/// the line color. A dot marks the final point.
class MESparkline extends StatelessWidget {
  const MESparkline({
    super.key,
    required this.values,
    this.height = 64,
    this.color,
    this.strokeWidth = 2.5,
    this.fill = true,
    this.showEndDot = true,
  });

  /// The data points, in order. Must contain at least 2 values.
  final List<double> values;
  final double height;

  /// Line color. Defaults to the color scheme primary.
  final Color? color;
  final double strokeWidth;

  /// Paint a translucent area fill under the line.
  final bool fill;

  /// Draw an emphasized dot on the last point.
  final bool showEndDot;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final motion = METheme.of(context).motion;
    final lineColor = color ?? scheme.primary;

    return TweenAnimationBuilder<double>(
      key: ValueKey(Object.hashAll(values)),
      tween: Tween(begin: 0, end: 1),
      duration: motion.slowSpatial.approximateDuration,
      curve: motion.slowSpatial.curve,
      builder: (context, t, _) => SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _SparklinePainter(
            values: values,
            progress: t.clamp(0.0, 1.0),
            color: lineColor,
            strokeWidth: strokeWidth,
            fill: fill,
            showEndDot: showEndDot,
          ),
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.values,
    required this.progress,
    required this.color,
    required this.strokeWidth,
    required this.fill,
    required this.showEndDot,
  });

  final List<double> values;
  final double progress;
  final Color color;
  final double strokeWidth;
  final bool fill;
  final bool showEndDot;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2 || size.width <= 0) return;

    final min = values.reduce(math.min);
    final max = values.reduce(math.max);
    final range = (max - min) == 0 ? 1.0 : (max - min);
    final inset = strokeWidth + 3;

    Offset pointAt(int i) {
      final x = inset + (size.width - inset * 2) * i / (values.length - 1);
      final normalized = (values[i] - min) / range;
      final y = size.height - inset - (size.height - inset * 2) * normalized;
      return Offset(x, y);
    }

    // Smooth path through the points with quadratic midpoint smoothing.
    final path = Path()..moveTo(pointAt(0).dx, pointAt(0).dy);
    for (var i = 1; i < values.length; i++) {
      final prev = pointAt(i - 1);
      final curr = pointAt(i);
      final mid = Offset((prev.dx + curr.dx) / 2, (prev.dy + curr.dy) / 2);
      path.quadraticBezierTo(prev.dx, prev.dy, mid.dx, mid.dy);
      if (i == values.length - 1) path.lineTo(curr.dx, curr.dy);
    }

    // Trim the path to the draw-in progress.
    final metrics = path.computeMetrics().toList();
    final totalLength = metrics.fold<double>(0, (sum, m) => sum + m.length);
    final visible = Path();
    var remaining = totalLength * progress;
    Offset? tip;
    for (final metric in metrics) {
      final take = math.min(remaining, metric.length);
      if (take <= 0) break;
      visible.addPath(metric.extractPath(0, take), Offset.zero);
      final tangent = metric.getTangentForOffset(take);
      if (tangent != null) tip = tangent.position;
      remaining -= take;
    }

    if (fill && tip != null) {
      final area = Path.from(visible)
        ..lineTo(tip.dx, size.height - inset)
        ..lineTo(pointAt(0).dx, size.height - inset)
        ..close();
      canvas.drawPath(
        area,
        Paint()
          ..style = PaintingStyle.fill
          ..shader = ui.Gradient.linear(
            Offset.zero,
            Offset(0, size.height),
            [
              color.withValues(alpha: 0.22),
              color.withValues(alpha: 0.02),
            ],
          ),
      );
    }

    canvas.drawPath(
      visible,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );

    if (showEndDot && tip != null) {
      canvas.drawCircle(tip, strokeWidth + 1.5, Paint()..color = color);
      canvas.drawCircle(
        tip,
        strokeWidth + 4,
        Paint()..color = color.withValues(alpha: 0.25),
      );
    }
  }

  @override
  bool shouldRepaint(_SparklinePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.values != values ||
      oldDelegate.color != color;
}

/// A single bar in an [MEBarChart].
class MEBarChartEntry {
  const MEBarChartEntry({required this.value, this.label, this.color});

  final double value;

  /// Optional label rendered under the bar.
  final String? label;

  /// Per-bar color override.
  final Color? color;
}

/// A Material 3 Expressive animated bar chart.
///
/// Bars grow from the baseline with a staggered spatial spring (each bar
/// starts slightly after the previous one) and have fully-rounded tops.
/// Tapping a bar selects it, morphing it to the primary color and showing
/// its value above.
class MEBarChart extends StatefulWidget {
  const MEBarChart({
    super.key,
    required this.entries,
    this.height = 160,
    this.barWidth = 28,
    this.selectedIndex,
    this.onBarSelected,
  });

  final List<MEBarChartEntry> entries;
  final double height;
  final double barWidth;

  /// Externally controlled selection. When null the chart manages its own.
  final int? selectedIndex;
  final ValueChanged<int>? onBarSelected;

  @override
  State<MEBarChart> createState() => _MEBarChartState();
}

class _MEBarChartState extends State<MEBarChart> {
  int? _internalSelected;

  int? get _selected => widget.selectedIndex ?? _internalSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final motion = METheme.of(context).motion;
    final maxValue = widget.entries.isEmpty
        ? 1.0
        : widget.entries.map((e) => e.value).reduce(math.max);
    final hasLabels = widget.entries.any((e) => e.label != null);

    return SizedBox(
      height: widget.height + (hasLabels ? 24 : 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (var i = 0; i < widget.entries.length; i++)
            _buildBar(context, i, scheme, text, motion, maxValue, hasLabels),
        ],
      ),
    );
  }

  Widget _buildBar(
    BuildContext context,
    int index,
    ColorScheme scheme,
    TextTheme text,
    MEMotionScheme motion,
    double maxValue,
    bool hasLabels,
  ) {
    final entry = widget.entries[index];
    final selected = _selected == index;
    final barColor =
        selected ? scheme.primary : (entry.color ?? scheme.secondaryContainer);
    final fraction =
        maxValue <= 0 ? 0.0 : (entry.value / maxValue).clamp(0.0, 1.0);
    final targetHeight = (widget.height - 28) * fraction;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Value label pops in above the selected bar.
        AnimatedScale(
          scale: selected ? 1 : 0,
          duration: motion.fastSpatial.approximateDuration,
          curve: motion.fastSpatial.curve,
          child: Text(
            entry.value % 1 == 0
                ? entry.value.toInt().toString()
                : entry.value.toStringAsFixed(1),
            style: text.labelMedium!.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () {
            if (widget.selectedIndex == null) {
              setState(() => _internalSelected = selected ? null : index);
            }
            widget.onBarSelected?.call(index);
          },
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: targetHeight),
            // Stagger: each bar starts a beat after the previous one.
            duration: motion.defaultSpatial.approximateDuration +
                Duration(milliseconds: index * 60),
            curve: Interval(
              (index * 0.08).clamp(0.0, 0.5),
              1.0,
              curve: motion.defaultSpatial.curve,
            ),
            builder: (context, h, _) => AnimatedContainer(
              duration: motion.defaultEffects.approximateDuration,
              curve: motion.defaultEffects.curve,
              width: widget.barWidth,
              height: math.max(h, 4),
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(widget.barWidth / 2),
                  bottom: Radius.circular(selected ? widget.barWidth / 4 : 4),
                ),
              ),
            ),
          ),
        ),
        if (hasLabels) ...[
          const SizedBox(height: 6),
          SizedBox(
            height: 18,
            child: Text(
              entry.label ?? '',
              style: text.labelSmall!.copyWith(
                color: selected ? scheme.primary : scheme.onSurfaceVariant,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
