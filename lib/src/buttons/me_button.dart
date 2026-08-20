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

  /// Leading/trailing padding: 12 / 16 / 24 / 48 / 64.
  double get horizontalPadding => switch (this) {
        MEButtonSize.extraSmall => 12,
        MEButtonSize.small => 16,
        MEButtonSize.medium => 24,
        MEButtonSize.large => 48,
        MEButtonSize.extraLarge => 64,
      };

  /// Icon size: 20 / 20 / 24 / 32 / 40.
  double get iconSize => switch (this) {
        MEButtonSize.extraSmall || MEButtonSize.small => 20,
        MEButtonSize.medium => 24,
        MEButtonSize.large => 32,
        MEButtonSize.extraLarge => 40,
      };

  /// Gap between icon and label: 4 / 8 / 8 / 12 / 16.
  double get iconGap => switch (this) {
        MEButtonSize.extraSmall => 4,
        MEButtonSize.small || MEButtonSize.medium => 8,
        MEButtonSize.large => 12,
        MEButtonSize.extraLarge => 16,
      };

  /// Label style for this size on [theme].
  TextStyle labelStyle(TextTheme theme) => switch (this) {
        MEButtonSize.extraSmall || MEButtonSize.small => theme.labelLarge!,
        MEButtonSize.medium => theme.titleMedium!,
        MEButtonSize.large => theme.headlineSmall!,
        MEButtonSize.extraLarge => theme.headlineLarge!,
      };
}

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
            borderRadius: BorderRadius.circular(size.squareCornerRadius));
    final selectedShape = RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(size.squareCornerRadius));

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
        height: size.height,
        padding: EdgeInsets.symmetric(horizontal: size.horizontalPadding),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                IconTheme.merge(
                  data: IconThemeData(size: size.iconSize, color: effectiveFg),
                  child: icon!,
                ),
                SizedBox(width: size.iconGap),
              ],
              DefaultTextStyle.merge(
                style: size.labelStyle(textTheme).copyWith(color: effectiveFg),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
