import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// A circular container that fills with an animated liquid wave.
///
/// New in the expressive idiom: a playful determinate progress indicator
/// for hero moments (downloads, goals, storage). The fill level springs
/// to [value] with the slow spatial spring, while the surface undulates
/// with two out-of-phase waves whose amplitude scales with how far the
/// level is from settling — so the liquid sloshes on change and calms
/// down at rest.
///
/// ```dart
/// MELiquidProgress(
///   value: 0.62,
///   size: 120,
///   label: Text('62%'),
/// )
/// ```
class MELiquidProgress extends StatefulWidget {
  const MELiquidProgress({
    super.key,
    required this.value,
    this.size = 120,
    this.label,
    this.color,
    this.backgroundColor,
    this.semanticLabel,
  }) : assert(value >= 0 && value <= 1, 'value must be within 0..1');

  /// Fill level, 0..1.
  final double value;

  /// Diameter of the indicator.
  final double size;

  /// Optional center label (e.g. a percentage readout).
  final Widget? label;

  /// Liquid color. Defaults to the scheme primary.
  final Color? color;

  /// Container color. Defaults to surfaceContainerHighest.
  final Color? backgroundColor;

  final String? semanticLabel;

  @override
  State<MELiquidProgress> createState() => _MELiquidProgressState();
}

class _MELiquidProgressState extends State<MELiquidProgress>
    with TickerProviderStateMixin {
  late final AnimationController _level = AnimationController.unbounded(
    vsync: this,
    value: widget.value,
  );
  late final AnimationController _wave = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  @override
  void didUpdateWidget(MELiquidProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      springTo(_level, widget.value, METheme.of(context).motion.slowSpatial);
    }
  }

  @override
  void dispose() {
    _level.dispose();
    _wave.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final liquid = widget.color ?? scheme.primary;
    final bg = widget.backgroundColor ?? scheme.surfaceContainerHighest;

    return Semantics(
      label: widget.semanticLabel,
      value: '${(widget.value * 100).round()}%',
      child: AnimatedBuilder(
        animation: Listenable.merge([_level, _wave]),
        builder: (context, child) {
          final level = _level.value.clamp(0.0, 1.0);
          // Slosh amplitude grows with level velocity, calming at rest.
          final slosh =
              (_level.velocity.abs() * 0.15).clamp(0.0, 1.0);
          return SizedBox(
            width: widget.size,
            height: widget.size,
            child: ClipOval(
              child: CustomPaint(
                painter: _LiquidPainter(
                  level: level,
                  phase: _wave.value * 2 * math.pi,
                  amplitude: widget.size * (0.015 + 0.05 * slosh),
                  liquidColor: liquid,
                  backgroundColor: bg,
                ),
                child: Center(
                  child: DefaultTextStyle.merge(
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: level > 0.55
                              ? scheme.onPrimary
                              : scheme.onSurface,
                        ),
                    child: child ?? const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          );
        },
        child: widget.label,
      ),
    );
  }
}

class _LiquidPainter extends CustomPainter {
  const _LiquidPainter({
    required this.level,
    required this.phase,
    required this.amplitude,
    required this.liquidColor,
    required this.backgroundColor,
  });

  final double level;
  final double phase;
  final double amplitude;
  final Color liquidColor;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = backgroundColor,
    );
    if (level <= 0.001) return;

    final surfaceY = size.height * (1 - level);

    // Back wave: dimmer, out of phase.
    canvas.drawPath(
      _wavePath(size, surfaceY, phase + math.pi, amplitude * 1.4),
      Paint()..color = liquidColor.withValues(alpha: 0.4),
    );
    // Front wave.
    canvas.drawPath(
      _wavePath(size, surfaceY, phase, amplitude),
      Paint()..color = liquidColor,
    );
  }

  Path _wavePath(Size size, double surfaceY, double phase, double amp) {
    final path = Path()..moveTo(0, surfaceY);
    const steps = 24;
    for (int i = 0; i <= steps; i++) {
      final x = size.width * i / steps;
      final y = surfaceY +
          amp * math.sin(phase + 2 * math.pi * i / steps * 1.5);
      path.lineTo(x, y);
    }
    path
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    return path;
  }

  @override
  bool shouldRepaint(_LiquidPainter oldDelegate) =>
      oldDelegate.level != level ||
      oldDelegate.phase != phase ||
      oldDelegate.amplitude != amplitude ||
      oldDelegate.liquidColor != liquidColor ||
      oldDelegate.backgroundColor != backgroundColor;
}
