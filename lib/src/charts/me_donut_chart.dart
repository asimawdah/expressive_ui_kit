import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// A segment of an [MEDonutChart].
@immutable
class MEDonutSegment {
  const MEDonutSegment({
    required this.value,
    this.color,
    this.label,
  }) : assert(value >= 0, 'value must be non-negative');

  final double value;

  /// Segment color. When null, a color is derived from the scheme's
  /// primary/secondary/tertiary rotation.
  final Color? color;

  /// Optional label shown in the legend.
  final String? label;
}

/// A Material 3 Expressive donut chart.
///
/// Segments sweep in sequentially with a spring, separated by small angular
/// gaps (an M3E signature). Tapping a segment selects it: the slice thickens
/// outward and the center swaps to that segment's share.
class MEDonutChart extends StatefulWidget {
  const MEDonutChart({
    super.key,
    required this.segments,
    this.size = 180,
    this.thickness = 24,
    this.gapDegrees = 3,
    this.center,
    this.showLegend = true,
    this.onSegmentSelected,
  });

  final List<MEDonutSegment> segments;
  final double size;
  final double thickness;

  /// The angular gap between adjacent segments, in degrees.
  final double gapDegrees;

  /// Custom center widget. Defaults to the selected segment's percentage,
  /// or the total when nothing is selected.
  final Widget? center;

  /// Render a wrap of color-dotted labels beside the chart.
  final bool showLegend;

  final ValueChanged<int?>? onSegmentSelected;

  @override
  State<MEDonutChart> createState() => _MEDonutChartState();
}

class _MEDonutChartState extends State<MEDonutChart> {
  int? _selected;

  List<Color> _colors(ColorScheme scheme) {
    const int n = 6;
    return [
      for (var i = 0; i < widget.segments.length; i++)
        widget.segments[i].color ??
            [
              scheme.primary,
              scheme.secondary,
              scheme.tertiary,
              scheme.primaryContainer,
              scheme.secondaryContainer,
              scheme.tertiaryContainer,
            ][i % n],
    ];
  }

  void _handleTapDown(TapDownDetails details) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final centerOffset = Offset(widget.size / 2, widget.size / 2);
    final local = details.localPosition - centerOffset;
    final distance = local.distance;
    final outer = widget.size / 2;
    final inner = outer - widget.thickness - 12;
    if (distance < inner || distance > outer + 8) {
      _select(null);
      return;
    }
    var angle = math.atan2(local.dy, local.dx);
    // Normalize to 0...2pi starting at the top (-pi/2).
    angle = (angle + math.pi / 2) % (2 * math.pi);
    if (angle < 0) angle += 2 * math.pi;

