import 'package:flutter/material.dart';

import '../internal/me_pressable.dart';
import '../theme/me_motion.dart';
import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';

/// Chip roles matching the M3 Expressive chip set.
enum MEChipType { assist, filter, input, suggestion }

/// A Material 3 Expressive chip.
///
/// Replaces [Chip], [FilterChip], [InputChip] and [ActionChip]. Filter
/// chips morph from rounded-square to fully-round when selected, with a
/// springy check-mark reveal.
class MEChip extends StatelessWidget {
  const MEChip({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.onDeleted,
    this.selected,
    this.height = 32,
    this.type,
  });

  final Widget label;
  final Widget? icon;
  final VoidCallback? onPressed;

  /// When set, shows a trailing remove affordance (input chip).
  final VoidCallback? onDeleted;

  /// When non-null the chip is a filter chip and toggles selection.
  final bool? selected;
  final double height;

  /// Explicit type. Inferred from [selected]/[onDeleted] when null.
  final MEChipType? type;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final motion = METheme.of(context).motion;
    final resolvedType = type ??
        (onDeleted != null
            ? MEChipType.input
            : selected != null
                ? MEChipType.filter
                : MEChipType.assist);
    final isFilter = resolvedType == MEChipType.filter || selected != null;
    final isSelected = selected ?? false;
    final enabled = onPressed != null;

    final bg = isSelected ? colors.secondaryContainer : Colors.transparent;
    final fg = !enabled
        ? colors.onSurface.withValues(alpha: 0.38)
        : isSelected
            ? colors.onSecondaryContainer
            : colors.onSurfaceVariant;

    final restShape = resolvedType == MEChipType.suggestion
        ? const StadiumBorder()
        : RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MECorners.small),
            side: isSelected
                ? BorderSide.none
                : BorderSide(color: colors.outlineVariant),
          );

    final showCheck = isFilter && isSelected;
    final showIcon = icon != null && !isSelected;
    final hasLeading = showCheck || showIcon;
    final hasTrailing = onDeleted != null;

    return MEPressable(
      onPressed: onPressed,
      enabled: enabled,
      shape: restShape,
      selectedShape: const StadiumBorder(),
      selected: isSelected,
      color: bg,
      overlayColor: fg.withValues(alpha: 0.1),
      child: Container(
        height: height,
        padding: EdgeInsetsDirectional.only(
          start: hasLeading ? 8 : 16,
          end: hasTrailing ? 8 : 16,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isFilter)
              MEMotionReveal(
                visible: showCheck,
                spec: motion.defaultSpatial,
                alignment: AlignmentDirectional.centerStart,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: Icon(Icons.check, size: 18, color: fg),
                ),
              ),
            if (showIcon) ...[
              IconTheme.merge(
                data: IconThemeData(size: 18, color: fg),
                child: icon!,
              ),
              const SizedBox(width: 8),
            ],
            DefaultTextStyle.merge(
              style: textTheme.labelLarge!.copyWith(color: fg),
              child: label,
            ),
            if (onDeleted != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onDeleted,
                child: Icon(Icons.close, size: 18, color: fg),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
