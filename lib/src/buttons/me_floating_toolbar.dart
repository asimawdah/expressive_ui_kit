import 'package:flutter/material.dart';

import '../internal/me_pressable.dart';
import '../theme/me_motion.dart';
import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';

/// An action inside an [MEFloatingToolbar].
class METoolbarAction {
  const METoolbarAction({
    required this.icon,
    this.selectedIcon,
    this.tooltip,
    this.onPressed,
  });

  final Widget icon;

  /// Icon shown while this action is the toolbar's selected index.
  final Widget? selectedIcon;
  final String? tooltip;
  final VoidCallback? onPressed;
}

/// A Material 3 Expressive floating toolbar.
///
/// A new M3E component: a floating pill of actions that hovers above
/// content (typically docked to the bottom of the screen). The selected
/// action is highlighted by a liquid pill that springs between slots,
/// morphing squarer while in motion.
class MEFloatingToolbar extends StatefulWidget {
  const MEFloatingToolbar({
    super.key,
    required this.actions,
    this.selectedIndex,
    this.onSelected,
    this.vibrant = false,
  });

  final List<METoolbarAction> actions;

  /// The highlighted action, or null for a toolbar with no selection
  /// state (momentary actions only).
  final int? selectedIndex;
  final ValueChanged<int>? onSelected;

  /// Uses the vibrant (primary-container) color role instead of the
  /// standard surface role.
  final bool vibrant;

  @override
  State<MEFloatingToolbar> createState() => _MEFloatingToolbarState();
}

class _MEFloatingToolbarState extends State<MEFloatingToolbar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pos = AnimationController.unbounded(
    vsync: this,
    value: (widget.selectedIndex ?? 0).toDouble(),
  );

  static const double _slot = 56;
  static const double _gap = 4;

  @override
  void didUpdateWidget(MEFloatingToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex &&
        widget.selectedIndex != null) {
      springTo(
        _pos,
        widget.selectedIndex!.toDouble(),
        METheme.of(context).motion.defaultSpatial,
      );
    }
  }

  @override
  void dispose() {
    _pos.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (Color bg, Color fg, Color pill, Color onPill) = widget.vibrant
        ? (
            colors.primaryContainer,
            colors.onPrimaryContainer,
            colors.primary,
            colors.onPrimary,
          )
        : (
            colors.surfaceContainerHigh,
            colors.onSurfaceVariant,
            colors.secondaryContainer,
            colors.onSecondaryContainer,
          );

    return Material(
      color: bg,
      shape: const StadiumBorder(),
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: AnimatedBuilder(
          animation: _pos,
          builder: (context, _) {
            final t = _pos.value;
            return Stack(
              children: [
                // Liquid selection pill behind the icons.
                if (widget.selectedIndex != null)
                  Positioned(
                    left: t * (_slot + _gap),
                    top: 0,
                    child: _SelectionPill(
                      color: pill,
                      // Squash while traveling between slots.
                      velocity: _pos.velocity,
                    ),
                  ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < widget.actions.length; i++) ...[
                      if (i > 0) const SizedBox(width: _gap),
                      _buildAction(i, fg, onPill, t),
                    ],
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAction(int i, Color fg, Color onPill, double t) {
    final action = widget.actions[i];
    final selected = widget.selectedIndex == i;
    // Fade the foreground toward the on-pill color as the pill arrives.
    final proximity = (1 - (t - i).abs()).clamp(0.0, 1.0);
    final color = widget.selectedIndex == null
        ? fg
        : Color.lerp(fg, onPill, proximity)!;

    Widget result = MEPressable(
      onPressed: () {
        widget.onSelected?.call(i);
        action.onPressed?.call();
      },
      shape: const StadiumBorder(),
      pressedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MECorners.medium),
      ),
      overlayColor: color.withValues(alpha: 0.1),
      semanticLabel: action.tooltip,
      child: SizedBox(
        width: _slot,
        height: _slot,
        child: Center(
          child: IconTheme.merge(
            data: IconThemeData(size: 24, color: color),
            child: selected ? (action.selectedIcon ?? action.icon) : action.icon,
          ),
        ),
      ),
    );

    if (action.tooltip != null) {
      result = Tooltip(message: action.tooltip!, child: result);
    }
    return result;
  }
}

class _SelectionPill extends StatelessWidget {
  const _SelectionPill({required this.color, required this.velocity});

  final Color color;
  final double velocity;

  @override
  Widget build(BuildContext context) {
    // Stretch horizontally with travel speed, like the nav bar indicator.
    final stretch = (velocity.abs() / 40).clamp(0.0, 10.0);
    return Container(
      width: 56 + stretch,
      height: 56,
      decoration: ShapeDecoration(
        color: color,
        shape: const StadiumBorder(),
      ),
    );
  }
}
