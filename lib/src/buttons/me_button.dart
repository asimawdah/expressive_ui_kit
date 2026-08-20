import 'package:flutter/material.dart';

import '../internal/me_pressable.dart';
import '../theme/me_shapes.dart';

/// Visual variants for [MEButton], matching the M3 Expressive color roles.
enum MEButtonVariant { elevated, filled, tonal, outlined, text }

/// The five Material 3 Expressive button sizes.
enum MEButtonSize { extraSmall, small, medium, large, extraLarge }

/// Resting shape family for [MEButton].
enum MEButtonShape { round, square }

/// M3 Expressive size tokens shared by buttons, icon buttons, toggles,
/// split buttons and button groups.
extension MEButtonSizeTokens on MEButtonSize {
  /// Container height: 32 / 40 / 56 / 96 / 136.
  double get height => switch (this) {
        MEButtonSize.extraSmall => 32,
        MEButtonSize.small => 40,
        MEButtonSize.medium => 56,
        MEButtonSize.large => 96,
        MEButtonSize.extraLarge => 136,
      };

  /// Resting square-family corner radius.
  double get squareCornerRadius => switch (this) {
        MEButtonSize.extraSmall || MEButtonSize.small => MECorners.medium,
        MEButtonSize.medium => MECorners.large,
        MEButtonSize.large => MECorners.extraLarge,
        MEButtonSize.extraLarge => MECorners.extraLargeIncreased,
      };

  /// Pressed-container corner radius (8 / 8 / 12 / 16 / 16).
  double get pressedCornerRadius => switch (this) {
        MEButtonSize.extraSmall || MEButtonSize.small => MECorners.small,
        MEButtonSize.medium => MECorners.medium,
        MEButtonSize.large || MEButtonSize.extraLarge => MECorners.large,
      };

  /// Shape both round and square buttons morph toward while pressed.
  ShapeBorder get pressedContainerShape => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(pressedCornerRadius),
      );
}

class _MEButtonSizeSpec {
  const _MEButtonSizeSpec({
    required this.height,
    required this.horizontalPadding,
    required this.iconSize,
    required this.textStyle,
    required this.squareRadius,
    required this.gap,
  });

  final double height;
  final double horizontalPadding;
  final double iconSize;
  final TextStyle Function(TextTheme) textStyle;
  final double squareRadius;
  final double gap;
}

const Map<MEButtonSize, _MEButtonSizeSpec> _sizeSpecs = {
  MEButtonSize.extraSmall: _MEButtonSizeSpec(
    height: 32,
    horizontalPadding: 12,
    iconSize: 20,
    textStyle: _labelLarge,
    squareRadius: MECorners.medium,
    gap: 4,
  ),
  MEButtonSize.small: _MEButtonSizeSpec(
    height: 40,
    horizontalPadding: 16,
    iconSize: 20,
    textStyle: _labelLarge,
    squareRadius: MECorners.medium,
    gap: 8,
  ),
  MEButtonSize.medium: _MEButtonSizeSpec(
    height: 56,
    horizontalPadding: 24,
    iconSize: 24,
    textStyle: _titleMedium,
    squareRadius: MECorners.large,
    gap: 8,
  ),
  MEButtonSize.large: _MEButtonSizeSpec(
    height: 96,
    horizontalPadding: 48,
    iconSize: 32,
    textStyle: _headlineSmall,
    squareRadius: MECorners.extraLarge,
    gap: 12,
  ),
  MEButtonSize.extraLarge: _MEButtonSizeSpec(
    height: 136,
    horizontalPadding: 64,
    iconSize: 40,
    textStyle: _headlineLarge,
    squareRadius: MECorners.extraLargeIncreased,
    gap: 16,
  ),
};

TextStyle _labelLarge(TextTheme t) => t.labelLarge!;
TextStyle _titleMedium(TextTheme t) => t.titleMedium!;
TextStyle _headlineSmall(TextTheme t) => t.headlineSmall!;
TextStyle _headlineLarge(TextTheme t) => t.headlineLarge!;

/// A Material 3 Expressive button.
///
/// Replaces [ElevatedButton], [FilledButton], [FilledButton.tonal],
/// [OutlinedButton] and [TextButton]. Adds the M3 Expressive five-size
/// scale. Press morphs to the per-size pressed corner radius; a non-null
/// [selected] turns the button into a toggle (unselected round, selected
/// square).
///
/// ```dart
/// MEButton.filled(
///   size: MEButtonSize.medium,
///   onPressed: () {},
///   icon: const Icon(Icons.send),
///   child: const Text('Send'),
/// )
/// ```
class MEButton extends StatelessWidget {
  const MEButton({
    super.key,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.icon,
    this.variant = MEButtonVariant.filled,
    this.size = MEButtonSize.small,
    this.shape = MEButtonShape.round,
    this.selected,
  });

