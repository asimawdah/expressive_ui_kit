import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Programmatically launches fireworks on an [MEFireworks] display.
class MEFireworksController {
  _MEFireworksState? _state;

  /// Launches a single firework at a random position.
  void launch() => _state?._launch();

  /// Launches a celebratory volley of [count] fireworks.
  void celebrate({int count = 5}) => _state?._celebrate(count);
}

/// A fireworks celebration canvas.
///
/// Each firework launches a rocket that arcs upward, then bursts into a
/// ring of sparks that fly outward with drag and gravity, twinkling as
/// they fade. Colors cycle through the scheme's primary, tertiary and
/// secondary. Tap anywhere on the canvas to launch one at that spot, or
/// drive it with an [MEFireworksController].
class MEFireworks extends StatefulWidget {
  const MEFireworks({
    super.key,
    this.controller,
    this.height = 240,
    this.autoPlay = false,
    this.haptics = true,
    this.semanticLabel,
  });

  final MEFireworksController? controller;
  final double height;

  /// Launches fireworks continuously while visible.
  final bool autoPlay;

  /// Emit a light haptic on each burst.
  final bool haptics;

  final String? semanticLabel;

  @override
  State<MEFireworks> createState() => _MEFireworksState();
}

class _Spark {
  _Spark({
    required this.angle,
    required this.speed,
    required this.color,
    required this.twinklePhase,
  });

  final double angle;
  final double speed;
  final Color color;
  final double twinklePhase;
}

class _Firework {
  _Firework({
    required this.origin,
    required this.target,
    required this.startTime,
    required this.color,
    required this.sparks,
  });

  /// Launch pad position (fraction of size).
  final Offset origin;

  /// Burst position (fraction of size).
  final Offset target;

  /// Seconds (in animation clock) when this firework launched.
  final double startTime;

  final Color color;
  final List<_Spark> sparks;

  static const double flightDuration = 0.7;
  static const double burstDuration = 1.6;

  bool exploded(double now) => now - startTime >= flightDuration;
  bool done(double now) =>
      now - startTime >= flightDuration + burstDuration;
}

