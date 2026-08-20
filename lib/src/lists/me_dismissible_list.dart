import 'package:flutter/material.dart';

import '../theme/me_shapes.dart';
import 'me_dismissible.dart';

/// Vertically stacked swipe-to-dismiss cards with expressive physics.
class MEDismissibleColumn extends StatelessWidget {
  const MEDismissibleColumn({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.onDismiss,
    this.onTap,
    this.direction = DismissDirection.horizontal,
    this.gap = 8,
    this.padding,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  /// Return `true` (or omit) to allow the dismiss. Called with the item
  /// index and swipe direction.
  final Future<bool> Function(int index, DismissDirection direction)? onDismiss;
  final ValueChanged<int>? onTap;
  final DismissDirection direction;
  final double gap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < itemCount; i++) ...[
            if (i > 0) SizedBox(height: gap),
            _MEDismissibleCard(
              index: i,
              direction: direction,
              onDismiss: onDismiss,
              onTap: onTap,
              child: itemBuilder(context, i),
            ),
          ],
        ],
      ),
    );
  }
}

/// Horizontally swipeable card list — same API as [MEDismissibleColumn].
class MEDismissibleList extends StatelessWidget {
  const MEDismissibleList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.onDismiss,
    this.onTap,
    this.direction = DismissDirection.vertical,
    this.gap = 8,
    this.padding,
    this.itemWidth = 220,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final Future<bool> Function(int index, DismissDirection direction)? onDismiss;
  final ValueChanged<int>? onTap;
  final DismissDirection direction;
  final double gap;
  final EdgeInsetsGeometry? padding;
  final double itemWidth;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
      itemCount: itemCount,
      separatorBuilder: (_, __) => SizedBox(width: gap),
      itemBuilder: (context, i) {
        return SizedBox(
          width: itemWidth,
          child: _MEDismissibleCard(
            index: i,
            direction: direction,
            onDismiss: onDismiss,
            onTap: onTap,
            child: itemBuilder(context, i),
          ),
        );
      },
    );
  }
}

class _MEDismissibleCard extends StatelessWidget {
  const _MEDismissibleCard({
    required this.index,
    required this.direction,
    required this.child,
    this.onDismiss,
    this.onTap,
  });

  final int index;
  final DismissDirection direction;
  final Widget child;
  final Future<bool> Function(int index, DismissDirection direction)? onDismiss;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return MEDismissible(
      dismissKey: ValueKey<int>(index),
      direction: direction,
      confirmDismiss:
          onDismiss == null ? null : (dir) => onDismiss!(index, dir),
      child: Material(
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MECorners.large),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap == null ? null : () => onTap!(index),
          child: child,
        ),
      ),
    );
  }
}