  const MEButton.elevated({
    super.key,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.icon,
    this.size = MEButtonSize.small,
    this.shape = MEButtonShape.round,
    this.selected,
  }) : variant = MEButtonVariant.elevated;

  const MEButton.filled({
    super.key,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.icon,
    this.size = MEButtonSize.small,
    this.shape = MEButtonShape.round,
    this.selected,
  }) : variant = MEButtonVariant.filled;

  const MEButton.tonal({
    super.key,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.icon,
    this.size = MEButtonSize.small,
    this.shape = MEButtonShape.round,
    this.selected,
  }) : variant = MEButtonVariant.tonal;

  const MEButton.outlined({
    super.key,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.icon,
    this.size = MEButtonSize.small,
    this.shape = MEButtonShape.round,
    this.selected,
  }) : variant = MEButtonVariant.outlined;

  const MEButton.text({
    super.key,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.icon,
    this.size = MEButtonSize.small,
    this.shape = MEButtonShape.round,
    this.selected,
  }) : variant = MEButtonVariant.text;

  final Widget child;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final Widget? icon;
  final MEButtonVariant variant;
  final MEButtonSize size;
  final MEButtonShape shape;

  /// When non-null the button acts as a toggle: selected toggle buttons
  /// morph to the square shape and use emphasized colors.
  final bool? selected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final spec = _sizeSpecs[size]!;
    final enabled = onPressed != null || onLongPress != null;
    final isSelected = selected ?? false;

    final isToggle = selected != null;
    final (Color bg, Color fg, double elevation, BorderSide? side) =
        switch (variant) {
      MEButtonVariant.elevated => (
          isToggle && isSelected ? colors.primary : colors.surfaceContainerLow,
          isToggle && isSelected ? colors.onPrimary : colors.primary,
          1.0,
          null
        ),
      MEButtonVariant.filled => (
          isToggle && !isSelected
              ? colors.surfaceContainerHighest
              : colors.primary,
          isToggle && !isSelected ? colors.onSurface : colors.onPrimary,
          0.0,
          null
        ),
      MEButtonVariant.tonal => (
          isToggle && isSelected ? colors.secondary : colors.secondaryContainer,
          isToggle && isSelected
              ? colors.onSecondary
              : colors.onSecondaryContainer,
          0.0,
          null
        ),
      MEButtonVariant.outlined => (
          isToggle && isSelected ? colors.inverseSurface : Colors.transparent,
          isToggle && isSelected
              ? colors.onInverseSurface
              : colors.onSurfaceVariant,
          0.0,
          BorderSide(color: colors.outlineVariant)
        ),
      MEButtonVariant.text => (
          Colors.transparent,
          isToggle && isSelected ? colors.primary : colors.primary,
          0.0,
          null
        ),
    };

    final effectiveBg = enabled ? bg : colors.onSurface.withValues(alpha: 0.12);
    final effectiveFg = enabled ? fg : colors.onSurface.withValues(alpha: 0.38);

    final restingShape = (isToggle ? !isSelected : shape == MEButtonShape.round)
        ? const StadiumBorder()
        : RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(spec.squareRadius));
    final selectedShape = RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(spec.squareRadius));

    return MEPressable(
      onPressed: onPressed,
      onLongPress: onLongPress,
      enabled: enabled,
      shape: restingShape,
      pressedShape: size.pressedContainerShape,
      selectedShape: isToggle ? selectedShape : null,
      selected: isSelected,
      color: effectiveBg,
      elevation: variant == MEButtonVariant.elevated ? elevation : 0,
      pressedElevation: variant == MEButtonVariant.elevated ? 2 : null,
      side: variant == MEButtonVariant.outlined ? side : null,
      overlayColor: effectiveFg.withValues(alpha: 0.1),
      haptics: true,
      child: Container(
        height: spec.height,
        padding: EdgeInsets.symmetric(horizontal: spec.horizontalPadding),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                IconTheme.merge(
                  data: IconThemeData(size: spec.iconSize, color: effectiveFg),
                  child: icon!,
                ),
                SizedBox(width: spec.gap),
              ],
              DefaultTextStyle.merge(
                style: spec.textStyle(textTheme).copyWith(color: effectiveFg),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
