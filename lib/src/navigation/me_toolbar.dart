import 'package:flutter/material.dart';

/// Styles for [METoolbar].
enum METoolbarStyle {
  /// A floating pill that hovers above content, typically docked to the
  /// bottom of the screen with a margin.
  floating,

  /// A full-width bar docked flush to a screen edge.
  docked,
}

/// A Material 3 Expressive toolbar.
///
/// A new M3E component: a horizontal container of actions (typically
/// [MEIconButton]s and one primary [MEButton]) that floats above content.
/// Replaces [BottomAppBar] for contextual actions.
///
/// ```dart
/// METoolbar(
///   children: [
///     MEIconButton(icon: const Icon(Icons.format_bold), onPressed: () {}),
///     MEIconButton(icon: const Icon(Icons.format_italic), onPressed: () {}),
///     MEButton.filled(onPressed: () {}, child: const Text('Share')),
///   ],
/// )
/// ```
class METoolbar extends StatelessWidget {
  const METoolbar({
    super.key,
    required this.children,
    this.style = METoolbarStyle.floating,
    this.color,
    this.gap = 4,
  });

  final List<Widget> children;
  final METoolbarStyle style;
  final Color? color;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bg = color ?? colors.primaryContainer;

    final content = Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: style == METoolbarStyle.floating
            ? MainAxisSize.min
            : MainAxisSize.max,
        mainAxisAlignment: style == METoolbarStyle.floating
            ? MainAxisAlignment.center
            : MainAxisAlignment.spaceEvenly,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(width: gap),
            children[i],
          ],
        ],
      ),
    );

    if (style == METoolbarStyle.docked) {
      return Material(
        color: bg,
        child: SafeArea(top: false, child: content),
      );
    }

    return Material(
      color: bg,
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: content,
    );
  }
}
