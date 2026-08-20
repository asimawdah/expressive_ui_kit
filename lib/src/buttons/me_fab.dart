import 'package:flutter/material.dart';

import '../internal/me_pressable.dart';
import '../theme/me_shapes.dart';

/// The three M3 Expressive FAB sizes. Expressive removes the old
/// "large FAB + separate small FAB" split in favor of a unified scale.
enum MEFabSize { small, medium, large }

/// Color variants for [MEFab].
enum MEFabVariant { primary, secondary, tertiary, tonal }

/// A Material 3 Expressive floating action button.
///
/// Replaces [FloatingActionButton]. Uses the expressive rounded-square
/// resting shape and morphs rounder while pressed.
class MEFab extends StatelessWidget {
  const MEFab({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = MEFabSize.medium,
    this.variant = MEFabVariant.primary,
    this.tooltip,
  }) : label = null;

  /// An extended FAB with an icon and a text label.
  ///
  /// Defaults to [MEFabSize.small] (56dp), matching the M3 Expressive
  /// extended FAB spec.
  const MEFab.extended({
    super.key,
    required this.icon,
    required Widget this.label,
    this.onPressed,
    this.size = MEFabSize.small,
    this.variant = MEFabVariant.primary,
    this.tooltip,
  });

  final Widget icon;
  final Widget? label;
  final VoidCallback? onPressed;
  final MEFabSize size;
  final MEFabVariant variant;
  final String? tooltip;

  static const Map<MEFabSize, (double, double, double)> _dims = {
    // (container, icon, cornerRadius)
    MEFabSize.small: (56, 24, MECorners.large),
    MEFabSize.medium: (80, 28, MECorners.extraLarge),
    MEFabSize.large: (96, 36, MECorners.extraLargeIncreased),
  };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final (container, iconSize, radius) = _dims[size]!;

    final (Color bg, Color fg) = switch (variant) {
      MEFabVariant.primary => (
          colors.primaryContainer,
          colors.onPrimaryContainer
        ),
      MEFabVariant.secondary => (
          colors.secondaryContainer,
          colors.onSecondaryContainer
        ),
      MEFabVariant.tertiary => (
          colors.tertiaryContainer,
          colors.onTertiaryContainer
        ),
      MEFabVariant.tonal => (colors.surfaceContainerHigh, colors.primary),
    };

    final content = label == null
        ? SizedBox(
            width: container,
            height: container,
            child: Center(
              child: IconTheme.merge(
                data: IconThemeData(size: iconSize, color: fg),
                child: icon,
              ),
            ),
          )
        : Container(
            height: container,
            padding: EdgeInsets.symmetric(horizontal: container * 0.32),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconTheme.merge(
                  data: IconThemeData(size: iconSize, color: fg),
                  child: icon,
                ),
                SizedBox(width: iconSize * 0.4),
                DefaultTextStyle.merge(
                  style: (size == MEFabSize.small
                          ? textTheme.titleMedium
                          : size == MEFabSize.medium
                              ? textTheme.titleLarge
                              : textTheme.headlineSmall)!
                      .copyWith(color: fg),
                  child: label!,
                ),
              ],
            ),
          );

    Widget result = MEPressable(
      onPressed: onPressed,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      pressedShape: const StadiumBorder(),
      color: bg,
      elevation: 3,
      pressedElevation: 1,
      overlayColor: fg.withValues(alpha: 0.1),
      semanticLabel: tooltip,
      haptics: true,
      // FABs squash a touch deeper for a more playful feel.
      pressedScale: 0.94,
      child: content,
    );

    if (tooltip != null) {
      result = Tooltip(message: tooltip!, child: result);
    }
    return result;
  }
}
