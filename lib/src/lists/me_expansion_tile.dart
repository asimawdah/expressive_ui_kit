import 'package:flutter/material.dart';

import '../theme/me_motion.dart';
import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';

/// A Material 3 Expressive expansion tile.
///
/// Replaces [ExpansionTile]. The container morphs from a pill into a
/// large-radius rectangle as it expands, and the reveal is driven by a
/// spatial spring so it overshoots slightly — the signature expressive
/// container transform.
class MEExpansionTile extends StatefulWidget {
  const MEExpansionTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    required this.children,
    this.initiallyExpanded = false,
    this.onExpansionChanged,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final List<Widget> children;
  final bool initiallyExpanded;
  final ValueChanged<bool>? onExpansionChanged;

  @override
  State<MEExpansionTile> createState() => _MEExpansionTileState();
}

class _MEExpansionTileState extends State<MEExpansionTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController.unbounded(
    vsync: this,
    value: widget.initiallyExpanded ? 1 : 0,
  );
  late bool _expanded = widget.initiallyExpanded;

  void _toggle() {
    setState(() => _expanded = !_expanded);
    springTo(
      _anim,
      _expanded ? 1 : 0,
      METheme.of(context).motion.defaultSpatial,
    );
    widget.onExpansionChanged?.call(_expanded);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        final t = _anim.value;
        final clamped = t.clamp(0.0, 1.0);
        final radius = 28.0 + (MECorners.large - 28.0) * t;
        return Material(
          color: Color.lerp(
            scheme.surfaceContainerLow,
            scheme.surfaceContainerHigh,
            clamped,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: _toggle,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      if (widget.leading != null) ...[
                        widget.leading!,
                        const SizedBox(width: 16),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            DefaultTextStyle(
                              style: textTheme.titleMedium!,
                              child: widget.title,
                            ),
                            if (widget.subtitle != null)
                              DefaultTextStyle(
                                style: textTheme.bodyMedium!.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                                child: widget.subtitle!,
                              ),
                          ],
                        ),
                      ),
                      Transform.rotate(
                        angle: 3.14159 * _anim.value,
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: t < 0 ? 0 : t,
                  child: child,
                ),
              ),
            ],
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: widget.children,
        ),
      ),
    );
  }
}
