import 'package:flutter/material.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// A Material 3 Expressive page indicator.
///
/// New to the expressive idiom (no direct standard equivalent). Shows a row
/// of dots where the active dot stretches into a pill with a spatial
/// spring, mirroring the liquid indicator used by [MENavigationBar].
/// Pairs with [MECarousel] or any [PageView].
class MEPageIndicator extends StatefulWidget {
  const MEPageIndicator({
    super.key,
    required this.count,
    required this.index,
    this.onDotPressed,
    this.dotSize = 8,
    this.activeWidth = 24,
    this.spacing = 6,
  }) : assert(index >= 0 && index < count, 'index must be within count.');

  final int count;
  final int index;

  /// When set, dots are tappable.
  final ValueChanged<int>? onDotPressed;
  final double dotSize;

  /// Width of the active pill.
  final double activeWidth;
  final double spacing;

  @override
  State<MEPageIndicator> createState() => _MEPageIndicatorState();
}

class _MEPageIndicatorState extends State<MEPageIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim =
      AnimationController.unbounded(vsync: this, value: widget.index.toDouble());

  @override
  void didUpdateWidget(MEPageIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index != oldWidget.index) {
      springTo(_anim, widget.index.toDouble(),
          METheme.of(context).motion.defaultSpatial);
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      label: 'Page ${widget.index + 1} of ${widget.count}',
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < widget.count; i++) ...[
                if (i > 0) SizedBox(width: widget.spacing),
                _buildDot(context, i, colors),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildDot(BuildContext context, int i, ColorScheme colors) {
    // Proximity of the animated position to this dot (1 = active, 0 = far).
    final proximity = (1 - (_anim.value - i).abs()).clamp(0.0, 1.0);
    final width =
        widget.dotSize + (widget.activeWidth - widget.dotSize) * proximity;
    final color =
        Color.lerp(colors.outlineVariant, colors.primary, proximity)!;

    final dot = Container(
      width: width,
      height: widget.dotSize,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(widget.dotSize / 2),
      ),
    );

    if (widget.onDotPressed == null) return dot;
    return GestureDetector(
      onTap: () => widget.onDotPressed!(i),
      behavior: HitTestBehavior.opaque,
      child: Padding(padding: const EdgeInsets.all(4), child: dot),
    );
  }
}
