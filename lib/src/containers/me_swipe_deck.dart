import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/me_motion.dart';
import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';

/// The direction a card left an [MESwipeDeck].
enum MESwipeDirection { left, right }

/// A Material 3 Expressive swipeable card deck.
///
/// The top card follows the drag with a slight rotation. Past the threshold
/// it flies off (calling [onSwiped]); otherwise it springs back with the
/// theme's bouncy spatial spring. Cards behind scale and rise into place as
/// the deck advances.
///
/// ```dart
/// MESwipeDeck(
///   itemCount: profiles.length,
///   itemBuilder: (context, i) => ProfileCard(profile: profiles[i]),
///   onSwiped: (i, dir) => like(profiles[i], dir == MESwipeDirection.right),
/// )
/// ```
class MESwipeDeck extends StatefulWidget {
  const MESwipeDeck({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.onSwiped,
    this.onEmpty,
    this.height = 320,
    this.visibleCards = 3,
  }) : assert(visibleCards >= 1, 'visibleCards must be at least 1');

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  /// Called after a card has been dismissed.
  final void Function(int index, MESwipeDirection direction)? onSwiped;

  /// Called once when the last card has been swiped away.
  final VoidCallback? onEmpty;

  final double height;

  /// How many stacked cards are visible behind the top card.
  final int visibleCards;

  @override
  State<MESwipeDeck> createState() => _MESwipeDeckState();
}

class _MESwipeDeckState extends State<MESwipeDeck>
    with SingleTickerProviderStateMixin {
  int _top = 0;
  Offset _drag = Offset.zero;
  bool _animatingOut = false;

  late final AnimationController _spring = AnimationController.unbounded(
    vsync: this,
    value: 0,
  );
  Offset _springFrom = Offset.zero;
  Offset _springTo = Offset.zero;

  @override
  void initState() {
    super.initState();
    _spring.addListener(() {
      final t = _spring.value.clamp(0.0, 1.2);
      setState(() {
        _drag = Offset.lerp(_springFrom, _springTo, t)!;
      });
      if (_animatingOut && t >= 1.0) {
        _completeSwipe();
      }
    });
  }

  @override
  void dispose() {
    _spring.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _spring.stop();
    setState(() => _drag += details.delta);
  }

  void _onPanEnd(DragEndDetails details) {
    final width = context.size?.width ?? 300;
    final threshold = width * 0.35;
    final velocity = details.velocity.pixelsPerSecond.dx;

    if (_drag.dx.abs() > threshold || velocity.abs() > 800) {
      final dir = (_drag.dx != 0 ? _drag.dx : velocity) > 0
          ? MESwipeDirection.right
          : MESwipeDirection.left;
      _flyOut(dir, width);
    } else {
      // Spring back to center with the bouncy spatial spring.
      _animatingOut = false;
      _springFrom = _drag;
      _springTo = Offset.zero;
      _spring.value = 0;
      springTo(_spring, 1, METheme.of(context).motion.defaultSpatial);
    }
  }

  void _flyOut(MESwipeDirection dir, double width) {
    _animatingOut = true;
    _pendingDirection = dir;
    _springFrom = _drag;
    _springTo = Offset(
      (dir == MESwipeDirection.right ? 1 : -1) * width * 1.5,
      _drag.dy * 1.4,
    );
    _spring.value = 0;
    springTo(_spring, 1, METheme.of(context).motion.fastEffects);
  }

  MESwipeDirection _pendingDirection = MESwipeDirection.right;

  void _completeSwipe() {
    _animatingOut = false;
    _spring.stop();
    final swiped = _top;
    setState(() {
      _top += 1;
      _drag = Offset.zero;
    });
    widget.onSwiped?.call(swiped, _pendingDirection);
    if (_top >= widget.itemCount) widget.onEmpty?.call();
  }

  /// Programmatically swipe the top card.
  void swipe(MESwipeDirection direction) {
    if (_top >= widget.itemCount || _animatingOut) return;
    final width = context.size?.width ?? 300;
    _flyOut(direction, width);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final motion = METheme.of(context).motion;
    final remaining = widget.itemCount - _top;

    if (remaining <= 0) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Text(
            'All done',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ),
      );
    }

    final visible = math.min(widget.visibleCards, remaining);
    final width = MediaQuery.sizeOf(context).width;
    final dragT = (_drag.dx.abs() / (width * 0.5)).clamp(0.0, 1.0);

    return SizedBox(
      height: widget.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Back cards, deepest first.
          for (var d = visible - 1; d >= 1; d--)
            _BackCard(
              key: ValueKey('back-${_top + d}'),
              depth: d,
              // As the top card drags away, the next card rises.
              rise: d == 1 ? dragT : 0,
              motion: motion,
              height: widget.height,
              child: widget.itemBuilder(context, _top + d),
            ),
          // Top draggable card.
          GestureDetector(
            key: ValueKey('top-$_top'),
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            child: Transform.translate(
              offset: _drag,
              child: Transform.rotate(
                angle: _drag.dx / width * 0.35,
                child: SizedBox(
                  height: widget.height - 24,
                  width: double.infinity,
                  child: Material(
                    color: scheme.surfaceContainerLow,
                    elevation: 4,
                    shadowColor: Colors.black26,
                    shape: MEShapeScheme.fromCorner(MECorners.extraLarge),
                    clipBehavior: Clip.antiAlias,
                    child: widget.itemBuilder(context, _top),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackCard extends StatelessWidget {
  const _BackCard({
    super.key,
    required this.depth,
    required this.rise,
    required this.motion,
    required this.height,
    required this.child,
  });

  final int depth;
  final double rise;
  final MEMotionScheme motion;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final effectiveDepth = depth - rise;
    final scale = 1.0 - effectiveDepth * 0.05;
    final dy = effectiveDepth * 12.0;

    return Transform.translate(
      offset: Offset(0, dy),
      child: Transform.scale(
        scale: scale,
        child: IgnorePointer(
          child: SizedBox(
            height: height - 24,
            width: double.infinity,
            child: Material(
              color: scheme.surfaceContainerLow,
              elevation: 1,
              shape: MEShapeScheme.fromCorner(MECorners.extraLarge),
              clipBehavior: Clip.antiAlias,
              child: Opacity(
                opacity: (1.0 - effectiveDepth * 0.25).clamp(0.3, 1.0),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
