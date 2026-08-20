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

/// Which corner the [MEFabMenu] trigger sits in.
enum MEFabMenuPosition { start, end }

/// A Material 3 Expressive FAB menu.
///
/// A FAB that expands into a vertical stack of labeled actions. When open
/// the trigger morphs from the medium 80dp FAB to the small 56dp size and
/// a rounder shape, matching the M3 Expressive FAB menu spec.
class MEFabMenu extends StatefulWidget {
  const MEFabMenu({
    super.key,
    required this.items,
    this.icon = const Icon(Icons.add),
    this.closeIcon = const Icon(Icons.close),
    this.position = MEFabMenuPosition.end,
    this.alignment,
  });

  final List<MEFabMenuItem> items;
  final Widget icon;
  final Widget closeIcon;

  /// Start = lower-leading, end = lower-trailing (the spec default).
  final MEFabMenuPosition position;

  /// Overrides [position] when set.
  final AlignmentDirectional? alignment;

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

  static const double _closedSize = 80;
  static const double _openSize = 56;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  AlignmentDirectional get _align =>
      widget.alignment ??
      (widget.position == MEFabMenuPosition.end
          ? AlignmentDirectional.bottomEnd
          : AlignmentDirectional.bottomStart);

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
    final end = _align == AlignmentDirectional.bottomEnd ||
        _align == AlignmentDirectional.topEnd ||
        _align == AlignmentDirectional.centerEnd;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              end ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < count; i++) ...[
              _buildItem(
                widget.items[i],
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
    final clamped = t.clamp(0.0, 1.0);
    final size = _closedSize + (_openSize - _closedSize) * clamped;
    final radius =
        MECorners.extraLarge + (size / 2 - MECorners.extraLarge) * clamped;
    return MEPressable(
      onPressed: _toggle,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      pressedShape: const StadiumBorder(),
      color: Color.lerp(colors.primaryContainer, colors.primary, clamped)!,
      elevation: 3,
      overlayColor: colors.onPrimary.withValues(alpha: 0.1),
      semanticLabel: _open ? 'Close menu' : 'Open menu',
      child: SizedBox(
        width: size,
        height: size,
        child: Center(
          child: IconTheme.merge(
            data: IconThemeData(
              size: 24 + 4 * (1 - clamped),
              color: Color.lerp(
                  colors.onPrimaryContainer, colors.onPrimary, clamped),
            ),
            child: clamped > 0.5 ? widget.closeIcon : widget.icon,
          ),
        ),
      ),
    );
  }
}
