import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// A pomodoro focus timer: a circular progress dial that drains over the
/// focus session, then flips to a break session in the tertiary color.
///
/// The dial ring drains smoothly, the remaining time renders in tabular
/// figures, and the play/pause control morphs between circle and rounded
/// square with the theme's spatial spring. Session transitions emit a
/// haptic and fire [onSessionEnd].
///
/// ```dart
/// MEPomodoro(
///   focusDuration: Duration(minutes: 25),
///   breakDuration: Duration(minutes: 5),
///   onSessionEnd: (wasFocus) => log(wasFocus),
/// )
/// ```
class MEPomodoro extends StatefulWidget {
  const MEPomodoro({
    super.key,
    this.focusDuration = const Duration(minutes: 25),
    this.breakDuration = const Duration(minutes: 5),
    this.size = 220,
    this.onSessionEnd,
    this.autoStartBreak = true,
  });

  /// Length of a focus session.
  final Duration focusDuration;

  /// Length of the break that follows.
  final Duration breakDuration;

  /// Diameter of the dial.
  final double size;

  /// Called when a session completes. The argument is true if the session
  /// that just ended was a focus session.
  final ValueChanged<bool>? onSessionEnd;

  /// Automatically start the break when focus completes (and vice versa).
  final bool autoStartBreak;

  @override
  State<MEPomodoro> createState() => _MEPomodoroState();
}

class _MEPomodoroState extends State<MEPomodoro> with TickerProviderStateMixin {
  late final AnimationController _session = AnimationController(
    vsync: this,
    duration: widget.focusDuration,
  );

  /// Play/pause morph: 0 = paused (play icon, circle), 1 = running.
  late final AnimationController _play = AnimationController.unbounded(
    vsync: this,
    value: 0,
  );

  bool _isFocus = true;

  @override
  void initState() {
    super.initState();
    _session.addStatusListener(_onSessionStatus);
    _session.addListener(() => setState(() {}));
  }

  void _onSessionStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    HapticFeedback.heavyImpact();
    widget.onSessionEnd?.call(_isFocus);
    setState(() {
      _isFocus = !_isFocus;
      _session.duration =
          _isFocus ? widget.focusDuration : widget.breakDuration;
      _session.value = 0;
    });
    if (widget.autoStartBreak) {
      _session.forward();
    } else {
      springTo(_play, 0, METheme.of(context).motion.defaultSpatial);
    }
  }

  void _toggle() {
    final motion = METheme.of(context).motion;
    if (_session.isAnimating) {
      _session.stop();
      springTo(_play, 0, motion.defaultSpatial);
    } else {
      _session.forward();
      springTo(_play, 1, motion.defaultSpatial);
    }
    HapticFeedback.selectionClick();
    setState(() {});
  }

  void _reset() {
    _session.stop();
    setState(() {
      _isFocus = true;
      _session.duration = widget.focusDuration;
      _session.value = 0;
    });
    springTo(_play, 0, METheme.of(context).motion.defaultSpatial);
    HapticFeedback.selectionClick();
  }

  @override
  void dispose() {
    _session.dispose();
    _play.dispose();
    super.dispose();
  }

  Duration get _remaining {
    final total = _isFocus ? widget.focusDuration : widget.breakDuration;
    return total * (1.0 - _session.value);
  }

  String _format(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final Color active = _isFocus ? scheme.primary : scheme.tertiary;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label:
          '${_isFocus ? 'Focus' : 'Break'} timer, ${_format(_remaining)} remaining',
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _PomodoroPainter(
                  progress: _session.value,
                  color: active,
                  track: scheme.surfaceContainerHighest,
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: METheme.of(context)
                      .motion
                      .defaultEffects
                      .approximateDuration,
                  switchInCurve:
                      METheme.of(context).motion.defaultEffects.curve,
                  switchOutCurve: METheme.of(context).motion.fastEffects.curve,
                  child: Text(
                    _isFocus ? 'Focus' : 'Break',
                    key: ValueKey(_isFocus),
                    style: textTheme.labelLarge!.copyWith(color: active),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _format(_remaining),
                  style: textTheme.displaySmall!.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _play,
                      builder: (context, _) {
                        final double t = _play.value.clamp(0.0, 1.0);
                        return Material(
                          color: active,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              // Circle when paused -> rounded square running.
                              24 - 10 * t,
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24 - 10 * t),
                            onTap: _toggle,
                            child: SizedBox(
                              width: 48,
                              height: 48,
                              child: Icon(
                                _session.isAnimating
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: _isFocus
                                    ? scheme.onPrimary
                                    : scheme.onTertiary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _reset,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Reset',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PomodoroPainter extends CustomPainter {
  _PomodoroPainter({
    required this.progress,
    required this.color,
    required this.track,
  });

  final double progress;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 8;
    const stroke = 10.0;

    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // Remaining arc drains clockwise from the top.
    final remaining = 1.0 - progress;
    if (remaining <= 0) return;
    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * remaining,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_PomodoroPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.track != track;
}
