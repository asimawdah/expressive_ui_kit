import 'package:flutter/material.dart';

import '../theme/me_shapes.dart';

/// Shows a Material 3 Expressive snackbar.
///
/// Replaces `ScaffoldMessenger.showSnackBar` with expressive styling:
/// a floating pill container with the large corner radius, inverse
/// surface colors and an optional action.
ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showMESnackBar(
  BuildContext context, {
  required String message,
  String? actionLabel,
  VoidCallback? onAction,
  Duration duration = const Duration(seconds: 4),
}) {
  final scheme = Theme.of(context).colorScheme;

  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: scheme.inverseSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MECorners.large),
      ),
      margin: const EdgeInsets.all(16),
      duration: duration,
      action: actionLabel == null
          ? null
          : SnackBarAction(
              label: actionLabel,
              textColor: scheme.inversePrimary,
              onPressed: onAction ?? () {},
            ),
    ),
  );
}
