import 'package:flutter/material.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// A Material 3 Expressive star rating control.
///
/// Stars pop with a staggered spatial-spring bounce when the rating
/// changes. Interactive when [onChanged] is provided; display-only
/// otherwise (supports half values like 3.5 in display mode).
class MERating extends StatefulWidget {
  const MERating({
    super.key,
    required this.value,
    this.count = 5,
    this.onChanged,
    this.size = 32,
    this.color,
  });

  /// Current rating, from 0 to [count]. Fractions render as partial fill
  /// in display-only mode.
  final double value;

  /// Number of stars.
  final int count;

  /// Called with the new rating (1-based) when a star is tapped.
  /// Tapping the current rating clears it to 0.
  final ValueChanged<double>? onChanged;

  final double size;

  /// Active star color. Defaults to the theme primary.
  final Color? color;

  @override
  State<MERating> createState() => _MERatingState();
}

class _MERatingState extends State<MERating> with TickerProviderStateMixin {
  late final List<AnimationController> _pops = List.generate(
    widget.count,
    (i) => AnimationController.unbounded(vsync: this, value: 1),
  );

  @override
  void didUpdateWidget(MERating oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value > oldWidget.value) {
      // Stagger-bounce the newly activated stars.
      final from = oldWidget.value.ceil();
      final to = widget.value.ceil().clamp(0, widget.count);
      for (var i = from; i < to; i++) {
        _pops[i].value = 0.4;
        Future<void>.delayed(Duration(milliseconds: (i - from) * 50), () {
          if (mounted) {
            springTo(_pops[i], 1, METheme.of(context).motion.fastSpatial);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    for (final c in _pops) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final active = widget.color ?? scheme.primary;
    final inactive = scheme.surfaceContainerHighest;

    return Semantics(
      slider: widget.onChanged != null,
      value: '${widget.value} of ${widget.count}',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(widget.count, (i) {
          final fill = (widget.value - i).clamp(0.0, 1.0);
          final star = AnimatedBuilder(
            animation: _pops[i],
            builder: (context, child) => Transform.scale(
              scale: _pops[i].value.clamp(0.0, 1.4),
              child: child,
            ),
            child: _Star(
              fill: fill,
              size: widget.size,
              active: active,
              inactive: inactive,
            ),
          );

          if (widget.onChanged == null) return star;
          return InkResponse(
            radius: widget.size * 0.7,
            onTap: () {
              final next = (i + 1).toDouble();
              widget.onChanged!(next == widget.value ? 0 : next);
            },
            child: star,
          );
        }),
      ),
    );
  }
}

class _Star extends StatelessWidget {
  const _Star({
    required this.fill,
    required this.size,
    required this.active,
    required this.inactive,
  });

  final double fill;
  final double size;
  final Color active;
  final Color inactive;

  @override
  Widget build(BuildContext context) {
    if (fill <= 0) {
      return Icon(Icons.star_rounded, size: size, color: inactive);
    }
    if (fill >= 1) {
      return Icon(Icons.star_rounded, size: size, color: active);
    }
    // Partial fill: clip the active star over the inactive one.
    return Stack(
      children: [
        Icon(Icons.star_rounded, size: size, color: inactive),
        ClipRect(
          clipper: _FractionClipper(fill),
          child: Icon(Icons.star_rounded, size: size, color: active),
        ),
      ],
    );
  }
}

class _FractionClipper extends CustomClipper<Rect> {
  const _FractionClipper(this.fraction);

  final double fraction;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(0, 0, size.width * fraction, size.height);

  @override
  bool shouldReclip(_FractionClipper oldClipper) =>
      oldClipper.fraction != fraction;
}
