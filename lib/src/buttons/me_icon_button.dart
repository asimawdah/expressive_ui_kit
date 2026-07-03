import 'package:flutter/material.dart';

import '../internal/me_pressable.dart';
import '../theme/me_shapes.dart';
import 'me_button.dart';

/// Width variants for [MEIconButton] introduced by M3 Expressive.
enum MEIconButtonWidth { narrow, normal, wide }

/// A Material 3 Expressive icon button.
///
/// Replaces [IconButton]. Supports the five M3E sizes, three widths,
/// all color variants, and toggle behavior with round-to-square shape
/// morphing when selected.
class MEIconButton extends StatelessWidget {
  const MEIconButton({
    super.key,
    required this.icon,
    this.selectedIcon,
    this.onPressed,
    this.variant = MEButtonVariant.tonal,
    this.size = MEButtonSize.small,
    this.width = MEIconButtonWidth.normal,
    this.shape = MEButtonShape.round,
    this.selected,
    this.tooltip,
  });

  final Widget icon;
  final Widget? selectedIcon;
  final VoidCallback? onPressed;
  final MEButtonVariant variant;
  final MEButtonSize size;
  final MEIconButtonWidth width;
  final MEButtonShape shape;

  /// When non-null the button acts as a toggle.
  final bool? selected;
  final String? tooltip;

  static const Map<MEButtonSize, (double, double, double)> _dims = {
    // (container, icon, squareRadius)
    MEButtonSize.extraSmall: (32, 20, MECorners.medium),
    MEButtonSize.small: (40, 24, MECorners.medium),
    MEButtonSize.medium: (56, 24, MECorners.large),
    MEButtonSize.large: (96, 32, MECorners.extraLarge),
    MEButtonSize.extraLarge: (136, 40, MECorners.extraLargeIncreased),
  };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (container, iconSize, squareRadius) = _dims[size]!;
    final enabled = onPressed != null;
    final isSelected = selected ?? false;

    final double widthFactor = switch (width) {
      MEIconButtonWidth.narrow => 0.75,
      MEIconButtonWidth.normal => 1.0,
      MEIconButtonWidth.wide => 1.5,
    };

    final (Color bg, Color fg) = switch (variant) {
      MEButtonVariant.filled => (colors.primary, colors.onPrimary),
      MEButtonVariant.tonal => (
          colors.secondaryContainer,
          colors.onSecondaryContainer
        ),
      MEButtonVariant.outlined => (Colors.transparent, colors.onSurfaceVariant),
      MEButtonVariant.elevated => (colors.surfaceContainerLow, colors.primary),
      MEButtonVariant.text => (Colors.transparent, colors.onSurfaceVariant),
    };

    final effectiveBg = !enabled
        ? colors.onSurface.withValues(alpha: 0.12)
        : isSelected
            ? colors.primary
            : bg;
    final effectiveFg = !enabled
        ? colors.onSurface.withValues(alpha: 0.38)
        : isSelected
            ? colors.onPrimary
            : fg;

    final restingShape = shape == MEButtonShape.round
        ? const StadiumBorder()
        : RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(squareRadius));
    final morphTarget = shape == MEButtonShape.round
        ? RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(squareRadius))
        : const StadiumBorder();

    Widget result = MEPressable(
      onPressed: onPressed,
      enabled: enabled,
      shape: restingShape,
      pressedShape: morphTarget,
      selectedShape: selected == null ? null : morphTarget,
      selected: isSelected,
      color: effectiveBg,
      side: variant == MEButtonVariant.outlined && enabled
          ? BorderSide(color: colors.outlineVariant)
          : null,
      overlayColor: effectiveFg.withValues(alpha: 0.1),
      semanticLabel: tooltip,
      child: SizedBox(
        width: container * widthFactor,
        height: container,
        child: Center(
          child: IconTheme.merge(
            data: IconThemeData(size: iconSize, color: effectiveFg),
            child: isSelected && selectedIcon != null ? selectedIcon! : icon,
          ),
        ),
      ),
    );

    if (tooltip != null) {
      result = Tooltip(message: tooltip!, child: result);
    }
    return result;
  }
}
