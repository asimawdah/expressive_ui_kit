import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;
import 'package:flutter/services.dart';

import '../theme/me_motion.dart';
import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';

/// A metronome with a swinging pendulum, tempo control and haptic ticks.
///
/// The pendulum arm swings on a sinusoidal cycle whose period follows the
/// current BPM. Each extreme of the swing emits a haptic tick and pulses a
/// beat dot. Tempo changes are spring-animated, and the play/stop control
/// morphs between a circle and a rounded square (the M3E state signal).
class MEMetronome extends StatefulWidget {
  const MEMetronome({
    super.key,
    this.bpm = 100,
    this.minBpm = 40,
    this.maxBpm = 220,
    this.beatsPerBar = 4,
    this.size = 200,
    this.onBeat,
    this.onBpmChanged,
  })  : assert(minBpm > 0),
        assert(maxBpm > minBpm),
        assert(beatsPerBar > 0);

  /// Initial tempo in beats per minute.
  final double bpm;

  final double minBpm;
  final double maxBpm;

  /// Beats per bar. The first beat of each bar gets a heavier haptic and a
  /// stronger dot pulse.
  final int beatsPerBar;

  /// Height of the metronome body.
  final double size;

  /// Called on every beat with the beat index within the bar (0-based).
  final ValueChanged<int>? onBeat;

  /// Called when the user changes the tempo with the +/- controls.
  final ValueChanged<double>? onBpmChanged;

  @override
  State<MEMetronome> createState() => _MEMetronomeState();
}

