import 'package:flutter/material.dart';

import '../internal/me_pressable.dart';
import '../theme/me_shapes.dart';

/// A segment within an [MESegmentedButton].
@immutable
class MESegment<T> {
  const MESegment({
    required this.value,
    required this.label,
    this.icon,
    this.enabled = true,
  });

  final T value;
  final Widget label;
  final Widget? icon;
  final bool enabled;
}

/// A Material 3 Expressive segmented button.
///
/// Replaces [SegmentedButton]. Selected segments morph from the shared
/// rounded-rectangle silhouette to a fully-round pill with a springy
/// check-mark reveal, following the M3E "shape communicates selection"
/// principle.
///
/// Supports single selection (default) and multi-selection via
/// [multiSelectionEnabled]. [emptySelectionAllowed] permits deselecting
/// the last selected segment.
class MESegmentedButton<T> extends StatelessWidget {
  const MESegmentedButton({
    super.key,
    required this.segments,
    required this.selected,
    required this.onSelectionChanged,
    this.multiSelectionEnabled = false,
    this.emptySelectionAllowed = false,
    this.showCheckmark = true,
    this.height = 40,
  }) : assert(segments.length >= 2, 'Provide at least two segments.');

  final List<MESegment<T>> segments;

  /// Currently selected values.
  final Set<T> selected;
  final ValueChanged<Set<T>> onSelectionChanged;
  final bool multiSelectionEnabled;
  final bool emptySelectionAllowed;
  final bool showCheckmark;
  final double height;

  void _handleTap(T value) {
    final next = Set<T>.of(selected);
    if (next.contains(value)) {
      if (next.length > 1 || emptySelectionAllowed) next.remove(value);
    } else {
      if (!multiSelectionEnabled) next.clear();
      next.add(value);
    }
    onSelectionChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(color: colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < segments.length; i++) ...[
            if (i > 0)
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: colors.outlineVariant,
              ),
            _buildSegment(context, segments[i], colors, textTheme),
          ],
        ],
      ),
    );
  }

  Widget _buildSegment(
    BuildContext context,
    MESegment<T> segment,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
    final isSelected = selected.contains(segment.value);
    final enabled = segment.enabled;

    final fg = !enabled
        ? colors.onSurface.withValues(alpha: 0.38)
        : isSelected
            ? colors.onSecondaryContainer
            : colors.onSurfaceVariant;

    return MEPressable(
      onPressed: enabled ? () => _handleTap(segment.value) : null,
      enabled: enabled,
      // Rest: square (blends into the shared container). Selected: pill.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MECorners.extraSmall),
      ),
      selectedShape: const StadiumBorder(),
      selected: isSelected,
      color: isSelected ? colors.secondaryContainer : Colors.transparent,
      overlayColor: fg.withValues(alpha: 0.1),
      semanticLabel: null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showCheckmark)
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                child: isSelected
                    ? Padding(
                        padding: const EdgeInsetsDirectional.only(end: 6),
                        child: Icon(Icons.check, size: 18, color: fg),
                      )
                    : const SizedBox.shrink(),
              ),
            if (segment.icon != null && !(isSelected && showCheckmark)) ...[
              IconTheme.merge(
                data: IconThemeData(size: 18, color: fg),
                child: segment.icon!,
              ),
              const SizedBox(width: 6),
            ],
            DefaultTextStyle.merge(
              style: textTheme.labelLarge!.copyWith(color: fg),
              child: segment.label,
            ),
          ],
        ),
      ),
    );
  }
}
