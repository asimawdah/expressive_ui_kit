import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// A virtual joystick with a spring-loaded thumb.
///
/// Drag the thumb anywhere within the base circle; release and it springs
/// back to center with the expressive underdamped bounce. Reports a
/// normalized [Offset] where each axis is in -1..1 (0,0 at center).
///
/// The thumb morphs squarer while grabbed and crossing the outer rim
/// ticks with a light haptic.
///
/// ```dart
/// MEJoystick(
///   onChanged: (v) => move(v.dx, v.dy),
/// )
/// ```
class MEJoystick extends StatefulWidget {
  const MEJoystick({
    super.key,
    required this.onChanged,
    this.size = 160,
    this.enabled = true,
  });

  /// Called continuously with the normalized thumb position, each axis in
  /// -1..1. Called with [Offset.zero] when released.
  final ValueChanged<Offset> onChanged;

  /// Diameter of the joystick base.
  final double size;

  final bool enabled;

  @override
  State<MEJoystick> createState() => _MEJoystickState();
}

class _MEJoystickState extends State<MEJoystick>
    with TickerProviderStateMixin {
  /// Current thumb offset in logical pixels from center.
  Offset _offset = Offset.zero;

  /// Springs the thumb back to center on release (0 -> 1 drives the
  /// interpolation from release position back to zero).
  late final AnimationController _return = AnimationController.unbounded(
    vsync: this,
    value: 1,
  );

  /// Grab morph for the thumb.
  late final AnimationController _grab = AnimationController.unbounded(
    vsync: this,
    value: 0,
  );

  Offset _releaseFrom = Offset.zero;
  bool _dragging = false;
  bool _atRim = false;

  double get _radius => widget.size / 2;
  double get _thumbRadius => widget.size * 0.19;
  double get _travel => _radius - _thumbRadius - 4;

  @override
  void initState() {
    super.initState();
    _return.addListener(_onReturnTick);
    _grab.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _return.dispose();
    _grab.dispose();
    super.dispose();
  }

  void _onReturnTick() {
    if (_dragging) return;
    // Interpolate from the release position back to center. The unclamped
    // spring value overshoots past 1, swinging the thumb slightly through
    // center for a physical wobble.
    final t = _return.value;
    setState(() {
      _offset = Offset.lerp(_releaseFrom, Offset.zero, t.clamp(0.0, 1.35))!;
    });
    widget.onChanged(_normalized);
  }

  Offset get _normalized => Offset(
        (_offset.dx / _travel).clamp(-1.0, 1.0),
        (_offset.dy / _travel).clamp(-1.0, 1.0),
      );

  void _start(DragStartDetails details) {
    if (!widget.enabled) return;
    _dragging = true;
    _return.stop();
    HapticFeedback.lightImpact();
    springTo(_grab, 1, METheme.of(context).motion.fastSpatial);
  }

  void _update(DragUpdateDetails details) {
    if (!_dragging) return;
    var next = _offset + details.delta;
    // Clamp to the travel circle.
    final distance = next.distance;
    final bool rim = distance >= _travel;
    if (rim) {
      next = next / distance * _travel;
    }
    if (rim != _atRim) {
      _atRim = rim;
      if (rim) HapticFeedback.selectionClick();
    }
    setState(() => _offset = next);
    widget.onChanged(_normalized);
  }

  void _end([DragEndDetails? details]) {
    if (!_dragging) return;
    _dragging = false;
    _atRim = false;
    _releaseFrom = _offset;
    _return.value = 0;
    springTo(_return, 1, METheme.of(context).motion.defaultSpatial);
    springTo(_grab, 0, METheme.of(context).motion.defaultSpatial);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final grabT = _grab.value.clamp(0.0, 1.2);

    // Thumb morphs from circle toward rounded square while grabbed.
    final thumbSize = _thumbRadius * 2;
    final thumbRadius =
        thumbSize / 2 - (thumbSize / 2 - thumbSize * 0.3) * grabT;

    final direction = _offset.distance < 4
        ? null
        : math.atan2(_offset.dy, _offset.dx);

    return Semantics(
      label: 'Joystick',
      slider: true,
      child: GestureDetector(
        onPanStart: _start,
        onPanUpdate: _update,
        onPanEnd: _end,
        onPanCancel: _end,
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Base.
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.surfaceContainerHigh,
                  border: Border.all(
                    color: _atRim ? scheme.primary : scheme.outlineVariant,
                    width: _atRim ? 2 : 1,
                  ),
                ),
              ),
              // Direction hint: a subtle tonal wedge toward the thumb.
              if (direction != null)
                Transform.rotate(
                  angle: direction,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: _radius * 0.55,
                      height: 3,
                      margin: EdgeInsets.only(right: _thumbRadius),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: scheme.primary.withValues(
                          alpha: 0.25 + 0.35 * _normalized.distance,
                        ),
                      ),
                    ),
                  ),
                ),
              // Thumb.
              Transform.translate(
                offset: _offset,
                child: Container(
                  width: thumbSize,
                  height: thumbSize,
                  decoration: BoxDecoration(
                    color: Color.lerp(
                      scheme.primary,
                      scheme.primaryContainer,
                      grabT * 0.4,
                    ),
                    borderRadius: BorderRadius.circular(thumbRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: 0.15 + 0.1 * grabT,
                        ),
                        blurRadius: 6 + 6 * grabT,
                        offset: Offset(0, 2 + 2 * grabT),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.drag_indicator,
                    size: thumbSize * 0.45,
                    color: Color.lerp(
                      scheme.onPrimary,
                      scheme.onPrimaryContainer,
                      grabT * 0.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
