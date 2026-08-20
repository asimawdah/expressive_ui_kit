import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/me_motion.dart';
import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';

/// Where an [MEMenu] popup attaches to its anchor.
enum MEMenuAnchorPosition { bottomStart, bottomEnd, topStart, topEnd }

/// A node in an [MEMenu] content tree.
@immutable
sealed class MEMenuNode {
  const MEMenuNode();
}

/// Standard action row in an [MEMenu].
class MEMenuEntry extends MEMenuNode {
  const MEMenuEntry({
    required this.label,
    this.value,
    this.leading,
    this.trailing,
    this.trailingText,
    this.supportingText,
    this.onPressed,
    this.enabled = true,
    this.isDestructive = false,
    this.selected = false,
  });

  final String label;
  final Object? value;
  final Widget? leading;
  final Widget? trailing;
  final String? trailingText;
  final String? supportingText;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool isDestructive;
  final bool selected;
}

/// Horizontal rule between rows inside one elevated menu surface.
class MEMenuDivider extends MEMenuNode {
  const MEMenuDivider();
}

/// Elevated surface / subgroup of items with an optional section [label].
///
/// Each top-level [MEMenuGroup] becomes its own card; consecutive non-group
/// nodes share one implicit surface.
class MEMenuGroup extends MEMenuNode {
  const MEMenuGroup({required this.children, this.label});

  /// Alias that names the item list [entries].
  const MEMenuGroup.entries({required List<MEMenuNode> entries, this.label})
      : children = entries;

  final String? label;
  final List<MEMenuNode> children;
}

/// A single entry in an [MEMenuAnchor] or [MEDropdown].
class MEMenuItem<T> {
  const MEMenuItem({
    required this.value,
    required this.label,
    this.icon,
    this.leading,
    this.trailing,
    this.trailingText,
    this.supportingText,
    this.enabled = true,
    this.isDestructive = false,
  });

  final T value;
  final String label;
  final IconData? icon;
  final Widget? leading;
  final Widget? trailing;
  final String? trailingText;
  final String? supportingText;
  final bool enabled;
  final bool isDestructive;

  MEMenuEntry toEntry() {
    return MEMenuEntry(
      label: label,
      value: value,
      leading: leading ?? (icon == null ? null : Icon(icon, size: 24)),
      trailing: trailing,
      trailingText: trailingText,
      supportingText: supportingText,
      enabled: enabled,
      isDestructive: isDestructive,
    );
  }
}

/// Builds the anchor for an [MEMenu], given a callback to open it.
typedef MEMenuAnchorBuilder = Widget Function(
  BuildContext context,
  VoidCallback open,
);

/// A Material 3 Expressive menu, matching Compose `DropdownMenuPopup`.
///
/// Inserts into the [Overlay] and springs open on the Y axis from the
/// anchor — not a [PopupRoute], so there is no slow page-transition delay.
class MEMenu extends StatefulWidget {
  const MEMenu({
    super.key,
    required this.anchorBuilder,
    this.children,
    this.entries,
    this.position = MEMenuAnchorPosition.bottomStart,
    this.onSelected,
    this.selectedValue,
    this.closeOnSelect = true,
    this.preferredWidth,
    this.onOpenChanged,
  }) : assert(
          children != null || entries != null,
          'Provide children or entries.',
        );

  /// Convenience constructor for a flat list of [MEMenuEntry]s.
  factory MEMenu.entries({
    Key? key,
    required MEMenuAnchorBuilder anchorBuilder,
    required List<MEMenuEntry> entries,
    MEMenuAnchorPosition position = MEMenuAnchorPosition.bottomStart,
    ValueChanged<Object?>? onSelected,
    Object? selectedValue,
    bool closeOnSelect = true,
    double? preferredWidth,
    ValueChanged<bool>? onOpenChanged,
  }) {
    return MEMenu(
      key: key,
      anchorBuilder: anchorBuilder,
      children: entries,
      position: position,
      onSelected: onSelected,
      selectedValue: selectedValue,
      closeOnSelect: closeOnSelect,
      preferredWidth: preferredWidth,
      onOpenChanged: onOpenChanged,
    );
  }

  final MEMenuAnchorBuilder anchorBuilder;
  final List<MEMenuNode>? children;
  final List<MEMenuEntry>? entries;
  final MEMenuAnchorPosition position;
  final ValueChanged<Object?>? onSelected;
  final Object? selectedValue;
  final bool closeOnSelect;
  final double? preferredWidth;
  final ValueChanged<bool>? onOpenChanged;

  List<MEMenuNode> get _nodes => children ?? entries!;

  @override
  State<MEMenu> createState() => _MEMenuState();
}

