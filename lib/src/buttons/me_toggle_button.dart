import 'package:flutter/material.dart';

import '../internal/me_pressable.dart';
import '../theme/me_shapes.dart';
import 'me_button.dart';

/// A Material 3 Expressive toggle button.
///
/// Round-to-square shape morphing when checked. Use [METoggleButton.filled],
/// [METoggleButton.tonal], [METoggleButton.outlined] or [METoggleButton.text]
/// for color variants. Distinct from [MEIconButton] (icon-only) and
/// [MESegmentedButton] (grouped exclusive/multi select).
class METoggleButton extends StatelessWidget {
  const METoggleButton({
    super.key,
    required this.checked,
    required this.onCheckedChange,
    this.icon,
    this.checkedIcon,
    this.label,
    this.variant = MEButtonVariant.tonal,
    this.size = MEButtonSize.small,
    this.tooltip,
  }) : assert(icon != null || label != null);

  const METoggleButton.filled({
    super.key,
    required this.checked,
    required this.onCheckedChange,
    this.icon,
    this.checkedIcon,
    this.label,
    this.size = MEButtonSize.small,
    this.tooltip,
  })  : variant = MEButtonVariant.filled,
        assert(icon != null || label != null);

  const METoggleButton.tonal({
    super.key,
    required this.checked,
    required this.onCheckedChange,
    this.icon,
    this.checkedIcon,
    this.label,
    this.size = MEButtonSize.small,
    this.tooltip,
  })  : variant = MEButtonVariant.tonal,
        assert(icon != null || label != null);

  const METoggleButton.outlined({
    super.key,
    required this.checked,
    required this.onCheckedChange,
    this.icon,
    this.checkedIcon,
    this.label,
    this.size = MEButtonSize.small,
    this.tooltip,
  })  : variant = MEButtonVariant.outlined,
        assert(icon != null || label != null);

  const METoggleButton.text({
    super.key,
    required this.checked,
    required this.onCheckedChange,
    this.icon,
    this.checkedIcon,
    this.label,
    this.size = MEButtonSize.small,
    this.tooltip,
  })  : variant = MEButtonVariant.text,
        assert(icon != null || label != null);

  final bool checked;
  final ValueChanged<bool>? onCheckedChange;
  final Widget? icon;
  final Widget? checkedIcon;
  final Widget? label;
  final MEButtonVariant variant;
  final MEButtonSize size;
  final String? tooltip;

  static const Map<MEButtonSize, (double, double, double, double)> _dims = {
    // (height, icon, pad, squareRadius)
    MEButtonSize.extraSmall: (32, 18, 10, MECorners.medium),
    MEButtonSize.small: (40, 20, 12, MECorners.medium),
    MEButtonSize.medium: (56, 24, 16, MECorners.large),
    MEButtonSize.large: (72, 28, 20, MECorners.extraLarge),
    MEButtonSize.extraLarge: (96, 32, 24, MECorners.extraLargeIncreased),
  };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final (height, iconSize, pad, squareRadius) = _dims[size]!;
    final enabled = onCheckedChange != null;

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
        : checked
            ? colors.primary
            : bg;
    final effectiveFg = !enabled
        ? colors.onSurface.withValues(alpha: 0.38)
        : checked
            ? colors.onPrimary
            : fg;

    final Widget? shownIcon =
        checked && checkedIcon != null ? checkedIcon : icon;

    Widget result = MEPressable(
      onPressed: enabled ? () => onCheckedChange!(!checked) : null,
      enabled: enabled,
      selected: checked,
      shape: const StadiumBorder(),
      selectedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(squareRadius),
      ),
      pressedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(squareRadius),
      ),
      color: effectiveBg,
      side: variant == MEButtonVariant.outlined && enabled && !checked
          ? BorderSide(color: colors.outlineVariant)
          : null,
      overlayColor: effectiveFg.withValues(alpha: 0.1),
      semanticLabel: tooltip,
      haptics: true,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: height, minWidth: height),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: pad),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (shownIcon != null)
                IconTheme.merge(
                  data: IconThemeData(size: iconSize, color: effectiveFg),
                  child: shownIcon,
                ),
              if (shownIcon != null && label != null) const SizedBox(width: 8),
              if (label != null)
                DefaultTextStyle.merge(
                  style: textTheme.labelLarge!.copyWith(color: effectiveFg),
                  child: label!,
                ),
            ],
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
