import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/me_theme.dart';

/// A single bubble in an [MEBubbleChart].
@immutable
class MEBubble {
  const MEBubble({
    required this.x,
    required this.y,
    required this.size,
    this.label,
    this.color,
  })  : assert(x >= 0 && x <= 1, 'x must be 0..1'),
        assert(y >= 0 && y <= 1, 'y must be 0..1'),
        assert(size >= 0 && size <= 1, 'size must be 0..1');

  /// Horizontal position, 0..1 (left to right).
  final double x;

  /// Vertical position, 0..1 (bottom to top).
  final double y;

  /// Relative bubble size, 0..1 (maps to min..max radius).
  final double size;

  /// Optional label drawn inside the bubble when it fits.
  final String? label;

  /// Overrides the scheme-derived color.
  final Color? color;
}

/// An animated bubble chart.
///
/// Bubbles inflate from zero with staggered spatial springs, overshooting
/// slightly before settling — and gently drift while idle so the chart
/// feels alive. Colors cycle through primary, tertiary and secondary
/// containers unless overridden per bubble.
class MEBubbleChart extends StatefulWidget {
  const MEBubbleChart({
    super.key,
    required this.bubbles,
    this.height = 220,
    this.minRadius = 10,
    this.maxRadius = 36,
    this.drift = true,
    this.semanticLabel,
  });

  final List<MEBubble> bubbles;
  final double height;
  final double minRadius;
  final double maxRadius;

  /// Whether bubbles gently bob while idle.
  final bool drift;

  final String? semanticLabel;

  @override
  State<MEBubbleChart> createState() => _MEBubbleChartState();
}

class _MEBubbleChartState extends State<MEBubbleChart>
    with TickerProviderStateMixin {
  late final AnimationController _enter;
  AnimationController? _idle;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
    if (widget.drift) {
      _idle = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 6),
      )..repeat();
    }
  }

  @override
  void didUpdateWidget(MEBubbleChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.drift && _idle == null) {
      _idle = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 6),
      )..repeat();
    } else if (!widget.drift && _idle != null) {
      _idle!.dispose();
      _idle = null;
    }
    if (!listEquals(oldWidget.bubbles, widget.bubbles)) {
      _enter.forward(from: 0);
    }
  }

  static bool listEquals(List<MEBubble> a, List<MEBubble> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].x != b[i].x || a[i].y != b[i].y || a[i].size != b[i].size) {
        return false;
      }
    }
    return true;
  }

  @override
  void dispose() {
    _enter.dispose();
    _idle?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final motion = METheme.of(context).motion;
    final curve = motion.defaultSpatial.curve;

    return Semantics(
      label: widget.semanticLabel ??
          'Bubble chart with ${widget.bubbles.length} bubbles',
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: AnimatedBuilder(
          animation: Listenable.merge([_enter, if (_idle != null) _idle!]),
          builder: (context, _) {
            return CustomPaint(
              painter: _BubblePainter(
                bubbles: widget.bubbles,
                enter: _enter.value,
                idle: _idle?.value ?? 0,
                curve: curve,
                minRadius: widget.minRadius,
                maxRadius: widget.maxRadius,
                colors: [
                  scheme.primary,
                  scheme.tertiary,
                  scheme.secondary,
                ],
                labelColor: scheme.onSurface,
                labelStyle: Theme.of(context).textTheme.labelSmall,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  _BubblePainter({
    required this.bubbles,
    required this.enter,
    required this.idle,
    required this.curve,
    required this.minRadius,
    required this.maxRadius,
    required this.colors,
    required this.labelColor,
    required this.labelStyle,
  });

  final List<MEBubble> bubbles;
  final double enter;
  final double idle;
  final Curve curve;
  final double minRadius;
  final double maxRadius;
  final List<Color> colors;
  final Color labelColor;
  final TextStyle? labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < bubbles.length; i++) {
      final bubble = bubbles[i];
      // Stagger: each bubble starts after a delay proportional to index.
      final delay = bubbles.length <= 1 ? 0.0 : i / (bubbles.length * 1.8);
      final local = ((enter - delay) / (1 - delay)).clamp(0.0, 1.0);
      final scale = curve.transform(local);
      if (scale <= 0.001) continue;

      final radius =
          (minRadius + (maxRadius - minRadius) * bubble.size) * scale;

      // Idle drift: small unique-phase bob per bubble.
      final phase = idle * 2 * math.pi + i * 1.7;
      final dx = math.sin(phase) * 2.0;
      final dy = math.cos(phase * 0.8) * 2.5;

      final center = Offset(
        bubble.x * size.width + dx,
        (1 - bubble.y) * size.height + dy,
      );

      final color = bubble.color ?? colors[i % colors.length];
      canvas.drawCircle(
        center,
        radius,
        Paint()..color = color.withValues(alpha: 0.25),
      );
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      final label = bubble.label;
      if (label != null && radius > 14) {
        final painter = TextPainter(
          text: TextSpan(
            text: label,
            style: (labelStyle ?? const TextStyle(fontSize: 11))
                .copyWith(color: labelColor),
          ),
          textDirection: TextDirection.ltr,
          maxLines: 1,
          ellipsis: '…',
        )..layout(maxWidth: radius * 2 - 6);
        if (painter.width <= radius * 2 - 4) {
          painter.paint(
            canvas,
            center - Offset(painter.width / 2, painter.height / 2),
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_BubblePainter oldDelegate) =>
      oldDelegate.enter != enter ||
      oldDelegate.idle != idle ||
      oldDelegate.bubbles != bubbles;
}