class _MEMetronomeState extends State<MEMetronome>
    with TickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_onTick);

  /// Continuous phase in beats. The pendulum is at an extreme on every
  /// integer value; fractional part drives the swing angle.
  double _phase = 0;
  Duration _lastElapsed = Duration.zero;

  late double _bpm = widget.bpm.clamp(widget.minBpm, widget.maxBpm);
  bool _running = false;
  int _beatIndex = -1;

  // Springs the beat dot pulse: kicked to 1 on each beat, decays to 0.
  late final AnimationController _pulse = AnimationController.unbounded(
    vsync: this,
    value: 0,
  );

  // 0 = stopped (circle), 1 = running (rounded square).
  late final AnimationController _shape = AnimationController.unbounded(
    vsync: this,
    value: 0,
  );

  @override
  void dispose() {
    _ticker.dispose();
    _pulse.dispose();
    _shape.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _lastElapsed).inMicroseconds / 1e6;
    _lastElapsed = elapsed;
    final prevPhase = _phase;
    _phase += dt * (_bpm / 60.0);

    // Beat fires each time the phase crosses an integer.
    if (prevPhase.floor() != _phase.floor()) {
      _beatIndex = (_beatIndex + 1) % widget.beatsPerBar;
      final bool downbeat = _beatIndex == 0;
      if (downbeat) {
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.selectionClick();
      }
      final motion = METheme.of(context).motion;
      _pulse.value = downbeat ? 1.4 : 1.0;
      springTo(_pulse, 0, motion.defaultEffects);
      widget.onBeat?.call(_beatIndex);
    }
    setState(() {});
  }

  void _toggleRunning() {
    final motion = METheme.of(context).motion;
    setState(() {
      _running = !_running;
      if (_running) {
        _lastElapsed = Duration.zero;
        _beatIndex = -1;
        // Start just before the first beat so it fires immediately.
        _phase = -0.02;
        _ticker.start();
      } else {
        _ticker.stop();
      }
    });
    springTo(_shape, _running ? 1 : 0, motion.defaultSpatial);
  }

  void _nudgeBpm(double delta) {
    setState(() {
      _bpm = (_bpm + delta).clamp(widget.minBpm, widget.maxBpm);
    });
    HapticFeedback.selectionClick();
    widget.onBpmChanged?.call(_bpm);
  }

  /// Current pendulum angle in radians. At rest it hangs centered; while
  /// running it swings sinusoidally, hitting extremes on each beat.
  double get _angle {
    if (!_running) return 0;
    const double maxAngle = 0.42; // ~24 degrees each way.
    return maxAngle * math.sin(math.pi * _phase);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final double bodyWidth = widget.size * 0.72;

    return Semantics(
      label: 'Metronome, ${_bpm.round()} beats per minute, '
          '${_running ? 'running' : 'stopped'}',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ----- Pendulum body -----
          SizedBox(
            width: bodyWidth,
            height: widget.size,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Trapezoid body.
                CustomPaint(
                  size: Size(bodyWidth, widget.size),
                  painter: _MEMetronomeBodyPainter(
                    color: scheme.surfaceContainerHighest,
                    outline: scheme.outlineVariant,
                  ),
                ),
                // Pendulum arm, pivoting at the bottom center.
                AnimatedBuilder(
                  animation: _pulse,
                  builder: (context, _) {
                    return Transform.rotate(
                      angle: _angle,
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Bob.
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: scheme.primary,
                            ),
                          ),
                          Container(
                            width: 4,
                            height: widget.size * 0.62,
                            decoration: BoxDecoration(
                              color: scheme.onSurfaceVariant,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                // Beat dot at the base, pulsing on each beat.
                Positioned(
                  bottom: 10,
                  child: AnimatedBuilder(
                    animation: _pulse,
                    builder: (context, _) {
                      final double p = _pulse.value.clamp(0.0, 1.5);
                      return Container(
                        width: 12 + 10 * p,
                        height: 12 + 10 * p,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.lerp(
                            scheme.primary,
                            scheme.tertiary,
                            (p / 1.4).clamp(0.0, 1.0),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // ----- Tempo + transport controls -----
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _MEBpmButton(
                icon: Icons.remove,
                semanticLabel: 'Slower',
                onPressed: _bpm > widget.minBpm ? () => _nudgeBpm(-4) : null,
              ),
              const SizedBox(width: 12),
              // Play / stop: morphs circle <-> rounded square.
              AnimatedBuilder(
                animation: _shape,
                builder: (context, _) {
                  final double t = _shape.value.clamp(0.0, 1.0);
                  final double radius = 28 - 16 * t;
                  return Material(
                    color: scheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(radius),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: _toggleRunning,
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: Icon(
                          _running ? Icons.stop : Icons.play_arrow,
                          color: scheme.onPrimary,
                          size: 28,
                          semanticLabel: _running ? 'Stop' : 'Start',
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              _MEBpmButton(
                icon: Icons.add,
                semanticLabel: 'Faster',
                onPressed: _bpm < widget.maxBpm ? () => _nudgeBpm(4) : null,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${_bpm.round()} BPM',
            style: textTheme.titleMedium?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _MEBpmButton extends StatelessWidget {
  const _MEBpmButton({
    required this.icon,
    required this.semanticLabel,
    this.onPressed,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: onPressed == null
          ? scheme.surfaceContainerHigh
          : scheme.secondaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MECorners.large),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            size: 20,
            color: onPressed == null
                ? scheme.onSurface.withValues(alpha: 0.38)
                : scheme.onSecondaryContainer,
            semanticLabel: semanticLabel,
          ),
        ),
      ),
    );
  }
}

class _MEMetronomeBodyPainter extends CustomPainter {
  const _MEMetronomeBodyPainter({required this.color, required this.outline});

  final Color color;
  final Color outline;

  @override
  void paint(Canvas canvas, Size size) {
    // Rounded trapezoid: narrow at the top, wide at the base.
    final double topInset = size.width * 0.28;
    final path = Path()
      ..moveTo(topInset, 0)
      ..lineTo(size.width - topInset, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      path,
      Paint()..color = color,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_MEMetronomeBodyPainter oldDelegate) =>
      color != oldDelegate.color || outline != oldDelegate.outline;
}
