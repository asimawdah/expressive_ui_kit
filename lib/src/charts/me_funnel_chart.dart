import 'package:flutter/material.dart';

import '../theme/me_motion.dart';
import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';

/// A stage in an [MEFunnelChart].
@immutable
class MEFunnelStage {
  const MEFunnelStage({required this.value, required this.label, this.color});

  final double value;
  final String label;

  /// Optional explicit color. When null, colors are derived from the
  /// Material color scheme, fading from primary toward tertiary.
  final Color? color;
}

/// A horizontal funnel chart with Material 3 Expressive motion.
///
/// Each stage renders as a rounded bar whose width is proportional to
/// its value relative to the first (largest) stage. Bars grow in with a
/// staggered spring, and each row shows the conversion percentage from
/// the previous stage.
class MEFunnelChart extends StatefulWidget {
  const MEFunnelChart({
    super.key,
    required this.stages,
    this.barHeight = 36,
    this.showConversion = true,
    this.semanticLabel,
  }) : assert(stages.length >= 2, 'Provide at least 2 stages');

  final List<MEFunnelStage> stages;

  final double barHeight;

  /// Whether to show stage-to-stage conversion percentages.
  final bool showConversion;

  final String? semanticLabel;

  @override
  State<MEFunnelChart> createState() => _MEFunnelChartState();
}

class _MEFunnelChartState extends State<MEFunnelChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    _entrance.forward();
  }

  @override
  void didUpdateWidget(MEFunnelChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.stages.length != oldWidget.stages.length) {
      _entrance
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  Color _stageColor(ColorScheme scheme, int index) {
    final stage = widget.stages[index];
    if (stage.color != null) return stage.color!;
    // Blend from primary to tertiary down the funnel.
    final t = index / (widget.stages.length - 1);
    return Color.lerp(scheme.primary, scheme.tertiary, t)!;
  }

  Color _stageTextColor(ColorScheme scheme, int index) {
    final stage = widget.stages[index];
    if (stage.color != null) return scheme.onSurface;
    final t = index / (widget.stages.length - 1);
    return Color.lerp(scheme.onPrimary, scheme.onTertiary, t)!;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final motion = METheme.of(context).motion;
    final maxValue = widget.stages.first.value;

    return Semantics(
      label: widget.semanticLabel ??
          'Funnel chart with ${widget.stages.length} stages',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < widget.stages.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            AnimatedBuilder(
              animation: _entrance,
              builder: (context, _) {
                // Staggered entrance: each stage starts after the
                // previous one is 40% in.
                final start =
                    (i * 0.4 / widget.stages.length).clamp(0.0, 0.9);
                final local = ((_entrance.value - start) / (1 - start))
                    .clamp(0.0, 1.0);
                final eased = motion.slowSpatial.curve.transform(local);
                final fraction =
                    (widget.stages[i].value / maxValue).clamp(0.0, 1.0);
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final width =
                        constraints.maxWidth * fraction * eased.clamp(0.0, 1.2);
                    return Row(
                      children: [
                        Container(
                          width: width.clamp(0.0, constraints.maxWidth),
                          height: widget.barHeight,
                          alignment: Alignment.centerLeft,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: _stageColor(scheme, i),
                            borderRadius:
                                BorderRadius.circular(MECorners.small),
                          ),
                          child: width > 90
                              ? Text(
                                  widget.stages[i].label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.labelMedium!.copyWith(
                                    color: _stageTextColor(scheme, i),
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        if (widget.showConversion && i > 0)
                          Text(
                            '${(widget.stages[i].value / widget.stages[i - 1].value * 100).round()}%',
                            style: textTheme.labelSmall!.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          )
                        else if (width <= 90)
                          Text(
                            widget.stages[i].label,
                            style: textTheme.labelSmall!.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
