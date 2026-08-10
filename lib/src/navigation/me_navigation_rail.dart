import 'package:flutter/material.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';
import 'me_navigation_bar.dart';

/// A Material 3 Expressive navigation rail.
///
/// Replaces [NavigationRail]. Supports collapsed (icon + label under) and
/// expanded (icon + label beside) modes with a spring-animated width and a
/// liquid pill indicator that travels between destinations — matching
/// [MENavigationBar] motion.
class MENavigationRail extends StatefulWidget {
  const MENavigationRail({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.expanded = false,
    this.leading,
    this.backgroundColor,
  });

  final List<MENavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  /// Whether the rail shows labels beside icons (expanded) or icon-only stack.
  final bool expanded;
  final Widget? leading;
  final Color? backgroundColor;

  @override
  State<MENavigationRail> createState() => _MENavigationRailState();
}

class _MENavigationRailState extends State<MENavigationRail>
    with TickerProviderStateMixin {
  late final AnimationController _indicator = AnimationController.unbounded(
    vsync: this,
    value: widget.selectedIndex.toDouble(),
  );

  late final AnimationController _iconBounce = AnimationController.unbounded(
    vsync: this,
    value: 1,
  );

  @override
  void didUpdateWidget(MENavigationRail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      final motion = METheme.of(context).motion;
      springTo(
        _indicator,
        widget.selectedIndex.toDouble(),
        motion.defaultSpatial,
      );
      _iconBounce.value = 0.82;
      springTo(_iconBounce, 1, motion.fastSpatial);
    }
  }

  @override
  void dispose() {
    _indicator.dispose();
    _iconBounce.dispose();
    super.dispose();
  }

  // Collapsed: icon slot at top (pad 12 + 32), label below — same as nav bar.
  static const double _collapsedItemHeight = 72;
  static const double _collapsedIconTop = 12;
  static const double _expandedItemHeight = 56;
  static const double _pillHeight = 32;
  static const double _pillWidth = 56;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final motion = METheme.of(context).motion;
    final count = widget.destinations.length;
    final itemHeight =
        widget.expanded ? _expandedItemHeight : _collapsedItemHeight;

    return AnimatedContainer(
      duration: motion.defaultSpatial.approximateDuration,
      curve: motion.defaultSpatial.curve,
      width: widget.expanded ? 220 : 96,
      color: widget.backgroundColor ?? colors.surface,
      child: SafeArea(
        right: false,
        left: false,
        bottom: false,
        child: Column(
          crossAxisAlignment: widget.expanded
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            if (widget.leading != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                child: widget.leading!,
              ),
            const SizedBox(height: 8),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return AnimatedBuilder(
                    animation: Listenable.merge([_indicator, _iconBounce]),
                    builder: (context, _) {
                      final pos = _indicator.value;
                      final remaining = (pos - widget.selectedIndex).abs();
                      final stretch = 1.0 + remaining.clamp(0.0, 1.0) * 0.45;
                      final squash = 1.0 - (stretch - 1.0) * 0.2;
                      final pillH = _pillHeight * squash * stretch;

                      // Collapsed: sit behind the icon slot.
                      // Expanded: sit vertically centered in the row.
                      final pillTop = widget.expanded
                          ? itemHeight * pos + (itemHeight - pillH) / 2
                          : itemHeight * pos +
                              _collapsedIconTop +
                              (_pillHeight - pillH) / 2;

                      final pillLeft = widget.expanded
                          ? 12.0
                          : (constraints.maxWidth - _pillWidth) / 2;
                      final pillW = widget.expanded
                          ? constraints.maxWidth - 24
                          : _pillWidth;

                      // Scroll when destinations exceed available height
                      // (e.g. landscape / split-screen). Pill stays in the
                      // same scrollable so it tracks the selected item.
                      return SingleChildScrollView(
                        child: SizedBox(
                          height: itemHeight * count,
                          width: constraints.maxWidth,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                top: pillTop,
                                left: pillLeft,
                                child: Container(
                                  width: pillW,
                                  height: pillH,
                                  decoration: BoxDecoration(
                                    color: colors.secondaryContainer,
                                    borderRadius:
                                        BorderRadius.circular(pillH / 2),
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  for (var i = 0; i < count; i++)
                                    SizedBox(
                                      height: itemHeight,
                                      width: double.infinity,
                                      child: _RailItem(
                                        destination: widget.destinations[i],
                                        selected: i == widget.selectedIndex,
                                        expanded: widget.expanded,
                                        bounceScale: i == widget.selectedIndex
                                            ? _iconBounce.value.clamp(0.7, 1.15)
                                            : 1,
                                        onTap: () =>
                                            widget.onDestinationSelected(i),
                                        colors: colors,
                                        textTheme: textTheme,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.destination,
    required this.selected,
    required this.expanded,
    required this.bounceScale,
    required this.onTap,
    required this.colors,
    required this.textTheme,
  });

  final MENavigationDestination destination;
  final bool selected;
  final bool expanded;
  final double bounceScale;
  final VoidCallback onTap;
  final ColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final iconColor =
        selected ? colors.onSecondaryContainer : colors.onSurfaceVariant;
    Widget icon = IconTheme.merge(
      data: IconThemeData(size: 24, color: iconColor),
      child: selected && destination.selectedIcon != null
          ? destination.selectedIcon!
          : destination.icon,
    );

    if (selected) {
      icon = Transform.scale(scale: bounceScale, child: icon);
    }

    if (expanded) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 56,
                  height: 32,
                  child: Center(child: icon),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 180),
                    style: textTheme.labelLarge!.copyWith(
                      color: selected
                          ? colors.onSecondaryContainer
                          : colors.onSurfaceVariant,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    child: Text(
                      destination.label,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Collapsed: fixed top padding so the icon aligns with the sliding pill.
    return Semantics(
      selected: selected,
      label: destination.label,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Column(
            children: [
              const SizedBox(height: 12),
              SizedBox(
                height: 32,
                width: 56,
                child: Center(child: icon),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: textTheme.labelMedium!.copyWith(
                  color: selected ? colors.onSurface : colors.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
                child: Text(destination.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
