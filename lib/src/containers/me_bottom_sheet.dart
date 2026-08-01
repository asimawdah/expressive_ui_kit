import 'package:flutter/material.dart';

import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';

/// Shows a Material 3 Expressive modal bottom sheet.
///
/// Replaces [showModalBottomSheet]. The sheet slides up with a spatial
/// spring (subtle overshoot), uses the extra-large top corner radius and a
/// prominent drag handle per the expressive spec.
Future<T?> showMEBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
  bool enableDrag = true,
  bool showDragHandle = true,
  bool useRootNavigator = true,
}) {
  final motion = METheme.of(context).motion;
  final scheme = Theme.of(context).colorScheme;
  const radius = BorderRadius.vertical(
    top: Radius.circular(MECorners.extraLargeIncreased),
  );

  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    showDragHandle: false,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    sheetAnimationStyle: AnimationStyle(
      duration: motion.defaultSpatial.approximateDuration,
      curve: motion.defaultSpatial.curve,
      reverseDuration: const Duration(milliseconds: 200),
      reverseCurve: Curves.easeInCubic,
    ),
    // ClipRRect + rectangular Material avoids an intermediate DecoratedBox
    // between Material and ListTiles (which triggers ink-splash asserts).
    builder: (context) => ClipRRect(
      borderRadius: radius,
      child: Material(
        color: scheme.surfaceContainerLow,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showDragHandle)
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: Container(
                  width: 48,
                  height: 6,
                  decoration: BoxDecoration(
                    color: scheme.outlineVariant,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            Flexible(child: builder(context)),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    ),
  );
}
