import 'package:flutter/material.dart';

import 'item_position.dart';
import 'me_dismissible.dart';

/// Vertically stacked swipe-to-dismiss cards with expressive physics.
///
/// Neighbours ease along with the dragged card (pull), and the stack uses
/// large outer / small inner corners like an M3 Expressive card group.
/// Swipe toward the start edge to archive, toward the end edge to delete.
class MEDismissibleColumn extends StatefulWidget {
  const MEDismissibleColumn({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.onDismiss,
    this.onTap,
    this.direction = DismissDirection.horizontal,
    this.gap = 4,
    this.padding,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  /// Called after the card has flown off. Return value is ignored; throw or
  /// handle errors inside the callback. Historically used as a confirm hook —
  /// use [MEDismissible.confirmDismiss] on a single row for that.
  final Future<bool> Function(int index, DismissDirection direction)? onDismiss;
  final ValueChanged<int>? onTap;
  final DismissDirection direction;
  final double gap;
  final EdgeInsetsGeometry? padding;

  @override
  State<MEDismissibleColumn> createState() => _MEDismissibleColumnState();
}

class _MEDismissibleColumnState extends State<MEDismissibleColumn> {
  int? _dragIndex;
  double _fraction = 0;
  late final List<Key> _keys = List<Key>.generate(
    widget.itemCount,
    (_) => UniqueKey(),
  );

  @override
  void didUpdateWidget(MEDismissibleColumn oldWidget) {
    super.didUpdateWidget(oldWidget);
    while (_keys.length < widget.itemCount) {
      _keys.add(UniqueKey());
    }
    while (_keys.length > widget.itemCount) {
      _keys.removeLast();
    }
  }

  void _onDrag(int index, double fraction) {
    final nextIndex = fraction.abs() < 0.002 ? null : index;
    if (nextIndex == _dragIndex && fraction == _fraction) return;
    setState(() {
      _dragIndex = nextIndex;
      _fraction = nextIndex == null ? 0 : fraction;
    });
  }

  Future<bool> _onDismissed(int index, DismissDirection direction) async {
    if (index >= 0 && index < _keys.length) {
      _keys.removeAt(index);
    }
    final result = await widget.onDismiss?.call(index, direction);
    return result ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return MEDismissibleDragScope(
      dragIndex: _dragIndex,
      fraction: _fraction,
      child: Padding(
        padding: widget.padding ?? EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < widget.itemCount; i++) ...[
              if (i > 0) SizedBox(height: widget.gap),
              _MEDismissibleCard(
                dismissKey: _keys[i],
                index: i,
                count: widget.itemCount,
                direction: widget.direction,
                onDismiss: widget.onDismiss == null ? null : _onDismissed,
                onTap: widget.onTap,
                onDragFraction: (f) => _onDrag(i, f),
                child: widget.itemBuilder(context, i),
              ),
            ],
          ],
        ),
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
            dismissKey: ValueKey<int>(i),
            index: i,
            count: itemCount,
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
    required this.dismissKey,
    required this.index,
    required this.count,
    required this.direction,
    required this.child,
    this.onDismiss,
    this.onTap,
    this.onDragFraction,
  });

  final Key dismissKey;
  final int index;
  final int count;
  final DismissDirection direction;
  final Widget child;
  final Future<bool> Function(int index, DismissDirection direction)? onDismiss;
  final ValueChanged<int>? onTap;
  final ValueChanged<double>? onDragFraction;

  ItemPosition get _position {
    if (count <= 1) return ItemPosition.alone;
    if (index == 0) return ItemPosition.start;
    if (index == count - 1) return ItemPosition.end;
    return ItemPosition.center;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final scope = MEDismissibleDragScope.maybeOf(context);
    final dx = scope?.offsetFor(index, Directionality.of(context)) ?? 0;
    final radius = _position.borderRadius;

    Widget card = Material(
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap == null ? null : () => onTap!(index),
        child: child,
      ),
    );

    Widget row = MEDismissible(
      dismissKey: dismissKey,
      direction: direction,
      onDismissed: onDismiss == null
          ? null
          : (dir) {
              onDismiss!(index, dir);
            },
      onDragFraction: onDragFraction,
      child: card,
    );

    if (dx != 0) {
      row = Transform.translate(offset: Offset(dx, 0), child: row);
    }
    return row;
  }
}
