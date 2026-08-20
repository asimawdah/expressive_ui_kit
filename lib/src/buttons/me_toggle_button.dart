import 'package:flutter/material.dart';

import '../internal/me_pressable.dart';
import 'me_button.dart';

/// A Material 3 Expressive toggle button.
///
/// Round when unchecked, square when checked, with the per-size pressed
/// corner radius while held. Distinct from [MEIconButton] (icon-only) and
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
    this.shape,
    this.selectedShape,
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
    this.shape,
    this.selectedShape,
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
    this.shape,
    this.selectedShape,
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
    this.shape,
    this.selectedShape,
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
    this.shape,
    this.selectedShape,
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

  /// Resting shape override, used by [METoggleButtonGroup] connected layout.
  final ShapeBorder? shape;

  /// Selected shape override, used by [METoggleButtonGroup] connected layout.
  final ShapeBorder? selectedShape;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final height = size.height;
    final iconSize = size.iconSize;
    final pad = size.horizontalPadding;
    final enabled = onCheckedChange != null;

    final (Color bg, Color fg) = switch (variant) {
      MEButtonVariant.filled => (
          checked ? colors.primary : colors.surfaceContainerHighest,
          checked ? colors.onPrimary : colors.onSurface
        ),
      MEButtonVariant.tonal => (
          checked ? colors.secondary : colors.secondaryContainer,
          checked ? colors.onSecondary : colors.onSecondaryContainer
        ),
      MEButtonVariant.outlined => (
          checked ? colors.inverseSurface : Colors.transparent,
          checked ? colors.onInverseSurface : colors.onSurfaceVariant
        ),
      MEButtonVariant.elevated => (
          checked ? colors.primary : colors.surfaceContainerLow,
          checked ? colors.onPrimary : colors.primary
        ),
      MEButtonVariant.text => (
          Colors.transparent,
          checked ? colors.primary : colors.onSurfaceVariant
        ),
    };

    final effectiveBg = enabled ? bg : colors.onSurface.withValues(alpha: 0.12);
    final effectiveFg = enabled ? fg : colors.onSurface.withValues(alpha: 0.38);

    final Widget? shownIcon =
        checked && checkedIcon != null ? checkedIcon : icon;

    Widget result = MEPressable(
      onPressed: enabled ? () => onCheckedChange!(!checked) : null,
      enabled: enabled,
      selected: checked,
      shape: shape ?? const StadiumBorder(),
      selectedShape: selectedShape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(size.squareCornerRadius),
          ),
      pressedShape: size.pressedContainerShape,
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
              if (shownIcon != null && label != null)
                SizedBox(width: size.iconGap),
              if (label != null)
                DefaultTextStyle.merge(
                  style:
                      size.labelStyle(textTheme).copyWith(color: effectiveFg),
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
