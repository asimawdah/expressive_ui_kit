import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// An hourglass timer: sand drains from the top bulb into the bottom one
/// over [duration], with a falling stream and a flip interaction.
///
/// Tapping the hourglass flips it 180 degrees with the default spatial
/// spring (overshooting slightly) and restarts the countdown. When the
/// sand runs out, [onEmpty] fires with a medium haptic.
class MEHourglass extends StatefulWidget {
  const MEHourglass({
    super.key,
    this.duration = const Duration(seconds: 30),
    this.size = 120,
    this.running = true,
    this.onEmpty,
    this.semanticLabel,
  });

  /// Time for the sand to fully drain.
  final Duration duration;

  /// Height of the hourglass.
  final double size;

  /// Whether the sand is draining.
  final bool running;

  /// Called when the top bulb empties.
  final VoidCallback? onEmpty;

  final String? semanticLabel;

  @override
  State<MEHourglass> createState() => _MEHourglassState();
}

class _MEHourglassState extends State<MEHourglass>
    with TickerProviderStateMixin {
  late final AnimationController _sand = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final AnimationController _flip = AnimationController.unbounded(
    vsync: this,
    value: 0,
  );
  int _halfTurns = 0;

  @override
  void initState() {
    super.initState();
    _sand.addStatusListener(_onSandStatus);
    if (widget.running) _sand.forward();
  }

  void _onSandStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      HapticFeedback.mediumImpact();
      widget.onEmpty?.call();
    }
  }

  @override
  void didUpdateWidget(MEHourglass oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sand.duration = widget.duration;
    if (widget.running != oldWidget.running) {
      if (widget.running) {
        _sand.forward();
      } else {
        _sand.stop();
      }
    }
  }

  @override
  void dispose() {
    _sand.dispose();
    _flip.dispose();
    super.dispose();
  }

  void _onFlip() {
    HapticFeedback.selectionClick();
    _halfTurns += 1;
    springTo(
      _flip,
      _halfTurns.toDouble(),
      METheme.of(context).motion.defaultSpatial,
    );
    _sand.value = 0;
    if (widget.running) _sand.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      label: widget.semanticLabel ?? 'Hourglass timer',
      button: true,
      child: GestureDetector(
        onTap: _onFlip,
        child: AnimatedBuilder(
          animation: Listenable.merge([_sand, _flip]),
          builder: (context, _) {
            return Transform.rotate(
              angle: _flip.value * math.pi,
              child: CustomPaint(
                size: Size(widget.size * 0.72, widget.size),
                painter: _MEHourglassPainter(
                  progress: _sand.value,
                  running: widget.running && _sand.isAnimating,
                  frameColor: scheme.outline,
                  sandColor: scheme.tertiary,
                  glassColor: scheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MEHourglassPainter extends CustomPainter {
  _MEHourglassPainter({
    required this.progress,
    required this.running,
    required this.frameColor,
    required this.sandColor,
    required this.glassColor,
  });

  /// 0.0 = top bulb full, 1.0 = fully drained.
  final double progress;
  final bool running;
  final Color frameColor;
  final Color sandColor;
  final Color glassColor;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final waist = Offset(w / 2, h / 2);
    const neck = 3.0;

    // Glass body: two triangular-ish bulbs built from one path.
    final glass = Path()
      ..moveTo(w * 0.08, h * 0.06)
      ..lineTo(w * 0.92, h * 0.06)
      ..quadraticBezierTo(w * 0.92, h * 0.32, waist.dx + neck, waist.dy)
      ..quadraticBezierTo(w * 0.92, h * 0.68, w * 0.92, h * 0.94)
      ..lineTo(w * 0.08, h * 0.94)
      ..quadraticBezierTo(w * 0.08, h * 0.68, waist.dx - neck, waist.dy)
      ..quadraticBezierTo(w * 0.08, h * 0.32, w * 0.08, h * 0.06)
      ..close();

    canvas.drawPath(glass, Paint()..color = glassColor);

    // Sand in the top bulb: a shrinking triangle clipped to the glass.
    final p = progress.clamp(0.0, 1.0);
    canvas.save();
    canvas.clipPath(glass);

    final sand = Paint()..color = sandColor;
    // Top sand: fills from its surface line down to the waist.
    final topSurface = h * (0.10 + 0.38 * p);
    if (p < 1.0) {
      final topSand = Path()
        ..moveTo(w * 0.10, topSurface)
        ..lineTo(w * 0.90, topSurface)
        ..lineTo(waist.dx + neck, waist.dy)
        ..lineTo(waist.dx - neck, waist.dy)
        ..close();
      canvas.drawPath(topSand, sand);
    }

    // Bottom sand: a growing mound.
    final moundHeight = h * 0.36 * p;
    final bottomSand = Path()
      ..moveTo(w * 0.06, h * 0.94)
      ..lineTo(w * 0.94, h * 0.94)
      ..lineTo(w * 0.94, h * 0.94 - moundHeight * 0.55)
      ..quadraticBezierTo(
        waist.dx,
        h * 0.94 - moundHeight * 1.45,
        w * 0.06,
        h * 0.94 - moundHeight * 0.55,
      )
      ..close();
    canvas.drawPath(bottomSand, sand);

    // Falling stream while running.
    if (running && p < 1.0) {
      canvas.drawRect(
        Rect.fromLTRB(
          waist.dx - 1,
          waist.dy,
          waist.dx + 1,
          h * 0.94 - moundHeight,
        ),
        sand,
      );
    }
    canvas.restore();

    // Frame: top and bottom caps plus the glass outline.
    final frame = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = frameColor;
    canvas.drawPath(glass, frame);

    final cap = Paint()
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..color = frameColor;
    canvas.drawLine(Offset(w * 0.02, h * 0.04), Offset(w * 0.98, h * 0.04), cap);
    canvas.drawLine(Offset(w * 0.02, h * 0.96), Offset(w * 0.98, h * 0.96), cap);
  }

  @override
  bool shouldRepaint(_MEHourglassPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.running != running;
}
