import 'package:flutter/material.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// A category in an [MEStackedBarChart].
@immutable
class MEStackedBar {
  const MEStackedBar({required this.values, this.label});

  /// One value per series. All bars must have the same number of values.
  final List<double> values;

  /// Optional label rendered under the bar.
  final String? label;
}

/// A stacked bar chart with staggered spring growth.
///
/// Each bar's segments grow from the baseline, staggered left to right,
/// driven by the theme's slow spatial spring so bars overshoot slightly.
/// Segment colors derive from the color scheme (primary, tertiary,
/// secondary, then error) unless [colors] is given. Values re-animate
/// interruptibly when the data changes.
///
/// ```dart
/// MEStackedBarChart(
///   seriesLabels: const ['Direct', 'Referral'],
///   bars: const [
///     MEStackedBar(values: [40, 24], label: 'Mon'),
///     MEStackedBar(values: [55, 30], label: 'Tue'),
///   ],
/// )
/// ```
class MEStackedBarChart extends StatefulWidget {
  const MEStackedBarChart({
    super.key,
    required this.bars,
    this.seriesLabels,
    this.colors,
    this.height = 220,
    this.barRadius = 6,
    this.semanticLabel,
  });

  final List<MEStackedBar> bars;

  /// Legend labels, one per series. No legend is shown when null.
  final List<String>? seriesLabels;

  /// Segment colors, one per series. Defaults to scheme-derived colors.
  final List<Color>? colors;

  final double height;
  final double barRadius;
  final String? semanticLabel;

  @override
  State<MEStackedBarChart> createState() => _MEStackedBarChartState();
}

class _MEStackedBarChartState extends State<MEStackedBarChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _grow = AnimationController.unbounded(
    vsync: this,
    value: 0,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        springTo(_grow, 1, METheme.of(context).motion.slowSpatial);
      }
    });
  }

  @override
  void didUpdateWidget(MEStackedBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.bars, oldWidget.bars)) {
      _grow.value = 0;
      springTo(_grow, 1, METheme.of(context).motion.slowSpatial);
    }
  }

  @override
  void dispose() {
    _grow.dispose();
    super.dispose();
  }

  List<Color> _seriesColors(ColorScheme scheme) {
    if (widget.colors != null) return widget.colors!;
    return [scheme.primary, scheme.tertiary, scheme.secondary, scheme.error];
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final colors = _seriesColors(scheme);

    double maxTotal = 0;
    for (final bar in widget.bars) {
      final total = bar.values.fold<double>(0, (a, b) => a + b);
      if (total > maxTotal) maxTotal = total;
    }
    if (maxTotal <= 0) maxTotal = 1;

    return Semantics(
      label: widget.semanticLabel ?? 'Stacked bar chart',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: widget.height,
            child: AnimatedBuilder(
              animation: _grow,
              builder: (context, _) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (int i = 0; i < widget.bars.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      Expanded(
                        child: _buildBar(
                          widget.bars[i],
                          i,
                          maxTotal,
                          colors,
                          textTheme,
                          scheme,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
          if (widget.seriesLabels != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                for (int s = 0; s < widget.seriesLabels!.length; s++)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors[s % colors.length],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.seriesLabels![s],
                        style: textTheme.labelMedium!.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBar(
    MEStackedBar bar,
    int index,
    double maxTotal,
    List<Color> colors,
    TextTheme textTheme,
    ColorScheme scheme,
  ) {
    // Stagger: each bar starts growing slightly after the previous one.
    final barCount = widget.bars.length;
    final delay = barCount <= 1 ? 0.0 : index / (barCount * 2.5);
    final t = ((_grow.value - delay) / (1 - delay)).clamp(0.0, 1.15);

    final chartHeight = widget.height - (bar.label != null ? 24.0 : 0.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Segments stack bottom-up: last series renders on top.
        for (int s = bar.values.length - 1; s >= 0; s--)
          Container(
            height:
                (bar.values[s] / maxTotal * chartHeight * t).clamp(0.0, 1e6),
            margin: EdgeInsets.only(bottom: s == 0 ? 0 : 2),
            decoration: BoxDecoration(
              color: colors[s % colors.length],
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(
                  s == bar.values.length - 1 ? widget.barRadius : 2,
                ),
                bottom: Radius.circular(s == 0 ? widget.barRadius : 2),
              ),
            ),
          ),
        if (bar.label != null) ...[
          const SizedBox(height: 6),
          Text(
            bar.label!,
            style: textTheme.labelSmall!.copyWith(
              color: scheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}
