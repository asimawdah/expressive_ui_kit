import 'package:flutter/material.dart';

import '../theme/me_shapes.dart';

/// A Material 3 Expressive navigation drawer.
///
/// Replaces [Drawer] / [NavigationDrawer]. Uses the extra-large trailing
/// corner radius and pill-shaped destination indicators that morph on
/// selection.
class MEDrawer extends StatelessWidget {
  const MEDrawer({
    super.key,
    this.header,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final Widget? header;
  final List<MEDrawerDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: scheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          right: Radius.circular(MECorners.extraLargeIncreased),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (header != null)
              Padding(padding: const EdgeInsets.all(24), child: header),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: destinations.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, i) {
                  final selected = i == selectedIndex;
                  final d = destinations[i];
                  final tile = Material(
                    color: selected
                        ? scheme.secondaryContainer
                        : Colors.transparent,
                    shape: const StadiumBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => onDestinationSelected(i),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              selected ? (d.selectedIcon ?? d.icon) : d.icon,
                              size: 24,
                              color: selected
                                  ? scheme.onSecondaryContainer
                                  : scheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                d.label,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge!
                                    .copyWith(
                                      color: selected
                                          ? scheme.onSecondaryContainer
                                          : scheme.onSurfaceVariant,
                                      fontWeight: selected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                              ),
                            ),
                            if (d.badge != null) d.badge!,
                          ],
                        ),
                      ),
                    ),
                  );
                  if (d.sectionLabel == null && !d.dividerBefore) return tile;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (d.dividerBefore)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Divider(
                            height: 1,
                            color: scheme.outlineVariant,
                          ),
                        ),
                      if (d.sectionLabel != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                          child: Text(
                            d.sectionLabel!,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(
                                  color: scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      tile,
                    ],
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

/// A destination in an [MEDrawer].
class MEDrawerDestination {
  const MEDrawerDestination({
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.badge,
    this.sectionLabel,
    this.dividerBefore = false,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final Widget? badge;

  /// Optional section caption drawn above this destination.
  final String? sectionLabel;

  /// Draws a divider above this destination.
  final bool dividerBefore;
}
