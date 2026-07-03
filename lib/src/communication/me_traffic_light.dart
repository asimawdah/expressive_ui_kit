import 'package:flutter/material.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// States for [METrafficLight].
enum METrafficState { stop, caution, go }

/// A status traffic light: three stacked lamps where the active one
/// blooms with a spring-driven glow halo.
///
/// Useful as a build/deploy/health status indicator. Colors map to the
/// scheme: stop = error, caution = tertiary, go = primary. The active
/// lamp scales up with the fast spatial spring (overshooting) while
/// inactive lamps dim to outlines.
class METrafficLight extends StatefulWidget {
  const METrafficLight({
    super.key,
    required this.state,
    this.axis = Axis.vertical,
    this.lampSize = 28,
    this.labels = const ['Stop', 'Caution', 'Go'],
    this.semanticLabel,
  }) : assert(labels.length == 3);

  final METrafficState state;

  /// Stack the lamps vertically (classic) or horizontally (compact).
  final Axis axis;

  final double lampSize;

  /// Accessibility labels for the three states.
  final List<String> labels;

  final String? semanticLabel;

  @override
  State<METrafficLight> createState() => _METrafficLightState();
}

class _METrafficLightState extends State<METrafficLight>
    with TickerProviderStateMixin {
  late final List<AnimationController> _lamps = List.generate(
    3,
    (i) => AnimationController.unbounded(
      vsync: this,
      value: widget.state.index == i ? 1 : 0,
    ),
  );

  @override
  void didUpdateWidget(METrafficLight oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state != oldWidget.state) {
      final motion = METheme.of(context).motion;
      for (var i = 0; i < 3; i++) {
        springTo(
          _lamps[i],
          widget.state.index == i ? 1 : 0,
          widget.state.index == i ? motion.fastSpatial : motion.defaultEffects,
        );
      }
    }
  }

  @override
  void dispose() {
    for (final c in _lamps) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = [scheme.error, scheme.tertiary, scheme.primary];

    final lamps = List<Widget>.generate(3, (i) {
      return AnimatedBuilder(
        animation: _lamps[i],
        builder: (context, _) {
          final t = _lamps[i].value.clamp(0.0, 1.3);
          final on = t.clamp(0.0, 1.0);
          return Container(
            width: widget.lampSize + 12,
            height: widget.lampSize + 12,
            alignment: Alignment.center,
            child: Transform.scale(
              scale: 0.85 + 0.15 * t,
              child: Container(
                width: widget.lampSize,
                height: widget.lampSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.lerp(
                    scheme.surfaceContainerHighest,
                    colors[i],
                    on,
                  ),
                  border: Border.all(
                    color: Color.lerp(scheme.outlineVariant, colors[i], on)!,
                    width: 1.5,
                  ),
                  boxShadow: [
                    if (on > 0.05)
                      BoxShadow(
                        color: colors[i].withValues(alpha: 0.45 * on),
                        blurRadius: 14 * on,
                        spreadRadius: 2 * on,
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });

    final content = widget.axis == Axis.vertical
        ? Column(mainAxisSize: MainAxisSize.min, children: lamps)
        : Row(mainAxisSize: MainAxisSize.min, children: lamps);

    return Semantics(
      label: widget.semanticLabel ?? 'Status light',
      value: widget.labels[widget.state.index],
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(widget.lampSize),
        ),
        child: content,
      ),
    );
  }
}
