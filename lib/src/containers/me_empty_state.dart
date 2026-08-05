import 'package:flutter/material.dart';

import 'me_morphing_shape.dart';

/// A Material 3 Expressive empty state.
///
/// Pairs an [MEMorphingShape] hero visual with a headline, supporting
/// text, and an optional action — the standard M3E pattern for empty
/// lists, zero-results searches, and onboarding moments.
class MEEmptyState extends StatelessWidget {
  const MEEmptyState({
    super.key,
    required this.title,
    this.icon,
    this.message,
    this.action,
    this.shapeSize = 140,
  });

  /// Headline widget, e.g. `Text('No messages yet')`.
  final Widget title;

  /// Icon shown inside the morphing shape.
  final IconData? icon;

  /// Supporting body text below the title.
  final Widget? message;

  /// Optional call-to-action (typically an `MEButton`).
  final Widget? action;

  /// Diameter of the morphing hero shape.
  final double shapeSize;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // FittedBox keeps intrinsic sizing (needed by SliverFillRemaining) while
    // scaling down when the remaining viewport is shorter than the content.
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MEMorphingShape(
                  size: shapeSize,
                  child: icon == null
                      ? null
                      : Icon(
                          icon,
                          size: shapeSize * 0.32,
                          color: colors.onPrimaryContainer,
                        ),
                ),
                const SizedBox(height: 20),
                DefaultTextStyle.merge(
                  style: textTheme.titleLarge,
                  textAlign: TextAlign.center,
                  child: title,
                ),
                if (message != null) ...[
                  const SizedBox(height: 8),
                  DefaultTextStyle.merge(
                    style: textTheme.bodyMedium!
                        .copyWith(color: colors.onSurfaceVariant),
                    textAlign: TextAlign.center,
                    child: message!,
                  ),
                ],
                if (action != null) ...[
                  const SizedBox(height: 24),
                  action!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
