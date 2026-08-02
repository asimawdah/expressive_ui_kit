import 'package:flutter/material.dart';

import '../internal/me_pressable.dart';
import '../theme/me_shapes.dart';

/// Visual variants for [MEButton], matching the M3 Expressive color roles.
enum MEButtonVariant { elevated, filled, tonal, outlined, text }

/// The five Material 3 Expressive button sizes.
enum MEButtonSize { extraSmall, small, medium, large, extraLarge }

/// Resting shape family for [MEButton].
enum MEButtonShape { round, square }

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
/// scale and spring-driven round-to-square shape morphing on press.
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

    final (Color bg, Color fg, double elevation, BorderSide? side) =
        switch (variant) {
      MEButtonVariant.elevated => (
          colors.surfaceContainerLow,
          colors.primary,
          1.0,
          null
        ),
      MEButtonVariant.filled => (colors.primary, colors.onPrimary, 0.0, null),
      MEButtonVariant.tonal => (
          colors.secondaryContainer,
          colors.onSecondaryContainer,
          0.0,
          null
        ),
      MEButtonVariant.outlined => (
          Colors.transparent,
          colors.onSurfaceVariant,
          0.0,
          BorderSide(color: colors.outlineVariant)
        ),
      MEButtonVariant.text => (Colors.transparent, colors.primary, 0.0, null),
    };

    final effectiveBg = !enabled
        ? colors.onSurface.withValues(alpha: 0.12)
        : isSelected && variant != MEButtonVariant.filled
            ? colors.primary
            : bg;
    final effectiveFg = !enabled
        ? colors.onSurface.withValues(alpha: 0.38)
        : isSelected && variant != MEButtonVariant.filled
            ? colors.onPrimary
            : fg;

    final restingShape = shape == MEButtonShape.round
        ? const StadiumBorder()
        : RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(spec.squareRadius));
    final morphTarget = shape == MEButtonShape.round
        ? RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(spec.squareRadius))
        : const StadiumBorder();

    return MEPressable(
      onPressed: onPressed,
      onLongPress: onLongPress,
      enabled: enabled,
      shape: restingShape,
      pressedShape: morphTarget,
      selectedShape: selected == null ? null : morphTarget,
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
