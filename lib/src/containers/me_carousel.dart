import 'package:flutter/material.dart';

import '../theme/me_shapes.dart';

/// A Material 3 Expressive carousel.
///
/// Replaces [CarouselView]. Implements the "hero" carousel layout: a large
/// leading item with smaller trailing previews. Items squash and stretch
/// as they scroll, and every item is clipped to the extra-large expressive
/// shape.
class MECarousel extends StatefulWidget {
  const MECarousel({
    super.key,
    required this.children,
    this.height = 200,
    this.itemFraction = 0.75,
    this.onTap,
  });

  final List<Widget> children;
  final double height;

  /// Fraction of the viewport occupied by the focused item.
  final double itemFraction;

  final ValueChanged<int>? onTap;

  @override
  State<MECarousel> createState() => _MECarouselState();
}

class _MECarouselState extends State<MECarousel> {
  late final PageController _controller = PageController(
    viewportFraction: widget.itemFraction,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: PageView.builder(
        controller: _controller,
        padEnds: false,
        itemCount: widget.children.length,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              double distance = 0;
              if (_controller.position.haveDimensions) {
                distance = ((_controller.page ?? 0) - index).abs();
              }
              // Items shrink slightly as they move away from focus.
              final scale = (1.0 - distance * 0.08).clamp(0.84, 1.0);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
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
                onTap:
                    widget.onTap == null ? null : () => widget.onTap!(index),
                child: SizedBox.expand(child: widget.children[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}
