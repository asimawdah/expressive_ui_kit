import 'package:flutter/material.dart';

import '../internal/me_pressable.dart';
import '../theme/me_shapes.dart';

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
  });

  const MECard.elevated({
    super.key,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.color,
    this.padding = const EdgeInsets.all(16),
  }) : variant = MECardVariant.elevated;

  const MECard.outlined({
    super.key,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.color,
    this.padding = const EdgeInsets.all(16),
  }) : variant = MECardVariant.outlined;

  final Widget child;
  final MECardVariant variant;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final Color? color;
  final EdgeInsetsGeometry padding;

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

    return MEPressable(
      onPressed: onPressed,
      onLongPress: onLongPress,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MECorners.largeIncreased),
        side: side ?? BorderSide.none,
      ),
      pressedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MECorners.extraLarge),
        side: side ?? BorderSide.none,
      ),
      color: color ?? bg,
      elevation: elevation,
      pressedElevation: variant == MECardVariant.elevated ? 0 : null,
      overlayColor: colors.onSurface.withValues(alpha: 0.08),
      child: Padding(padding: padding, child: child),
    );
  }
}
