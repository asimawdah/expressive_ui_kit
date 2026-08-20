import 'package:flutter/material.dart';
import 'package:material_new_shapes/material_new_shapes.dart';

/// Clips [child] to an official Material 3 Expressive [RoundedPolygon]
/// (the 35-shape library: cookie, pill, sunny, clover, …).
///
/// Prefer this over a homemade clip when the product asks for an M3
/// expressive shape container. For a looping morph, use [MELoadingIndicator]
/// or [MEMorphingShape].
class MEShapeContainer extends StatelessWidget {
  const MEShapeContainer({
    super.key,
    required this.polygon,
    required this.child,
    this.size = 48,
    this.color,
  });

  /// A normalized [RoundedPolygon], typically from [MaterialShapes].
  final RoundedPolygon polygon;
  final Widget child;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final fill = color ?? Theme.of(context).colorScheme.primaryContainer;
    return SizedBox(
      width: size,
      height: size,
      child: ClipPath(
        clipper: _PolygonClipper(polygon),
        child: ColoredBox(
          color: fill,
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _PolygonClipper extends CustomClipper<Path> {
  const _PolygonClipper(this.polygon);

  final RoundedPolygon polygon;

  @override
  Path getClip(Size size) {
    final path = polygon.toPath();
    final matrix = Matrix4.diagonal3Values(size.width, size.height, 1);
    return path.transform(matrix.storage);
  }

  @override
  bool shouldReclip(_PolygonClipper oldClipper) =>
      oldClipper.polygon != polygon;
}
