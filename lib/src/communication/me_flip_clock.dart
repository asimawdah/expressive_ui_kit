import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/me_motion.dart';
import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';

/// A split-flap style clock display with Material 3 Expressive motion.
///
/// Each digit lives on a tonal card split horizontally. When a digit
/// changes, the top half folds down over the bottom half in 3D
/// perspective — the fold is driven by the theme's spatial spring, so it
/// lands with a slight bounce like a mechanical flap.
///
/// By default shows the current time (HH:MM:SS). Provide [value] to
/// display an arbitrary string of digits instead (e.g. a countdown or
/// score), in which case the widget stops ticking on its own.
class MEFlipClock extends StatefulWidget {
  const MEFlipClock({
    super.key,
    this.value,
    this.showSeconds = true,
    this.use24HourFormat = true,
    this.digitSize = 44,
    this.semanticLabel,
  });

  /// Digits (and optional `:` separators) to display. When null, the
  /// widget displays the current time and updates every second.
  final String? value;

  /// Whether to include seconds when displaying the current time.
  final bool showSeconds;

  /// Whether the self-ticking clock uses 24-hour format.
  final bool use24HourFormat;

  /// Height of each digit card. Width is derived from it.
  final double digitSize;

  final String? semanticLabel;

  @override
  State<MEFlipClock> createState() => _MEFlipClockState();
}

class _MEFlipClockState extends State<MEFlipClock> {
  Timer? _timer;
  late String _text = _resolveText();

  @override
  void initState() {
    super.initState();
    if (widget.value == null) _startTicking();
  }

  @override
  void didUpdateWidget(MEFlipClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value == null) {
        _startTicking();
      } else {
        _timer?.cancel();
        _timer = null;
      }
      setState(() => _text = _resolveText());
    }
  }

  void _startTicking() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _text = _resolveText());
    });
  }

  String _resolveText() {
    if (widget.value != null) return widget.value!;
    final now = DateTime.now();
    final hour = widget.use24HourFormat
        ? now.hour
        : (now.hour % 12 == 0 ? 12 : now.hour % 12);
    final parts = [
      hour.toString().padLeft(2, '0'),
      now.minute.toString().padLeft(2, '0'),
      if (widget.showSeconds) now.second.toString().padLeft(2, '0'),
    ];
    return parts.join(':');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: widget.semanticLabel ?? 'Clock showing $_text',
      liveRegion: widget.value == null,
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < _text.length; i++)
              if (_text[i] == ':')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    ':',
                    style: TextStyle(
                      fontSize: widget.digitSize * 0.6,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _FlipDigit(
                    digit: _text[i],
                    size: widget.digitSize,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _FlipDigit extends StatefulWidget {
  const _FlipDigit({required this.digit, required this.size});

  final String digit;
  final double size;

  @override
  State<_FlipDigit> createState() => _FlipDigitState();
}

class _FlipDigitState extends State<_FlipDigit>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flip = AnimationController.unbounded(
    vsync: this,
    value: 1,
  );
  late String _current = widget.digit;
  String _previous = '';

  @override
  void didUpdateWidget(_FlipDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.digit != _current) {
      _previous = _current;
      _current = widget.digit;
      _flip.value = 0;
      springTo(_flip, 1, METheme.of(context).motion.defaultSpatial);
    }
  }

  @override
  void dispose() {
    _flip.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final height = widget.size;
    final width = widget.size * 0.72;
    final style = TextStyle(
      fontSize: height * 0.62,
      fontWeight: FontWeight.w700,
      color: scheme.onSurface,
      fontFeatures: const [FontFeature.tabularFigures()],
      height: 1.0,
    );

    Widget halfCard({required String digit, required bool top}) {
      return ClipRect(
        child: Align(
          alignment: top ? Alignment.topCenter : Alignment.bottomCenter,
          heightFactor: 0.5,
          child: Container(
            width: width,
            height: height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(MECorners.small),
            ),
            child: Text(digit, style: style),
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _flip,
      builder: (context, _) {
        final t = _flip.value.clamp(0.0, 1.0);
        // First half of the motion folds the old top down to flat;
        // second half unfolds the new bottom into place.
        final foldingTop = t < 0.5;
        final angle = foldingTop
            ? (t / 0.5) * (math.pi / 2)
            : (1 - (t - 0.5) / 0.5) * (math.pi / 2);
        return SizedBox(
          width: width,
          height: height,
          child: Stack(
            children: [
              // Static halves: new top, old bottom (until second phase).
              Align(
                alignment: Alignment.topCenter,
                child: halfCard(digit: _current, top: true),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: halfCard(
                  digit: foldingTop ? _previous : _current,
                  top: false,
                ),
              ),
              // The folding flap, hinged at the horizontal center line.
              Align(
                alignment:
                    foldingTop ? Alignment.topCenter : Alignment.bottomCenter,
                child: Transform(
                  alignment:
                      foldingTop ? Alignment.bottomCenter : Alignment.topCenter,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.002)
                    ..rotateX(foldingTop ? -angle : angle),
                  child: halfCard(
                    digit: foldingTop ? _previous : _current,
                    top: foldingTop,
                  ),
                ),
              ),
              // Center hinge line.
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: width,
                  height: 1.5,
                  color: scheme.surface,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
