import 'package:flutter/material.dart';

import '../internal/me_pressable.dart';
import '../theme/me_shapes.dart';
import 'item_position.dart';
import 'me_list_tile.dart';

/// Vertically stacked cards with dynamic corner rounding.
///
/// Neighbours share a 2dp gap and the first/last items get large radii —
/// the same segmented-container language as [MEListGroup], but for any
/// child, not just [MEListTile].
class MECardList extends StatelessWidget {
  const MECardList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.onTap,
    this.onLongPress,
    this.gap = 2,
    this.outlined = false,
    this.listPadding,
    this.colorBuilder,
    this.borderRadiusBuilder,
  })  : shrinkWrap = true,
        physics = const NeverScrollableScrollPhysics(),
        scrollable = false;

  /// Scrollable / lazy variant.
  const MECardList.builder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.onTap,
    this.onLongPress,
    this.gap = 2,
    this.outlined = false,
    this.listPadding,
    this.shrinkWrap = false,
    this.physics,
    this.colorBuilder,
    this.borderRadiusBuilder,
  }) : scrollable = true;

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final ValueChanged<int>? onTap;
  final ValueChanged<int>? onLongPress;
  final double gap;
  final bool outlined;
  final EdgeInsetsGeometry? listPadding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final bool scrollable;
  final Color? Function(int index)? colorBuilder;
  final BorderRadius? Function(int index, MEListPosition position)?
      borderRadiusBuilder;

  MEListPosition _position(int index) {
    if (itemCount == 1) return MEListPosition.only;
    if (index == 0) return MEListPosition.first;
    if (index == itemCount - 1) return MEListPosition.last;
    return MEListPosition.middle;
  }

  BorderRadius _radiusFor(MEListPosition position) {
    const large = Radius.circular(MECorners.large);
    const small = Radius.circular(MECorners.extraSmall);
    switch (position) {
      case MEListPosition.only:
        return const BorderRadius.all(large);
      case MEListPosition.first:
        return const BorderRadius.vertical(top: large, bottom: small);
      case MEListPosition.middle:
        return const BorderRadius.all(small);
      case MEListPosition.last:
        return const BorderRadius.vertical(top: small, bottom: large);
    }
  }

  Widget _item(BuildContext context, int index) {
    final scheme = Theme.of(context).colorScheme;
    final position = _position(index);
    final radius =
        borderRadiusBuilder?.call(index, position) ?? _radiusFor(position);
    final color = colorBuilder?.call(index) ?? scheme.surfaceContainerLow;

    return MEPressable(
      onPressed: onTap == null ? null : () => onTap!(index),
      onLongPress: onLongPress == null ? null : () => onLongPress!(index),
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: outlined
            ? BorderSide(color: scheme.outlineVariant)
            : BorderSide.none,
      ),
      color: color,
      child: itemBuilder(context, index),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) return const SizedBox.shrink();

    if (!scrollable) {
      return Padding(
        padding: listPadding ?? EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < itemCount; i++) ...[
              if (i > 0) SizedBox(height: gap),
              _item(context, i),
            ],
          ],
        ),
      );
    }

    return ListView.separated(
      padding: listPadding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: itemCount,
      separatorBuilder: (_, __) => SizedBox(height: gap),
      itemBuilder: _item,
    );
  }
}

/// Maps [ItemPosition] used by older list APIs onto [MEListPosition].
MEListPosition meListPositionFromItem(ItemPosition position) {
  return switch (position) {
    ItemPosition.alone ||
    ItemPosition.left ||
    ItemPosition.right =>
      MEListPosition.only,
    ItemPosition.start || ItemPosition.top => MEListPosition.first,
    ItemPosition.end ||
    ItemPosition.bottom ||
    ItemPosition.bottomLeft ||
    ItemPosition.bottomRight =>
      MEListPosition.last,
    ItemPosition.center => MEListPosition.middle,
  };
}
