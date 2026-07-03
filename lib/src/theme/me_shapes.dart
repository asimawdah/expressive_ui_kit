import 'package:flutter/material.dart';

/// Material 3 Expressive corner radius tokens.
///
/// M3 Expressive expands the shape scale and makes shape a first-class
/// interaction signal: components morph between round and square shapes
/// on press and selection.
abstract final class MECorners {
  static const double none = 0;
  static const double extraSmall = 4;
  static const double small = 8;
  static const double medium = 12;
  static const double large = 16;
  static const double largeIncreased = 20;
  static const double extraLarge = 28;
  static const double extraLargeIncreased = 32;
  static const double extraExtraLarge = 48;

  /// A sentinel meaning "fully rounded" (stadium / circle).
  static const double full = double.infinity;
}

/// The Material 3 Expressive shape scheme.
@immutable
class MEShapeScheme {
  const MEShapeScheme();

  ShapeBorder get none => const RoundedRectangleBorder();
  ShapeBorder get extraSmall => _rounded(MECorners.extraSmall);
  ShapeBorder get small => _rounded(MECorners.small);
  ShapeBorder get medium => _rounded(MECorners.medium);
  ShapeBorder get large => _rounded(MECorners.large);
  ShapeBorder get largeIncreased => _rounded(MECorners.largeIncreased);
  ShapeBorder get extraLarge => _rounded(MECorners.extraLarge);
  ShapeBorder get extraLargeIncreased =>
      _rounded(MECorners.extraLargeIncreased);
  ShapeBorder get full => const StadiumBorder();

  static ShapeBorder _rounded(double radius) =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));

  /// Resolves a corner token to a concrete shape.
  static ShapeBorder fromCorner(double corner) {
    if (corner == MECorners.full) return const StadiumBorder();
    return RoundedRectangleBorder(borderRadius: BorderRadius.circular(corner));
  }
}

/// Interpolates between two shapes. Used by widgets that morph shape on
/// press/selection (buttons, switches, chips, FABs...).
///
/// Handles the [StadiumBorder] <-> [RoundedRectangleBorder] pair, which
/// [ShapeBorder.lerp] cannot interpolate directly, by converting the
/// stadium into an equivalent rounded rectangle at layout time.
class MEShapeMorph {
  const MEShapeMorph({required this.from, required this.to});

  final ShapeBorder from;
  final ShapeBorder to;

  /// Returns the shape at morph progress [t] (0.0 = [from], 1.0 = [to])
  /// for a widget of the given [size].
  ShapeBorder evaluate(double t, Size size) {
    final a = _normalize(from, size);
    final b = _normalize(to, size);
    return ShapeBorder.lerp(a, b, t) ?? (t < 0.5 ? a : b);
  }

  static ShapeBorder _normalize(ShapeBorder shape, Size size) {
    if (shape is StadiumBorder) {
      return RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(size.shortestSide / 2),
        side: shape.side,
      );
    }
    if (shape is CircleBorder) {
      return RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(size.shortestSide / 2),
        side: shape.side,
      );
    }
    return shape;
  }
}
