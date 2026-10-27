import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';

/// A Material 3 Expressive wheel picker.
///
/// A vertical scroll wheel of items with a tonal selection window. Items
/// scale and fade as they curve away from the center, the selection
/// window's shape morphs squarer while the wheel is being dragged, and
/// each detent emits a light haptic tick.
///
/// ```dart
/// MEWheelPicker(
///   items: const ['Small', 'Medium', 'Large'],
///   onSelected: (i) => setState(() => size = i),
/// )
/// ```
class MEWheelPicker extends StatefulWidget {
  const MEWheelPicker({
    super.key,
    required this.items,
    this.initialIndex = 0,
    this.onSelected,
    this.height = 200,
    this.itemExtent = 44,
    this.haptics = true,
  });

  /// Labels for each wheel entry.
  final List<String> items;

  /// Index selected when the picker is first built.
  final int initialIndex;

  /// Called with the item index whenever the wheel settles on a detent.
  final ValueChanged<int>? onSelected;

  final double height;
  final double itemExtent;

  /// Emit a selection haptic on each detent change.
  final bool haptics;

  @override
  State<MEWheelPicker> createState() => _MEWheelPickerState();
}

class _MEWheelPickerState extends State<MEWheelPicker> {
  late final FixedExtentScrollController _controller =
      FixedExtentScrollController(initialItem: widget.initialIndex);
  late int _selected = widget.initialIndex;
  bool _dragging = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSelectedItemChanged(int index) {
    if (index == _selected) return;
    setState(() => _selected = index);
    if (widget.haptics) HapticFeedback.selectionClick();
    widget.onSelected?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final motion = METheme.of(context).motion;

    return SizedBox(
      height: widget.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Selection window: morphs squarer while dragging, like a
          // pressed M3E surface.
          AnimatedContainer(
            duration: motion.defaultSpatial.approximateDuration,
            curve: motion.defaultSpatial.curve,
            height: widget.itemExtent,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: ShapeDecoration(
              color: scheme.secondaryContainer,
              shape: MEShapeScheme.fromCorner(
                _dragging ? MECorners.small : MECorners.large,
              ),
            ),
          ),
          NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n is ScrollStartNotification) {
                setState(() => _dragging = true);
              } else if (n is ScrollEndNotification) {
                setState(() => _dragging = false);
              }
              return false;
            },
            child: ListWheelScrollView.useDelegate(
              controller: _controller,
              itemExtent: widget.itemExtent,
              physics: const FixedExtentScrollPhysics(),
              diameterRatio: 1.6,
              perspective: 0.004,
              overAndUnderCenterOpacity: 0.35,
              onSelectedItemChanged: _onSelectedItemChanged,
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: widget.items.length,
                builder: (context, i) {
                  final selected = i == _selected;
                  return Center(
                    child: AnimatedDefaultTextStyle(
                      duration: motion.defaultEffects.approximateDuration,
                      curve: Curves.easeOutCubic,
                      style: (selected
                              ? METypography.emphasize(text.titleMedium!)
                              : text.bodyLarge!)
                          .copyWith(
                        color: selected
                            ? scheme.onSecondaryContainer
                            : scheme.onSurfaceVariant,
                      ),
                      child: Text(widget.items[i]),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
