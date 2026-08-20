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
    MEButtonSize.small: (40, 20, MECorners.medium),
    MEButtonSize.medium: (56, 24, MECorners.large),
    MEButtonSize.large: (96, 32, MECorners.extraLarge),
    MEButtonSize.extraLarge: (136, 40, MECorners.extraLargeIncreased),
  };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (container, iconSize, squareRadius) = _dims[size]!;
    final enabled = onPressed != null;
    final isToggle = selected != null;
    final isSelected = selected ?? false;

    final double widthFactor = switch (width) {
      MEIconButtonWidth.narrow => 0.75,
      MEIconButtonWidth.normal => 1.0,
      MEIconButtonWidth.wide => 1.5,
    };

    final (Color bg, Color fg) = switch (variant) {
      MEButtonVariant.filled => (
          isToggle && !isSelected
              ? colors.surfaceContainerHighest
              : colors.primary,
          isToggle && !isSelected ? colors.onSurface : colors.onPrimary
        ),
      MEButtonVariant.tonal => (
          isToggle && isSelected ? colors.secondary : colors.secondaryContainer,
          isToggle && isSelected
              ? colors.onSecondary
              : colors.onSecondaryContainer
        ),
      MEButtonVariant.outlined => (
          isToggle && isSelected ? colors.inverseSurface : Colors.transparent,
          isToggle && isSelected
              ? colors.onInverseSurface
              : colors.onSurfaceVariant
        ),
      MEButtonVariant.elevated => (
          isToggle && isSelected ? colors.primary : colors.surfaceContainerLow,
          isToggle && isSelected ? colors.onPrimary : colors.primary
        ),
      MEButtonVariant.text => (
          Colors.transparent,
          isToggle && isSelected ? colors.primary : colors.onSurfaceVariant
        ),
    };

    final effectiveBg = enabled ? bg : colors.onSurface.withValues(alpha: 0.12);
    final effectiveFg = enabled ? fg : colors.onSurface.withValues(alpha: 0.38);

    final restingShape = (isToggle ? !isSelected : shape == MEButtonShape.round)
        ? const StadiumBorder()
        : RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(squareRadius));
    final selectedShape = RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(squareRadius));

    Widget result = MEPressable(
      onPressed: onPressed,
      enabled: enabled,
      shape: restingShape,
      pressedShape: size.pressedContainerShape,
      selectedShape: selected == null ? null : selectedShape,
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
