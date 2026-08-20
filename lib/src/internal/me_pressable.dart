import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'me_keyboard.dart';
import '../theme/me_motion.dart';
import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';

/// Internal: an interactive Material surface with M3 Expressive
/// spring-driven shape morphing.
///
/// The surface renders [shape] at rest and morphs toward [pressedShape]
/// while pressed (and toward [selectedShape] when [selected] is true),
/// driven by the theme's spatial spring so the morph bounces and is
/// interruptible.
class MEPressable extends StatefulWidget {
  const MEPressable({
    super.key,
    required this.child,
    required this.shape,
    this.pressedShape,
    this.selectedShape,
    this.selected = false,
    this.onPressed,
    this.onLongPress,
    this.color = Colors.transparent,
    this.overlayColor,
    this.shadowColor,
    this.elevation = 0,
    this.pressedElevation,
    this.side,
    this.enabled = true,
    this.semanticLabel,
    this.pressedScale = 0.97,
    this.haptics = false,
  });

  final Widget child;
  final ShapeBorder shape;

  /// Shape to morph toward while pressed. Defaults to a slightly squarer
  /// version of [shape].
  final ShapeBorder? pressedShape;

  /// Shape used while [selected] is true.
  final ShapeBorder? selectedShape;
  final bool selected;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final Color color;
  final Color? overlayColor;
  final Color? shadowColor;
  final double elevation;
  final double? pressedElevation;
  final BorderSide? side;
  final bool enabled;
  final String? semanticLabel;

  /// Scale while fully pressed. The release spring naturally overshoots
  /// past 1.0, giving the M3 Expressive squash-and-bounce feel. Set to
  /// 1.0 to disable the scale effect.
  final double pressedScale;

  /// Emit a light haptic tick on press-down.
  final bool haptics;

  @override
  State<MEPressable> createState() => _MEPressableState();
}

class _MEPressableState extends State<MEPressable>
    with TickerProviderStateMixin {
  late final AnimationController _press = AnimationController.unbounded(
    vsync: this,
    value: 0,
  );
  late final AnimationController _select = AnimationController.unbounded(
    vsync: this,
    value: widget.selected ? 1 : 0,
  );

  /// Laid-out child size. Shape morphs (stadium ↔ rounded rect) need the
  /// real box; parent constraints are often unbounded for wrap-content
  /// buttons and must not be substituted with a fake 100×40 fallback.
  Size _layoutSize = Size.zero;

  @override
  void didUpdateWidget(MEPressable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected) {
      springTo(
        _select,
        widget.selected ? 1 : 0,
        METheme.of(context).motion.defaultSpatial,
      );
    }
  }

  @override
  void dispose() {
    _press.dispose();
    _select.dispose();
    super.dispose();
  }

  void _setPressed(bool pressed) {
    if (pressed && widget.haptics) HapticFeedback.lightImpact();
    springTo(
      _press,
      pressed ? 1 : 0,
      pressed
          ? METheme.of(context).motion.fastSpatial
          : METheme.of(context).motion.defaultSpatial,
    );
  }

  void _handleChildSize(Size size) {
    if (!mounted) return;
    if ((size.width - _layoutSize.width).abs() < 0.5 &&
        (size.height - _layoutSize.height).abs() < 0.5) {
      return;
    }
    setState(() => _layoutSize = size);
  }

  ShapeBorder _resolveShape(Size size) {
    ShapeBorder base = widget.shape;
    if (widget.selectedShape != null) {
      final t = _select.value.clamp(0.0, 1.5);
      base = MEShapeMorph(from: widget.shape, to: widget.selectedShape!)
          .evaluate(t, size);
    }
    final pressedShape = widget.pressedShape ?? _defaultPressedShape(size);
    final t = _press.value.clamp(0.0, 1.5);
    var shape = MEShapeMorph(from: base, to: pressedShape).evaluate(t, size);
    if (widget.side != null && shape is RoundedRectangleBorder) {
      shape = shape.copyWith(side: widget.side);
    }
    return shape;
  }

  ShapeBorder _restingShape() {
    if (widget.selected && widget.selectedShape != null) {
      return widget.selectedShape!;
    }
    return widget.shape;
  }

  ShapeBorder _defaultPressedShape(Size size) {
    // Press morphs toward a squarer shape: ~35% of the resting roundness.
    final normalized = MEShapeMorph(
      from: widget.shape,
      to: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(size.shortestSide * 0.18),
      ),
    );
    return normalized.evaluate(1.0, size);
  }

  @override
  Widget build(BuildContext context) {
    final interactive = widget.enabled &&
        (widget.onPressed != null || widget.onLongPress != null);

    return Semantics(
      button: widget.onPressed != null,
      enabled: interactive,
      label: widget.semanticLabel,
      child: Focus(
        canRequestFocus: interactive,
        onKeyEvent: (node, event) => MEKeyboard.handleActivation(
          event: event,
          onActivate: interactive ? widget.onPressed : null,
        ),
        child: AnimatedBuilder(
          animation: Listenable.merge([_press, _select]),
          builder: (context, child) {
            final hasSize = _layoutSize.width > 0 && _layoutSize.height > 0;
            final shape =
                hasSize ? _resolveShape(_layoutSize) : _restingShape();
            final double elevation = widget.pressedElevation == null
                ? widget.elevation
                : (widget.elevation +
                        (widget.pressedElevation! - widget.elevation) *
                            _press.value.clamp(0.0, 1.0))
                    .clamp(0.0, 24.0)
                    .toDouble();
            // M3 Expressive squash: scale dips toward [pressedScale]
            // while pressed. Because the release spring is underdamped
            // the unclamped press value swings below 0, which pushes the
            // scale slightly past 1.0 for a natural overshoot bounce.
            final double scale = widget.pressedScale >= 1.0
                ? 1.0
                : (1.0 -
                        (1.0 - widget.pressedScale) *
                            _press.value.clamp(-0.35, 1.2))
                    .clamp(widget.pressedScale - 0.02, 1.03);
            return Transform.scale(
              scale: scale,
              child: Material(
                color: widget.color,
                shadowColor: widget.shadowColor ?? Colors.black,
                elevation: elevation,
                shape: shape,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  customBorder: shape,
                  overlayColor: widget.overlayColor == null
                      ? null
                      : WidgetStatePropertyAll(widget.overlayColor),
                  onTap: interactive ? widget.onPressed : null,
                  onLongPress: interactive ? widget.onLongPress : null,
                  onHighlightChanged: interactive ? _setPressed : null,
                  child: child,
                ),
              ),
            );
          },
          child: _SizeProbe(
            onSize: _handleChildSize,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Reports the child's laid-out size after the frame so [MEPressable]
/// can morph shapes against the real box, not parent max constraints.
class _SizeProbe extends SingleChildRenderObjectWidget {
  const _SizeProbe({required this.onSize, super.child});

  final ValueChanged<Size> onSize;

  @override
  RenderProxyBox createRenderObject(BuildContext context) {
    return _RenderSizeProbe(onSize);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderSizeProbe renderObject,
  ) {
    renderObject.onSize = onSize;
  }
}

class _RenderSizeProbe extends RenderProxyBox {
  _RenderSizeProbe(this.onSize);

  ValueChanged<Size> onSize;
  Size? _notified;

  @override
  void performLayout() {
    super.performLayout();
    if (size == _notified) return;
    _notified = size;
    final next = size;
    WidgetsBinding.instance.addPostFrameCallback((_) => onSize(next));
  }
}
