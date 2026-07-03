import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// A like (heart) button with an expressive particle burst.
///
/// Tapping to like squashes the heart, then springs it back up with the
/// fast spatial spring while a ring of confetti dots bursts outward and
/// fades. Unliking simply deflates the fill. An optional count label
/// pops when it changes.
///
/// ```dart
/// MELikeButton(
///   liked: isLiked,
///   count: likeCount,
///   onChanged: (v) => setState(() => isLiked = v),
/// )
/// ```
class MELikeButton extends StatefulWidget {
  const MELikeButton({
    super.key,
    required this.liked,
    this.onChanged,
    this.count,
    this.size = 28,
    this.color,
    this.semanticLabel,
  });

  /// Whether the button is currently liked.
  final bool liked;

  /// Called with the new liked state when tapped.
  final ValueChanged<bool>? onChanged;

  /// Optional like count shown next to the heart.
  final int? count;

  /// Icon size.
  final double size;

  /// Fill color when liked. Defaults to the scheme error color (a
  /// heart-like red in most schemes).
  final Color? color;

  final String? semanticLabel;

  @override
  State<MELikeButton> createState() => _MELikeButtonState();
}

class _MELikeButtonState extends State<MELikeButton>
    with TickerProviderStateMixin {
  // Unbounded so the spring can overshoot past 1.0.
  late final AnimationController _pop = AnimationController.unbounded(
    vsync: this,
    value: widget.liked ? 1 : 0,
  );
  late final AnimationController _burst = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );

  @override
  void didUpdateWidget(MELikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.liked != oldWidget.liked) {
      final motion = METheme.of(context).motion;
      if (widget.liked) {
        // Start squashed, spring up with overshoot, and fire the burst.
        _pop.value = 0.0;
        springTo(_pop, 1.0, motion.fastSpatial);
        _burst.forward(from: 0.0);
      } else {
        springTo(_pop, 0.0, motion.defaultEffects);
      }
    }
  }

  @override
  void dispose() {
    _pop.dispose();
    _burst.dispose();
    super.dispose();
  }

  void _toggle() {
    if (widget.onChanged == null) return;
    HapticFeedback.lightImpact();
    widget.onChanged!(!widget.liked);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fill = widget.color ?? scheme.error;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      label: widget.semanticLabel ?? 'Like',
      toggled: widget.liked,
      child: InkWell(
        onTap: widget.onChanged == null ? null : _toggle,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: widget.size * 1.9,
                height: widget.size * 1.9,
                child: AnimatedBuilder(
                  animation: Listenable.merge([_pop, _burst]),
                  builder: (context, _) {
                    final t = _pop.value;
                    // Scale dips below 1 at t=0..squash then overshoots.
                    final double scale = widget.liked
                        ? (0.75 + 0.25 * t.clamp(-0.3, 1.6))
                        : 1.0;
                    return CustomPaint(
                      painter: _BurstPainter(
                        progress: _burst.isAnimating ? _burst.value : 0,
                        color: fill,
                        secondary: scheme.tertiary,
                      ),
                      child: Center(
                        child: Transform.scale(
                          scale: scale.clamp(0.6, 1.25),
                          child: Icon(
                            widget.liked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: widget.size,
                            color: Color.lerp(
                              scheme.onSurfaceVariant,
                              fill,
                              t.clamp(0.0, 1.0),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (widget.count != null) ...[
                const SizedBox(width: 2),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: Text(
                    '${widget.count}',
                    key: ValueKey<int>(widget.count!),
                    style: textTheme.labelLarge!.copyWith(
                      color: widget.liked ? fill : scheme.onSurfaceVariant,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Paints the radial confetti burst: 8 primary dots flying outward plus
/// 8 smaller offset dots, all fading as they travel.
class _BurstPainter extends CustomPainter {
  _BurstPainter({
    required this.progress,
    required this.color,
    required this.secondary,
  });

  final double progress;
  final Color color;
  final Color secondary;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final center = size.center(Offset.zero);
    final maxRadius = size.shortestSide / 2;

    // Ease out: dots decelerate as they fly.
    final eased = Curves.easeOutCubic.transform(progress);
    final travel = maxRadius * (0.45 + 0.55 * eased);
    final double opacity = (1.0 - progress).clamp(0.0, 1.0);
    final double dotSize = size.shortestSide * 0.045 * (1.0 - 0.5 * eased);

    final paint = Paint()..color = color.withValues(alpha: opacity);
    final paint2 = Paint()
      ..color = secondary.withValues(alpha: opacity * 0.85);

    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final pos = center + Offset(math.cos(angle), math.sin(angle)) * travel;
      canvas.drawCircle(pos, dotSize, paint);
      // Smaller offset satellite dot.
      final angle2 = angle + math.pi / 8;
      final pos2 = center +
          Offset(math.cos(angle2), math.sin(angle2)) * (travel * 0.8);
      canvas.drawCircle(pos2, dotSize * 0.6, paint2);
    }
  }

  @override
  bool shouldRepaint(_BurstPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
