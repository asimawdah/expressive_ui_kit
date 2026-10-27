import 'package:flutter/material.dart';

import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';

/// Shows a Material 3 Expressive modal side sheet.
///
/// Implements the M3 "side sheet" pattern, which has no standard Flutter
/// widget. The sheet slides in from the trailing edge with a spring curve,
/// uses the expressive extra-large corner on its leading edge, and sits on
/// `surfaceContainerLow` with a scrim.
///
/// ```dart
/// showMESideSheet(
///   context: context,
///   title: const Text('Filters'),
///   builder: (context) => const FilterList(),
/// );
/// ```
Future<T?> showMESideSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Widget? title,
  double width = 320,
  bool showCloseButton = true,
}) {
  final motion = METheme.of(context).motion;

  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: motion.defaultSpatial.approximateDuration,
    pageBuilder: (context, animation, secondaryAnimation) {
      return AlignTransition(
        alignment: const AlwaysStoppedAnimation(AlignmentDirectional.centerEnd),
        child: _MESideSheet(
          title: title,
          width: width,
          showCloseButton: showCloseButton,
          child: builder(context),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: motion.defaultSpatial.curve,
        reverseCurve: Curves.easeIn,
      );
      final isRtl = Directionality.of(context) == TextDirection.rtl;
      return SlideTransition(
        position: Tween<Offset>(
          begin: Offset(isRtl ? -1 : 1, 0),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      );
    },
  );
}

class _MESideSheet extends StatelessWidget {
  const _MESideSheet({
    required this.child,
    required this.width,
    required this.showCloseButton,
    this.title,
  });

  final Widget child;
  final double width;
  final bool showCloseButton;
  final Widget? title;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Material(
        color: colors.surfaceContainerLow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadiusDirectional.horizontal(
            start: Radius.circular(MECorners.extraLarge),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: width,
          height: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (title != null || showCloseButton)
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: 24,
                    end: 12,
                    top: 12,
                    bottom: 4,
                  ),
                  child: Row(
                    children: [
                      if (title != null)
                        Expanded(
                          child: DefaultTextStyle.merge(
                            style: textTheme.titleLarge!
                                .copyWith(color: colors.onSurface),
                            child: title!,
                          ),
                        )
                      else
                        const Spacer(),
                      if (showCloseButton)
                        IconButton(
                          icon: const Icon(Icons.close),
                          color: colors.onSurfaceVariant,
                          onPressed: () => Navigator.of(context).pop(),
                          tooltip: MaterialLocalizations.of(context)
                              .closeButtonTooltip,
                        ),
                    ],
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
