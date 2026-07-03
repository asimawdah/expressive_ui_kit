import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A Material 3 Expressive linear progress indicator.
///
/// Replaces [LinearProgressIndicator]. Renders the M3E wavy active track
/// with a flat remaining track, a gap around the leading edge, and the
/// stop indicator dot at the end. Pass `value: null` for the
/// indeterminate variant.
class MELinearProgressIndicator extends StatefulWidget {
  const MELinearProgressIndicator({
    super.key,
    this.value,
    this.height = 10,
    this.strokeWidth = 4,
    this.amplitude = 3,
    this.wavelength = 40,
    this.color,
    this.trackColor,
    this.wavy = true,
    this.semanticsLabel,
  });

  /// Progress from 0.0 to 1.0, or null for indeterminate.
  final double? value;
  final double height;
  final double strokeWidth;

  /// Wave height. Set 0 (or [wavy] false) for a flat expressive track.
  final double amplitude;
  final double wavelength;
  final Color? color;
  final Color? trackColor;
  final bool wavy;
  final String? semanticsLabel;

  @override
  State<MELinearProgressIndicator> createState() =>
      _MELinearProgressIndicatorState();
}

class _MELinearProgressIndicatorState extends State<MELinearProgressIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: widget.semanticsLabel ?? 'Progress indicator',
      value: widget.value == null
          ? null
          : '${(widget.value! * 100).round()} percent',
      child: SizedBox(
        height: math.max(widget.height, widget.amplitude * 2 + widget.strokeWidth),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            size: Size.infinite,
            painter: _WavyLinearPainter(
              value: widget.value,
              phase: _controller.value,
              amplitude: widget.wavy ? widget.amplitude : 0,
              wavelength: widget.wavelength,
              strokeWidth: widget.strokeWidth,
              color: widget.color ?? colors.primary,
              trackColor: widget.trackColor ?? colors.secondaryContainer,
            ),
          ),
        ),
      ),
    );
  }
}

class _WavyLinearPainter extends CustomPainter {
  _WavyLinearPainter({
    required this.value,
    required this.phase,
    required this.amplitude,
    required this.wavelength,
    required this.strokeWidth,
    required this.color,
    required this.trackColor,
  });

  final double? value;
  final double phase;
  final double amplitude;
  final double wavelength;
  final double strokeWidth;
  final Color color;
  final Color trackColor;

  static const double _gap = 6;

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    final activePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (value != null) {
      final v = value!.clamp(0.0, 1.0);
      final activeEnd = v * size.width;

      // Active wavy segment.
      if (activeEnd > strokeWidth) {
        _paintWave(canvas, activePaint, 0, activeEnd - _gap, cy, size);
      }
      // Remaining flat track.
      if (activeEnd + _gap < size.width - strokeWidth) {
        canvas.drawLine(
          Offset(activeEnd + _gap, cy),
          Offset(size.width - strokeWidth, cy),
          trackPaint,
        );
      }
      // Stop indicator dot at the far end.
      canvas.drawCircle(
        Offset(size.width - strokeWidth / 2, cy),
        strokeWidth / 2,
        Paint()..color = color,
      );
    } else {
      // Indeterminate: a wavy segment sweeps across the track.
      final segmentWidth = size.width * 0.35;
      final travel = size.width + segmentWidth;
      final start = phase * travel - segmentWidth;
      final end = start + segmentWidth;

      if (start - _gap > 0) {
        canvas.drawLine(
          Offset(0, cy),
          Offset(math.max(0, start - _gap), cy),
          trackPaint,
        );
      }
      if (end + _gap < size.width) {
        canvas.drawLine(
          Offset(end + _gap, cy),
          Offset(size.width, cy),
          trackPaint,
        );
      }
      _paintWave(
        canvas,
        activePaint,
        math.max(0, start),
        math.min(size.width, end),
        cy,
        size,
      );
    }
  }

  void _paintWave(
    Canvas canvas,
    Paint paint,
    double from,
    double to,
    double cy,
    Size size,
  ) {
    if (to <= from) return;
    if (amplitude <= 0) {
      canvas.drawLine(Offset(from, cy), Offset(to, cy), paint);
      return;
    }
    final path = Path()..moveTo(from, cy + _waveY(from));
    for (double x = from; x <= to; x += 2) {
      path.lineTo(x, cy + _waveY(x));
    }
    path.lineTo(to, cy + _waveY(to));
    canvas.drawPath(path, paint);
  }

  double _waveY(double x) {
    final travel = phase * wavelength * 2;
    return math.sin((x - travel) / wavelength * 2 * math.pi) * amplitude;
  }

  @override
  bool shouldRepaint(_WavyLinearPainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.phase != phase ||
      oldDelegate.amplitude != amplitude ||
      oldDelegate.color != color;
}
