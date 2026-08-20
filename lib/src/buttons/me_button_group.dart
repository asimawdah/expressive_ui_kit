import 'package:flutter/material.dart';

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

class _MEButtonGroupState extends State<MEButtonGroup>
    with TickerProviderStateMixin {
  int _pressedIndex = -1;
  late final AnimationController _press = AnimationController.unbounded(
    vsync: this,
    value: 0,
  );

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  void _setPressed(int index, bool pressed) {
    setState(() => _pressedIndex = pressed ? index : -1);
    springTo(
      _press,
      pressed ? 1 : 0,
      pressed
          ? METheme.of(context).motion.fastSpatial
          : METheme.of(context).motion.defaultSpatial,
    );
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
    return AnimatedBuilder(
      animation: _press,
      builder: (context, _) {
        final t = _press.value.clamp(0.0, 1.2);
        return widget.direction == Axis.vertical
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < widget.items.length; i++) ...[
                    if (i > 0) SizedBox(height: connected ? 2 : 8),
                    _buildChild(context, i, t, connected),
                  ],
                ],
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < widget.items.length; i++) ...[
                    if (i > 0) SizedBox(width: connected ? 2 : 8),
                    _buildChild(context, i, t, connected),
                  ],
                ],
              );
      },
    );
  }

  Widget _buildChild(BuildContext context, int i, double t, bool connected) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final item = widget.items[i];
    final selected = widget.selectedIndices.contains(i);
    final isPressed = _pressedIndex == i;
    final isNeighbor = (_pressedIndex - i).abs() == 1;

    // Signature group motion: pressed grows, direct neighbors compress
    // along the layout axis.
    final double scale = isPressed
        ? 1 + 0.08 * t
        : isNeighbor
            ? 1 - 0.06 * t
            : 1;

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

    return Transform.scale(
      scaleX: widget.direction == Axis.horizontal ? scale : 1,
      scaleY: widget.direction == Axis.vertical ? scale : 1,
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
