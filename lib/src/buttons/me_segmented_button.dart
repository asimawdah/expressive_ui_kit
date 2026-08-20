import 'package:flutter/material.dart';

import '../internal/me_keyboard.dart';
import '../theme/me_theme.dart';

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
/// In single-selection mode a stadium indicator slides between segments
/// (similar to [NavigationBar]), with no hard divider between options.
///
/// Set [expanded] to `false` for a compact intrinsic-width control.
class MESegmentedButton<T> extends StatefulWidget {
  const MESegmentedButton({
    super.key,
    required this.segments,
    required this.selected,
    required this.onSelectionChanged,
    this.multiSelectionEnabled = false,
    this.emptySelectionAllowed = false,
    this.showCheckmark = true,
    this.expanded = true,
    this.height = 40,
    this.animationDuration,
    this.animationCurve,
    this.focusNode,
    this.autofocus = false,
  }) : assert(segments.length >= 2, 'Provide at least two segments.');

  final List<MESegment<T>> segments;

  /// Currently selected values.
  final Set<T> selected;
  final ValueChanged<Set<T>> onSelectionChanged;
  final bool multiSelectionEnabled;
  final bool emptySelectionAllowed;
  final bool showCheckmark;

  /// When true (default), the control fills available width and each segment
  /// expands equally with centered content.
  final bool expanded;
  final double height;

  /// Thumb / checkmark duration. Null uses the theme spatial spring.
  final Duration? animationDuration;

  /// Thumb / checkmark curve. Null uses the theme spatial spring.
  final Curve? animationCurve;

  /// Optional focus node for keyboard navigation (single-selection mode).
  final FocusNode? focusNode;

  /// Whether this control should request focus when first built.
  final bool autofocus;

  @override
  State<MESegmentedButton<T>> createState() => _MESegmentedButtonState<T>();
}

class _MESegmentedButtonState<T> extends State<MESegmentedButton<T>> {
  static const _thumbInset = 3.0;

  void _handleTap(T value) {
    final next = Set<T>.of(widget.selected);
    if (next.contains(value)) {
      if (next.length > 1 || widget.emptySelectionAllowed) next.remove(value);
    } else {
      if (!widget.multiSelectionEnabled) next.clear();
      next.add(value);
    }
    widget.onSelectionChanged(next);
  }

  int get _selectedIndex {
    if (widget.selected.isEmpty) return 0;
    final index = widget.segments.indexWhere(
      (segment) => segment.value == widget.selected.first,
    );
    return index < 0 ? 0 : index;
  }

  AlignmentGeometry get _thumbAlignment {
    final count = widget.segments.length;
    if (count <= 1) return AlignmentDirectional.center;
    final t = _selectedIndex / (count - 1);
    // Directional so the thumb tracks the mirrored Row in RTL.
    return AlignmentDirectional(-1.0 + 2.0 * t, 0);
  }

  bool get _useSlidingThumb => !widget.multiSelectionEnabled;

  Duration _duration(BuildContext context) =>
      widget.animationDuration ??
      METheme.of(context).motion.defaultSpatial.approximateDuration;

  Curve _curve(BuildContext context) =>
      widget.animationCurve ?? METheme.of(context).motion.defaultSpatial.curve;

  void _selectIndex(int index) {
    if (index < 0 || index >= widget.segments.length) return;
    final segment = widget.segments[index];
    if (!segment.enabled) return;
    widget.onSelectionChanged({segment.value});
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Focus(
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      onKeyEvent: _useSlidingThumb
          ? (node, event) => MEKeyboard.handleHorizontalSelection(
                event: event,
                current: _selectedIndex,
                count: widget.segments.length,
                direction: Directionality.of(context),
                onSelected: _selectIndex,
              )
          : null,
      child: Container(
        height: widget.height,
        width: widget.expanded ? double.infinity : null,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.height / 2),
          border: Border.all(color: colors.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: _useSlidingThumb
            ? _buildSlidingBody(colors, textTheme)
            : _buildMultiBody(colors, textTheme),
      ),
    );
  }

