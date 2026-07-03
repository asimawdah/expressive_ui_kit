import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// Scheme-derived paper colors for [MEStickyNote].
enum MEStickyNoteColor { primary, secondary, tertiary }

/// A sticky-note surface with a folded corner and a springy entrance.
///
/// The note drops in on mount — scaling up and settling into its resting
/// [angle] with the slow spatial spring. Pressing squashes the note
/// slightly and levels its tilt; releasing springs back with a wobble.
///
/// ```dart
/// MEStickyNote(
///   color: MEStickyNoteColor.tertiary,
///   child: Text('Buy oat milk'),
/// )
/// ```
class MEStickyNote extends StatefulWidget {
  const MEStickyNote({
    super.key,
    required this.child,
    this.color = MEStickyNoteColor.tertiary,
    this.angle = -2.0,
    this.width = 190,
    this.height = 190,
    this.onPressed,
    this.semanticLabel,
  });

  /// Note content. Text inherits the paper's ink color.
  final Widget child;

  /// Paper color, derived from the ambient [ColorScheme] containers.
  final MEStickyNoteColor color;

  /// Resting tilt, in degrees. Small values (-4..4) look most natural.
  final double angle;

  final double width;
  final double height;
  final VoidCallback? onPressed;
  final String? semanticLabel;

  @override
  State<MEStickyNote> createState() => _MEStickyNoteState();
}

class _MEStickyNoteState extends State<MEStickyNote>
    with TickerProviderStateMixin {
  late final AnimationController _enter =
      AnimationController.unbounded(vsync: this, value: 0);
  late final AnimationController _press =
      AnimationController.unbounded(vsync: this, value: 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      springTo(_enter, 1, METheme.of(context).motion.slowSpatial);
    });
  }

  @override
  void dispose() {
    _enter.dispose();
    _press.dispose();
    super.dispose();
  }

  void _setPressed(bool pressed) {
    if (pressed) HapticFeedback.lightImpact();
    final motion = METheme.of(context).motion;
    springTo(
      _press,
      pressed ? 1 : 0,
      pressed ? motion.fastSpatial : motion.defaultSpatial,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Color paper;
    Color ink;
    switch (widget.color) {
      case MEStickyNoteColor.primary:
        paper = scheme.primaryContainer;
        ink = scheme.onPrimaryContainer;
        break;
      case MEStickyNoteColor.secondary:
        paper = scheme.secondaryContainer;
        ink = scheme.onSecondaryContainer;
        break;
      case MEStickyNoteColor.tertiary:
        paper = scheme.tertiaryContainer;
        ink = scheme.onTertiaryContainer;
        break;
    }
    final restAngle = widget.angle * math.pi / 180;
    final interactive = widget.onPressed != null;

    return Semantics(
      label: widget.semanticLabel,
      button: interactive,
      child: GestureDetector(
        onTapDown: interactive ? (_) => _setPressed(true) : null,
        onTapUp: interactive
            ? (_) {
                _setPressed(false);
                widget.onPressed!();
              }
            : null,
        onTapCancel: interactive ? () => _setPressed(false) : null,
        child: AnimatedBuilder(
          animation: Listenable.merge([_enter, _press]),
          builder: (context, child) {
            final e = _enter.value;
            final p = _press.value.clamp(0.0, 1.2);
            // Entrance: scale up from 60% while over-rotating toward rest.
            // Press: slight squash and the tilt levels halfway out.
            final scale = (0.6 + 0.4 * e) * (1.0 - 0.04 * p);
            final angle = restAngle * (2.0 - e) * (1.0 - 0.5 * p);
            return Opacity(
              opacity: e.clamp(0.0, 1.0),
              child: Transform.rotate(
                angle: angle,
                child: Transform.scale(scale: scale, child: child),
              ),
            );
          },
          child: CustomPaint(
            painter: _StickyNotePainter(paper: paper, shadow: scheme.shadow),
            child: SizedBox(
              width: widget.width,
              height: widget.height,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: DefaultTextStyle.merge(
                  style: TextStyle(color: ink),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints the note paper with a clipped, folded bottom-right corner.
class _StickyNotePainter extends CustomPainter {
  const _StickyNotePainter({required this.paper, required this.shadow});

  final Color paper;
  final Color shadow;

  @override
  void paint(Canvas canvas, Size size) {
    const fold = 30.0;
    const r = 6.0;
    final body = Path()
      ..moveTo(r, 0)
      ..lineTo(size.width - r, 0)
      ..quadraticBezierTo(size.width, 0, size.width, r)
      ..lineTo(size.width, size.height - fold)
      ..lineTo(size.width - fold, size.height)
      ..lineTo(r, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - r)
      ..lineTo(0, r)
      ..quadraticBezierTo(0, 0, r, 0)
      ..close();
    canvas.drawShadow(body.shift(const Offset(0, 2)), shadow, 4, false);
    canvas.drawPath(body, Paint()..color = paper);
    // The folded-over corner reads as a slightly darker triangle.
    final foldPath = Path()
      ..moveTo(size.width - fold, size.height)
      ..lineTo(size.width, size.height - fold)
      ..lineTo(size.width - fold, size.height - fold)
      ..close();
    canvas.drawPath(
      foldPath,
      Paint()..color = Color.lerp(paper, shadow, 0.18)!,
    );
  }

  @override
  bool shouldRepaint(_StickyNotePainter oldDelegate) =>
      oldDelegate.paper != paper || oldDelegate.shadow != shadow;
}
