import 'package:flutter/material.dart';

import '../internal/me_pressable.dart';
import '../theme/me_motion.dart';
import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';

/// A node in an [METreeView].
class METreeNode {
  const METreeNode({
    required this.label,
    this.icon,
    this.children = const [],
    this.initiallyExpanded = false,
  });

  final Widget label;
  final IconData? icon;
  final List<METreeNode> children;
  final bool initiallyExpanded;

  bool get isLeaf => children.isEmpty;
}

/// A Material 3 Expressive tree view.
///
/// Hierarchical data with spring-animated expand/collapse: children
/// unfold with a spatial spring while the chevron rotates, and each row
/// is a pressable surface with the shared shape-morph press feedback.
class METreeView extends StatelessWidget {
  const METreeView({
    super.key,
    required this.nodes,
    this.onNodePressed,
    this.indent = 24,
  });

  final List<METreeNode> nodes;

  /// Called when a leaf node (or any node's row) is tapped.
  final ValueChanged<METreeNode>? onNodePressed;

  /// Horizontal indentation per depth level.
  final double indent;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final node in nodes)
          _METreeTile(
            node: node,
            depth: 0,
            indent: indent,
            onNodePressed: onNodePressed,
          ),
      ],
    );
  }
}

class _METreeTile extends StatefulWidget {
  const _METreeTile({
    required this.node,
    required this.depth,
    required this.indent,
    required this.onNodePressed,
  });

  final METreeNode node;
  final int depth;
  final double indent;
  final ValueChanged<METreeNode>? onNodePressed;

  @override
  State<_METreeTile> createState() => _METreeTileState();
}

class _METreeTileState extends State<_METreeTile>
    with SingleTickerProviderStateMixin {
  late bool _expanded;
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _expanded = widget.node.initiallyExpanded;
    _anim = AnimationController.unbounded(
      vsync: this,
      value: _expanded ? 1 : 0,
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    springTo(
      _anim,
      _expanded ? 1 : 0,
      METheme.of(context).motion.defaultSpatial,
    );
    widget.onNodePressed?.call(widget.node);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final node = widget.node;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              EdgeInsetsDirectional.only(start: widget.depth * widget.indent),
          child: MEPressable(
            onPressed: node.isLeaf
                ? (widget.onNodePressed == null
                    ? null
                    : () => widget.onNodePressed!(node))
                : _toggle,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(MECorners.medium),
            ),
            overlayColor: colors.onSurface.withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!node.isLeaf)
                    AnimatedBuilder(
                      animation: _anim,
                      builder: (context, child) => Transform.rotate(
                        // Quarter turn with spring overshoot.
                        angle: _anim.value.clamp(-0.2, 1.2) * 1.5708,
                        child: child,
                      ),
                      child: Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: colors.onSurfaceVariant,
                      ),
                    )
                  else
                    const SizedBox(width: 20),
                  const SizedBox(width: 8),
                  if (node.icon != null) ...[
                    Icon(
                      node.icon,
                      size: 20,
                      color: node.isLeaf
                          ? colors.onSurfaceVariant
                          : colors.primary,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: DefaultTextStyle.merge(
                      style: textTheme.bodyMedium,
                      child: node.label,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!node.isLeaf)
          // Spring-driven unfold: height and opacity follow the spring.
          AnimatedBuilder(
            animation: _anim,
            builder: (context, child) {
              final t = _anim.value.clamp(0.0, 1.0);
              if (t == 0) return const SizedBox.shrink();
              return ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: t,
                  child: Opacity(opacity: t, child: child),
                ),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final child in node.children)
                  _METreeTile(
                    node: child,
                    depth: widget.depth + 1,
                    indent: widget.indent,
                    onNodePressed: widget.onNodePressed,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
