import 'package:flutter/material.dart';

/// A horizontally scrolling marquee for content wider than its container
/// (song titles, news tickers, announcements).
///
/// The content scrolls at a constant [velocity] with a pause at each loop
/// start, and fades out at both edges. If the content fits, no scrolling
/// happens at all. Wrap arbitrary widgets, not just text.
class MEMarquee extends StatefulWidget {
  const MEMarquee({
    super.key,
    required this.child,
    this.velocity = 36,
    this.spacing = 48,
    this.pause = const Duration(milliseconds: 1200),
    this.fadeWidth = 24,
    this.height,
  });

  final Widget child;

  /// Scroll speed in logical pixels per second.
  final double velocity;

  /// Gap between the end of the content and its repeated copy.
  final double spacing;

  /// Pause before each loop starts.
  final Duration pause;

  /// Width of the fade masks at each edge.
  final double fadeWidth;

  /// Fixed height. Defaults to the child's intrinsic height.
  final double? height;

  @override
  State<MEMarquee> createState() => _MEMarqueeState();
}

class _MEMarqueeState extends State<MEMarquee>
    with SingleTickerProviderStateMixin {
  final ScrollController _scroll = ScrollController();
  bool _running = false;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeStart());
  }

  Future<void> _maybeStart() async {
    if (_disposed || _running || !_scroll.hasClients) return;
    final max = _scroll.position.maxScrollExtent;
    if (max <= 0) return;
    _running = true;

    while (!_disposed && _scroll.hasClients) {
      await Future<void>.delayed(widget.pause);
      if (_disposed || !_scroll.hasClients) break;
      // One copy + spacing = half the scroll extent (two copies rendered).
      final distance =
          _scroll.position.maxScrollExtent / 2 + widget.spacing / 2;
      final duration = Duration(
        milliseconds:
            (distance / widget.velocity * 1000).clamp(500, 60000).round(),
      );
      try {
        await _scroll.animateTo(
          distance,
          duration: duration,
          curve: Curves.linear,
        );
      } catch (_) {
        break;
      }
      if (_disposed || !_scroll.hasClients) break;
      _scroll.jumpTo(0);
    }
    _running = false;
  }

  @override
  void didUpdateWidget(MEMarquee oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeStart());
  }

  @override
  void dispose() {
    _disposed = true;
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: ShaderMask(
        shaderCallback: (rect) {
          final fade = (widget.fadeWidth / rect.width).clamp(0.0, 0.4);
          return LinearGradient(
            colors: const [
              Colors.transparent,
              Colors.white,
              Colors.white,
              Colors.transparent,
            ],
            stops: [0.0, fade, 1.0 - fade, 1.0],
          ).createShader(rect);
        },
        blendMode: BlendMode.dstIn,
        child: SingleChildScrollView(
          controller: _scroll,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            children: [
              widget.child,
              SizedBox(width: widget.spacing),
              // Second copy so the loop reset is invisible.
              widget.child,
              SizedBox(width: widget.spacing),
            ],
          ),
        ),
      ),
    );
  }
}
