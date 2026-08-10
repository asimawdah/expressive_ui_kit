import 'package:flutter/material.dart';

import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';

/// A Material 3 Expressive dialog.
///
/// Replaces [AlertDialog]. Uses the expressive extra-large container
/// shape. Show it with [showMEDialog] for the spring-scale entrance.
class MEDialog extends StatelessWidget {
  const MEDialog({
    super.key,
    this.icon,
    this.title,
    this.content,
    this.actions = const [],
  });

  final Widget? icon;
  final Widget? title;
  final Widget? content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      backgroundColor: colors.surfaceContainerHigh,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MECorners.extraLarge),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 280, maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: icon != null
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                IconTheme.merge(
                  data: IconThemeData(size: 28, color: colors.secondary),
                  child: icon!,
                ),
                const SizedBox(height: 16),
              ],
              if (title != null) ...[
                DefaultTextStyle.merge(
                  style: textTheme.headlineSmall!.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: icon != null ? TextAlign.center : TextAlign.start,
                  child: title!,
                ),
                const SizedBox(height: 16),
              ],
              if (content != null)
                DefaultTextStyle.merge(
                  style: textTheme.bodyMedium!
                      .copyWith(color: colors.onSurfaceVariant),
                  child: content!,
                ),
              if (actions.isNotEmpty) ...[
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 8,
                  children: actions,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows an [MEDialog] with the M3 Expressive spring-scale entrance
/// transition. Replaces [showDialog] for dialogs.
Future<T?> showMEDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  final motion = METheme.of(context).motion;
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withValues(alpha: 0.4),
    transitionDuration: motion.defaultSpatial.approximateDuration,
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final scale = CurvedAnimation(
        parent: animation,
        curve: motion.defaultSpatial.curve,
        reverseCurve: Curves.easeIn,
      );
      final fade = CurvedAnimation(
        parent: animation,
        curve: motion.defaultEffects.curve,
        reverseCurve: Curves.easeIn,
      );
      return FadeTransition(
        opacity: fade,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(scale),
          child: child,
        ),
      );
    },
  );
}
