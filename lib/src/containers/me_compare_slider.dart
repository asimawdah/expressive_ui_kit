import 'package:flutter/material.dart';

import '../theme/me_motion.dart';
import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';

/// A Material 3 Expressive before/after comparison slider.
///
/// Overlays two widgets and reveals the [after] side with a draggable
/// divider. The divider handle press-morphs squarer while dragging and
/// the reveal position springs to where you release. Useful for photo
/// edits, theme previews, and design comparisons.
class MECompareSlider extends StatefulWidget {
  const MECompareSlider({
    super.key,
    required this.before,
    required this.after,
    this.initialPosition = 0.5,
    this.height = 220,
    this.beforeLabel,
    this.afterLabel,
  });

  /// Shown on the left of the divider.
  final Widget before;

  /// Shown on the right of the divider.
  final Widget after;

  /// Initial divider position (0..1).
  final double initialPosition;
  final double height;

  /// Optional corner labels (e.g. "Before" / "After").
  final String? beforeLabel;
  final String? afterLabel;

  @override
  State<MECompareSlider> createState() => _MECompareSliderState();
}

class _MECompareSliderState extends State<MECompareSlider>
    with SingleTickerProviderStateMixin {
  late final AnimationController _position = AnimationController.unbounded(
    vsync: this,
    value: widget.initialPosition,
  );
  bool _dragging = false;

  @override
  void dispose() {
    _position.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return GestureDetector(
          onHorizontalDragStart: (_) => setState(() => _dragging = true),
          onHorizontalDragUpdate: (d) {
            _position.value =
                (_position.value + d.delta.dx / width).clamp(0.0, 1.0);
          },
          onHorizontalDragEnd: (_) {
            setState(() => _dragging = false);
            // Settle in place with a soft spring for the release feel.
            springTo(_position, _position.value.clamp(0.02, 0.98),
                METheme.of(context).motion.fastSpatial);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(MECorners.extraLarge),
            child: SizedBox(
              height: widget.height,
              width: double.infinity,
              child: AnimatedBuilder(
                animation: _position,
                builder: (context, _) {
                  final t = _position.value.clamp(0.0, 1.0);
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      widget.before,
                      // The "after" layer, clipped to the divider.
                      ClipRect(
                        clipper: _RightClipper(t),
                        child: widget.after,
                      ),
                      // Corner labels.
                      if (widget.beforeLabel != null)
                        Positioned(
                          left: 12,
                          top: 12,
                          child: _label(context, widget.beforeLabel!),
                        ),
                      if (widget.afterLabel != null)
                        Positioned(
                          right: 12,
                          top: 12,
                          child: _label(context, widget.afterLabel!),
                        ),
                      // Divider line + handle.
                      Positioned(
                        left: width * t - 1.5,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 3,
                          color: scheme.surface,
                        ),
                      ),
                      Positioned(
                        left: width * t - 20,
                        top: widget.height / 2 - 20,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          curve: Curves.easeOut,
                          width: 40,
                          height: 40,
                          decoration: ShapeDecoration(
                            color: scheme.surface,
                            shape: RoundedRectangleBorder(
                              // Press-morph: rounder at rest, squarer
                              // while dragging.
                              borderRadius:
                                  BorderRadius.circular(_dragging ? 12 : 20),
                            ),
                            shadows: const [
                              BoxShadow(
                                color: Color(0x33000000),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.unfold_more,
                            size: 20,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _label(BuildContext context, String text) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: ShapeDecoration(
        color: scheme.surface.withValues(alpha: 0.85),
        shape: const StadiumBorder(),
      ),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .labelSmall!
            .copyWith(color: scheme.onSurface),
      ),
    );
  }
}

/// Clips to the region right of the divider at fraction [t].
class _RightClipper extends CustomClipper<Rect> {
  const _RightClipper(this.t);

  final double t;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(size.width * t, 0, size.width, size.height);

  @override
  bool shouldReclip(_RightClipper oldClipper) => oldClipper.t != t;
}
