import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/me_theme.dart';

/// An animated "now playing" equalizer glyph.
///
/// New in the expressive idiom: a compact set of rounded bars that bob up
/// and down while [playing] is true, each with its own phase so the motion
/// feels organic. When paused the bars settle to a low resting height.
///
/// ```dart
/// MEEqualizer(playing: isPlaying, size: 24)
/// ```
class MEEqualizer extends StatefulWidget {
  const MEEqualizer({
    super.key,
    this.playing = true,
    this.size = 24,
    this.bars = 4,
    this.color,
  }) : assert(bars >= 2, 'bars must be >= 2');

  /// Whether the bars animate.
  final bool playing;

  /// Height of the glyph. Width is derived from [bars].
  final double size;

  /// Number of bars.
  final int bars;

  /// Bar color. Defaults to the scheme primary.
  final Color? color;

  @override
  State<MEEqualizer> createState() => _MEEqualizerState();
}

class _MEEqualizerState extends State<MEEqualizer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void initState() {
    super.initState();
    if (widget.playing) _controller.repeat();
  }

  @override
  void didUpdateWidget(MEEqualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.playing != oldWidget.playing) {
      if (widget.playing) {
        _controller.repeat();
      } else {
        _controller.animateTo(
          _controller.value > 0.5 ? 1.0 : 0.0,
          duration:
              METheme.of(context).motion.defaultEffects.approximateDuration,
          curve: METheme.of(context).motion.defaultEffects.curve,
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    final barWidth = widget.size / (widget.bars * 2 - 1);

    return SizedBox(
      width: barWidth * (widget.bars * 2 - 1),
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (int i = 0; i < widget.bars; i++) ...[
                if (i > 0) SizedBox(width: barWidth),
                _bar(i, barWidth, color),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _bar(int index, double width, Color color) {
    // Each bar bobs with its own phase and rate for an organic feel.
    final t = _controller.value * 2 * math.pi;
    final phase = index * 1.7;
    final wave = widget.playing
        ? 0.5 + 0.5 * math.sin(t * (1.0 + index * 0.35) + phase)
        : 0.0;
    final height = widget.size * (0.2 + 0.8 * wave);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(width / 2),
      ),
    );
  }
}
