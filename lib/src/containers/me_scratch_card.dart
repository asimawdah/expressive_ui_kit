import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/me_motion.dart';
import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';

/// A scratch-off reveal card with Material 3 Expressive motion.
///
/// The [child] is hidden under a tonal cover layer. Dragging scratches
/// the cover away along the finger path. Once [revealThreshold] of the
/// area has been scratched, the remaining cover fades out with the
/// effects spring, the card gives a success haptic, and [onRevealed]
/// fires.
class MEScratchCard extends StatefulWidget {
  const MEScratchCard({
    super.key,
    required this.child,
    this.cover,
    this.coverLabel = 'Scratch to reveal',
    this.brushRadius = 22,
    this.revealThreshold = 0.55,
    this.onRevealed,
    this.height = 160,
    this.semanticLabel,
  });

  /// The hidden content.
  final Widget child;

  /// Optional custom cover widget. Defaults to a tonal surface with
  /// [coverLabel].
  final Widget? cover;

  final String coverLabel;

  /// Radius of the scratch brush in logical pixels.
  final double brushRadius;

  /// Fraction (0-1) of the area that must be scratched before the rest
  /// auto-reveals.
  final double revealThreshold;

  final VoidCallback? onRevealed;

  final double height;

  final String? semanticLabel;

  @override
  State<MEScratchCard> createState() => _MEScratchCardState();
}

class _MEScratchCardState extends State<MEScratchCard>
    with SingleTickerProviderStateMixin {
  final List<Offset?> _points = [];
  late final AnimationController _fade = AnimationController.unbounded(
    vsync: this,
    value: 0,
  );
  bool _revealed = false;
  int _estimatedScratched = 0;

  void _addPoint(Offset point, Size size) {
    if (_revealed) return;
    setState(() => _points.add(point));
    // Cheap coverage estimate: each brush stamp covers pi*r^2; count
    // unique-ish stamps against the total area, capped at 1.0.
    _estimatedScratched++;
    final brushArea = 3.14159 * widget.brushRadius * widget.brushRadius * 0.55;
    final coverage =
        (_estimatedScratched * brushArea) / (size.width * size.height);
    if (coverage >= widget.revealThreshold) _reveal();
  }

  void _reveal() {
    if (_revealed) return;
    _revealed = true;
    HapticFeedback.mediumImpact();
    springTo(_fade, 1, METheme.of(context).motion.defaultEffects);
    widget.onRevealed?.call();
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: widget.semanticLabel ?? widget.coverLabel,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(MECorners.large),
        child: SizedBox(
          height: widget.height,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, widget.height);
              return Stack(
                fit: StackFit.expand,
                children: [
                  // Hidden content.
                  ColoredBox(
                    color: scheme.surfaceContainerLow,
                    child: widget.child,
                  ),
                  // Scratchable cover.
                  AnimatedBuilder(
                    animation: _fade,
                    builder: (context, child) {
                      final opacity = (1 - _fade.value).clamp(0.0, 1.0);
                      if (opacity == 0) return const SizedBox.shrink();
                      return Opacity(
                        opacity: opacity,
                        child: child,
                      );
                    },
                    child: GestureDetector(
                      onPanUpdate: (d) => _addPoint(d.localPosition, size),
                      onPanEnd: (_) => _points.add(null),
                      child: _ScratchSurface(
                        points: _points,
                        brushRadius: widget.brushRadius,
                        cover: widget.cover ??
                            Container(
                              color: scheme.tertiaryContainer,
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.touch_app_outlined,
                                    color: scheme.onTertiaryContainer,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.coverLabel,
                                    style: TextStyle(
                                      color: scheme.onTertiaryContainer,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
  }
}

/// Paints the cover, erasing along the scratched path with BlendMode.clear.
class _ScratchSurface extends StatelessWidget {
  const _ScratchSurface({
    required this.points,
    required this.brushRadius,
    required this.cover,
  });

  final List<Offset?> points;
  final double brushRadius;
  final Widget cover;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _ScratchClipper(points: points, brushRadius: brushRadius),
      child: cover,
    );
  }
}

/// Clips OUT the scratched path (keeps everything except scratched areas).
class _ScratchClipper extends CustomClipper<Path> {
  _ScratchClipper({required this.points, required this.brushRadius});

  final List<Offset?> points;
  final double brushRadius;

  @override
  Path getClip(Size size) {
    final scratched = Path();
    Offset? previous;
    for (final point in points) {
      if (point == null) {
        previous = null;
        continue;
      }
      if (previous != null) {
        // Stroke segment as a thick line between stamps.
        final delta = point - previous;
        final steps =
            (delta.distance / (brushRadius * 0.5)).ceil().clamp(1, 24);
        for (int s = 0; s <= steps; s++) {
          final p = previous + delta * (s / steps);
          scratched.addOval(
            Rect.fromCircle(center: p, radius: brushRadius),
          );
        }
      } else {
        scratched.addOval(Rect.fromCircle(center: point, radius: brushRadius));
      }
      previous = point;
    }
    final full = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    return Path.combine(ui.PathOperation.difference, full, scratched);
  }

  @override
  bool shouldReclip(_ScratchClipper oldClipper) =>
      oldClipper.points.length != points.length;
}