class _MEMenuState extends State<MEMenu> {
  final GlobalKey _anchorKey = GlobalKey();
  bool _open = false;

  Future<void> _openMenu() async {
    if (_open) return;
    final anchorContext = _anchorKey.currentContext;
    if (anchorContext == null) return;
    final anchor = _overlayRectFor(anchorContext);
    if (anchor == null) return;

    setState(() => _open = true);
    widget.onOpenChanged?.call(true);
    final result = await showMEMenu<Object?>(
      context: context,
      anchor: anchor,
      children: widget._nodes,
      position: widget.position,
      selectedValue: widget.selectedValue,
      closeOnSelect: widget.closeOnSelect,
      preferredWidth: widget.preferredWidth,
    );
    if (mounted) {
      setState(() => _open = false);
      widget.onOpenChanged?.call(false);
    }
    if (result != null) widget.onSelected?.call(result);
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _anchorKey,
      child: widget.anchorBuilder(context, _openMenu),
    );
  }
}

/// A Material 3 Expressive menu anchored to its [child].
///
/// Replaces [PopupMenuButton] / [MenuAnchor]. Prefer [MEMenu] when the
/// trigger needs an explicit `open` callback (for example a button).
class MEMenuAnchor<T> extends StatelessWidget {
  const MEMenuAnchor({
    super.key,
    required this.items,
    required this.onSelected,
    required this.child,
    this.position = MEMenuAnchorPosition.bottomStart,
    this.selectedValue,
    this.preferredWidth,
  });

  final List<MEMenuItem<T>> items;
  final ValueChanged<T> onSelected;
  final Widget child;
  final MEMenuAnchorPosition position;
  final T? selectedValue;
  final double? preferredWidth;

  @override
  Widget build(BuildContext context) {
    return MEMenu(
      anchorBuilder: (context, open) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: open,
        child: child,
      ),
      children: [for (final item in items) item.toEntry()],
      position: position,
      selectedValue: selectedValue,
      preferredWidth: preferredWidth,
      onSelected: (value) {
        if (value is T) onSelected(value);
      },
    );
  }
}

/// Shows an expressive menu popup anchored to [anchor].
///
/// Returns the selected [MEMenuEntry.value], or `null` if dismissed.
Future<T?> showMEMenu<T>({
  required BuildContext context,
  required Rect anchor,
  required List<MEMenuNode> children,
  MEMenuAnchorPosition position = MEMenuAnchorPosition.bottomStart,
  T? selectedValue,
  bool closeOnSelect = true,
  double? preferredWidth,
}) {
  final completer = Completer<T?>();
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (overlayContext) {
      return _MEMenuPopup<T>(
        anchor: anchor,
        children: children,
        position: position,
        selectedValue: selectedValue,
        closeOnSelect: closeOnSelect,
        preferredWidth: preferredWidth,
        onSelected: (value) => _completeOnce(completer, value),
        onDismiss: () => _completeOnce(completer, null),
        onRemove: () => entry.remove(),
      );
    },
  );
  Overlay.of(context, rootOverlay: true).insert(entry);
  return completer.future;
}

void _completeOnce<T>(Completer<T?> completer, T? value) {
  if (!completer.isCompleted) completer.complete(value);
}

Rect? _overlayRectFor(BuildContext context) {
  final object = context.findRenderObject();
  if (object is! RenderBox || !object.hasSize || !object.attached) {
    return null;
  }
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  final ancestor = overlay?.context.findRenderObject();
  return MatrixUtils.transformRect(
    object.getTransformTo(ancestor),
    Offset.zero & object.size,
  );
}

List<MEMenuGroup> _partitionSurfaces(List<MEMenuNode> nodes) {
  if (nodes.isEmpty) return const [];
  final surfaces = <MEMenuGroup>[];
  var flatRun = <MEMenuNode>[];

  void flushFlat() {
    if (flatRun.isEmpty) return;
    surfaces.add(MEMenuGroup(children: List<MEMenuNode>.of(flatRun)));
    flatRun = [];
  }

  for (final node in nodes) {
    if (node is MEMenuGroup) {
      flushFlat();
      surfaces.add(node);
    } else {
      flatRun.add(node);
    }
  }
  flushFlat();
  return surfaces;
}

class _MEMenuPlacement {
  const _MEMenuPlacement({
    required this.left,
    required this.width,
    required this.maxHeight,
    required this.opensAbove,
    this.top,
    this.bottom,
  });

  final double left;
  final double width;
  final double maxHeight;
  final bool opensAbove;
  final double? top;
  final double? bottom;
}

