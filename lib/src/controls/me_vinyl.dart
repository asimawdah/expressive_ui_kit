import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// A spinning vinyl record with a tonearm, driven by [playing].
///
/// When [playing] becomes true the record spins up to speed with inertia
/// and the tonearm swings onto the groove; when false the record coasts
/// to a stop and the arm lifts away. Tapping the record toggles playback
/// (when [onChanged] is provided). Put album art in [label] — it is
/// clipped to the center label circle.
class MEVinyl extends StatefulWidget {
  const MEVinyl({
    super.key,
    this.playing = false,
    this.onChanged,
    this.size = 200,
    this.label,
  });

  /// Whether the record is spinning.
  final bool playing;

  /// Called with the toggled state when the record is tapped.
  final ValueChanged<bool>? onChanged;

  /// Diameter of the record.
  final double size;

  /// Optional center label content (album art, initials...).
  final Widget? label;

  @override
  State<MEVinyl> createState() => _MEVinylState();
}

class _MEVinylState extends State<MEVinyl>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  double _angle = 0; // record rotation, radians
  double _speed = 0; // radians/second
  double _arm = 0; // tonearm progress 0 (lifted) -> 1 (on groove)

  static const double _targetSpeed = 2 * math.pi * (33.3 / 60); // 33 RPM

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
  }

  void _tick(Duration now) {
    final dt = _last == Duration.zero
        ? 0.0
        : (now - _last).inMicroseconds / 1e6;
    _last = now;
    if (dt <= 0) return;

    final targetSpeed = widget.playing ? _targetSpeed : 0.0;
    final targetArm = widget.playing ? 1.0 : 0.0;

    // Inertia: the platter accelerates/decelerates smoothly.
    final speedLerp = 1 - math.exp(-dt * (widget.playing ? 2.5 : 1.2));
    _speed += (targetSpeed - _speed) * speedLerp;

    // Tonearm eases toward its target.
    final armLerp = 1 - math.exp(-dt * 4);
    _arm += (targetArm - _arm) * armLerp;

    final moving = _speed.abs() > 0.01 ||
        (targetArm - _arm).abs() > 0.001;
    if (moving) {
      setState(() => _angle = (_angle + _speed * dt) % (2 * math.pi));
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _toggle() {
    if (widget.onChanged == null) return;
    HapticFeedback.selectionClick();
    widget.onChanged!(!widget.playing);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final size = widget.size;
    final labelSize = size * 0.36;

    return Semantics(
      button: widget.onChanged != null,
      label: widget.playing ? 'Pause record' : 'Play record',
      child: GestureDetector(
        onTap: _toggle,
        child: SizedBox(
          width: size * 1.18,
          height: size,
          child: Stack(
            children: [
              // Record.
              Positioned(
                left: 0,
                top: 0,
                child: Transform.rotate(
                  angle: _angle,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scheme.inverseSurface,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Grooves.
                        CustomPaint(
                          size: Size(size, size),
                          painter: _GroovePainter(
                            color: scheme.onInverseSurface
                                .withValues(alpha: 0.12),
                          ),
                        ),
                        // Center label.
                        ClipOval(
                          child: Container(
                            width: labelSize,
                            height: labelSize,
                            color: scheme.primary,
                            alignment: Alignment.center,
                            child: widget.label == null
                                ? Icon(
                                    Icons.music_note,
                                    color: scheme.onPrimary,
                                    size: labelSize * 0.4,
                                  )
                                : DefaultTextStyle(
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(
                                            color: scheme.onPrimary),
                                    child: SizedBox(
                                      width: labelSize,
                                      height: labelSize,
                                      child: widget.label,
                                    ),
                                  ),
                          ),
                        ),
                        // Spindle.
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: scheme.onInverseSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Tonearm: pivots from the top right onto the groove.
              Positioned(
                right: 0,
                top: 0,
                child: Transform.rotate(
                  // Lifted rest position -> on-groove position.
                  angle: -0.5 + 0.62 * _arm,
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: 20,
                    height: size * 0.62,
                    child: Column(
                      children: [
                        // Pivot base.
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: scheme.surfaceContainerHighest,
                            border: Border.all(color: scheme.outline),
                          ),
                        ),
                        // Arm shaft.
                        Expanded(
                          child: Center(
                            child: Container(
                              width: 4,
                              decoration: BoxDecoration(
                                color: scheme.outline,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                        // Headshell.
                        Container(
                          width: 10,
                          height: 18,
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroovePainter extends CustomPainter {
  _GroovePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = color;
    // Concentric grooves between the label and the rim.
    final inner = size.width * 0.22;
    final outer = size.width * 0.47;
    for (double r = inner; r < outer; r += 5) {
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(_GroovePainter oldDelegate) =>
      oldDelegate.color != color;
}
