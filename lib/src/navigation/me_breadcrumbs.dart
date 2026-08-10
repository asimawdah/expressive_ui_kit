import 'package:flutter/material.dart';

import '../internal/me_pressable.dart';
import '../theme/me_shapes.dart';

/// A single crumb in an [MEBreadcrumbs] trail.
@immutable
class MEBreadcrumb {
  const MEBreadcrumb({required this.label, this.icon});

  final String label;
  final IconData? icon;
}

/// A Material 3 Expressive breadcrumb trail.
///
/// Each ancestor crumb is a pill-shaped pressable that morphs squarer on
/// press; the current (last) crumb is emphasized and inert. Long trails
/// scroll horizontally.
class MEBreadcrumbs extends StatelessWidget {
  const MEBreadcrumbs({
    super.key,
    required this.crumbs,
    this.onCrumbPressed,
    this.separator,
  });

  final List<MEBreadcrumb> crumbs;

  /// Called with the index of the tapped crumb (never the last one).
  final ValueChanged<int>? onCrumbPressed;

  /// Widget between crumbs. Defaults to a chevron.
  final Widget? separator;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final sep = separator ??
        Icon(
          Icons.chevron_right,
          size: 18,
          color: scheme.onSurfaceVariant,
        );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < crumbs.length; i++) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: sep,
              ),
            if (i < crumbs.length - 1)
              MEPressable(
                shape: MEShapeScheme.fromCorner(MECorners.full),
                pressedShape: MEShapeScheme.fromCorner(MECorners.small),
                onPressed:
                    onCrumbPressed == null ? null : () => onCrumbPressed!(i),
                overlayColor: scheme.primary.withValues(alpha: 0.08),
                semanticLabel: crumbs[i].label,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (crumbs[i].icon != null) ...[
                        Icon(
                          crumbs[i].icon,
                          size: 16,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        crumbs[i].label,
                        style: text.labelLarge!.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: ShapeDecoration(
                  color: scheme.secondaryContainer,
                  shape: const StadiumBorder(),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (crumbs[i].icon != null) ...[
                      Icon(
                        crumbs[i].icon,
                        size: 16,
                        color: scheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      crumbs[i].label,
                      style: text.labelLarge!.copyWith(
                        color: scheme.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
