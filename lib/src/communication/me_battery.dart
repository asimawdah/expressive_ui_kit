import 'package:flutter/material.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// A battery level indicator with a spring-animated fill.
///
/// The fill springs to its level and colors itself semantically: error
/// below 20%, tertiary below 50%, primary otherwise. When [charging] is
/// true a soft pulse travels through the fill and a bolt icon overlays
/// the body.
class MEBattery extends StatefulWidget {
  const MEBattery({
    super.key,
    required this.value,
    this.charging = false,
    this.width = 88,
    this.height = 40,
    this.showPercent = true,
    this.semanticLabel,
  }) : assert(value >= 0 && value <= 1, 'value must be 0..1');

  /// Charge level, 0.0 to 1.0.
  final double value;

  /// Whether the battery is charging (shows a bolt and a pulsing fill).
  final bool charging;

  final double width;
  final double height;

  /// Whether to show the numeric percentage inside the body.
  final bool showPercent;

  final String? semanticLabel;

  @override
  State<MEBattery> createState() => _MEBatteryState();
}

class _MEBatteryState extends State<MEBattery> with TickerProviderStateMixin {
  late final AnimationController _level = AnimationController.unbounded(
    vsync: this,
    value: widget.value,
  );
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void initState() {
    super.initState();
    if (widget.charging) _pulse.repeat();
  }

  @override
  void didUpdateWidget(MEBattery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      springTo(_level, widget.value, METheme.of(context).motion.defaultSpatial);
    }
    if (widget.charging != oldWidget.charging) {
      if (widget.charging) {
        _pulse.repeat();
      } else {
        _pulse.stop();
        _pulse.value = 0;
      }
    }
  }

  @override
  void dispose() {
    _level.dispose();
    _pulse.dispose();
    super.dispose();
  }

  Color _fillColor(ColorScheme scheme, double t) {
    if (t < 0.2) return scheme.error;
    if (t < 0.5) return scheme.tertiary;
    return scheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final percent = (widget.value * 100).round();

    return Semantics(
      label: widget.semanticLabel ?? 'Battery',
      value: '$percent%${widget.charging ? ', charging' : ''}',
      child: AnimatedBuilder(
        animation: Listenable.merge([_level, _pulse]),
        builder: (context, _) {
          final t = _level.value.clamp(0.0, 1.0);
          final fill = _fillColor(scheme, t);
          final capWidth = widget.width * 0.06;
          final bodyWidth = widget.width - capWidth - 2;
          final radius = widget.height * 0.28;

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Body.
              Container(
                width: bodyWidth,
                height: widget.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(color: scheme.outline, width: 2),
                ),
                padding: const EdgeInsets.all(3),
                child: Stack(
                  children: [
                    // Fill.
                    ClipRRect(
                      borderRadius: BorderRadius.circular(radius - 4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: t,
                          heightFactor: 1,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: widget.charging
                                  ? Color.lerp(
                                      fill,
                                      scheme.primaryContainer,
                                      // Soft pulse: 0 -> 0.35 -> 0.
                                      (0.5 - (_pulse.value - 0.5).abs()) * 0.7,
                                    )
                                  : fill,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Percent label / bolt.
                    Center(
                      child: widget.charging
                          ? Icon(
                              Icons.bolt,
                              size: widget.height * 0.55,
                              color: scheme.onSurface,
                            )
                          : widget.showPercent
                              ? Text(
                                  '$percent',
                                  style: textTheme.labelMedium!.copyWith(
                                    color: scheme.onSurface,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 2),
              // Cap.
              Container(
                width: capWidth,
                height: widget.height * 0.4,
                decoration: BoxDecoration(
                  color: scheme.outline,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(capWidth),
                    bottomRight: Radius.circular(capWidth),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
