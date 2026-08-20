import 'package:flutter/material.dart';

import '../theme/me_shapes.dart';

/// Layout styles for [MECarousel], matching the M3 Expressive carousel set.
enum MECarouselType {
  /// Large leading item with smaller trailing previews (default).
  hero,

  /// Equal-width items that fill most of the viewport.
  contained,

  /// Smaller peeking items with space around the focused card.
  uncontained,
}

/// Where the focused hero item sits.
enum MECarouselHeroAlignment { start, center }

/// A Material 3 Expressive carousel.
///
/// Replaces [CarouselView]. Items squash and stretch as they scroll and
/// are clipped to the extra-large expressive shape.
class MECarousel extends StatefulWidget {
  const MECarousel({
    super.key,
    required this.children,
    this.height = 200,
    this.itemFraction,
    this.type = MECarouselType.hero,
    this.heroAlignment = MECarouselHeroAlignment.start,
    this.axis = Axis.horizontal,
    this.onTap,
    this.onChange,
  });

  final List<Widget> children;
  final double height;

  /// Fraction of the viewport occupied by the focused item.
  /// When null, derived from [type].
  final double? itemFraction;
  final MECarouselType type;
  final MECarouselHeroAlignment heroAlignment;
  final Axis axis;
  final ValueChanged<int>? onTap;

  /// Called with the leading/focal index as the carousel scrolls.
  final ValueChanged<int>? onChange;

  double get _fraction =>
      itemFraction ??
      switch (type) {
        MECarouselType.hero => 0.75,
        MECarouselType.contained => 0.88,
        MECarouselType.uncontained => 0.55,
      };

  bool get _padEnds =>
      type == MECarouselType.uncontained ||
      (type == MECarouselType.hero &&
          heroAlignment == MECarouselHeroAlignment.center);

  @override
  State<MECarousel> createState() => _MECarouselState();
}

class _MECarouselState extends State<MECarousel> {
  late PageController _controller = PageController(
    viewportFraction: widget._fraction,
  );
  int _lastIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handlePage);
  }

  void _handlePage() {
    if (!_controller.hasClients || !_controller.position.haveDimensions) {
      return;
    }
    final index = (_controller.page ?? 0).round();
    if (index == _lastIndex) return;
    _lastIndex = index;
    widget.onChange?.call(index);
  }

  @override
  void didUpdateWidget(covariant MECarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget._fraction != widget._fraction) {
      _controller.removeListener(_handlePage);
      _controller.dispose();
      _controller = PageController(viewportFraction: widget._fraction)
        ..addListener(_handlePage);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handlePage);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gap = widget.type == MECarouselType.contained ? 8.0 : 6.0;
    return SizedBox(
      height: widget.height,
      child: PageView.builder(
        controller: _controller,
        padEnds: widget._padEnds,
        scrollDirection: widget.axis,
        itemCount: widget.children.length,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              double distance = 0;
              if (_controller.position.haveDimensions) {
                distance = ((_controller.page ?? 0) - index).abs();
              }
              final shrink = widget.type == MECarouselType.contained ? 0.04 : 0.08;
              final scale = (1.0 - distance * shrink).clamp(0.84, 1.0);
              return Padding(
                padding: widget.axis == Axis.vertical
                    ? EdgeInsets.symmetric(vertical: gap / 2)
                    : EdgeInsets.symmetric(horizontal: gap / 2),
                child: Align(
                  child: SizedBox(
                    height: widget.height * scale,
                    child: child,
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(MECorners.extraLarge),
              child: GestureDetector(
                onTap: widget.onTap == null ? null : () => widget.onTap!(index),
                child: SizedBox.expand(child: widget.children[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}
