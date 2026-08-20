import 'package:flutter/material.dart';

import '../internal/me_pressable.dart';
import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';

/// Tracks a multi-select session for [MESelection].
class MESelectionController extends ChangeNotifier {
  final Set<int> _selected = <int>{};

  bool get isSelectionMode => _selected.isNotEmpty;

  int get selectedCount => _selected.length;

  Set<int> get selected => Set<int>.unmodifiable(_selected);

  bool isSelected(int index) => _selected.contains(index);

  void select(int index) {
    if (_selected.add(index)) notifyListeners();
  }

  void deselect(int index) {
    if (_selected.remove(index)) notifyListeners();
  }

  void toggle(int index) {
    if (!_selected.remove(index)) _selected.add(index);
    notifyListeners();
  }

  void selectAll(int count) {
    _selected
      ..clear()
      ..addAll(List<int>.generate(count, (i) => i));
    notifyListeners();
  }

  void clear() {
    if (_selected.isEmpty) return;
    _selected.clear();
    notifyListeners();
  }
}

/// Multi-select host: optional [MESelectionAppBar] plus any list [body].
///
/// Selected rows pick up [selectedColor] automatically. Wrap with
/// [PopScope] so system back clears selection first.
class MESelection extends StatelessWidget {
  const MESelection({
    super.key,
    required this.controller,
    required this.itemCount,
    required this.body,
    this.appBar,
    this.selectedColor,
  });

  final MESelectionController controller;
  final int itemCount;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Color? selectedColor;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return MESelectionScope(
          controller: controller,
          selectedColor:
              selectedColor ?? Theme.of(context).colorScheme.secondaryContainer,
          child: Scaffold(
            appBar: appBar,
            body: body,
          ),
        );
      },
    );
  }
}

/// Inherited selection state consumed by [MESelectionLeading] and lists.
class MESelectionScope extends InheritedWidget {
  const MESelectionScope({
    super.key,
    required this.controller,
    required this.selectedColor,
    required super.child,
  });

  final MESelectionController controller;
  final Color selectedColor;

  static MESelectionScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MESelectionScope>();
  }

  @override
  bool updateShouldNotify(MESelectionScope oldWidget) =>
      controller != oldWidget.controller ||
      selectedColor != oldWidget.selectedColor;
}

/// Idle header that morphs into a contextual selection bar with select-all.
class MESelectionAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MESelectionAppBar({
    super.key,
    required this.idle,
    required this.controller,
    required this.itemCount,
    this.actions = const [],
    this.title,
  });

  /// Widget shown when nothing is selected (typically an [MEAppBar] or
  /// search bar). Used as a regular (non-sliver) header.
  final Widget idle;
  final MESelectionController controller;
  final int itemCount;
  final List<Widget> actions;
  final Widget? title;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (!controller.isSelectionMode) {
          return SizedBox(height: preferredSize.height, child: idle);
        }
        final scheme = Theme.of(context).colorScheme;
        return Material(
          color: scheme.secondaryContainer,
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 64,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: controller.clear,
                    tooltip: 'Clear selection',
                  ),
                  Expanded(
                    child: DefaultTextStyle.merge(
                      style: Theme.of(context).textTheme.titleLarge!,
                      child:
                          title ?? Text('${controller.selectedCount} selected'),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      controller.selectedCount == itemCount
                          ? Icons.deselect
                          : Icons.select_all,
                    ),
                    tooltip: controller.selectedCount == itemCount
                        ? 'Deselect all'
                        : 'Select all',
                    onPressed: () {
                      if (controller.selectedCount == itemCount) {
                        controller.clear();
                      } else {
                        controller.selectAll(itemCount);
                      }
                    },
                  ),
                  ...actions,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Leading slot that morphs between [child] and a selected check affordance.
class MESelectionLeading extends StatelessWidget {
  const MESelectionLeading({
    super.key,
    required this.selected,
    required this.child,
    this.selectedChild,
    this.onTap,
  });

  final bool selected;
  final Widget child;
  final Widget? selectedChild;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final check = selectedChild ??
        CircleAvatar(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          child: const Icon(Icons.check, size: 20),
        );

    return GestureDetector(
      onTap: onTap,
      child: AnimatedSwitcher(
        duration: METheme.of(context).motion.fastSpatial.approximateDuration,
        switchInCurve: METheme.of(context).motion.fastSpatial.curve,
        child: selected
            ? KeyedSubtree(key: const ValueKey('on'), child: check)
            : KeyedSubtree(key: const ValueKey('off'), child: child),
      ),
    );
  }
}

/// A pressable row that picks up [MESelectionScope.selectedColor] when
/// selected. Useful as a [MECardList] item.
class MESelectionTile extends StatelessWidget {
  const MESelectionTile({
    super.key,
    required this.index,
    required this.child,
    this.onTap,
    this.onLongPress,
  });

  final int index;
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final scope = MESelectionScope.maybeOf(context);
    final selected = scope?.controller.isSelected(index) ?? false;
    final scheme = Theme.of(context).colorScheme;

    return MEPressable(
      selected: selected,
      selectedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MECorners.extraLarge),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MECorners.large),
      ),
      color: selected
          ? (scope?.selectedColor ?? scheme.secondaryContainer)
          : scheme.surfaceContainerLow,
      onPressed: onTap ??
          () {
            if (scope == null) return;
            if (scope.controller.isSelectionMode) {
              scope.controller.toggle(index);
            }
          },
      onLongPress: onLongPress ?? () => scope?.controller.select(index),
      child: child,
    );
  }
}

/// Regular (non-sliver) idle header used as [MESelectionAppBar.idle].
class MESelectionIdleBar extends StatelessWidget {
  const MESelectionIdleBar({
    super.key,
    required this.title,
    this.leading,
    this.actions = const [],
  });

  final Widget title;
  final Widget? leading;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              if (leading != null) leading!,
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DefaultTextStyle.merge(
                    style: Theme.of(context).textTheme.titleLarge!,
                    child: title,
                  ),
                ),
              ),
              ...actions,
            ],
          ),
        ),
      ),
    );
  }
}
