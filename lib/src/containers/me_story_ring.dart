import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';
import 'me_avatar.dart';

/// A story-style ring around an [MEAvatar], signalling unseen content.
///
/// New in the expressive idiom. The ring is drawn as arc segments (one per
/// story) with small angular gaps — the same gap language as the M3E
/// loading indicator. On first build the segments sweep in with the slow
/// spatial spring; when [seen] flips to true the ring collapses to a thin
/// neutral outline.
///
/// ```dart
/// MEStoryRing(
///   segments: 3,
///   seen: false,
///   child: MEAvatar(image: NetworkImage(url), size: 56),
/// )
/// ```
class MEStoryRing extends StatefulWidget {
  const MEStoryRing({
    super.key,
    required this.child,
    this.segments = 1,
    this.seen = false,
    this.thickness = 3,
    this.gap = 3,
    this.color,
    this.seenColor,
  }) : assert(segments >= 1, 'segments must be >= 1');

  /// The avatar (or any circular widget) to wrap.
  final Widget child;

  /// Number of arc segments — typically the number of stories.
  final int segments;

  /// When true, the ring collapses to a thin neutral outline.
  final bool seen;

  /// Stroke width of the unseen ring.
  final double thickness;

  /// Padding between the child and the ring, also used as the angular
  /// gap (in logical pixels of arc length) between segments.
  final double gap;

  /// Ring color. Defaults to the scheme primary.
  final Color? color;

  /// Ring color once seen. Defaults to outlineVariant.
  final Color? seenColor;

  @override
  State<MEStoryRing> createState() => _MEStoryRingState();
}

class _MEStoryRingState extends State<MEStoryRing>
    with TickerProviderStateMixin {
  late final AnimationController _sweep = AnimationController.unbounded(
    vsync: this,
    value: 0,
  );
  late final AnimationController _seen = AnimationController.unbounded(
    vsync: this,
    value: widget.seen ? 1 : 0,
  );
  bool _swept = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_swept) {
      _swept = true;
      springTo(_sweep, 1, METheme.of(context).motion.slowSpatial);
    }
  }

  @override
  void didUpdateWidget(MEStoryRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.seen != oldWidget.seen) {
      springTo(
        _seen,
        widget.seen ? 1 : 0,
        METheme.of(context).motion.defaultEffects,
      );
    }
  }

  @override
  void dispose() {
    _sweep.dispose();
    _seen.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final unseenColor = widget.color ?? scheme.primary;
    final seenColor = widget.seenColor ?? scheme.outlineVariant;

    return AnimatedBuilder(
      animation: Listenable.merge([_sweep, _seen]),
      builder: (context, child) {
        final seenT = _seen.value.clamp(0.0, 1.0);
        return CustomPaint(
          foregroundPainter: _StoryRingPainter(
            segments: widget.segments,
            sweep: _sweep.value.clamp(0.0, 1.0),
            color: Color.lerp(unseenColor, seenColor, seenT)!,
            thickness: widget.thickness -
                (widget.thickness - 1.5) * seenT,
            gapPixels: widget.gap,
          ),
          child: child,
        );
      },
      child: Padding(
        padding: EdgeInsets.all(widget.thickness + widget.gap),
        child: widget.child,
      ),
    );
  }
}

class _StoryRingPainter extends CustomPainter {
  const _StoryRingPainter({
    required this.segments,
    required this.sweep,
    required this.color,
    required this.thickness,
    required this.gapPixels,
  });

  final int segments;
  final double sweep;
  final Color color;
  final double thickness;
  final double gapPixels;

  @override
  void paint(Canvas canvas, Size size) {
    if (sweep <= 0) return;
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - thickness) / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..color = color;

    final rect = Rect.fromCircle(center: center, radius: radius);
    if (segments == 1) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * sweep,
        false,
        paint,
      );
      return;
    }

    // Convert the pixel gap to an angle at this radius.
    final gapAngle = gapPixels / radius;
    final segmentAngle = (2 * math.pi / segments) - gapAngle;
    for (int i = 0; i < segments; i++) {
      final start = -math.pi / 2 + i * (segmentAngle + gapAngle);
      canvas.drawArc(rect, start, segmentAngle * sweep, false, paint);
    }
  }

  @override
  bool shouldRepaint(_StoryRingPainter oldDelegate) =>
      oldDelegate.segments != segments ||
      oldDelegate.sweep != sweep ||
      oldDelegate.color != color ||
      oldDelegate.thickness != thickness ||
      oldDelegate.gapPixels != gapPixels;
}
