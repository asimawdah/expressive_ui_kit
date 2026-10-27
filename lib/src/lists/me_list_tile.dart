import 'package:flutter/material.dart';

import '../internal/me_pressable.dart';
import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';

/// A Material 3 Expressive list tile.
///
/// Replaces [ListTile]. In M3 Expressive, list items sit on rounded
/// "segmented" containers: the first item in a group gets a large top
/// radius, the last a large bottom radius, and middle items stay nearly
/// square — controlled by [position]. Tiles morph shape on press and
/// selection like every other expressive component.
enum MEListPosition { only, first, middle, last }

class MEListTile extends StatelessWidget {
  const MEListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onPressed,
    this.onLongPress,
    this.selected = false,
    this.enabled = true,
    this.position = MEListPosition.only,
  });

  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final bool selected;
  final bool enabled;

  /// Where this tile sits in its group; controls corner rounding.
  final MEListPosition position;

  BorderRadius _radiusFor(MEListPosition position) {
    const large = Radius.circular(MECorners.large);
    const small = Radius.circular(MECorners.extraSmall);
    switch (position) {
      case MEListPosition.only:
        return const BorderRadius.all(large);
      case MEListPosition.first:
        return const BorderRadius.vertical(top: large, bottom: small);
      case MEListPosition.middle:
        return const BorderRadius.all(small);
      case MEListPosition.last:
        return const BorderRadius.vertical(top: small, bottom: large);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final shapes = METheme.of(context).shapes;

    final shape = RoundedRectangleBorder(borderRadius: _radiusFor(position));

    return MEPressable(
      shape: shape,
      selectedShape: shapes.extraLarge,
      selected: selected,
      onPressed: enabled ? onPressed : null,
      onLongPress: enabled ? onLongPress : null,
      enabled: enabled,
      color: selected ? scheme.secondaryContainer : scheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            if (leading != null) ...[
              IconTheme(
                data: IconThemeData(
                  color: selected
                      ? scheme.onSecondaryContainer
                      : scheme.onSurfaceVariant,
                  size: 24,
                ),
                child: leading!,
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DefaultTextStyle(
                    style: textTheme.bodyLarge!.copyWith(
                      color: selected
                          ? scheme.onSecondaryContainer
                          : scheme.onSurface,
                    ),
                    child: title,
                  ),
                  if (subtitle != null)
                    DefaultTextStyle(
                      style: textTheme.bodyMedium!.copyWith(
                        color: selected
                            ? scheme.onSecondaryContainer
                            : scheme.onSurfaceVariant,
                      ),
                      child: subtitle!,
                    ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 16),
              IconTheme(
                data: IconThemeData(
                  color: scheme.onSurfaceVariant,
                  size: 24,
                ),
                child: trailing!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Lays out [MEListTile]s as an expressive segmented group with 2dp gaps,
/// automatically assigning [MEListPosition]s.
class MEListGroup extends StatelessWidget {
  const MEListGroup({super.key, required this.children, this.gap = 2});

  final List<MEListTile> children;
  final double gap;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(height: gap),
          MEListTile(
            key: children[i].key,
            leading: children[i].leading,
            title: children[i].title,
            subtitle: children[i].subtitle,
            trailing: children[i].trailing,
            onPressed: children[i].onPressed,
            onLongPress: children[i].onLongPress,
            selected: children[i].selected,
            enabled: children[i].enabled,
            position: children.length == 1
                ? MEListPosition.only
                : i == 0
                    ? MEListPosition.first
                    : i == children.length - 1
                        ? MEListPosition.last
                        : MEListPosition.middle,
          ),
        ],
      ],
    );
  }
}
