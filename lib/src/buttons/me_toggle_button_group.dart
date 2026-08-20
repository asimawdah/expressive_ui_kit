import 'package:flutter/material.dart';

import '../internal/me_neighbor_squish.dart';
import '../theme/me_motion.dart';
import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';
import 'me_button.dart';
import 'me_button_group.dart';
import 'me_toggle_button.dart';

/// One action in an [METoggleButtonGroup].
class METoggleButtonGroupItem {
  const METoggleButtonGroupItem({
    this.icon,
    this.checkedIcon,
    this.label,
    this.tooltip,
  }) : assert(icon != null || label != null);

  final Widget? icon;
  final Widget? checkedIcon;
  final Widget? label;
  final String? tooltip;
}

/// A row (or column) of [METoggleButton]s with neighbor-squish motion.
///
/// Distinct from [MEButtonGroup], which is a cluster of momentary actions.
/// Use this for checked tool clusters (bold / italic / underline).
class METoggleButtonGroup extends StatefulWidget {
  const METoggleButtonGroup({
    super.key,
    required this.items,
    required this.selected,
    required this.onChanged,
    this.multiSelect = true,
    this.variant = MEButtonVariant.tonal,
    this.size = MEButtonSize.small,
    this.direction = Axis.horizontal,
    this.style = MEButtonGroupStyle.standard,
    this.gap,
  });

  final List<METoggleButtonGroupItem> items;
  final Set<int> selected;
  final ValueChanged<Set<int>> onChanged;
  final bool multiSelect;
  final MEButtonVariant variant;
  final MEButtonSize size;
  final Axis direction;
  final MEButtonGroupStyle style;

  /// Gap between items. Defaults to 8 (standard) or 2 (connected).
  final double? gap;

  @override
  State<METoggleButtonGroup> createState() => _METoggleButtonGroupState();
}

class _METoggleButtonGroupState extends State<METoggleButtonGroup> {
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

  void _toggle(int index) {
    final next = Set<int>.of(widget.selected);
    if (next.contains(index)) {
      if (widget.multiSelect || next.length > 1) next.remove(index);
    } else {
      if (!widget.multiSelect) next.clear();
      next.add(index);
    }
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final connected = widget.style == MEButtonGroupStyle.connected;
    final gap = widget.gap ?? (connected ? 2.0 : 8.0);
    return MEMotionBuilder(
      value: _pressedIndex != null ? 1.0 : 0.0,
      spec: METheme.of(context).motion.defaultSpatial,
      builder: (context, t, _) {
        final children = [
          for (var i = 0; i < widget.items.length; i++) ...[
            if (i > 0)
              SizedBox(
                width: widget.direction == Axis.horizontal ? gap : 0,
                height: widget.direction == Axis.vertical ? gap : 0,
              ),
            _buildItem(i, t, connected),
          ],
        ];
        return widget.direction == Axis.horizontal
            ? Row(mainAxisSize: MainAxisSize.min, children: children)
            : Column(mainAxisSize: MainAxisSize.min, children: children);
      },
    );
  }

  Widget _buildItem(int i, double t, bool connected) {
    final item = widget.items[i];
    ShapeBorder? connectedShape;
    if (connected) {
      final last = widget.items.length - 1;
      final r = widget.size.height / 2;
      const inner = MECorners.small;
      connectedShape = RoundedRectangleBorder(
        borderRadius: widget.direction == Axis.vertical
            ? BorderRadiusDirectional.vertical(
                top: Radius.circular(i == 0 ? r : inner),
                bottom: Radius.circular(i == last ? r : inner),
              )
            : BorderRadiusDirectional.horizontal(
                start: Radius.circular(i == 0 ? r : inner),
                end: Radius.circular(i == last ? r : inner),
              ),
      );
    }

    return MENeighborSquish(
      factor: meNeighborSquishFactor(
        index: i,
        count: widget.items.length,
        pressedIndex: _lastPressedIndex,
        t: t,
      ),
      alignment: meNeighborSquishAlignment(
        index: i,
        pressedIndex: _lastPressedIndex,
        direction: widget.direction,
      ),
      direction: widget.direction,
      child: Listener(
        onPointerDown: (_) => _setPressed(i, true),
        onPointerUp: (_) => _setPressed(i, false),
        onPointerCancel: (_) => _setPressed(i, false),
        child: METoggleButton(
          checked: widget.selected.contains(i),
          icon: item.icon,
          checkedIcon: item.checkedIcon,
          label: item.label,
          tooltip: item.tooltip,
          variant: widget.variant,
          size: widget.size,
          shape: connectedShape,
          selectedShape: connectedShape,
          onCheckedChange: (_) => _toggle(i),
        ),
      ),
    );
  }
}