class _MEMenuPopup<T> extends StatefulWidget {
  const _MEMenuPopup({
    required this.anchor,
    required this.children,
    required this.position,
    required this.onSelected,
    required this.onDismiss,
    required this.onRemove,
    this.selectedValue,
    this.closeOnSelect = true,
    this.preferredWidth,
  });

  final Rect anchor;
  final List<MEMenuNode> children;
  final MEMenuAnchorPosition position;
  final T? selectedValue;
  final bool closeOnSelect;
  final double? preferredWidth;
  final ValueChanged<T?> onSelected;
  final VoidCallback onDismiss;
  final VoidCallback onRemove;

  @override
  State<_MEMenuPopup<T>> createState() => _MEMenuPopupState<T>();
}

class _MEMenuPopupState<T> extends State<_MEMenuPopup<T>>
    with SingleTickerProviderStateMixin {
  static const double _minWidth = 112;
  static const double _maxWidth = 280;
  static const double _maxHeight = 320;
  static const double _edge = 12;
  static const double _anchorOffset = 4;
  static const double _containerRadius = MECorners.large;
  static const double _itemRadius = MECorners.medium;
  static const double _entryHeight = 48;
  static const double _sectionGap = 8;

  late final AnimationController _expand;
  bool _dismissing = false;
  bool _selected = false;
  bool _removed = false;
  final FocusScopeNode _focusScope = FocusScopeNode(debugLabel: 'MEMenu');

  @override
  void initState() {
    super.initState();
    _expand = AnimationController.unbounded(vsync: this, value: 0)
      ..addListener(_onTick);
    springTo(_expand, 1, MEMotionScheme.expressive.defaultSpatial);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusScope.requestFocus();
    });
  }

  @override
  void dispose() {
    _expand
      ..removeListener(_onTick)
      ..dispose();
    _focusScope.dispose();
    super.dispose();
  }

  void _onTick() {
    if (_dismissing && !_removed && _expand.value <= 0.01) {
      _removed = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onRemove();
      });
    }
  }

  void _dismiss() {
    if (_dismissing) return;
    if (!_selected) widget.onDismiss();
    _dismissing = true;
    springTo(_expand, 0, METheme.of(context).motion.fastSpatial);
  }

  void _handleSelect(Object? value, VoidCallback? onPressed) {
    onPressed?.call();
    if (!widget.closeOnSelect) return;
    _selected = true;
    widget.onSelected(value is T || value == null ? value as T? : null);
    _dismiss();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event.logicalKey != LogicalKeyboardKey.escape) {
      return KeyEventResult.ignored;
    }
    if (event is KeyDownEvent) _dismiss();
    return KeyEventResult.handled;
  }

  _MEMenuPlacement _place(Size screen, TextDirection direction) {
    final width = (widget.preferredWidth ??
            (widget.anchor.width + 176).clamp(_minWidth, _maxWidth))
        .clamp(_minWidth, _maxWidth);
    final count = _approximateCount(widget.children);
    final approxHeight =
        (count * _entryHeight).clamp(_entryHeight * 2, _maxHeight);
    final spaceBelow = screen.height - widget.anchor.bottom - _edge;
    final spaceAbove = widget.anchor.top - _edge;
    final preferAbove = widget.position == MEMenuAnchorPosition.topStart ||
        widget.position == MEMenuAnchorPosition.topEnd;
    final opensAbove = preferAbove
        ? spaceAbove >= approxHeight || spaceAbove > spaceBelow
        : spaceBelow < approxHeight && spaceAbove > spaceBelow;

    final isRtl = direction == TextDirection.rtl;
    final alignEnd = switch (widget.position) {
      MEMenuAnchorPosition.bottomEnd || MEMenuAnchorPosition.topEnd => !isRtl,
      MEMenuAnchorPosition.bottomStart ||
      MEMenuAnchorPosition.topStart =>
        isRtl,
    };
    var left = alignEnd ? widget.anchor.right - width : widget.anchor.left;
    left = left.clamp(_edge, screen.width - width - _edge);

    final maxHeight =
        (opensAbove ? spaceAbove : spaceBelow).clamp(0.0, _maxHeight);
    if (opensAbove) {
      return _MEMenuPlacement(
        left: left,
        width: width,
        maxHeight: maxHeight,
        opensAbove: true,
        bottom: screen.height - widget.anchor.top + _anchorOffset,
      );
    }
    return _MEMenuPlacement(
      left: left,
      width: width,
      maxHeight: maxHeight,
      opensAbove: false,
      top: widget.anchor.bottom + _anchorOffset,
    );
  }

  int _approximateCount(List<MEMenuNode> nodes) {
    var count = 0;
    for (final node in nodes) {
      switch (node) {
        case MEMenuGroup(:final children, :final label):
          if (label != null) count += 1;
          count += _approximateCount(children);
        case MEMenuDivider():
          count += 1;
        case MEMenuEntry():
          count += 1;
      }
    }
    return count == 0 ? 1 : count;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final size = MediaQuery.sizeOf(context);
    final placement = _place(size, Directionality.of(context));
    final scaleAlignment =
        placement.opensAbove ? Alignment.bottomCenter : Alignment.topCenter;

    return Positioned.fill(
      child: FocusScope(
        node: _focusScope,
        child: Focus(
          skipTraversal: true,
          onKeyEvent: _onKey,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _dismiss,
                ),
              ),
              Positioned(
                left: placement.left,
                width: placement.width,
                top: placement.top,
                bottom: placement.bottom,
                child: AnimatedBuilder(
                  animation: _expand,
                  builder: (context, child) {
                    final progress = _expand.value.clamp(0.0, 1.5);
                    final scale = progress.clamp(0.0, 1.2);
                    return IgnorePointer(
                      ignoring: progress < 0.02,
                      child: Opacity(
                        opacity: progress.clamp(0.0, 1.0),
                        child: Transform.scale(
                          alignment: scaleAlignment,
                          scaleY: scale,
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: _minWidth,
                      maxWidth: placement.width,
                      maxHeight: placement.maxHeight,
                    ),
                    child: _surfaces(scheme),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _surfaces(ColorScheme scheme) {
    final surfaces = _partitionSurfaces(widget.children);
    return ListView(
      padding: const EdgeInsets.all(6),
      shrinkWrap: true,
      children: [
        for (var i = 0; i < surfaces.length; i++) ...[
          if (i > 0) const SizedBox(height: _sectionGap),
          _surfaceCard(scheme, surfaces[i]),
        ],
      ],
    );
  }

  Widget _surfaceCard(ColorScheme scheme, MEMenuGroup group) {
    return Material(
      color: scheme.surfaceContainerLow,
      elevation: 3,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_containerRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (group.label != null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  group.label!,
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ),
            for (final node in group.children) _node(scheme, node),
          ],
        ),
      ),
    );
  }

  Widget _node(ColorScheme scheme, MEMenuNode node) {
    return switch (node) {
      MEMenuDivider() => Divider(
          height: 1,
          color: scheme.outlineVariant,
        ),
      MEMenuGroup(:final children, :final label) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (label != null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ),
            for (final child in children) _node(scheme, child),
          ],
        ),
      MEMenuEntry() => _item(scheme, node),
    };
  }

  Widget _item(ColorScheme scheme, MEMenuEntry entry) {
    final enabled = entry.enabled;
    final selected = entry.selected ||
        (widget.selectedValue != null && widget.selectedValue == entry.value);
    final foreground = !enabled
        ? scheme.onSurface.withValues(alpha: 0.38)
        : entry.isDestructive
            ? scheme.error
            : selected
                ? scheme.onTertiaryContainer
                : scheme.onSurface;
    final iconColor = !enabled
        ? scheme.onSurfaceVariant.withValues(alpha: 0.38)
        : entry.isDestructive
            ? scheme.error
            : selected
                ? scheme.onTertiaryContainer
                : scheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: selected ? scheme.tertiaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(_itemRadius),
        child: InkWell(
          onTap: enabled
              ? () => _handleSelect(entry.value, entry.onPressed)
              : null,
          borderRadius: BorderRadius.circular(_itemRadius),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: _entryHeight),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: entry.supportingText == null ? 0 : 8,
              ),
              child: Row(
                children: [
                  if (entry.leading != null) ...[
                    IconTheme.merge(
                      data: IconThemeData(color: iconColor, size: 24),
                      child: entry.leading!,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          entry.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge!
                              .copyWith(color: foreground),
                        ),
                        if (entry.supportingText != null)
                          Text(
                            entry.supportingText!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium!
                                .copyWith(
                                  color: enabled
                                      ? (selected
                                          ? scheme.onTertiaryContainer
                                          : scheme.onSurfaceVariant)
                                      : scheme.onSurface
                                          .withValues(alpha: 0.38),
                                ),
                          ),
                      ],
                    ),
                  ),
                  if (entry.trailingText != null) ...[
                    const SizedBox(width: 12),
                    Text(
                      entry.trailingText!,
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                            color: enabled
                                ? scheme.onSurfaceVariant
                                : scheme.onSurface.withValues(alpha: 0.38),
                          ),
                    ),
                  ],
                  if (entry.trailing != null) ...[
                    const SizedBox(width: 12),
                    IconTheme.merge(
                      data: IconThemeData(color: iconColor, size: 24),
                      child: entry.trailing!,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
