import 'package:flutter/material.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// A Material 3 Expressive animated success (or error) indicator.
///
/// A tonal circle springs in with overshoot while the check (or cross)
/// stroke draws itself. Use it in confirmation dialogs, empty states after
/// completing a flow, or payment-success screens.
///
/// ```dart
/// const MESuccessCheck(size: 96)
/// MESuccessCheck.error(size: 96)
/// ```
class MESuccessCheck extends StatefulWidget {
  const MESuccessCheck({
    super.key,
    this.size = 72,
    this.color,
    this.iconColor,
  }) : isError = false;

  const MESuccessCheck.error({
    super.key,
    this.size = 72,
    this.color,
    this.iconColor,
  }) : isError = true;

  final double size;

  /// Circle fill. Defaults to primaryContainer (errorContainer for
  /// [MESuccessCheck.error]).
  final Color? color;

  /// Stroke color. Defaults to onPrimaryContainer (onErrorContainer).
  final Color? iconColor;

  final bool isError;

  @override
  State<MESuccessCheck> createState() => _MESuccessCheckState();
}

class _MESuccessCheckState extends State<MESuccessCheck>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter = AnimationController.unbounded(
    vsync: this,
    value: 0,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      springTo(_enter, 1, METheme.of(context).motion.defaultSpatial);
    });
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = widget.color ??
        (widget.isError ? scheme.errorContainer : scheme.primaryContainer);
    final fg = widget.iconColor ??
        (widget.isError ? scheme.onErrorContainer : scheme.onPrimaryContainer);

    return AnimatedBuilder(
      animation: _enter,
      builder: (context, _) {
        final t = _enter.value;
        // Circle pops in first; stroke draws in the latter 60%.
        final circleScale = (t * 1.4).clamp(0.0, 1.15);
        final stroke = ((t - 0.35) / 0.65).clamp(0.0, 1.0);
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Transform.scale(
            scale: circleScale,
            child: DecoratedBox(
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: CustomPaint(
                painter: _StrokePainter(
                  progress: stroke,
                  color: fg,
                  isError: widget.isError,
                  strokeWidth: widget.size / 14,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StrokePainter extends CustomPainter {
  _StrokePainter({
    required this.progress,
    required this.color,
    required this.isError,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final bool isError;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;
    final Path path;
    if (isError) {
      path = Path()
        ..moveTo(w * 0.34, h * 0.34)
        ..lineTo(w * 0.66, h * 0.66)
        ..moveTo(w * 0.66, h * 0.34)
        ..lineTo(w * 0.34, h * 0.66);
    } else {
      path = Path()
        ..moveTo(w * 0.29, h * 0.52)
        ..lineTo(w * 0.44, h * 0.66)
        ..lineTo(w * 0.71, h * 0.37);
    }

    if (progress >= 1.0) {
      canvas.drawPath(path, paint);
      return;
    }
    double total = 0;
    final metrics = path.computeMetrics().toList();
    for (final m in metrics) {
      total += m.length;
    }
    double remaining = total * progress;
    for (final m in metrics) {
      if (remaining <= 0) break;
      final draw = remaining.clamp(0, m.length).toDouble();
      canvas.drawPath(m.extractPath(0, draw), paint);
      remaining -= draw;
    }
  }

  @override
  bool shouldRepaint(_StrokePainter old) =>
      old.progress != progress || old.color != color;
}
