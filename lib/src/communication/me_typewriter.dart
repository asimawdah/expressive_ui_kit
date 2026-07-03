import 'dart:async';

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';

/// A text widget that reveals its content character by character, like a
/// typewriter, with a blinking block cursor.
///
/// Layout is reserved up-front (the full string is measured invisibly), so
/// surrounding content never reflows while typing. Supports looping through
/// multiple phrases with a backspace-erase transition between them.
///
/// ```dart
/// METypewriter(
///   phrases: const ['Build expressively.', 'Ship with springs.'],
///   style: Theme.of(context).textTheme.headlineSmall,
/// )
/// ```
class METypewriter extends StatefulWidget {
  const METypewriter({
    super.key,
    required this.phrases,
    this.style,
    this.typingInterval = const Duration(milliseconds: 55),
    this.erasingInterval = const Duration(milliseconds: 28),
    this.pause = const Duration(milliseconds: 1600),
    this.loop = true,
    this.showCursor = true,
  }) : assert(phrases.length > 0, 'phrases must not be empty');

  /// The phrases to type out, one after another.
  final List<String> phrases;

  final TextStyle? style;

  /// Delay between typed characters.
  final Duration typingInterval;

  /// Delay between erased characters.
  final Duration erasingInterval;

  /// How long a fully typed phrase stays on screen before erasing
  /// (ignored for the final phrase when [loop] is false).
  final Duration pause;

  /// Whether to cycle through [phrases] forever. When false, typing stops
  /// on the last phrase.
  final bool loop;

  /// Whether to render the blinking block cursor.
  final bool showCursor;

  @override
  State<METypewriter> createState() => _METypewriterState();
}

class _METypewriterState extends State<METypewriter>
    with SingleTickerProviderStateMixin {
  int _phrase = 0;
  int _chars = 0;
  bool _erasing = false;
  Timer? _timer;

  late final AnimationController _cursor = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat();

  @override
  void initState() {
    super.initState();
    _schedule(widget.typingInterval);
  }

  @override
  void didUpdateWidget(METypewriter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.phrases, widget.phrases)) {
      _timer?.cancel();
      _phrase = 0;
      _chars = 0;
      _erasing = false;
      _schedule(widget.typingInterval);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cursor.dispose();
    super.dispose();
  }

  void _schedule(Duration delay) {
    _timer = Timer(delay, _tick);
  }

  void _tick() {
    if (!mounted) return;
    final text = widget.phrases[_phrase];
    setState(() {
      if (_erasing) {
        _chars--;
        if (_chars <= 0) {
          _erasing = false;
          _phrase = (_phrase + 1) % widget.phrases.length;
        }
      } else {
        _chars++;
      }
    });

    final bool doneTyping = !_erasing && _chars >= text.length;
    final bool lastPhrase = _phrase == widget.phrases.length - 1;

    if (doneTyping) {
      if (!widget.loop && lastPhrase) return; // Finished.
      if (widget.phrases.length == 1 && !widget.loop) return;
      _erasing = true;
      _schedule(widget.pause);
    } else {
      _schedule(_erasing ? widget.erasingInterval : widget.typingInterval);
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? Theme.of(context).textTheme.titleLarge;
    final scheme = Theme.of(context).colorScheme;
    final text = widget.phrases[_phrase];
    final visible = text.substring(0, _chars.clamp(0, text.length));

    // The longest phrase reserves layout so nothing reflows while typing.
    String longest = '';
    for (final p in widget.phrases) {
      if (p.length > longest.length) longest = p;
    }

    return Semantics(
      label: text,
      liveRegion: true,
      child: Stack(
        children: [
          // Invisible full-width placeholder.
          Opacity(
            opacity: 0,
            child: Text('$longest\u2588', style: style),
          ),
          Positioned.fill(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    visible,
                    style: style,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                  ),
                ),
                if (widget.showCursor)
                  FadeTransition(
                    opacity: _cursor.drive(
                      TweenSequence<double>([
                        TweenSequenceItem(
                          tween: ConstantTween(1),
                          weight: 50,
                        ),
                        TweenSequenceItem(
                          tween: ConstantTween(0),
                          weight: 50,
                        ),
                      ]),
                    ),
                    child: Text(
                      '\u2588',
                      style: style?.copyWith(color: scheme.primary),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