class _MEFireworksState extends State<MEFireworks>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock;
  final List<_Firework> _fireworks = [];
  final math.Random _random = math.Random();
  final Set<_Firework> _hapticFired = {};
  double _lastAutoLaunch = 0;

  double get _now => _clock.value * _clockSpan;
  static const double _clockSpan = 3600; // seconds per controller cycle

  @override
  void initState() {
    super.initState();
    _clock = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3600),
    );
    widget.controller?._state = this;
    if (widget.autoPlay) {
      _clock.repeat();
    }
  }

  @override
  void didUpdateWidget(MEFireworks oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._state = null;
      widget.controller?._state = this;
    }
    if (widget.autoPlay && !_clock.isAnimating) {
      _clock.repeat();
    }
  }

  @override
  void dispose() {
    widget.controller?._state = null;
    _clock.dispose();
    super.dispose();
  }

  void _ensureRunning() {
    if (!_clock.isAnimating) _clock.repeat();
  }

  void _launch({Offset? at}) {
    _ensureRunning();
    final colorIndex = _random.nextInt(3);
    final scheme = Theme.of(context).colorScheme;
    final color = [scheme.primary, scheme.tertiary, scheme.secondary][colorIndex];

    final target = at ??
        Offset(
          0.15 + _random.nextDouble() * 0.7,
          0.15 + _random.nextDouble() * 0.35,
        );
    final sparkCount = 14 + _random.nextInt(8);
    final sparks = List.generate(sparkCount, (i) {
      return _Spark(
        angle: i / sparkCount * 2 * math.pi + _random.nextDouble() * 0.3,
        speed: 0.6 + _random.nextDouble() * 0.5,
        color: color,
        twinklePhase: _random.nextDouble() * 2 * math.pi,
      );
    });

    setState(() {
      _fireworks.add(_Firework(
        origin: Offset(target.dx, 1.05),
        target: target,
        startTime: _now,
        color: color,
        sparks: sparks,
      ));
    });
  }

  void _celebrate(int count) {
    for (var i = 0; i < count; i++) {
      Future.delayed(Duration(milliseconds: i * 240), () {
        if (mounted) _launch();
      });
    }
  }

  void _tick() {
    final now = _now;
    // Cleanup finished fireworks.
    _fireworks.removeWhere((f) {
      final finished = f.done(now);
      if (finished) _hapticFired.remove(f);
      return finished;
    });
    // Haptic at burst moment.
    if (widget.haptics) {
      for (final f in _fireworks) {
        if (f.exploded(now) && !_hapticFired.contains(f)) {
          _hapticFired.add(f);
          HapticFeedback.lightImpact();
        }
      }
    }
    // Auto play launches on an interval.
    if (widget.autoPlay && now - _lastAutoLaunch > 0.9) {
      _lastAutoLaunch = now;
      _launch();
    }
    // Idle the clock when nothing is active.
    if (!widget.autoPlay && _fireworks.isEmpty && _clock.isAnimating) {
      _clock.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: widget.semanticLabel ?? 'Fireworks display',
      child: GestureDetector(
        onTapDown: (details) {
          final box = context.findRenderObject() as RenderBox?;
          if (box == null) return;
          final local = box.globalToLocal(details.globalPosition);
          _launch(
            at: Offset(
              (local.dx / box.size.width).clamp(0.05, 0.95),
              (local.dy / box.size.height).clamp(0.05, 0.9),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: widget.height,
            width: double.infinity,
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
            child: AnimatedBuilder(
              animation: _clock,
              builder: (context, _) {
                _tick();
                return CustomPaint(
                  painter: _FireworksPainter(
                    fireworks: List.of(_fireworks),
                    now: _now,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _FireworksPainter extends CustomPainter {
  _FireworksPainter({required this.fireworks, required this.now});

  final List<_Firework> fireworks;
  final double now;

  @override
  void paint(Canvas canvas, Size size) {
    for (final f in fireworks) {
      final elapsed = now - f.startTime;
      if (elapsed < _Firework.flightDuration) {
        _paintRocket(canvas, size, f, elapsed / _Firework.flightDuration);
      } else {
        _paintBurst(
          canvas,
          size,
          f,
          (elapsed - _Firework.flightDuration) / _Firework.burstDuration,
        );
      }
    }
  }

  void _paintRocket(Canvas canvas, Size size, _Firework f, double t) {
    // Ease-out flight with a slight horizontal sway.
    final eased = 1 - (1 - t) * (1 - t);
    final x = (f.origin.dx +
            (f.target.dx - f.origin.dx) * eased +
            math.sin(t * math.pi * 3) * 0.01) *
        size.width;
    final y =
        (f.origin.dy + (f.target.dy - f.origin.dy) * eased) * size.height;

    final paint = Paint()..color = f.color;
    canvas.drawCircle(Offset(x, y), 2.5, paint);
    // Trail.
    for (var i = 1; i <= 3; i++) {
      final trailT = (t - i * 0.05).clamp(0.0, 1.0);
      final trailEased = 1 - (1 - trailT) * (1 - trailT);
      final tx = (f.origin.dx + (f.target.dx - f.origin.dx) * trailEased) *
          size.width;
      final ty = (f.origin.dy + (f.target.dy - f.origin.dy) * trailEased) *
          size.height;
      canvas.drawCircle(
        Offset(tx, ty),
        2.0 - i * 0.5,
        Paint()..color = f.color.withValues(alpha: 0.5 - i * 0.15),
      );
    }
  }

  void _paintBurst(Canvas canvas, Size size, _Firework f, double t) {
    if (t >= 1) return;
    final center = Offset(
      f.target.dx * size.width,
      f.target.dy * size.height,
    );
    final fade = (1 - t).clamp(0.0, 1.0);
    final radiusBase = size.shortestSide * 0.28;

    for (final spark in f.sparks) {
      // Drag: distance grows fast then decelerates.
      final distance = radiusBase * spark.speed * (1 - math.pow(1 - t, 2.2));
      // Gravity droop.
      final droop = 30.0 * t * t;
      final pos = center +
          Offset(
            math.cos(spark.angle) * distance,
            math.sin(spark.angle) * distance + droop,
          );
      // Twinkle: alpha oscillates as it fades.
      final twinkle =
          0.6 + 0.4 * math.sin(t * 14 + spark.twinklePhase);
      canvas.drawCircle(
        pos,
        2.2 * fade + 0.4,
        Paint()..color = spark.color.withValues(alpha: fade * twinkle),
      );
    }
  }

  @override
  bool shouldRepaint(_FireworksPainter oldDelegate) => true;
}
