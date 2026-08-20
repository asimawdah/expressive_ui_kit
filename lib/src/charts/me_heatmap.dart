import 'package:flutter/material.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// A single cell in an [MEHeatmap].
class MEHeatmapCell {
  const MEHeatmapCell({required this.value, this.tooltip});

  /// Intensity of this cell. Normalized against the maximum value in the
  /// dataset.
  final double value;

  /// Optional tooltip text (e.g. "12 commits on March 3").
  final String? tooltip;
}

/// A Material 3 Expressive heatmap calendar (contribution graph).
///
/// Renders a grid of rounded cells whose fill intensity maps to their
/// value, colored from the theme's primary. Cells pop in with a
/// diagonally staggered spring when the widget first builds. Tap a cell
/// to select it — it morphs rounder and shows its tooltip below the grid.
class MEHeatmap extends StatefulWidget {
  const MEHeatmap({
    super.key,
    required this.cells,
    this.columns = 12,
    this.cellSize = 22,
    this.spacing = 4,
    this.onCellPressed,
  });

  /// Cell data in row-major order.
  final List<MEHeatmapCell> cells;

  /// Number of columns in the grid.
  final int columns;
  final double cellSize;
  final double spacing;

  /// Called with the cell index when a cell is tapped.
  final ValueChanged<int>? onCellPressed;

  @override
  State<MEHeatmap> createState() => _MEHeatmapState();
}

class _MEHeatmapState extends State<MEHeatmap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;
  int? _selected;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final motion = METheme.of(context).motion;
    final rows = (widget.cells.length / widget.columns).ceil();
    double maxValue = 1;
    for (final c in widget.cells) {
      if (c.value > maxValue) maxValue = c.value;
    }

    final selectedTooltip =
        _selected == null ? null : widget.cells[_selected!].tooltip;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            for (int r = 0; r < rows; r++) ...[
              if (r > 0) SizedBox(height: widget.spacing),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int c = 0; c < widget.columns; c++) ...[
                    if (c > 0) SizedBox(width: widget.spacing),
                    _cell(
                        r * widget.columns + c, r, c, maxValue, scheme, motion),
                  ],
                ],
              ),
            ],
          ],
        ),
        // Selected cell details.
        AnimatedSize(
          duration: motion.defaultEffects.approximateDuration,
          curve: motion.defaultEffects.curve,
          alignment: Alignment.topLeft,
          child: selectedTooltip == null
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    selectedTooltip,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _cell(int index, int row, int col, double maxValue, ColorScheme scheme,
      MEMotionScheme motion) {
    if (index >= widget.cells.length) {
      return SizedBox(width: widget.cellSize, height: widget.cellSize);
    }
    final cell = widget.cells[index];
    final intensity = (cell.value / maxValue).clamp(0.0, 1.0);
    final selected = _selected == index;

    // Diagonal stagger: cells further down-right enter later.
    final order = (row + col) /
        ((widget.cells.length / widget.columns).ceil() + widget.columns);
    final curve = Interval(
      (order * 0.6).clamp(0.0, 0.9),
      (order * 0.6 + 0.4).clamp(0.1, 1.0),
      curve: motion.defaultSpatial.curve,
    );

    return AnimatedBuilder(
      animation: _enter,
      builder: (context, child) {
        final t = curve.transform(_enter.value);
        return Transform.scale(scale: t.clamp(0.0, 1.1), child: child);
      },
      child: GestureDetector(
        onTap: widget.onCellPressed == null && cell.tooltip == null
            ? null
            : () {
                setState(() => _selected = selected ? null : index);
                widget.onCellPressed?.call(index);
              },
        child: MEMotionBuilder(
          value: selected ? 1.0 : 0.0,
          spec: motion.fastSpatial,
          builder: (context, t, _) {
            return Container(
              width: widget.cellSize,
              height: widget.cellSize,
              decoration: BoxDecoration(
                color: intensity == 0
                    ? scheme.surfaceContainerHigh
                    : Color.lerp(scheme.primaryContainer, scheme.primary,
                        intensity * 0.85),
                borderRadius: BorderRadius.circular(
                  widget.cellSize * 0.25 +
                      (widget.cellSize / 2 - widget.cellSize * 0.25) * t,
                ),
                border: selected
                    ? Border.all(color: scheme.onSurface, width: 2)
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }
}
