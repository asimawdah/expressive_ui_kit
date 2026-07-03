import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/me_shapes.dart';
import 'me_number_ticker.dart';

/// An expressive stopwatch with rolling digits and spring-morphing
/// start/stop controls.
///
/// Minutes and seconds roll on [MENumberTicker] cells; centiseconds render
/// as plain tabular text (they change too fast to animate meaningfully).
/// The primary control morphs between a circle (running: stop glyph) and a
/// rounded square (paused: play glyph) — the M3 Expressive shape signal.
///
/// The widget owns its timer. Use [onLap] to receive lap timestamps.
///
/// ```dart
/// MEStopwatch(onLap: (elapsed) => laps.add(elapsed))
/// ```
class MEStopwatch extends StatefulWidget {
  const MEStopwatch({
    super.key,
    this.onLap,
    this.digitStyle,
  });

  /// Called with the current elapsed time when the lap button is pressed
  /// while running.
  final ValueChanged<Duration>? onLap;

  /// Style for the rolling digits. Defaults to `displaySmall` with
  /// tabular figures.
  final TextStyle? digitStyle;

  @override
  State<MEStopwatch> createState() => _MEStopwatchState();
}

class _MEStopwatchState extends State<MEStopwatch> {
  final Stopwatch _watch = Stopwatch();
  Timer? _ticker;

  bool get _running => _watch.isRunning;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.mediumImpact();
    setState(() {
      if (_running) {
        _watch.stop();
        _ticker?.cancel();
        _ticker = null;
      } else {
        _watch.start();
        // ~30fps is plenty for a centisecond readout.
        _ticker = Timer.periodic(
          const Duration(milliseconds: 33),
          (_) => setState(() {}),
        );
      }
    });
  }

  void _reset() {
    HapticFeedback.lightImpact();
    setState(() => _watch.reset());
  }

  void _lap() {
    HapticFeedback.selectionClick();
    widget.onLap?.call(_watch.elapsed);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final elapsed = _watch.elapsed;
    final minutes = elapsed.inMinutes;
    final seconds = elapsed.inSeconds % 60;
    final centis = (elapsed.inMilliseconds % 1000) ~/ 10;

    final digitStyle = (widget.digitStyle ??
            Theme.of(context).textTheme.displaySmall!)
        .copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
    final centiStyle = digitStyle.copyWith(
      fontSize: (digitStyle.fontSize ?? 36) * 0.55,
      color: scheme.onSurfaceVariant,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            MENumberTicker(
              value: minutes,
              padWidth: 2,
              style: digitStyle,
            ),
            Text(':', style: digitStyle),
            MENumberTicker(
              value: seconds,
              padWidth: 2,
              style: digitStyle,
            ),
            const SizedBox(width: 4),
            SizedBox(
              // Fixed slot so the fast centisecond digits don't jitter.
              width: (centiStyle.fontSize ?? 20) * 1.4,
              child: Text(
                centis.toString().padLeft(2, '0'),
                style: centiStyle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Reset — only enabled when stopped with elapsed time.
            _RoundAction(
              icon: Icons.refresh,
              tooltip: 'Reset',
              enabled: !_running && elapsed > Duration.zero,
              onPressed: _reset,
            ),
            const SizedBox(width: 16),
            // Primary start/stop: circle while running, rounded square
            // while paused.
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutBack,
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _running ? scheme.errorContainer : scheme.primary,
                borderRadius: BorderRadius.circular(
                  _running ? 36 : MECorners.largeIncreased,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(
                    _running ? 36 : MECorners.largeIncreased,
                  ),
                  onTap: _toggle,
                  child: Icon(
                    _running ? Icons.stop : Icons.play_arrow,
                    size: 32,
                    color:
                        _running ? scheme.onErrorContainer : scheme.onPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            _RoundAction(
              icon: Icons.flag_outlined,
              tooltip: 'Lap',
              enabled: _running,
              onPressed: _lap,
            ),
          ],
        ),
      ],
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.tooltip,
    required this.enabled,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: scheme.surfaceContainerHigh,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: enabled ? onPressed : null,
          child: SizedBox(
            width: 52,
            height: 52,
            child: Icon(
              icon,
              size: 22,
              color: enabled
                  ? scheme.onSurface
                  : scheme.onSurface.withValues(alpha: 0.35),
            ),
          ),
        ),
      ),
    );
  }
}
