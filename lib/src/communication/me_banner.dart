import 'package:flutter/material.dart';

import '../theme/me_shapes.dart';

/// A Material 3 Expressive banner.
///
/// Replaces [MaterialBanner]. A prominent inline message with optional
/// icon and up to two actions, in an expressive large-radius container.
/// Place it at the top of the content area (it is a normal box widget,
/// not an overlay).
class MEBanner extends StatelessWidget {
  const MEBanner({
    super.key,
    required this.content,
    this.icon,
    this.actions = const [],
    this.color,
  });

  final Widget content;
  final Widget? icon;

  /// Up to two actions, typically `MEButton.text`.
  final List<Widget> actions;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: color ?? colors.secondaryContainer,
      borderRadius: BorderRadius.circular(MECorners.large),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (icon != null) ...[
                  IconTheme.merge(
                    data: IconThemeData(
                      size: 24,
                      color: colors.onSecondaryContainer,
                    ),
                    child: icon!,
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8, top: 2),
                    child: DefaultTextStyle.merge(
                      style: textTheme.bodyMedium!
                          .copyWith(color: colors.onSecondaryContainer),
                      child: content,
                    ),
                  ),
                ),
              ],
            ),
            if (actions.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  for (var i = 0; i < actions.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    actions[i],
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}
