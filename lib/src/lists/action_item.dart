import 'package:flutter/material.dart';

import 'item_position.dart';

/// Material 3 Expressive list item with segmented style, spring-based
/// press animation, large rounded corners, and emphasized typography.
class ActionItem extends StatefulWidget {
  const ActionItem({
    super.key,
    required this.title,
    required this.itemPosition,
    this.subtitle,
    this.centerTitle = false,
    this.icon,
    this.onTap,
    this.onLongPress,
    this.trailing,
    this.tileColor,
    this.titleColor,
    this.below,
    this.gap,
    this.selected,
    this.customRadius,
    this.hasLine = false,
    this.maxSubtitleLines = 1,
    this.maxTitleLines = 1,
    this.padding,
    this.outerPadding,
    this.contentPadding,
    this.isTitleExpanded = false,
    this.disableTitleExpansion = false,
    this.isPro,
  });

  final Object? title;
  final Widget? subtitle;
  final bool centerTitle;
  final Widget? icon;
  final ItemPosition itemPosition;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget? trailing;
  final Widget? below;
  final Color? tileColor;
  final Color? titleColor;
  final double? gap;
  final bool? selected;
  final BorderRadius? customRadius;
  final bool hasLine;
  final int maxSubtitleLines;
  final int maxTitleLines;
  final double? padding;
  final EdgeInsetsGeometry? outerPadding;
  final EdgeInsetsGeometry? contentPadding;
  final bool isTitleExpanded;
  final bool disableTitleExpansion;
  final bool? isPro;
  @override
  State<ActionItem> createState() => _ActionItemState();
}

class _ActionItemState extends State<ActionItem> {
  bool _pressed = false;
  late bool _isTitleExpanded;

  @override
  void initState() {
    super.initState();
    _isTitleExpanded = widget.isTitleExpanded;
  }

  bool _isTextOverflowing({
    required String text,
    required TextStyle? style,
    required double maxWidth,
    required TextDirection textDirection,
  }) {
    if (!maxWidth.isFinite || widget.maxTitleLines <= 0 || _isTitleExpanded) {
      return false;
    }

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: widget.maxTitleLines,
      textDirection: textDirection,
    )..layout(maxWidth: maxWidth);

    return textPainter.didExceedMaxLines;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    final lineBorder = widget.hasLine
        ? Border(
            left: isRTL
                ? BorderSide(color: theme.colorScheme.outline, width: 2)
                : BorderSide.none,
            right: !isRTL
                ? BorderSide(color: theme.colorScheme.outline, width: 2)
                : BorderSide.none,
          )
        : null;

    late final Widget newTitle;
    if (widget.title is String) {
      final titleText = widget.title.toString();
      final titleStyle = theme.textTheme.titleMedium?.copyWith(
        color: widget.titleColor,
      );

      final titleWidget = DecoratedBox(
        decoration: BoxDecoration(border: lineBorder),
        child: Padding(
          padding: const EdgeInsets.only(left: 4, right: 4),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final textWidget = Text(
                titleText,
                style: titleStyle,
                maxLines: _isTitleExpanded ? null : widget.maxTitleLines,
                overflow: _isTitleExpanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
              );

              final shouldEnableExpansion = _isTextOverflowing(
                text: titleText,
                style: titleStyle,
                maxWidth: constraints.maxWidth,
                textDirection: Directionality.of(context),
              );

              if (!shouldEnableExpansion || widget.disableTitleExpansion) {
                return textWidget;
              }

              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => setState(() => _isTitleExpanded = true),
                child: textWidget,
              );
            },
          ),
        ),
      );
      newTitle = titleWidget;
    } else if (widget.title is Widget) {
      newTitle = widget.title as Widget;
    } else {
      newTitle = const SizedBox.shrink();
    }

    final effectiveContentPadding = widget.contentPadding ??
        EdgeInsets.symmetric(horizontal: widget.gap ?? 16.0);

    final effectiveMinVerticalPadding =
        widget.padding ?? (widget.subtitle == null ? 14.0 : 10.0);

    final borderRadius = widget.selected == true
        ? ItemPosition.alone.borderRadius
        : (widget.customRadius ?? widget.itemPosition.borderRadius);

    final isInteractive = widget.onTap != null || widget.onLongPress != null;

    return Material(
      type: MaterialType.transparency,
      child: Padding(
        padding: widget.outerPadding ??
            (widget.selected == true
                ? const EdgeInsets.symmetric(vertical: 2)
                : widget.itemPosition.padding),
        child: Listener(
          onPointerDown:
              isInteractive ? (_) => setState(() => _pressed = true) : null,
          onPointerUp:
              isInteractive ? (_) => setState(() => _pressed = false) : null,
          onPointerCancel:
              isInteractive ? (_) => setState(() => _pressed = false) : null,
          child: AnimatedScale(
            scale: _pressed ? 0.97 : 1.0,
            duration: Duration(milliseconds: _pressed ? 100 : 350),
            curve: _pressed ? Curves.easeOutCubic : Curves.easeOutBack,
            child: ClipRRect(
              borderRadius: borderRadius,
              child: Material(
                color: widget.selected == true
                    ? theme.colorScheme.secondaryContainer
                    : widget.tileColor ?? theme.colorScheme.surfaceContainer,
                child: InkWell(
                  onTap: widget.onTap,
                  onLongPress: widget.onLongPress,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Avoid ListTile ink assertions when an ancestor paints a
                      // colored DecoratedBox (e.g. modal sheets).
                      Material(
                        type: MaterialType.transparency,
                        child: ListTile(
                          leading: widget.icon,
                          title: newTitle,
                          trailing: widget.trailing,
                          subtitle: widget.subtitle,
                          contentPadding: effectiveContentPadding,
                          selected: widget.selected ?? false,
                          minVerticalPadding: effectiveMinVerticalPadding,
                        ),
                      ),
                      if (widget.below != null)
                        Padding(
                          padding: effectiveContentPadding,
                          child: widget.below!,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
