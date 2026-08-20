import 'package:flutter/material.dart';

import '../internal/me_pressable.dart';
import '../theme/me_shapes.dart';
import 'me_menu.dart';

/// A Material 3 Expressive dropdown field.
///
/// Replaces [DropdownButton] / [DropdownMenu]. Renders as a pill-shaped
/// field that opens an expressive spring-animated menu.
///
/// Use [MEDropdown.future] when items are loaded asynchronously, and
/// [multiSelect] for a chip-style multi-value field.
class MEDropdown<T> extends StatefulWidget {
  const MEDropdown({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.label,
    this.hintText,
    this.leading,
    this.enabled = true,
    this.multiSelect = false,
    this.values,
    this.onChangedValues,
    this.searchEnabled = false,
  }) : itemsLoader = null;

  /// Loads [items] once when first built, then behaves like the default.
  const MEDropdown.future({
    super.key,
    required this.itemsLoader,
    required this.onChanged,
    this.value,
    this.label,
    this.hintText,
    this.leading,
    this.enabled = true,
    this.multiSelect = false,
    this.values,
    this.onChangedValues,
    this.searchEnabled = false,
  }) : items = const [];

  final List<MEMenuItem<T>> items;
  final Future<List<MEMenuItem<T>>> Function()? itemsLoader;
  final T? value;
  final ValueChanged<T> onChanged;
  final String? label;
  final String? hintText;
  final Widget? leading;
  final bool enabled;
  final bool multiSelect;
  final Set<T>? values;
  final ValueChanged<Set<T>>? onChangedValues;

  /// When true, the open menu shows a search field that filters items.
  final bool searchEnabled;

  @override
  State<MEDropdown<T>> createState() => _MEDropdownState<T>();
}

/// Catalog name matching Material's dropdown menu.
typedef MEDropdownMenu<T> = MEDropdown<T>;

class _MEDropdownState<T> extends State<MEDropdown<T>> {
  List<MEMenuItem<T>> _items = const [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _items = widget.items;
    _loadIfNeeded();
  }

  @override
  void didUpdateWidget(covariant MEDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.itemsLoader == null && widget.items != oldWidget.items) {
      _items = widget.items;
    }
  }

  Future<void> _loadIfNeeded() async {
    final loader = widget.itemsLoader;
    if (loader == null) return;
    setState(() => _loading = true);
    final next = await loader();
    if (!mounted) return;
    setState(() {
      _items = next;
      _loading = false;
    });
  }

  Set<T> get _selectedValues {
    if (widget.multiSelect) {
      return widget.values ??
          (widget.value == null ? <T>{} : {widget.value as T});
    }
    return widget.value == null ? <T>{} : {widget.value as T};
  }

  String _displayLabel(Set<T> selected) {
    if (selected.isEmpty) return widget.hintText ?? 'Select';
    final labels = [
      for (final item in _items)
        if (selected.contains(item.value)) item.label,
    ];
    return labels.isEmpty ? widget.hintText ?? 'Select' : labels.join(', ');
  }

  void _handleSelected(T value) {
    widget.onChanged(value);
    if (widget.multiSelect) {
      final next = Set<T>.of(_selectedValues);
      next.contains(value) ? next.remove(value) : next.add(value);
      widget.onChangedValues?.call(next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final selected = _selectedValues;
    final hasValue = selected.isNotEmpty;
    final menuItems = [
      for (final item in _items)
        MEMenuItem<T>(
          value: item.value,
          label: item.label,
          icon: item.icon,
          leading: item.leading,
          trailing: widget.multiSelect && selected.contains(item.value)
              ? const Icon(Icons.check, size: 20)
              : item.trailing,
          trailingText: item.trailingText,
          supportingText: item.supportingText,
          enabled: item.enabled,
          isDestructive: item.isDestructive,
        ),
    ];

    return MEMenu(
      position: MEMenuAnchorPosition.bottomStart,
      selectedValue: widget.multiSelect ? null : widget.value,
      closeOnSelect: !widget.multiSelect,
      searchHint: widget.searchEnabled ? (widget.hintText ?? 'Search') : null,
      onSelected: (value) {
        if (value is T) _handleSelected(value);
      },
      children: [for (final item in menuItems) item.toEntry()],
      anchorBuilder: (context, open) {
        return MEPressable(
          onPressed: widget.enabled && !_loading ? open : null,
          enabled: widget.enabled && !_loading,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MECorners.extraLarge),
          ),
          pressedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MECorners.large),
          ),
          color: scheme.surfaceContainerHigh,
          side: BorderSide(color: scheme.outlineVariant),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  if (widget.leading != null) ...[
                    IconTheme(
                      data: IconThemeData(
                        color: scheme.onSurfaceVariant,
                        size: 24,
                      ),
                      child: widget.leading!,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.label != null)
                          Text(
                            widget.label!,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(color: scheme.onSurfaceVariant),
                          ),
                        Text(
                          _loading ? 'Loading…' : _displayLabel(selected),
                          style:
                              Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    color: hasValue && !_loading
                                        ? scheme.onSurface
                                        : scheme.onSurfaceVariant,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_drop_down,
                    color: scheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