  Widget _buildSlidingBody(ColorScheme colors, TextTheme textTheme) {
    final thumb = DecoratedBox(
      decoration: ShapeDecoration(
        color: colors.secondaryContainer,
        shape: const StadiumBorder(),
      ),
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        if (widget.selected.isNotEmpty)
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(_thumbInset),
              child: AnimatedAlign(
                duration: _duration(context),
                curve: _curve(context),
                alignment: _thumbAlignment,
                child: FractionallySizedBox(
                  widthFactor: 1 / widget.segments.length,
                  heightFactor: 1,
                  child: thumb,
                ),
              ),
            ),
          ),
        Row(
          mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
          children: [
            for (final segment in widget.segments)
              if (widget.expanded)
                Expanded(child: _buildLabelSegment(segment, colors, textTheme))
              else
                _buildLabelSegment(segment, colors, textTheme),
          ],
        ),
      ],
    );
  }

  Widget _buildMultiBody(ColorScheme colors, TextTheme textTheme) {
    return Row(
      mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
      children: [
        for (final segment in widget.segments)
          if (widget.expanded)
            Expanded(
              child: _buildLegacySegment(segment, colors, textTheme),
            )
          else
            _buildLegacySegment(segment, colors, textTheme),
      ],
    );
  }

  Widget _buildLabelSegment(
    MESegment<T> segment,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
    final isSelected = widget.selected.contains(segment.value);
    final enabled = segment.enabled;
    final fg = !enabled
        ? colors.onSurface.withValues(alpha: 0.38)
        : isSelected
            ? colors.onSecondaryContainer
            : colors.onSurfaceVariant;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? () => _handleTap(segment.value) : null,
      child: SizedBox(
        height: widget.height,
        width: widget.expanded ? double.infinity : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
            children: [
              if (widget.showCheckmark)
                AnimatedSize(
                  duration: _duration(context),
                  curve: _curve(context),
                  child: isSelected
                      ? Padding(
                          padding: const EdgeInsetsDirectional.only(end: 8),
                          child: Icon(Icons.check, size: 18, color: fg),
                        )
                      : const SizedBox.shrink(),
                ),
              if (segment.icon != null &&
                  !(isSelected && widget.showCheckmark)) ...[
                IconTheme.merge(
                  data: IconThemeData(size: 18, color: fg),
                  child: segment.icon!,
                ),
                const SizedBox(width: 8),
              ],
              if (widget.expanded)
                Flexible(
                  child: AnimatedDefaultTextStyle(
                    duration: _duration(context),
                    curve: _curve(context),
                    style: textTheme.labelLarge!.copyWith(
                      color: fg,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    child: segment.label,
                  ),
                )
              else
                AnimatedDefaultTextStyle(
                  duration: _duration(context),
                  curve: _curve(context),
                  style: textTheme.labelLarge!.copyWith(
                    color: fg,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  child: segment.label,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegacySegment(
    MESegment<T> segment,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
    final isSelected = widget.selected.contains(segment.value);
    final enabled = segment.enabled;
    final fg = !enabled
        ? colors.onSurface.withValues(alpha: 0.38)
        : isSelected
            ? colors.onSecondaryContainer
            : colors.onSurfaceVariant;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? () => _handleTap(segment.value) : null,
      child: AnimatedContainer(
        duration: _duration(context),
        curve: _curve(context),
        height: widget.height,
        width: widget.expanded ? double.infinity : null,
        decoration: ShapeDecoration(
          color: isSelected ? colors.secondaryContainer : Colors.transparent,
          shape: const StadiumBorder(),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
          children: [
            if (widget.showCheckmark)
              AnimatedSize(
                duration: _duration(context),
                curve: _curve(context),
                child: isSelected
                    ? Padding(
                        padding: const EdgeInsetsDirectional.only(end: 8),
                        child: Icon(Icons.check, size: 18, color: fg),
                      )
                    : const SizedBox.shrink(),
              ),
            if (segment.icon != null &&
                !(isSelected && widget.showCheckmark)) ...[
              IconTheme.merge(
                data: IconThemeData(size: 18, color: fg),
                child: segment.icon!,
              ),
              const SizedBox(width: 8),
            ],
            if (widget.expanded)
              Flexible(
                child: DefaultTextStyle.merge(
                  style: textTheme.labelLarge!.copyWith(color: fg),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  child: segment.label,
                ),
              )
            else
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
