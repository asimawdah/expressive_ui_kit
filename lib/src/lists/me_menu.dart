import 'package:flutter/material.dart';

import '../theme/me_motion.dart';
import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';

/// A single entry in an [MEMenuAnchor] or [MEDropdown].
class MEMenuItem<T> {
  const MEMenuItem({
    required this.value,
    required this.label,
    this.icon,
    this.enabled = true,
  });

  final T value;
  final String label;
  final IconData? icon;
  final bool enabled;
}

/// A Material 3 Expressive menu, anchored to its child.
///
/// Replaces [PopupMenuButton] / [MenuAnchor]. The menu container scales in
/// with a spatial spring (slight overshoot) from the anchor and uses the
/// extra-large expressive corner radius.
class MEMenuAnchor<T> extends StatefulWidget {
  const MEMenuAnchor({
    super.key,
    required this.items,
    required this.onSelected,
    required this.child,
  });

  final List<MEMenuItem<T>> items;
  final ValueChanged<T> onSelected;

  /// The anchor. Tapping it opens the menu.
  final Widget child;

  @override
  State<MEMenuAnchor<T>> createState() => _MEMenuAnchorState<T>();
}

class _MEMenuAnchorState<T> extends State<MEMenuAnchor<T>> {
  Future<void> _open() async {
    final box = context.findRenderObject()! as RenderBox;
    final overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        box.localToGlobal(Offset.zero, ancestor: overlay),
        box.localToGlobal(
          box.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    final motion = METheme.of(context).motion;
    final selected = await Navigator.of(context).push<T>(
      _MEMenuRoute<T>(
        position: position,
        items: widget.items,
        spring: motion.defaultSpatial,
        textDirection: Directionality.of(context),
      ),
    );
    if (selected != null) widget.onSelected(selected);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _open,
      child: widget.child,
    );
  }
}

class _MEMenuRoute<T> extends PopupRoute<T> {
  _MEMenuRoute({
    required this.position,
    required this.items,
    required this.spring,
    required this.textDirection,
  });

  final RelativeRect position;
  final List<MEMenuItem<T>> items;
  final MESpringSpec spring;
  final TextDirection textDirection;

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Dismiss menu';

  @override
  Duration get transitionDuration => spring.approximateDuration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final curved = CurvedAnimation(parent: animation, curve: spring.curve);
    final scaleAlignment = textDirection == TextDirection.rtl
        ? Alignment.topRight
        : Alignment.topLeft;

    return CustomSingleChildLayout(
      delegate: _MEMenuLayout(position, textDirection: textDirection),
      child: ScaleTransition(
        scale: curved,
        alignment: scaleAlignment,
        child: FadeTransition(
          opacity: animation,
          child: Material(
            color: scheme.surfaceContainer,
            elevation: 3,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(MECorners.extraLarge),
            ),
            clipBehavior: Clip.antiAlias,
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  for (final item in items)
                    InkWell(
                      onTap: item.enabled
                          ? () => Navigator.of(context).pop(item.value)
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (item.icon != null) ...[
                              Icon(
                                item.icon,
                                size: 20,
                                color: item.enabled
                                    ? scheme.onSurfaceVariant
                                    : scheme.onSurface.withValues(alpha: 0.38),
                              ),
                              const SizedBox(width: 12),
                            ],
                            Text(
                              item.label,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                    color: item.enabled
                                        ? scheme.onSurface
                                        : scheme.onSurface
                                            .withValues(alpha: 0.38),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MEMenuLayout extends SingleChildLayoutDelegate {
  _MEMenuLayout(this.position, {required this.textDirection});

  final RelativeRect position;
  final TextDirection textDirection;

  static const double _margin = 8;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.loose(constraints.biggest);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final anchorTop = position.top;
    final anchorBottom = size.height - position.bottom;
    final anchorLeft = position.left;
    final anchorRight = size.width - position.right;

    final maxY = (size.height - childSize.height - _margin)
        .clamp(_margin, double.infinity);
    final maxX = (size.width - childSize.width - _margin)
        .clamp(_margin, double.infinity);

    // Prefer below the anchor; fall back above when there isn't room.
    var y = anchorBottom;
    if (y + childSize.height > size.height - _margin) {
      y = anchorTop - childSize.height;
    }
    y = y.clamp(_margin, maxY);

    // Align to the anchor's start edge (RTL-aware), keep on-screen.
    final double x;
    if (textDirection == TextDirection.rtl) {
      x = (anchorRight - childSize.width).clamp(_margin, maxX);
    } else {
      x = anchorLeft.clamp(_margin, maxX);
    }

    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_MEMenuLayout oldDelegate) =>
      position != oldDelegate.position ||
      textDirection != oldDelegate.textDirection;
}