    final total = widget.segments.fold<double>(0, (s, e) => s + e.value);
    if (total <= 0) return;
    var cursor = 0.0;
    for (var i = 0; i < widget.segments.length; i++) {
      final sweep = widget.segments[i].value / total * 2 * math.pi;
      if (angle >= cursor && angle < cursor + sweep) {
        _select(_selected == i ? null : i);
        return;
      }
      cursor += sweep;
    }
  }

  void _select(int? index) {
    setState(() => _selected = index);
    widget.onSegmentSelected?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final motion = METheme.of(context).motion;
    final colors = _colors(scheme);
    final total = widget.segments.fold<double>(0, (s, e) => s + e.value);

    final chart = GestureDetector(
      onTapDown: _handleTapDown,
      child: TweenAnimationBuilder<double>(
        key: ValueKey(
          Object.hashAll(widget.segments.map((s) => s.value)),
        ),
        tween: Tween(begin: 0, end: 1),
        duration: motion.slowSpatial.approximateDuration,
        curve: motion.slowSpatial.curve,
        builder: (context, sweepT, _) => TweenAnimationBuilder<double>(
          tween: Tween(
            begin: 0,
            end: _selected == null ? 0 : 1,
          ),
          duration: motion.defaultSpatial.approximateDuration,
          curve: motion.defaultSpatial.curve,
          builder: (context, selectT, _) => SizedBox(
            width: widget.size,
            height: widget.size,
            child: CustomPaint(
              painter: _DonutPainter(
                segments: widget.segments,
                colors: colors,
                thickness: widget.thickness,
                gapDegrees: widget.gapDegrees,
                sweepProgress: sweepT.clamp(0.0, 1.0),
                selected: _selected,
                selectProgress: selectT.clamp(0.0, 1.0),
              ),
              child: Center(
                child: widget.center ??
                    _DonutCenter(
                      total: total,
                      selected: _selected,
                      segments: widget.segments,
                      scheme: scheme,
                      text: text,
                    ),
              ),
            ),
          ),
        ),
      ),
    );

    if (!widget.showLegend) return chart;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        chart,
        const SizedBox(width: 20),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < widget.segments.length; i++)
                if (widget.segments[i].label != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MEMotionBuilder(
                          value: _selected == i ? 1.0 : 0.0,
                          spec: motion.fastSpatial,
                          builder: (context, t, _) {
                            final size = 10 + 4 * t;
                            return Container(
                              width: size,
                              height: size,
                              decoration: BoxDecoration(
                                color: colors[i],
                                borderRadius: BorderRadius.circular(
                                  5 - t,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            widget.segments[i].label!,
                            style: text.labelMedium!.copyWith(
                              color: _selected == null || _selected == i
                                  ? scheme.onSurface
                                  : scheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DonutCenter extends StatelessWidget {
  const _DonutCenter({
    required this.total,
    required this.selected,
    required this.segments,
    required this.scheme,
    required this.text,
  });

  final double total;
  final int? selected;
  final List<MEDonutSegment> segments;
  final ColorScheme scheme;
  final TextTheme text;

  @override
  Widget build(BuildContext context) {
    final String value;
    final String caption;
    if (selected != null && total > 0) {
      value = '${(segments[selected!].value / total * 100).round()}%';
      caption = segments[selected!].label ?? 'Selected';
    } else {
      value = total % 1 == 0 ? total.toInt().toString() : total.toString();
      caption = 'Total';
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: METheme.of(context).motion.fastEffects.approximateDuration,
          switchInCurve: METheme.of(context).motion.fastEffects.curve,
          switchOutCurve: METheme.of(context).motion.fastEffects.curve,
          child: Text(
            value,
            key: ValueKey(value),
            style: METypography.emphasize(
              text.headlineSmall!.copyWith(color: scheme.onSurface),
            ),
          ),
        ),
        Text(
          caption,
          style: text.labelSmall!.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.segments,
    required this.colors,
    required this.thickness,
    required this.gapDegrees,
    required this.sweepProgress,
    required this.selected,
    required this.selectProgress,
  });

  final List<MEDonutSegment> segments;
  final List<Color> colors;
  final double thickness;
  final double gapDegrees;
  final double sweepProgress;
  final int? selected;
  final double selectProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final total = segments.fold<double>(0, (s, e) => s + e.value);
    if (total <= 0) return;

    final gap = gapDegrees * math.pi / 180;
    // Start at the top.
    var cursor = -math.pi / 2;

    for (var i = 0; i < segments.length; i++) {
      final fullSweep = segments[i].value / total * 2 * math.pi;
      final sweep = math.max(0.0, fullSweep * sweepProgress - gap);
      if (sweep <= 0) {
        cursor += fullSweep * sweepProgress;
        continue;
      }

      final bool isSelected = selected == i;
      final double bulge = isSelected ? 5 * selectProgress : 0;
      final rect = (Offset.zero & size).deflate(thickness / 2 + 6 - bulge);

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness + bulge * 2
        ..strokeCap = StrokeCap.round
        ..color = selected == null || isSelected
            ? colors[i]
            : colors[i].withValues(alpha: 0.35);

      canvas.drawArc(rect, cursor + gap / 2, sweep, false, paint);
      cursor += fullSweep * sweepProgress;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter oldDelegate) =>
      sweepProgress != oldDelegate.sweepProgress ||
      selectProgress != oldDelegate.selectProgress ||
      selected != oldDelegate.selected ||
      segments != oldDelegate.segments;
}
