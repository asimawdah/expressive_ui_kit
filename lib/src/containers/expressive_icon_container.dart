import 'dart:math';

import 'package:flutter/material.dart';

/// M3 Expressive icon container that draws a 6-sided cookie shape
/// (matching Android's [MaterialShapes.Cookie6Sided]) as background.
///
/// Parameters are derived from the Material 3 Expressive shape library:
/// - 6-pointed star polygon with inner radius ratio of 0.75
/// - CornerRounding(radius = 0.5, smoothing = 0.6) for heavy rounding
class ExpressiveIconContainer extends StatelessWidget {
  const ExpressiveIconContainer({
    super.key,
    required this.child,
    this.size = 48,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.5,
    this.shape = ExpressiveShape.cookie6Sided,
  });

  final Widget child;
  final double size;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final ExpressiveShape shape;

  @override
  Widget build(BuildContext context) {
    final bgColor =
        backgroundColor ?? Theme.of(context).colorScheme.primaryContainer;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ExpressiveShapePainter(
          color: bgColor,
          shape: shape,
          borderColor: borderColor,
          borderWidth: borderColor == null ? 0 : borderWidth,
        ),
        child: Center(child: child),
      ),
    );
  }
}

enum ExpressiveShape {
  // square(4, 0.75, 0.0, 0.0),
  cookie4Sided(4, 0.75, 0.0, 0.0),
  cookie6Sided(6, 0.75, 0.50, 0.60),
  cookie9Sided(9, 0.80, 0.50, 0.60),
  cookie12Sided(12, 0.80, 0.50, 0.60);

  const ExpressiveShape(
    this.points,
    this.innerRadiusRatio,
    this.cornerRadius,
    this.smoothing,
  );

  final int points;
  final double innerRadiusRatio;
  final double cornerRadius;
  final double smoothing;
}

class _ExpressiveShapePainter extends CustomPainter {
  final Color color;
  final ExpressiveShape shape;
  final Color? borderColor;
  final double borderWidth;

  _ExpressiveShapePainter({
    required this.color,
    required this.shape,
    this.borderColor,
    this.borderWidth = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildPath(size, shape);

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawPath(path, fillPaint);

    if (borderColor != null && borderWidth > 0) {
      final strokePaint = Paint()
        ..color = borderColor!
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth
        ..isAntiAlias = true;
      canvas.drawPath(path, strokePaint);
    }
  }

  static Path _buildPath(Size size, ExpressiveShape shape) {
    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = min(size.width, size.height) / 2;
    final innerR = r * shape.innerRadiusRatio;
    final n = shape.points;

    // Generate alternating outer/inner vertices for the star polygon.
    final vertices = <Offset>[];
    final angleStep = 360.0 / n;
    for (var i = 0; i < n; i++) {
      final outerAngle = (i * angleStep - 90) * pi / 180;
      vertices.add(Offset(cx + r * cos(outerAngle), cy + r * sin(outerAngle)));
      final innerAngle = (i * angleStep + angleStep / 2 - 90) * pi / 180;
      vertices.add(
        Offset(cx + innerR * cos(innerAngle), cy + innerR * sin(innerAngle)),
      );
    }

    final total = vertices.length;
    final rf = shape.cornerRadius;
    final sm = shape.smoothing;

    for (var i = 0; i < total; i++) {
      final prev = vertices[(i - 1 + total) % total];
      final curr = vertices[i];
      final next = vertices[(i + 1) % total];

      // Cut points along edges toward previous and next vertices.
      final cutStart = Offset(
        curr.dx + (prev.dx - curr.dx) * rf,
        curr.dy + (prev.dy - curr.dy) * rf,
      );
      final cutEnd = Offset(
        curr.dx + (next.dx - curr.dx) * rf,
        curr.dy + (next.dy - curr.dy) * rf,
      );

      // Cubic bezier control points with smoothing offset.
      final cp1 = Offset(
        cutStart.dx + (curr.dx - cutStart.dx) * sm,
        cutStart.dy + (curr.dy - cutStart.dy) * sm,
      );
      final cp2 = Offset(
        cutEnd.dx + (curr.dx - cutEnd.dx) * sm,
        cutEnd.dy + (curr.dy - cutEnd.dy) * sm,
      );

      if (i == 0) {
        path.moveTo(cutStart.dx, cutStart.dy);
      } else {
        path.lineTo(cutStart.dx, cutStart.dy);
      }

      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, cutEnd.dx, cutEnd.dy);
    }

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _ExpressiveShapePainter oldDelegate) {
    return color != oldDelegate.color ||
        shape != oldDelegate.shape ||
        borderColor != oldDelegate.borderColor ||
        borderWidth != oldDelegate.borderWidth;
  }
}
