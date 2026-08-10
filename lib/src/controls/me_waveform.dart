import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// An audio waveform seek bar in the Material 3 Expressive style.
///
/// Renders [samples] as rounded bars. Bars left of the playhead use the
/// primary color; bars right of it use the surface container color. Drag
/// or tap to seek — the playhead follows with a spring, bars near the
/// touch point stretch taller while dragging (a squash-and-stretch
/// effect), and detents tick with a light haptic every 10%.
class MEWaveform extends StatefulWidget {
  const MEWaveform({
    super.key,
    required this.samples,
    required this.progress,
    this.onChanged,
    this.onChangeEnd,
    this.height = 56,
    this.barWidth = 3,
    this.barGap = 2,
    this.color,
    this.trackColor,
  });

  /// Normalized amplitudes (0.0 to 1.0). Typically 40-100 values.
  final List<double> samples;

  /// Playback progress from 0.0 to 1.0.
  final double progress;

  /// Called continuously while the user drags or taps.
  final ValueChanged<double>? onChanged;

  /// Called when the user lifts their finger.
  final ValueChanged<double>? onChangeEnd;

  final double height;
  final double barWidth;
  final double barGap;

  /// Played-portion color. Defaults to the scheme primary.
  final Color? color;

  /// Unplayed-portion color. Defaults to surfaceContainerHighest.
  final Color? trackColor;

  @override
  State<MEWaveform> createState() => _MEWaveformState();
}

class _MEWaveformState extends State<MEWaveform> with TickerProviderStateMixin {
  late final AnimationController _playhead = AnimationController.unbounded(
    vsync: this,
    value: widget.progress.clamp(0.0, 1.0),
  );

  /// 0 -> at rest, 1 -> actively dragging (drives the stretch effect).
  late final AnimationController _drag =
      AnimationController.unbounded(vsync: this, value: 0);

  bool _dragging = false;
  double _touchX = 0;
  int _lastDetent = -1;

  @override
  void didUpdateWidget(MEWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_dragging && widget.progress != oldWidget.progress) {
      springTo(
        _playhead,
        widget.progress.clamp(0.0, 1.0),
        METheme.of(context).motion.defaultSpatial,
      );
    }
  }

  @override
  void dispose() {
    _playhead.dispose();
    _drag.dispose();
    super.dispose();
  }

  void _seekTo(double dx, double width, {required bool end}) {
    final value = (dx / width).clamp(0.0, 1.0);
    _touchX = dx;
    _playhead.value = value;

    final detent = (value * 10).floor();
    if (detent != _lastDetent) {
      _lastDetent = detent;
      HapticFeedback.selectionClick();
    }

    widget.onChanged?.call(value);
    if (end) widget.onChangeEnd?.call(value);
  }

  void _setDragging(bool dragging) {
    if (_dragging == dragging) return;
    _dragging = dragging;
    final motion = METheme.of(context).motion;
    springTo(_drag, dragging ? 1 : 0,
        dragging ? motion.fastSpatial : motion.defaultSpatial);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final played = widget.color ?? scheme.primary;
    final track = widget.trackColor ?? scheme.surfaceContainerHighest;

    return Semantics(
      slider: true,
      value: '${(widget.progress * 100).round()}%',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) {
              _setDragging(true);
              _seekTo(d.localPosition.dx, width, end: false);
            },
            onTapUp: (d) {
              _seekTo(d.localPosition.dx, width, end: true);
              _setDragging(false);
            },
            onHorizontalDragStart: (d) {
              _setDragging(true);
              _seekTo(d.localPosition.dx, width, end: false);
            },
            onHorizontalDragUpdate: (d) =>
                _seekTo(d.localPosition.dx, width, end: false),
            onHorizontalDragEnd: (_) {
              _setDragging(false);
              widget.onChangeEnd?.call(_playhead.value.clamp(0.0, 1.0));
            },
            child: SizedBox(
              height: widget.height,
              child: AnimatedBuilder(
                animation: Listenable.merge([_playhead, _drag]),
                builder: (context, _) {
                  return CustomPaint(
                    size: Size(width, widget.height),
                    painter: _WaveformPainter(
                      samples: widget.samples,
                      progress: _playhead.value.clamp(0.0, 1.0),
                      dragT: _drag.value.clamp(0.0, 1.2),
                      touchX: _touchX,
                      playedColor: played,
                      trackColor: track,
                      barWidth: widget.barWidth,
                      barGap: widget.barGap,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  _WaveformPainter({
    required this.samples,
    required this.progress,
    required this.dragT,
    required this.touchX,
    required this.playedColor,
    required this.trackColor,
    required this.barWidth,
    required this.barGap,
  });

  final List<double> samples;
  final double progress;
  final double dragT;
  final double touchX;
  final Color playedColor;
  final Color trackColor;
  final double barWidth;
  final double barGap;

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.isEmpty) return;
    final slot = barWidth + barGap;
    final barCount = (size.width / slot).floor().clamp(1, 10000);
    final playheadX = progress * size.width;

    for (var i = 0; i < barCount; i++) {
      final x = i * slot + barWidth / 2;
      // Resample the amplitude list onto the bar count.
      final sample = samples[
          (i * samples.length ~/ barCount).clamp(0, samples.length - 1)];

      // Stretch bars near the touch point while dragging.
      double stretch = 1.0;
      if (dragT > 0) {
        final dist = (x - touchX).abs();
        const influence = 48.0;
        if (dist < influence) {
          stretch = 1.0 + (1.0 - dist / influence) * 0.45 * dragT;
        }
      }

      final h = (sample.clamp(0.05, 1.0)) *
          (size.height - 8) *
          stretch.clamp(1.0, 1.6);
      final paint = Paint()
        ..color = x <= playheadX ? playedColor : trackColor
        ..strokeWidth = barWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(x, size.height / 2 - h / 2),
        Offset(x, size.height / 2 + h / 2),
        paint,
      );
    }

    // Playhead knob.
    final knob = Paint()..color = playedColor;
    canvas.drawCircle(
      Offset(playheadX, size.height / 2),
      4 + 2 * dragT.clamp(0.0, 1.0),
      knob,
    );
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.dragT != dragT ||
      oldDelegate.touchX != touchX ||
      oldDelegate.samples != samples;
}
