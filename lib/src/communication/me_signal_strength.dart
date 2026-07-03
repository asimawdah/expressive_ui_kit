import 'package:flutter/material.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// A signal strength indicator with spring-animated bars.
///
/// Bars grow in height from left to right; active bars fill with a spring
/// (staggered, so a level change ripples across), inactive bars rest as
/// tonal stubs. While [searching] is true the bars run a scanning wave.
/// Colors follow strength: error (1 bar) -> tertiary -> primary (full).
class MESignalStrength extends StatefulWidget {
  const MESignalStrength({
    super.key,
    required this.level,
    this.bars = 4,
    this.searching = false,
    this.size = 28,
    this.semanticLabel,
  })  : assert(bars > 1),
        assert(level >= 0);

  /// Active bar count, 0..[bars].
  final int level;

  /// Total number of bars.
  final int bars;

  /// When true, ignores [level] and animates a scanning wave.
  final bool searching;

  /// Height of the tallest bar.
  final double size;

  final String? semanticLabel;

  @override
  State<MESignalStrength> createState() => _MESignalStrengthState();
}

class _MESignalStrengthState extends State<MESignalStrength>
    with TickerProviderStateMixin {
  late final List<AnimationController> _fills = [
    for (int i = 0; i < widget.bars; i++)
      AnimationController.unbounded(
        vsync: this,
        value: i < widget.level ? 1 : 0,
      ),
  ];

  // Drives the searching wave.
  late final AnimationController _scan = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void initState() {
    super.initState();
    if (widget.searching) _scan.repeat();
  }

  @override
  void didUpdateWidget(MESignalStrength oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searching != oldWidget.searching) {
      if (widget.searching) {
        _scan.repeat();
      } else {
        _scan.stop();
        _scan.value = 0;
      }
    }
    if (widget.level != oldWidget.level && !widget.searching) {
      final motion = METheme.of(context).motion;
      for (int i = 0; i < widget.bars; i++) {
        final target = i < widget.level ? 1.0 : 0.0;
        // Stagger so changes ripple from left to right.
        Future.delayed(Duration(milliseconds: 40 * i), () {
          if (mounted) springTo(_fills[i], target, motion.defaultSpatial);
        });
      }
    }
  }

  @override
  void dispose() {
    for (final c in _fills) {
      c.dispose();
    }
    _scan.dispose();
    super.dispose();
  }

  Color _strengthColor(ColorScheme scheme) {
    if (widget.level <= 1) return scheme.error;
    if (widget.level < widget.bars) return scheme.tertiary;
    return scheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final active = _strengthColor(scheme);
    final double barWidth = widget.size / (widget.bars * 1.8);
    final double gap = barWidth * 0.8;

    return Semantics(
      label: widget.semanticLabel ??
          (widget.searching
              ? 'Searching for signal'
              : 'Signal strength ${widget.level} of ${widget.bars}'),
      child: AnimatedBuilder(
        animation: Listenable.merge([..._fills, _scan]),
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (int i = 0; i < widget.bars; i++) ...[
                if (i > 0) SizedBox(width: gap),
                _bar(i, scheme, active, barWidth),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _bar(int i, ColorScheme scheme, Color active, double barWidth) {
    // Bar heights step up linearly.
    final double height = widget.size * ((i + 1) / widget.bars);

    double fill;
    if (widget.searching) {
      // Traveling wave: each bar lights as the scan passes over it.
      final double pos = _scan.value * (widget.bars + 1.5) - 1;
      fill = (1.0 - (pos - i).abs()).clamp(0.0, 1.0);
    } else {
      fill = _fills[i].value.clamp(0.0, 1.2);
    }

    return SizedBox(
      width: barWidth,
      height: widget.size,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Track stub.
          Container(
            width: barWidth,
            height: height,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(barWidth / 2),
            ),
          ),
          // Spring-animated fill grows from the bottom.
          Container(
            width: barWidth,
            height: (height * fill).clamp(0.0, height * 1.1),
            decoration: BoxDecoration(
              color: Color.lerp(
                scheme.surfaceContainerHighest,
                active,
                fill.clamp(0.0, 1.0),
              ),
              borderRadius: BorderRadius.circular(barWidth / 2),
            ),
          ),
        ],
      ),
    );
  }
}
