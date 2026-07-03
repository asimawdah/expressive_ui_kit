import 'package:flutter/material.dart';

import '../theme/me_theme.dart';
import 'me_navigation_bar.dart';

/// A Material 3 Expressive navigation rail.
///
/// Replaces [NavigationRail]. Supports the M3E collapsed (icon-only) and
/// expanded (icon + label) modes with a spring-animated width transition,
/// merging the old rail and drawer into one component.
class MENavigationRail extends StatelessWidget {
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

  /// Whether the rail shows labels beside icons (expanded) or icon-only.
  final bool expanded;
  final Widget? leading;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final motion = METheme.of(context).motion;

    return AnimatedContainer(
      duration: motion.defaultSpatial.approximateDuration,
      curve: motion.defaultSpatial.curve,
      width: expanded ? 220 : 96,
      color: backgroundColor ?? colors.surface,
      child: Column(
        crossAxisAlignment:
            expanded ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          if (leading != null)
            Padding(padding: const EdgeInsets.all(16), child: leading!),
          const SizedBox(height: 8),
          for (var i = 0; i < destinations.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: _RailItem(
                destination: destinations[i],
                selected: i == selectedIndex,
                expanded: expanded,
                onTap: () => onDestinationSelected(i),
                colors: colors,
                textTheme: textTheme,
              ),
            ),
        ],
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.destination,
    required this.selected,
    required this.expanded,
    required this.onTap,
    required this.colors,
    required this.textTheme,
  });

  final MENavigationDestination destination;
  final bool selected;
  final bool expanded;
  final VoidCallback onTap;
  final ColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final iconColor =
        selected ? colors.onSecondaryContainer : colors.onSurfaceVariant;
    final icon = IconTheme.merge(
      data: IconThemeData(size: 24, color: iconColor),
      child: selected && destination.selectedIcon != null
          ? destination.selectedIcon!
          : destination.icon,
    );

    if (expanded) {
      return Material(
        color: selected ? colors.secondaryContainer : Colors.transparent,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                icon,
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    destination.label,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelLarge!.copyWith(
                      color: selected
                          ? colors.onSecondaryContainer
                          : colors.onSurfaceVariant,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Semantics(
      selected: selected,
      label: destination.label,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: selected ? colors.secondaryContainer : Colors.transparent,
            shape: const StadiumBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: SizedBox(
                width: 56,
                height: 32,
                child: Center(child: icon),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            destination.label,
            style: textTheme.labelMedium!.copyWith(
              color: selected ? colors.onSurface : colors.onSurfaceVariant,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
