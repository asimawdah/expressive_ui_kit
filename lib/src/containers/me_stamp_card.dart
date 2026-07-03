import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/me_motion.dart';
import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';

/// A loyalty stamp card ("buy 10, get 1 free").
///
/// Earned stamps punch in with a spring: they drop from above with a
/// scale overshoot and a haptic thump, like a rubber stamp hitting
/// paper. The most recently earned stamp animates whenever [earned]
/// increases. When the card completes, the reward slot pulses.
class MEStampCard extends StatefulWidget {
  const MEStampCard({
    super.key,
    required this.total,
    required this.earned,
    this.icon = Icons.local_cafe_outlined,
    this.rewardIcon = Icons.card_giftcard,
    this.title,
    this.columns = 5,
    this.onCompleted,
    this.haptics = true,
    this.semanticLabel,
  })  : assert(total > 0, 'total must be > 0'),
        assert(
            earned >= 0 && earned <= total, 'earned must be within 0..total');

  /// Total stamps needed (including the reward slot).
  final int total;

  /// Stamps earned so far.
  final int earned;

  /// Glyph for a punched stamp.
  final IconData icon;

  /// Glyph for the final reward slot.
  final IconData rewardIcon;

  /// Optional header above the grid.
  final Widget? title;

  final int columns;

  /// Fired once when [earned] reaches [total].
  final VoidCallback? onCompleted;

  final bool haptics;
  final String? semanticLabel;

  @override
  State<MEStampCard> createState() => _MEStampCardState();
}

class _MEStampCardState extends State<MEStampCard>
    with TickerProviderStateMixin {
  late final AnimationController _punch;
  late final AnimationController _rewardPulse;
  int _animatingIndex = -1;

  @override
  void initState() {
    super.initState();
    _punch = AnimationController.unbounded(vsync: this, value: 1);
    _rewardPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.earned >= widget.total) {
      _rewardPulse.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(MEStampCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.earned > oldWidget.earned) {
      _animatingIndex = widget.earned - 1;
      _punch.value = 0;
      springTo(_punch, 1, METheme.of(context).motion.fastSpatial);
      if (widget.haptics) HapticFeedback.mediumImpact();
      if (widget.earned >= widget.total) {
        final onCompleted = widget.onCompleted;
        if (onCompleted != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) onCompleted();
          });
        }
        _rewardPulse.repeat(reverse: true);
        if (widget.haptics) HapticFeedback.heavyImpact();
      }
    } else if (widget.earned < oldWidget.earned) {
      _animatingIndex = -1;
      if (widget.earned < widget.total) _rewardPulse.stop();
    }
  }

  @override
  void dispose() {
    _punch.dispose();
    _rewardPulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      label: widget.semanticLabel ??
          'Stamp card, ${widget.earned} of ${widget.total} stamps earned',
      child: Material(
        color: scheme.surfaceContainerLow,
        shape: MEShapeScheme.fromCorner(MECorners.extraLarge),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.title != null) ...[
                widget.title!,
                const SizedBox(height: 16),
              ],
              LayoutBuilder(
                builder: (context, constraints) {
                  final spacing = 10.0;
                  final cell =
                      (constraints.maxWidth - spacing * (widget.columns - 1)) /
                          widget.columns;
                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: List.generate(widget.total, (i) {
                      return SizedBox(
                        width: cell,
                        height: cell,
                        child: _buildSlot(context, i, scheme),
                      );
                    }),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlot(BuildContext context, int index, ColorScheme scheme) {
    final isReward = index == widget.total - 1;
    final punched = index < widget.earned;

    Widget slot;
    if (isReward && !punched) {
      // Reward slot: pulses when everything else is earned.
      final ready = widget.earned == widget.total - 1;
      slot = AnimatedBuilder(
        animation: _rewardPulse,
        builder: (context, _) {
          final pulse = ready ? 1.0 + _rewardPulse.value * 0.08 : 1.0;
          return Transform.scale(
            scale: pulse,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: scheme.tertiary,
                  width: 2,
                ),
                color: scheme.tertiaryContainer.withValues(alpha: 0.4),
              ),
              child: Icon(
                widget.rewardIcon,
                color: scheme.tertiary,
                size: 22,
              ),
            ),
          );
        },
      );
    } else if (punched) {
      final isAnimating = index == _animatingIndex;
      slot = AnimatedBuilder(
        animation: _punch,
        builder: (context, _) {
          // Punch-in: drops from 1.6x scale with spring overshoot.
          final t = isAnimating ? _punch.value.clamp(0.0, 1.2) : 1.0;
          final scale = 1.6 - 0.6 * t;
          final opacity = t.clamp(0.0, 1.0);
          return Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale.clamp(0.8, 1.6),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isReward ? scheme.tertiary : scheme.primary,
                ),
                child: Icon(
                  isReward ? widget.rewardIcon : widget.icon,
                  color: isReward ? scheme.onTertiary : scheme.onPrimary,
                  size: 22,
                ),
              ),
            ),
          );
        },
      );
    } else {
      slot = DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: scheme.outlineVariant, width: 2),
        ),
        child: Icon(
          widget.icon,
          color: scheme.outlineVariant,
          size: 20,
        ),
      );
    }
    return slot;
  }
}
