import 'package:flutter/material.dart';

import '../internal/me_pressable.dart';
import '../theme/me_motion.dart';
import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';

/// An item in an [MEFabMenu].
class MEFabMenuItem {
  const MEFabMenuItem({
    required this.icon,
    required this.label,
    this.onPressed,
  });

  final Widget icon;
  final Widget label;
  final VoidCallback? onPressed;
}

/// A Material 3 Expressive FAB menu.
///
/// A new M3E component: a FAB that expands into a vertical stack of
/// labeled action buttons with a staggered spring entrance. Replaces
/// speed-dial patterns built on [FloatingActionButton].
class MEFabMenu extends StatefulWidget {
  const MEFabMenu({
    super.key,
    required this.items,
    this.icon = const Icon(Icons.add),
    this.closeIcon = const Icon(Icons.close),
    this.alignment = AlignmentDirectional.bottomEnd,
  });

  final List<MEFabMenuItem> items;
  final Widget icon;
  final Widget closeIcon;
  final AlignmentDirectional alignment;

  @override
  State<MEFabMenu> createState() => _MEFabMenuState();
}

class _MEFabMenuState extends State<MEFabMenu>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController.unbounded(
    vsync: this,
    value: 0,
  );
  bool _open = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _open = !_open);
    springTo(
      _controller,
      _open ? 1 : 0,
      METheme.of(context).motion.defaultSpatial,
    );
  }

  void _select(MEFabMenuItem item) {
    _toggle();
    item.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final count = widget.items.length;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < count; i++) ...[
              _buildItem(
                widget.items[i],
                // Stagger: later items (closer to the FAB) appear first.
                _staggered(t, count - 1 - i, count),
                colors,
                textTheme,
              ),
              const SizedBox(height: 8),
            ],
            _buildToggle(colors, t),
          ],
        );
      },
    );
  }

  double _staggered(double t, int index, int count) {
    final start = index / (count * 2);
    final v = ((t - start) / (1 - start)).clamp(0.0, 1.5);
    return v;
  }

  Widget _buildItem(
    MEFabMenuItem item,
    double t,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
    if (t <= 0.001 && !_open) return const SizedBox.shrink();
    return Opacity(
      opacity: t.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(0, (1 - t) * 24),
        child: Transform.scale(
          scale: 0.6 + 0.4 * t,
          alignment: Alignment.bottomRight,
          child: MEPressable(
            onPressed: () => _select(item),
            shape: const StadiumBorder(),
            color: colors.primaryContainer,
            elevation: 2,
            overlayColor: colors.onPrimaryContainer.withValues(alpha: 0.1),
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconTheme.merge(
                    data: IconThemeData(
                      size: 24,
                      color: colors.onPrimaryContainer,
                    ),
                    child: item.icon,
                  ),
                  const SizedBox(width: 12),
                  DefaultTextStyle.merge(
                    style: textTheme.titleMedium!
                        .copyWith(color: colors.onPrimaryContainer),
                    child: item.label,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggle(ColorScheme colors, double t) {
    return MEPressable(
      onPressed: _toggle,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          MECorners.extraLarge + (28 - MECorners.extraLarge) * t.clamp(0, 1),
        ),
      ),
      color: Color.lerp(colors.primaryContainer, colors.primary,
          t.clamp(0.0, 1.0))!,
      elevation: 3,
      overlayColor: colors.onPrimary.withValues(alpha: 0.1),
      semanticLabel: _open ? 'Close menu' : 'Open menu',
      child: SizedBox(
        width: 80,
        height: 80,
        child: Center(
          child: Transform.rotate(
            // The open icon rotates 45deg as it cross-fades into the
            // close icon (which arrives already upright).
            angle: t.clamp(0.0, 1.0) * (t > 0.5 ? 0.0 : 0.785398),
            child: IconTheme.merge(
              data: IconThemeData(
                size: 28,
                color: Color.lerp(colors.onPrimaryContainer, colors.onPrimary,
                    t.clamp(0.0, 1.0)),
              ),
              child: t > 0.5 ? widget.closeIcon : widget.icon,
            ),
          ),
        ),
      ),
    );
  }
}
