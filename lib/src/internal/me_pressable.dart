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
/// Matches `m3e_core` buttons: press morphs **corner radius** with a snappy
/// effects spring; release uses the spatial spring so the shape can bounce.
/// The surface is not scaled unless [pressedScale] is below 1.0.
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
    this.pressedScale = 1.0,
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

  /// Scale while fully pressed. Defaults to 1.0 (shape morph only, like
  /// `m3e_core` buttons). Values below 1.0 enable squash; the release spring
  /// is left unclamped so it can overshoot past 1.0.
  final double pressedScale;

  /// Emit a light haptic tick on press-down.
  final bool haptics;

  @override
  State<MEPressable> createState() => _MEPressableState();
}

class _MEPressableState extends State<MEPressable> {
  bool _pressed = false;

  /// Laid-out child size. Shape morphs (stadium ↔ rounded rect) need the
  /// real box; parent constraints are often unbounded for wrap-content
  /// buttons and must not be substituted with a fake 100×40 fallback.
  Size _layoutSize = Size.zero;

  void _setPressed(bool pressed) {
    if (pressed == _pressed) return;
    if (pressed && widget.haptics) HapticFeedback.lightImpact();
    setState(() => _pressed = pressed);
  }

  void _handleChildSize(Size size) {
    if (!mounted) return;
    if ((size.width - _layoutSize.width).abs() < 0.5 &&
        (size.height - _layoutSize.height).abs() < 0.5) {
      return;
    }
    setState(() => _layoutSize = size);
  }

  ShapeBorder _resolveShape(Size size, double pressT, double selectT) {
    ShapeBorder base = widget.shape;
    if (widget.selectedShape != null) {
      base = MEShapeMorph(from: widget.shape, to: widget.selectedShape!)
          .evaluate(selectT, size);
    }
    final pressedShape = widget.pressedShape ?? _defaultPressedShape(size);
    var shape =
        MEShapeMorph(from: base, to: pressedShape).evaluate(pressT, size);
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
    final motion = METheme.of(context).motion;
    // Same pairing as m3e_core: snappy effects spring while pressed,
    // spatial spring on release so the morph can bounce.
    final pressSpec = _pressed ? motion.fastEffects : motion.defaultSpatial;

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
        child: MEMotionBuilder(
          value: widget.selected ? 1.0 : 0.0,
          spec: motion.defaultSpatial,
          builder: (context, selectT, _) {
            return MEMotionBuilder(
              value: _pressed ? 1.0 : 0.0,
              spec: pressSpec,
              builder: (context, pressT, child) {
                final hasSize = _layoutSize.width > 0 && _layoutSize.height > 0;
                final shape = hasSize
                    ? _resolveShape(_layoutSize, pressT, selectT)
                    : _restingShape();
                final double elevation = widget.pressedElevation == null
                    ? widget.elevation
                    : (widget.elevation +
                            (widget.pressedElevation! - widget.elevation) *
                                pressT.clamp(0.0, 1.0))
                        .clamp(0.0, 24.0)
                        .toDouble();
                Widget surface = Material(
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
                );
                if (widget.pressedScale < 1.0) {
                  // Unclamped: release overshoot pushes scale past 1.0.
                  final scale = 1.0 - (1.0 - widget.pressedScale) * pressT;
                  surface = Transform.scale(scale: scale, child: surface);
                }
                return surface;
              },
              child: _SizeProbe(
                onSize: _handleChildSize,
                child: widget.child,
              ),
            );
          },
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
