import 'package:flutter/material.dart';

import '../internal/me_neighbor_squish.dart';
import '../internal/me_pressable.dart';
import '../theme/me_motion.dart';
import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';
import 'me_button.dart';

/// Layout styles for [MEButtonGroup].
enum MEButtonGroupStyle {
  /// Children keep their own shapes with a small gap between them.
  /// Pressing a child causes its neighbors to compress — the signature
  /// M3 Expressive group interaction.
  standard,

  /// Children share one connected pill: outer corners are fully rounded,
  /// inner corners are small. Used for single/multi-select segmented
  /// controls (replaces [SegmentedButton]).
  connected,
}

/// A child of [MEButtonGroup].
class MEButtonGroupItem {
  const MEButtonGroupItem({
    required this.child,
    this.icon,
    this.onPressed,
  });

  final Widget child;
  final Widget? icon;
  final VoidCallback? onPressed;
}

/// A Material 3 Expressive button group.
///
/// A new M3E component that arranges related buttons with shared shape
/// and motion. In [MEButtonGroupStyle.standard] the pressed button grows
/// while its neighbors shrink; in [MEButtonGroupStyle.connected] the
/// group forms a segmented pill with selection support.
class MEButtonGroup extends StatefulWidget {
  const MEButtonGroup({
    super.key,
    required this.items,
    this.style = MEButtonGroupStyle.standard,
    this.selectedIndices = const {},
    this.onSelectionChanged,
    this.multiSelect = false,
    this.size = MEButtonSize.small,
    this.direction = Axis.horizontal,
  });

  final List<MEButtonGroupItem> items;
  final MEButtonGroupStyle style;

  /// Selected indices, used by [MEButtonGroupStyle.connected].
  final Set<int> selectedIndices;
  final ValueChanged<Set<int>>? onSelectionChanged;
  final bool multiSelect;

  /// Container height. Defaults to the small (40dp) M3E button size.
  final MEButtonSize size;

  /// Layout axis. Vertical groups still neighbor-squish along that axis.
  final Axis direction;

  @override
  State<MEButtonGroup> createState() => _MEButtonGroupState();
}

class _MEButtonGroupState extends State<MEButtonGroup> {
  int? _pressedIndex;
  int? _lastPressedIndex;

  void _setPressed(int index, bool pressed) {
    setState(() {
      if (pressed) {
        _pressedIndex = index;
        _lastPressedIndex = index;
      } else if (_pressedIndex == index) {
        _pressedIndex = null;
      }
    });
  }

  void _handleTap(int index) {
    widget.items[index].onPressed?.call();
    if (widget.onSelectionChanged == null) return;
    final next = Set<int>.of(widget.selectedIndices);
    if (widget.multiSelect) {
      next.contains(index) ? next.remove(index) : next.add(index);
    } else {
      next
        ..clear()
        ..add(index);
    }
    widget.onSelectionChanged!(next);
  }

  @override
  Widget build(BuildContext context) {
    final connected = widget.style == MEButtonGroupStyle.connected;
    final motion = METheme.of(context).motion;
    return MEMotionBuilder(
      value: _pressedIndex != null ? 1.0 : 0.0,
      spec: motion.defaultSpatial,
      builder: (context, t, _) {
        final children = [
          for (var i = 0; i < widget.items.length; i++) ...[
            if (i > 0)
              SizedBox(
                width: widget.direction == Axis.horizontal
                    ? (connected ? 2.0 : 8.0)
                    : 0,
                height: widget.direction == Axis.vertical
                    ? (connected ? 2.0 : 8.0)
                    : 0,
              ),
            _buildChild(context, i, t, connected),
          ],
        ];
        return widget.direction == Axis.vertical
            ? Column(mainAxisSize: MainAxisSize.min, children: children)
            : Row(mainAxisSize: MainAxisSize.min, children: children);
      },
    );
  }

  Widget _buildChild(BuildContext context, int i, double t, bool connected) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final item = widget.items[i];
    final selected = widget.selectedIndices.contains(i);

    final factor = meNeighborSquishFactor(
      index: i,
      count: widget.items.length,
      pressedIndex: _lastPressedIndex,
      t: t,
    );
    final alignment = meNeighborSquishAlignment(
      index: i,
      pressedIndex: _lastPressedIndex,
      direction: widget.direction,
    );

    final last = widget.items.length - 1;
    final height = widget.size.height;
    final ShapeBorder shape;
    if (!connected) {
      shape = const StadiumBorder();
    } else {
      shape = RoundedRectangleBorder(
        borderRadius: _connectedRadius(
          index: i,
          last: last,
          radius: height / 2,
          vertical: widget.direction == Axis.vertical,
        ),
      );
    }

    final bg = selected
        ? colors.primary
        : connected
            ? colors.surfaceContainerHigh
            : colors.secondaryContainer;
    final fg = selected
        ? colors.onPrimary
        : connected
            ? colors.onSurface
            : colors.onSecondaryContainer;

    return MENeighborSquish(
      factor: factor,
      alignment: alignment,
      direction: widget.direction,
      child: Listener(
        onPointerDown: (_) => _setPressed(i, true),
        onPointerUp: (_) => _setPressed(i, false),
        onPointerCancel: (_) => _setPressed(i, false),
        child: MEPressable(
          onPressed: () => _handleTap(i),
          shape: shape,
          pressedShape: widget.size.pressedContainerShape,
          color: bg,
          overlayColor: fg.withValues(alpha: 0.1),
          child: Container(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.icon != null) ...[
                  IconTheme.merge(
                    data: IconThemeData(size: 20, color: fg),
                    child: item.icon!,
                  ),
                  const SizedBox(width: 8),
                ],
                DefaultTextStyle.merge(
                  style: textTheme.labelLarge!.copyWith(color: fg),
                  child: item.child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

BorderRadiusDirectional _connectedRadius({
  required int index,
  required int last,
  required double radius,
  required bool vertical,
}) {
  const inner = MECorners.small;
  if (vertical) {
    return BorderRadiusDirectional.vertical(
      top: Radius.circular(index == 0 ? radius : inner),
      bottom: Radius.circular(index == last ? radius : inner),
    );
  }
  return BorderRadiusDirectional.horizontal(
    start: Radius.circular(index == 0 ? radius : inner),
    end: Radius.circular(index == last ? radius : inner),
  );
}
