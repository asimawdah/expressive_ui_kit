import 'package:flutter/material.dart';

/// A Material 3 Expressive bottom app bar.
///
/// Replaces [BottomAppBar]. Holds up to four leading actions and an
/// optional trailing FAB slot. For contextual/floating action clusters
/// prefer `METoolbar`, which is the M3E-native pattern; this widget
/// covers the classic docked layout.
class MEBottomAppBar extends StatelessWidget {
  const MEBottomAppBar({
    super.key,
    required this.actions,
    this.fab,
    this.color,
    this.height = 72,
  });

  /// Leading action buttons (typically `MEIconButton`s).
  final List<Widget> actions;

  /// Optional trailing floating action button (typically a small `MEFab`).
  final Widget? fab;

  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: color ?? colors.surfaceContainer,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: 8, end: 16),
            child: Row(
              children: [
                for (final action in actions)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: action,
                  ),
                const Spacer(),
                if (fab != null) fab!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
