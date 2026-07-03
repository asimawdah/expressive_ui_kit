import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// An action in an [MEOrbitMenu].
@immutable
class MEOrbitAction {
  const MEOrbitAction({
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
}

/// A radial menu: actions orbit out from a central toggle on spring arcs.
///
/// Opening flings each satellite outward along its own angle with a
/// stagger, so the ring blooms; closing pulls them back in. The central
/// button's icon cross-rotates, and its shape morphs round -> square
/// while open (the M3E selected-state signal). Satellites also scale and
/// fade with the same interruptible springs.
class MEOrbitMenu extends StatefulWidget {
  const MEOrbitMenu({
    super.key,
    required this.actions,
    this.radius = 96,
    this.startAngle = 180,
    this.sweepAngle = 90,
    this.icon = Icons.add,
    this.onOpenChanged,
  }) : assert(actions.length > 0);

  final List<MEOrbitAction> actions;

  /// Orbit distance from the center of the toggle.
  final double radius;

  /// Angle of the first satellite, in degrees. 0 points right, angles run
  /// counterclockwise (90 = up, 180 = left).
  final double startAngle;

  /// Arc that the satellites spread across, in degrees.
  final double sweepAngle;

  /// Icon of the central toggle; rotates 45 degrees when open (so
  /// [Icons.add] becomes a close cross).
  final IconData icon;

  final ValueChanged<bool>? onOpenChanged;

  @override
  State<MEOrbitMenu> createState() => _MEOrbitMenuState();
}

class _MEOrbitMenuState extends State<MEOrbitMenu>
    with TickerProviderStateMixin {
  late final List<AnimationController> _orbits = [
    for (int i = 0; i < widget.actions.length; i++)
      AnimationController.unbounded(vsync: this, value: 0),
  ];
  late final AnimationController _toggle = AnimationController.unbounded(
    vsync: this,
    value: 0,
  );
  bool _open = false;

  @override
  void dispose() {
    for (final c in _orbits) {
      c.dispose();
    }
    _toggle.dispose();
    super.dispose();
  }

  void _setOpen(bool open) {
    final motion = METheme.of(context).motion;
    setState(() => _open = open);
    HapticFeedback.lightImpact();
    springTo(_toggle, open ? 1 : 0, motion.defaultSpatial);
    for (int i = 0; i < _orbits.length; i++) {
      // Stagger: opening blooms outward in order, closing collapses in
      // reverse so the ring folds back neatly.
      final int order = open ? i : (_orbits.length - 1 - i);
      Future.delayed(Duration(milliseconds: 30 * order), () {
        if (mounted) {
          springTo(_orbits[i], open ? 1 : 0, motion.defaultSpatial);
        }
      });
    }
    widget.onOpenChanged?.call(open);
  }

  Offset _direction(int i) {
    final int count = widget.actions.length;
    final double step = count == 1 ? 0 : widget.sweepAngle / (count - 1);
    final double deg = widget.startAngle + step * i;
    final double rad = deg * math.pi / 180;
    // Screen y grows downward, so negate for counterclockwise angles.
    return Offset(math.cos(rad), -math.sin(rad));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // The stack is sized to contain the full orbit in every direction.
    final double extent = widget.radius * 2 + 56;

    return SizedBox(
      width: extent,
      height: extent,
      child: AnimatedBuilder(
        animation: Listenable.merge([..._orbits, _toggle]),
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Satellites.
              for (int i = 0; i < widget.actions.length; i++)
                _satellite(i, scheme),
              // Central toggle.
              _centralToggle(scheme),
            ],
          );
        },
      ),
    );
  }

  Widget _satellite(int i, ColorScheme scheme) {
    final action = widget.actions[i];
    final double t = _orbits[i].value;
    final Offset offset = _direction(i) * (widget.radius * t);
    final double scale = t.clamp(0.0, 1.15);
    final double opacity = t.clamp(0.0, 1.0);

    return Transform.translate(
      offset: offset,
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity,
          child: Material(
            color: scheme.secondaryContainer,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            elevation: 2 * opacity,
            child: InkWell(
              onTap: _open
                  ? () {
                      action.onPressed();
                      _setOpen(false);
                    }
                  : null,
              child: SizedBox(
                width: 48,
                height: 48,
                child: Icon(
                  action.icon,
                  size: 22,
                  color: scheme.onSecondaryContainer,
                  semanticLabel: action.tooltip,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _centralToggle(ColorScheme scheme) {
    final double t = _toggle.value.clamp(0.0, 1.0);
    // Shape morphs round -> rounded square while open.
    final double radius = 28 - 12 * t;
    return Material(
      color: Color.lerp(scheme.primary, scheme.tertiary, t * 0.35)!,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      child: InkWell(
        onTap: () => _setOpen(!_open),
        child: SizedBox(
          width: 56,
          height: 56,
          child: Transform.rotate(
            // Cross-rotates 45 degrees (plus spring overshoot).
            angle: _toggle.value * math.pi / 4,
            child: Icon(
              widget.icon,
              color: scheme.onPrimary,
              size: 26,
              semanticLabel: _open ? 'Close menu' : 'Open menu',
            ),
          ),
        ),
      ),
    );
  }
}
