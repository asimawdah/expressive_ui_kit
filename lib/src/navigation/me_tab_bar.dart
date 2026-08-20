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

/// A Material 3 Expressive tab bar.
///
/// Replaces [TabBar]. Instead of an underline indicator, the selected tab
/// is wrapped in a pill container that slides between tabs with a spatial
/// spring, overshooting slightly — the expressive "selection follows
/// focus" pattern. Supports arrow-key navigation (including RTL).
class METabBar extends StatefulWidget {
  const METabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onSelected,
    this.focusNode,
    this.autofocus = false,
  });

  final List<METab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

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
        height: 56,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          // Fully rounded container (height 56 -> radius 28).
          borderRadius: BorderRadius.circular(28),
        ),
        padding: const EdgeInsets.all(4),
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
                      top: 0,
                      bottom: 0,
                      width: tabWidth,
                      child: Container(
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
                                        ? scheme.onSecondaryContainer
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
                                            ? scheme.onSecondaryContainer
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
