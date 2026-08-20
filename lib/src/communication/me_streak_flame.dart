import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// A habit-streak flame with a live flicker and a popping day counter.
///
/// While [active], the flame sways and flickers organically (driven by
/// layered sine waves) in warm scheme colors. When the streak is broken
/// ([active] = false) the flame freezes and grays out. Incrementing
/// [count] pops the number in with the fast spatial spring.
///
/// ```dart
/// MEStreakFlame(count: 12, active: true)
/// ```
class MEStreakFlame extends StatefulWidget {
  const MEStreakFlame({
    super.key,
    required this.count,
    this.active = true,
    this.size = 44,
    this.semanticLabel,
  });

  /// Current streak length, shown beside the flame.
  final int count;

  /// Whether the streak is alive. Inactive flames freeze and gray out.
  final bool active;

  /// Height of the flame glyph.
  final double size;

  final String? semanticLabel;

  @override
  State<MEStreakFlame> createState() => _MEStreakFlameState();
}

class _MEStreakFlameState extends State<MEStreakFlame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _time = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  );

  @override
  void initState() {
    super.initState();
    if (widget.active) _time.repeat();
  }

  @override
  void didUpdateWidget(MEStreakFlame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active != oldWidget.active) {
      if (widget.active) {
        _time.repeat();
      } else {
        _time.stop();
      }
    }
  }

  @override
  void dispose() {
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final spec = METheme.of(context).motion.fastSpatial;
    final Color outer;
    final Color inner;
    if (widget.active) {
      outer = scheme.error;
      inner = scheme.tertiaryContainer;
    } else {
      outer = scheme.onSurface.withValues(alpha: 0.24);
      inner = scheme.onSurface.withValues(alpha: 0.12);
    }
    final countStyle = METypography.emphasize(
      Theme.of(context).textTheme.titleLarge!,
    ).copyWith(
      color: widget.active ? scheme.onSurface : scheme.onSurfaceVariant,
    );

    return Semantics(
      label: widget.semanticLabel ??
          '${widget.count} day streak, '
              '${widget.active ? 'active' : 'broken'}',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomPaint(
            size: Size(widget.size * 0.8, widget.size),
            painter: _FlamePainter(
              time: _time,
              active: widget.active,
              outer: outer,
              inner: inner,
            ),
          ),
          const SizedBox(width: 6),
          // Keyed so a count change re-runs the pop-in tween.
          MEMotionBuilder(
            key: ValueKey<int>(widget.count),
            value: 1,
            from: 0,
            spec: spec,
            builder: (context, v, child) {
              return Transform.scale(
                scale: 0.6 + 0.4 * v,
                child: child,
              );
            },
            child: Text('${widget.count}', style: countStyle),
          ),
        ],
      ),
    );
  }
}

class _FlamePainter extends CustomPainter {
  _FlamePainter({
    required this.time,
    required this.active,
    required this.outer,
    required this.inner,
  }) : super(repaint: time);

  final Animation<double> time;
  final bool active;
  final Color outer;
  final Color inner;

  @override
  void paint(Canvas canvas, Size size) {
    final t = time.value * 2 * math.pi;
    final w = size.width;
    final h = size.height;
    // Layered sines give a non-mechanical flicker.
    final sway = active ? (math.sin(3 * t) + 0.5 * math.sin(7 * t + 1.3)) : 0.0;
    final flick = active
        ? 1.0 + 0.05 * math.sin(5 * t + 0.7) + 0.03 * math.sin(11 * t)
        : 1.0;

    Path flame(double s, double swayBias) {
      final tipX = w / 2 + sway * w * 0.06 * swayBias;
      final tipY = h - h * 0.95 * s * flick;
      final baseY = h - h * 0.24 * s;
      return Path()
        ..moveTo(w / 2 - w * 0.34 * s, baseY)
        ..quadraticBezierTo(w / 2 - w * 0.44 * s, h - h * 0.6 * s, tipX, tipY)
        ..quadraticBezierTo(
            w / 2 + w * 0.44 * s, h - h * 0.6 * s, w / 2 + w * 0.34 * s, baseY)
        ..quadraticBezierTo(w / 2 + w * 0.42 * s, h, w / 2, h)
        ..quadraticBezierTo(
            w / 2 - w * 0.42 * s, h, w / 2 - w * 0.34 * s, baseY)
        ..close();
    }

    canvas.drawPath(flame(1.0, 1.0), Paint()..color = outer);
    canvas.drawPath(flame(0.55, 1.6), Paint()..color = inner);
  }

  @override
  bool shouldRepaint(_FlamePainter oldDelegate) =>
      oldDelegate.active != active ||
      oldDelegate.outer != outer ||
      oldDelegate.inner != inner;
}
