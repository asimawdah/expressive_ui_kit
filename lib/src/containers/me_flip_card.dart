import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/me_motion.dart';
import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';

/// A Material 3 Expressive flip card.
///
/// Shows [front] and flips in 3D to reveal [back] with a spatial spring —
/// the underdamped spring gives the rotation a satisfying settle-wobble.
/// Tap to flip by default, or drive it externally with [flipped].
class MEFlipCard extends StatefulWidget {
  const MEFlipCard({
    super.key,
    required this.front,
    required this.back,
    this.flipped,
    this.onFlip,
    this.flipOnTap = true,
    this.direction = Axis.horizontal,
  });

  final Widget front;
  final Widget back;

  /// Externally controlled flip state. When null the card manages its own.
  final bool? flipped;
  final ValueChanged<bool>? onFlip;

  /// Whether tapping the card flips it.
  final bool flipOnTap;

  /// Flip around the vertical axis (horizontal) or horizontal axis
  /// (vertical).
  final Axis direction;

  @override
  State<MEFlipCard> createState() => _MEFlipCardState();
}

class _MEFlipCardState extends State<MEFlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController.unbounded(
    vsync: this,
    value: (widget.flipped ?? false) ? 1 : 0,
  );
  bool _internalFlipped = false;

  bool get _flipped => widget.flipped ?? _internalFlipped;

  @override
  void didUpdateWidget(MEFlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.flipped != null && widget.flipped != oldWidget.flipped) {
      springTo(
        _anim,
        widget.flipped! ? 1 : 0,
        METheme.of(context).motion.defaultSpatial,
      );
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _flip() {
    final next = !_flipped;
    if (widget.flipped == null) {
      _internalFlipped = next;
      springTo(
        _anim,
        next ? 1 : 0,
        METheme.of(context).motion.defaultSpatial,
      );
    }
    widget.onFlip?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: widget.flipOnTap,
      label: 'Flip card, ${_flipped ? 'back' : 'front'} showing',
      child: GestureDetector(
        onTap: widget.flipOnTap ? _flip : null,
        child: AnimatedBuilder(
          animation: _anim,
          builder: (context, _) {
            final t = _anim.value;
            final angle = t * math.pi;
            final showBack = t > 0.5;
            final transform = Matrix4.identity()..setEntry(3, 2, 0.0012);
            if (widget.direction == Axis.horizontal) {
              transform.rotateY(angle);
            } else {
              transform.rotateX(angle);
            }
            Widget face = showBack ? widget.back : widget.front;
            if (showBack) {
              // Counter-rotate the back face so it reads correctly.
              final counter = Matrix4.identity();
              if (widget.direction == Axis.horizontal) {
                counter.rotateY(math.pi);
              } else {
                counter.rotateX(math.pi);
              }
              face = Transform(
                transform: counter,
                alignment: Alignment.center,
                child: face,
              );
            }
            return Transform(
              transform: transform,
              alignment: Alignment.center,
              child: face,
            );
          },
        ),
      ),
    );
  }
}

/// A ready-made face for [MEFlipCard]: a filled, rounded container.
class MEFlipCardFace extends StatelessWidget {
  const MEFlipCardFace({
    super.key,
    required this.child,
    this.color,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? scheme.primaryContainer,
        borderRadius: BorderRadius.circular(MECorners.extraLarge),
      ),
      child: child,
    );
  }
}
