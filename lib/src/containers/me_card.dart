import 'package:flutter/material.dart';
import 'package:expressive_ui_kit/expressive_ui_kit.dart';

import '../internal/me_pressable.dart';

/// Visual variants for [MECard].
enum MECardVariant { elevated, filled, outlined }

/// A Material 3 Expressive card.
///
/// Replaces [Card]. Interactive cards (with [onPressed]) morph to a
/// squarer shape with a spring while pressed.
class MECard extends StatelessWidget {
  const MECard({
    super.key,
    required this.child,
    this.variant = MECardVariant.filled,
    this.onPressed,
    this.onLongPress,
    this.color,
    this.padding = const EdgeInsets.all(16),
    this.itemPosition,
  });

  const MECard.elevated({
    super.key,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.color,
    this.padding = const EdgeInsets.all(16),
    this.itemPosition,
  }) : variant = MECardVariant.elevated;

  const MECard.outlined({
    super.key,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.color,
    this.padding = const EdgeInsets.all(16),
    this.itemPosition,
  }) : variant = MECardVariant.outlined;

  final Widget child;
  final MECardVariant variant;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final Color? color;
  final EdgeInsetsGeometry padding;
  final ItemPosition? itemPosition;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final (Color bg, double elevation, BorderSide? side) = switch (variant) {
      MECardVariant.elevated => (colors.surfaceContainerLow, 1.0, null),
      MECardVariant.filled => (colors.surfaceContainerHighest, 0.0, null),
      MECardVariant.outlined => (
          colors.surface,
          0.0,
          BorderSide(color: colors.outlineVariant)
        ),
    };

    final baseShape = RoundedRectangleBorder(
      borderRadius: itemPosition?.borderRadius ?? BorderRadius.circular(24),
    );
    final resolvedShape = baseShape.copyWith(side: side);
    final pressedShape = baseShape.copyWith(side: BorderSide.none);

    return MEPressable(
      onPressed: onPressed,
      onLongPress: onLongPress,
      shape: resolvedShape,
      pressedShape: pressedShape,
      color: color ?? bg,
      elevation: elevation,
      pressedElevation: variant == MECardVariant.elevated ? 0 : null,
      overlayColor: colors.onSurface.withValues(alpha: 0.08),
      child: Padding(padding: padding, child: child),
    );
  }
}
