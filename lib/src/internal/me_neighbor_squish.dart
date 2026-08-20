import 'package:flutter/widgets.dart';

/// How much a pressed group item grows, as a fraction of its natural size.
/// Same ratio `m3e_core` uses for neighbor-squish (`expandedRatio: 0.15`).
const double kMENeighborSquishRatio = 0.15;

/// Layout factor for one item in an M3E button group.
///
/// The pressed item grows by [kMENeighborSquishRatio] × [t]; direct neighbors
/// give that space back so the row's total width stays the same. [t] is the
/// unclamped motor spring progress (may overshoot past 1).
double meNeighborSquishFactor({
  required int index,
  required int count,
  required int? pressedIndex,
  required double t,
}) {
  if (pressedIndex == null || count <= 0) return 1.0;
  final growth = kMENeighborSquishRatio * t;
  if (index == pressedIndex) return 1.0 + growth;
  if (count == 1) return 1.0;
  if (pressedIndex == 0) {
    return index == 1 ? 1.0 - growth : 1.0;
  }
  if (pressedIndex == count - 1) {
    return index == count - 2 ? 1.0 - growth : 1.0;
  }
  if ((index - pressedIndex).abs() == 1) return 1.0 - growth / 2;
  return 1.0;
}

/// Compress neighbors toward the pressed item; the pressed item stays centered.
Alignment meNeighborSquishAlignment({
  required int index,
  required int? pressedIndex,
  required Axis direction,
}) {
  if (pressedIndex == null || index == pressedIndex) {
    return Alignment.center;
  }
  if (direction == Axis.horizontal) {
    return index < pressedIndex ? Alignment.centerRight : Alignment.centerLeft;
  }
  return index < pressedIndex ? Alignment.bottomCenter : Alignment.topCenter;
}

/// Applies [meNeighborSquishFactor] as a layout factor (not [Transform.scale]),
/// matching `m3e_core` width-compression neighbor squish.
class MENeighborSquish extends StatelessWidget {
  const MENeighborSquish({
    super.key,
    required this.factor,
    required this.alignment,
    required this.direction,
    required this.child,
  });

  final double factor;
  final Alignment alignment;
  final Axis direction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      widthFactor: direction == Axis.horizontal ? factor : null,
      heightFactor: direction == Axis.vertical ? factor : null,
      child: child,
    );
  }
}
