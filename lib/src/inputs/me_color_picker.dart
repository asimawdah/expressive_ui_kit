import 'package:flutter/material.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// A Material 3 Expressive color swatch picker.
///
/// Presents a wrap of color swatches. The selected swatch morphs from a
/// circle into a rounded square with a spring (shape-as-state) and shows a
/// contrast-aware check mark that pops in.
class MEColorPicker extends StatelessWidget {
  const MEColorPicker({
    super.key,
    required this.colors,
    this.selected,
    this.onChanged,
    this.swatchSize = 44,
    this.spacing = 10,
  });

  /// The palette to offer.
  final List<Color> colors;

  /// Currently selected color (matched by value).
  final Color? selected;

  final ValueChanged<Color>? onChanged;
  final double swatchSize;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: [
        for (final color in colors)
          _Swatch(
            color: color,
            size: swatchSize,
            selected:
                selected != null && color.toARGB32() == selected!.toARGB32(),
            onPressed: onChanged == null ? null : () => onChanged!(color),
          ),
      ],
    );
  }
}

class _Swatch extends StatefulWidget {
  const _Swatch({
    required this.color,
    required this.size,
    required this.selected,
    this.onPressed,
  });

  final Color color;
  final double size;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  State<_Swatch> createState() => _SwatchState();
}

class _SwatchState extends State<_Swatch> with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController.unbounded(
    vsync: this,
    value: widget.selected ? 1 : 0,
  );

  @override
  void didUpdateWidget(_Swatch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected) {
      springTo(
        _anim,
        widget.selected ? 1 : 0,
        METheme.of(context).motion.defaultSpatial,
      );
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Contrast-aware check color.
    final check =
        ThemeData.estimateBrightnessForColor(widget.color) == Brightness.dark
            ? Colors.white
            : Colors.black87;

    return Semantics(
      button: true,
      selected: widget.selected,
      label: 'Color swatch',
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, _) {
          final t = _anim.value.clamp(0.0, 1.2);
          // Circle at rest -> rounded square when selected.
          final radius = widget.size / 2 - (widget.size * 0.28) * t;
          return GestureDetector(
            onTap: widget.onPressed,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius:
                    BorderRadius.circular(radius.clamp(6, widget.size / 2)),
                border: Border.all(
                  color:
                      widget.selected ? scheme.primary : scheme.outlineVariant,
                  width: widget.selected ? 2 : 1,
                ),
              ),
              child: Center(
                child: Transform.scale(
                  scale: _anim.value.clamp(0.0, 1.15),
                  child:
                      Icon(Icons.check, size: widget.size * 0.5, color: check),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
