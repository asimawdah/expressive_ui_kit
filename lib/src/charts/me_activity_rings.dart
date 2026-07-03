import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// A single ring in an [MEActivityRings] display.
@immutable
class MEActivityRing {
  const MEActivityRing({
    required this.value,
    this.color,
    this.label,
  });

  /// Progress from 0.0 to 1.0. Values above 1.0 are rendered as a full
  /// ring (overflow wrap is not drawn).
  final double value;

  /// Ring color. Defaults to a scheme-derived color per ring index
  /// (primary, tertiary, secondary).
  final Color? color;

  /// Optional legend label.
  final String? label;
}

/// Concentric activity rings with spring-driven sweep, in the style of
/// fitness rings but themed with Material color roles.
///
/// Each ring sweeps from zero to its value with the slow spatial spring,
/// staggered outside-in. Rounded stroke caps and a faint track complete
/// the look. Set a new [rings] list and the rings re-sweep from their
/// previous values (interruptible).
class MEActivityRings extends StatefulWidget {
  const MEActivityRings({
    super.key,
    required this.rings,
    this.size = 160,
    this.thickness = 14,
    this.gap = 6,
    this.center,
    this.showLegend = false,
  });

  /// Rings ordered outside-in.
  final List<MEActivityRing> rings;

  /// Diameter of the outermost ring.
  final double size;

  /// Stroke width of each ring.
  final double thickness;

  /// Radial gap between rings.
  final double gap;

  /// Optional widget in the middle (e.g. an icon or total).
  final Widget? center;

  /// When true, renders a legend row of label dots under the rings.
  final bool showLegend;

  @override
  State<MEActivityRings> createState() => _MEActivityRingsState();
}

class _MEActivityRingsState extends State<MEActivityRings>
    with TickerProviderStateMixin {
  final List<AnimationController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _syncControllers();
    WidgetsBinding.instance.addPostFrameCallback((_) => _animate());
  }

  void _syncControllers() {
    while (_controllers.length < widget.rings.length) {
      _controllers.add(AnimationController.unbounded(vsync: this, value: 0));
    }
    while (_controllers.length > widget.rings.length) {
      _controllers.removeLast().dispose();
    }
  }

  void _animate() {
    if (!mounted) return;
    final motion = METheme.of(context).motion;
    for (var i = 0; i < _controllers.length; i++) {
      final target = widget.rings[i].value.clamp(0.0, 1.0);
      // Stagger outside-in: outer rings start first.
      Future.delayed(Duration(milliseconds: 90 * i), () {
        if (!mounted || i >= _controllers.length) return;
        springTo(_controllers[i], target, motion.slowSpatial);
      });
    }
  }

  @override
  void didUpdateWidget(MEActivityRings oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncControllers();
    _animate();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Color _ringColor(ColorScheme scheme, int i) {
    return widget.rings[i].color ??
        [scheme.primary, scheme.tertiary, scheme.secondary][i % 3];
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final rings = SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge(_controllers),
        builder: (context, _) {
          return CustomPaint(
            painter: _RingsPainter(
              values: [
                for (final c in _controllers) c.value.clamp(0.0, 1.0),
              ],
              colors: [
                for (var i = 0; i < widget.rings.length; i++)
                  _ringColor(scheme, i),
              ],
              trackColor: scheme.surfaceContainerHigh,
              thickness: widget.thickness,
              gap: widget.gap,
            ),
            child: widget.center == null
                ? null
                : Center(child: widget.center),
          );
        },
      ),
    );

    if (!widget.showLegend) return rings;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        rings,
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: [
            for (var i = 0; i < widget.rings.length; i++)
              if (widget.rings[i].label != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _ringColor(scheme, i),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.rings[i].label!,
                      style: text.labelMedium!
                          .copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
          ],
        ),
      ],
    );
  }
}

class _RingsPainter extends CustomPainter {
  _RingsPainter({
    required this.values,
    required this.colors,
    required this.trackColor,
    required this.thickness,
    required this.gap,
  });

  final List<double> values;
  final List<Color> colors;
  final Color trackColor;
  final double thickness;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    for (var i = 0; i < values.length; i++) {
      final radius =
          size.shortestSide / 2 - thickness / 2 - i * (thickness + gap);
      if (radius <= 0) break;
      final rect = Rect.fromCircle(center: center, radius: radius);

      final track = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..color = trackColor;
      canvas.drawArc(rect, 0, math.pi * 2, false, track);

      if (values[i] <= 0) continue;
      final arc = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round
        ..color = colors[i];
      canvas.drawArc(
        rect,
        -math.pi / 2,
        math.pi * 2 * values[i],
        false,
        arc,
      );
    }
  }

  @override
  bool shouldRepaint(_RingsPainter oldDelegate) =>
      oldDelegate.values != values ||
      oldDelegate.colors != colors ||
      oldDelegate.trackColor != trackColor;
}
