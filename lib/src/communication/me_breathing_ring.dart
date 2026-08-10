import 'package:flutter/material.dart';

/// A guided-breathing ring that expands and contracts on a breath cycle.
///
/// The ring inflates during the inhale phase, holds, deflates during the
/// exhale, and holds again — with the phase label cross-fading in the
/// center. The halo blooms with the inhale using effects-family opacity
/// animation, keeping color changes bounce-free per M3E motion rules.
///
/// ```dart
/// MEBreathingRing(
///   inhale: Duration(seconds: 4),
///   exhale: Duration(seconds: 6),
/// )
/// ```
class MEBreathingRing extends StatefulWidget {
  const MEBreathingRing({
    super.key,
    this.size = 200,
    this.inhale = const Duration(seconds: 4),
    this.inhaleHold = const Duration(seconds: 2),
    this.exhale = const Duration(seconds: 6),
    this.exhaleHold = const Duration(seconds: 2),
    this.inhaleLabel = 'Breathe in',
    this.holdLabel = 'Hold',
    this.exhaleLabel = 'Breathe out',
    this.semanticLabel,
  });

  final double size;
  final Duration inhale;
  final Duration inhaleHold;
  final Duration exhale;
  final Duration exhaleHold;
  final String inhaleLabel;
  final String holdLabel;
  final String exhaleLabel;
  final String? semanticLabel;

  @override
  State<MEBreathingRing> createState() => _MEBreathingRingState();
}

class _MEBreathingRingState extends State<MEBreathingRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _cycle;

  Duration get _total =>
      widget.inhale + widget.inhaleHold + widget.exhale + widget.exhaleHold;

  @override
  void initState() {
    super.initState();
    _cycle = AnimationController(vsync: this, duration: _total)..repeat();
  }

  @override
  void didUpdateWidget(MEBreathingRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_total != _cycle.duration) {
      _cycle
        ..duration = _total
        ..repeat();
    }
  }

  @override
  void dispose() {
    _cycle.dispose();
    super.dispose();
  }

  /// Returns (breath progress 0..1, phase label) for cycle time [t] 0..1.
  (double, String) _phase(double t) {
    final total = _total.inMilliseconds.toDouble();
    final inhaleEnd = widget.inhale.inMilliseconds / total;
    final holdEnd = inhaleEnd + widget.inhaleHold.inMilliseconds / total;
    final exhaleEnd = holdEnd + widget.exhale.inMilliseconds / total;

    if (t < inhaleEnd) {
      final p = t / inhaleEnd;
      return (Curves.easeInOutSine.transform(p), widget.inhaleLabel);
    }
    if (t < holdEnd) return (1.0, widget.holdLabel);
    if (t < exhaleEnd) {
      final p = (t - holdEnd) / (exhaleEnd - holdEnd);
      return (1.0 - Curves.easeInOutSine.transform(p), widget.exhaleLabel);
    }
    return (0.0, widget.holdLabel);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label: widget.semanticLabel ?? 'Breathing exercise',
      child: AnimatedBuilder(
        animation: _cycle,
        builder: (context, _) {
          final (breath, label) = _phase(_cycle.value);
          final ringSize = widget.size * (0.55 + 0.45 * breath);

          return SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Halo blooms with the inhale (effects: opacity only).
                Container(
                  width: ringSize * 1.25,
                  height: ringSize * 1.25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.primary.withValues(
                      alpha: 0.10 + 0.15 * breath,
                    ),
                  ),
                ),
                // The breathing ring itself.
                Container(
                  width: ringSize,
                  height: ringSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.primaryContainer,
                    border: Border.all(
                      color: scheme.primary,
                      width: 2 + 2 * breath,
                    ),
                  ),
                ),
                // Phase label cross-fades between changes.
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: Text(
                    label,
                    key: ValueKey<String>(label),
                    style: textTheme.titleMedium!.copyWith(
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
