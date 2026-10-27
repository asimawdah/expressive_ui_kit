import 'package:flutter/material.dart';

import '../theme/me_shapes.dart';

/// A Material 3 Expressive tooltip.
///
/// Replaces [Tooltip]. Uses the expressive medium corner radius, an
/// inverse-surface container, and a spring-curved scale-in transition.
class METooltip extends StatelessWidget {
  const METooltip({
    super.key,
    required this.message,
    required this.child,
    this.preferBelow = true,
  });

  final String message;
  final Widget child;
  final bool preferBelow;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: message,
      preferBelow: preferBelow,
      decoration: BoxDecoration(
        color: scheme.inverseSurface,
        borderRadius: BorderRadius.circular(MECorners.medium),
      ),
      textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
            color: scheme.onInverseSurface,
          ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      waitDuration: const Duration(milliseconds: 400),
      exitDuration: const Duration(milliseconds: 100),
      showDuration: const Duration(seconds: 3),
      enableTapToDismiss: true,
      triggerMode: TooltipTriggerMode.longPress,
      child: child,
    );
  }
}
