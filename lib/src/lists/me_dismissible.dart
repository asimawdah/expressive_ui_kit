import 'package:flutter/material.dart';

import '../theme/me_shapes.dart';

/// A Material 3 Expressive swipe-to-dismiss wrapper.
///
/// Replaces [Dismissible]. Reveals a themed action background with an icon
/// that scales in as the drag passes the dismiss threshold, and rounds the
/// child's corners while it is being dragged (shape communicates state).
/// Snap-back uses the framework's physics so an aborted swipe springs home.
class MEDismissible extends StatefulWidget {
  const MEDismissible({
    super.key,
    required this.dismissKey,
    required this.child,
    this.onDismissed,
    this.confirmDismiss,
    this.direction = DismissDirection.endToStart,
    this.icon = Icons.delete_outline,
    this.backgroundColor,
    this.foregroundColor,
  });

  /// Key identifying the underlying [Dismissible].
  final Key dismissKey;
  final Widget child;
  final ValueChanged<DismissDirection>? onDismissed;
  final ConfirmDismissCallback? confirmDismiss;
  final DismissDirection direction;

  /// Icon shown in the revealed action background.
  final IconData icon;

  /// Background color of the revealed action. Defaults to error container.
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  State<MEDismissible> createState() => _MEDismissibleState();
}

class _MEDismissibleState extends State<MEDismissible> {
  bool _dragging = false;

  Widget _buildBackground(BuildContext context, AlignmentGeometry alignment) {
    final colors = Theme.of(context).colorScheme;
    final bg = widget.backgroundColor ?? colors.errorContainer;
    final fg = widget.foregroundColor ?? colors.onErrorContainer;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(MECorners.large),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Icon(widget.icon, color: fg),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: widget.dismissKey,
      direction: widget.direction,
      onDismissed: widget.onDismissed,
      confirmDismiss: widget.confirmDismiss,
      onUpdate: (details) {
        final dragging = details.progress > 0;
        if (dragging != _dragging) setState(() => _dragging = dragging);
      },
      background: _buildBackground(context, AlignmentDirectional.centerStart),
      secondaryBackground:
          _buildBackground(context, AlignmentDirectional.centerEnd),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          // While dragging, the row lifts and rounds its corners.
          borderRadius: BorderRadius.circular(
            _dragging ? MECorners.large : MECorners.none,
          ),
        ),
        child: widget.child,
      ),
    );
  }
}
