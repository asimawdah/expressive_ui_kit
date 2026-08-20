import 'package:flutter/material.dart';

import '../theme/me_theme.dart';
import 'me_list_tile.dart';

/// A Material 3 Expressive reorderable list.
///
/// Replaces [ReorderableListView] for simple vertical lists built from
/// [MEListTile] segments. Each row exposes a drag handle; callers supply
/// stable [keys] so items keep their identity while reordering.
class MEReorderableList extends StatelessWidget {
  const MEReorderableList({
    super.key,
    required this.keys,
    required this.itemBuilder,
    required this.onReorder,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.dragHandleIcon = Icons.drag_handle,
    this.itemSpacing = 4,
  }) : assert(keys.length > 0);

  /// Stable keys for each row, in display order.
  final List<Key> keys;

  /// Builds the tile body for [index]. [position] is derived from the row's
  /// place in the list so grouped corner radii stay correct.
  final Widget Function(
      BuildContext context, int index, MEListPosition position) itemBuilder;

  final ReorderCallback onReorder;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final IconData dragHandleIcon;
  final double itemSpacing;

  MEListPosition _positionFor(int index) {
    final count = keys.length;
    if (count == 1) return MEListPosition.only;
    if (index == 0) return MEListPosition.first;
    if (index == count - 1) return MEListPosition.last;
    return MEListPosition.middle;
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return ReorderableListView.builder(
      padding: padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      itemCount: keys.length,
      onReorderItem: onReorder,
      buildDefaultDragHandles: false,
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final t = METheme.of(context)
                .motion
                .fastSpatial
                .curve
                .transform(animation.value);
            return Material(
              elevation: 4 * t,
              borderRadius: BorderRadius.circular(12),
              child: child,
            );
          },
          child: child,
        );
      },
      itemBuilder: (context, index) {
        return Padding(
          key: keys[index],
          padding: EdgeInsets.only(
              bottom: index == keys.length - 1 ? 0 : itemSpacing),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ReorderableDragStartListener(
                index: index,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4, right: 8),
                  child: Icon(dragHandleIcon, color: iconColor),
                ),
              ),
              Expanded(
                child: itemBuilder(context, index, _positionFor(index)),
              ),
            ],
          ),
        );
      },
    );
  }
}
