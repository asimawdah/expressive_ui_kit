import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/me_motion.dart';
import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';

/// A press-and-hold confirmation button for destructive or irreversible
/// actions.
///
/// While held, an error-colored fill sweeps across the pill and the button
/// morphs squarer. Releasing early lets the fill spring back to zero;
/// holding to completion fires [onConfirmed] with a heavy haptic. An
/// alternative to [MESlideToConfirm] where vertical space is tight.
///
/// ```dart
/// MEHoldButton(
///   label: 'Hold to delete',
///   onConfirmed: deleteAccount,
/// )
/// ```
class MEHoldButton extends StatefulWidget {
  const MEHoldButton({
    super.key,
    required this.label,
    required this.onConfirmed,
    this.confirmedLabel,
    this.icon,
    this.holdDuration = const Duration(milliseconds: 1200),
    this.height = 56,
    this.enabled = true,
  });

  /// Label at rest and while holding.
  final String label;

  /// Label shown after confirmation. Defaults to [label].
  final String? confirmedLabel;

  /// Optional leading icon. Defaults to a delete-style warning icon slot
  /// being empty.
  final Widget? icon;

  /// How long the button must be held to confirm.
  final Duration holdDuration;

  final double height;
  final bool enabled;

  /// Called once when the hold completes.
  final VoidCallback onConfirmed;

  @override
  State<MEHoldButton> createState() => _MEHoldButtonState();
}

class _MEHoldButtonState extends State<MEHoldButton>
    with TickerProviderStateMixin {
  /// Linear fill progress 0..1 while holding.
  late final AnimationController _fill = AnimationController(
    vsync: this,
    duration: widget.holdDuration,
  );

  /// Unbounded spring controller for the release snap-back and the shape
  /// morph, so the abort feels physical rather than a linear reverse.
  late final AnimationController _shape = AnimationController.unbounded(
    vsync: this,
    value: 0,
  );

  bool _confirmed = false;
  int _lastTickDecile = -1;

  @override
  void initState() {
    super.initState();
    _fill.addStatusListener(_onFillStatus);
    _fill.addListener(_onFillTick);
    _shape.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _fill.dispose();
    _shape.dispose();
    super.dispose();
  }

  void _onFillTick() {
    // Escalating haptic ticks every 25% while holding.
    final decile = (_fill.value * 4).floor();
    if (decile != _lastTickDecile && _fill.isAnimating) {
      _lastTickDecile = decile;
      if (decile > 0) HapticFeedback.selectionClick();
    }
    setState(() {});
  }

  void _onFillStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_confirmed) {
      setState(() => _confirmed = true);
      HapticFeedback.heavyImpact();
      widget.onConfirmed();
      springTo(_shape, 0, METheme.of(context).motion.defaultSpatial);
    }
  }

  void _startHold() {
    if (!widget.enabled || _confirmed) return;
    HapticFeedback.lightImpact();
    _lastTickDecile = -1;
    _fill.forward(from: _fill.value);
    springTo(_shape, 1, METheme.of(context).motion.fastSpatial);
  }

  void _cancelHold() {
    if (_confirmed) return;
    // Abort: fill springs back to zero instead of linearly reversing.
    _fill.stop();
    final spring = METheme.of(context).motion.defaultSpatial;
    _fill.animateBack(
      0,
      duration: spring.approximateDuration,
      curve: spring.curve,
    );
    springTo(_shape, 0, spring);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final double shapeT = _shape.value.clamp(0.0, 1.2);
    final double radius = _confirmed
        ? MECorners.large
        : (widget.height / 2) + (MECorners.large - widget.height / 2) * shapeT;

    final Color surface =
        _confirmed ? scheme.errorContainer : scheme.surfaceContainerHigh;
    final Color fillColor = scheme.error;
    final double t = _fill.value;

    final String label =
        _confirmed ? (widget.confirmedLabel ?? widget.label) : widget.label;

    // Foreground switches to onError once the fill has swept past center.
    final Color fg = _confirmed
        ? scheme.onErrorContainer
        : (t > 0.5 ? scheme.onError : scheme.onSurface);

    return Semantics(
      button: true,
      enabled: widget.enabled && !_confirmed,
      label: label,
      hint: _confirmed ? null : 'Press and hold to confirm',
      child: GestureDetector(
        onTapDown: (_) => _startHold(),
        onTapUp: (_) => _cancelHold(),
        onTapCancel: _cancelHold,
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(radius),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Error fill sweeping left -> right while held.
              if (!_confirmed)
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: t.clamp(0.0, 1.0),
                  child: ColoredBox(color: fillColor),
                ),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      IconTheme.merge(
                        data: IconThemeData(size: 20, color: fg),
                        child:
                            _confirmed ? const Icon(Icons.check) : widget.icon!,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge!
                          .copyWith(color: fg),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
