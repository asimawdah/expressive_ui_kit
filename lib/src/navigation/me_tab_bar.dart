import 'package:flutter/material.dart';

import '../internal/me_keyboard.dart';
import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// A single tab for [METabBar].
class METab {
  const METab({required this.label, this.icon});

  final String label;
  final IconData? icon;
}

/// Layout of an [METabBar].
enum METabBarVariant {
  /// Filled pill container with a sliding selection indicator (primary).
  primary,

  /// Flat bar with a short underline under the selected tab (secondary).
  secondary,
}

/// A Material 3 Expressive tab bar.
///
/// Replaces [TabBar]. Primary tabs wrap the selection in a pill that slides
/// with a spatial spring. Secondary tabs use an underline indicator.
class METabBar extends StatefulWidget {
  const METabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onSelected,
    this.variant = METabBarVariant.primary,
    this.focusNode,
    this.autofocus = false,
  });

  final List<METab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final METabBarVariant variant;

  /// Optional focus node for keyboard navigation.
  final FocusNode? focusNode;

  /// Whether this bar should request focus when first built.
  final bool autofocus;

  @override
  State<METabBar> createState() => _METabBarState();
}

class _METabBarState extends State<METabBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController.unbounded(
    vsync: this,
    value: widget.selectedIndex.toDouble(),
  );

  @override
  void didUpdateWidget(METabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      springTo(
        _anim,
        widget.selectedIndex.toDouble(),
        METheme.of(context).motion.defaultSpatial,
      );
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final count = widget.tabs.length;

    return Focus(
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      onKeyEvent: (node, event) => MEKeyboard.handleHorizontalSelection(
        event: event,
        current: widget.selectedIndex,
        count: count,
        direction: Directionality.of(context),
        onSelected: widget.onSelected,
      ),
      child: Container(
        height: widget.variant == METabBarVariant.secondary ? 48 : 56,
        decoration: widget.variant == METabBarVariant.secondary
            ? null
            : BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(28),
              ),
        padding: EdgeInsets.all(
          widget.variant == METabBarVariant.secondary ? 0 : 4,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tabWidth = constraints.maxWidth / count;
            // Row mirrors children in RTL; PositionedDirectional.start keeps the
            // pill aligned with the same logical tab under either direction.
            return Stack(
              children: [
                AnimatedBuilder(
                  animation: _anim,
                  builder: (context, _) {
                    final x = _anim.value.clamp(-0.25, count - 0.75);
                    return PositionedDirectional(
                      start: x * tabWidth,
                      top: widget.variant == METabBarVariant.secondary
                          ? null
                          : 0,
                      bottom: 0,
                      width: tabWidth,
                      child: widget.variant == METabBarVariant.secondary
                          ? Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                height: 3,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: scheme.primary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: scheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                    );
                  },
                ),
                Row(
                  children: [
                    for (var i = 0; i < count; i++)
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () => widget.onSelected(i),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.tabs[i].icon != null) ...[
                                  Icon(
                                    widget.tabs[i].icon,
                                    size: 20,
                                    color: i == widget.selectedIndex
                                        ? (widget.variant ==
                                                METabBarVariant.secondary
                                            ? scheme.primary
                                            : scheme.onSecondaryContainer)
                                        : scheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Text(
                                  widget.tabs[i].label,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(
                                        color: i == widget.selectedIndex
                                            ? (widget.variant ==
                                                    METabBarVariant.secondary
                                                ? scheme.primary
                                                : scheme.onSecondaryContainer)
                                            : scheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
