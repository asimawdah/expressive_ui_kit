import 'package:flutter/material.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// A Material 3 Expressive badge.
///
/// Replaces [Badge]. Pops in with a bouncy spatial spring when it appears
/// or its count changes.
///
/// When [child] is null the badge renders standalone, for use in slots
/// that anchor it themselves (e.g. `MENavigationDestination.badge`).
class MEBadge extends StatefulWidget {
  const MEBadge({
    super.key,
    this.child,
    this.count,
    this.visible = true,
  });

  final Widget? child;

  /// Optional count. When null, renders a small dot badge.
  final int? count;
  final bool visible;

  @override
  State<MEBadge> createState() => _MEBadgeState();
}

class _MEBadgeState extends State<MEBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController.unbounded(
    vsync: this,
    value: widget.visible ? 1 : 0,
  );

  @override
  void didUpdateWidget(MEBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible != oldWidget.visible ||
        widget.count != oldWidget.count) {
      if (widget.visible && widget.count != oldWidget.count) {
        // Re-pop on count change.
        _anim.value = 0.6;
      }
      springTo(
        _anim,
        widget.visible ? 1 : 0,
        METheme.of(context).motion.fastSpatial,
      );
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDot = widget.count == null;

    final Widget bubble = AnimatedBuilder(
      animation: _anim,
      builder: (context, child) => Transform.scale(
        scale: _anim.value.clamp(0.0, 1.5),
        child: child,
      ),
      child: Container(
              constraints: BoxConstraints(
                minWidth: isDot ? 8 : 16,
                minHeight: isDot ? 8 : 16,
              ),
              padding: isDot
                  ? EdgeInsets.zero
                  : const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: scheme.error,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: isDot
                  ? null
                  : Text(
                      widget.count! > 999 ? '999+' : '${widget.count}',
                      style: TextStyle(
                        color: scheme.onError,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
            ),
    );

    // Standalone badge: render just the bubble.
    if (widget.child == null) return bubble;

    // Anchored badge: overlay the bubble on the child's top-right corner.
    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child!,
        Positioned(top: -4, right: -4, child: bubble),
      ],
    );
  }
}
