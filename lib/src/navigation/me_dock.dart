import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/me_motion.dart';
import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';

/// An item in an [MEDock].
class MEDockItem {
  const MEDockItem({
    required this.icon,
    this.tooltip,
    this.onPressed,
  });

  final IconData icon;
  final String? tooltip;
  final VoidCallback? onPressed;
}

/// A Material 3 Expressive dock: a floating pill of icons where the icon
/// under the pointer (or finger) magnifies, with neighbors scaling off
/// smoothly by distance — the classic dock effect rebuilt on M3E springs
/// and color roles.
///
/// On touch, drag along the dock to scrub; release to activate.
class MEDock extends StatefulWidget {
  const MEDock({
    super.key,
    required this.items,
    this.baseSize = 44,
    this.magnification = 1.6,
    this.spread = 96,
  });

  final List<MEDockItem> items;

  /// Resting diameter of each icon cell.
  final double baseSize;

  /// Scale factor of the cell directly under the pointer.
  final double magnification;

  /// Horizontal falloff distance of the magnification bump, in pixels.
  final double spread;

  @override
  State<MEDock> createState() => _MEDockState();
}

class _MEDockState extends State<MEDock> {
  /// Pointer x-position local to the row, or null when not hovering.
  double? _pointerX;
  int? _activeIndex;

  double _scaleFor(int index) {
    final x = _pointerX;
    if (x == null) return 1.0;
    final center = (index + 0.5) * widget.baseSize;
    final distance = (x - center).abs();
    if (distance >= widget.spread) return 1.0;
    // Cosine falloff: 1.0 at spread distance, magnification at 0.
    final t = 1.0 - distance / widget.spread;
    final eased = (1 - (1 - t) * (1 - t));
    return 1.0 + (widget.magnification - 1.0) * eased;
  }

  int _indexAt(double x) =>
      (x / widget.baseSize).floor().clamp(0, widget.items.length - 1);

  void _updatePointer(double? x, {bool haptic = false}) {
    final newIndex = x == null ? null : _indexAt(x);
    if (haptic && newIndex != _activeIndex && newIndex != null) {
      HapticFeedback.selectionClick();
    }
    setState(() {
      _pointerX = x;
      _activeIndex = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final motion = METheme.of(context).motion;
    final rowWidth = widget.baseSize * widget.items.length;

    return Material(
      color: scheme.surfaceContainerHigh,
      elevation: 3,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: MouseRegion(
          onHover: (e) => _updatePointer(e.localPosition.dx),
          onExit: (_) => _updatePointer(null),
          child: GestureDetector(
            onHorizontalDragStart: (d) =>
                _updatePointer(d.localPosition.dx, haptic: true),
            onHorizontalDragUpdate: (d) =>
                _updatePointer(d.localPosition.dx, haptic: true),
            onHorizontalDragEnd: (_) {
              final index = _activeIndex;
              _updatePointer(null);
              if (index != null) widget.items[index].onPressed?.call();
            },
            child: SizedBox(
              width: rowWidth,
              height: widget.baseSize * widget.magnification,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (int i = 0; i < widget.items.length; i++)
                    _DockCell(
                      item: widget.items[i],
                      baseSize: widget.baseSize,
                      scale: _scaleFor(i),
                      hovered: _activeIndex == i,
                      spec: motion.fastSpatial,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DockCell extends StatelessWidget {
  const _DockCell({
    required this.item,
    required this.baseSize,
    required this.scale,
    required this.hovered,
    required this.spec,
  });

  final MEDockItem item;
  final double baseSize;
  final double scale;
  final bool hovered;
  final MESpringSpec spec;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Widget cell = MEMotionBuilder(
      value: scale,
      spec: spec,
      builder: (context, s, child) {
        return SizedBox(
          width: baseSize,
          height: baseSize * s,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: MEMotionBuilder(
              value: hovered ? 1.0 : 0.0,
              spec: spec,
              builder: (context, h, _) {
                final size = baseSize * s - 6;
                return Container(
                  width: size,
                  height: size,
                  decoration: ShapeDecoration(
                    color: Color.lerp(
                      Colors.transparent,
                      scheme.primaryContainer,
                      h.clamp(0.0, 1.0),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        baseSize - (baseSize - MECorners.large) * h,
                      ),
                    ),
                  ),
                  child: child,
                );
              },
            ),
          ),
        );
      },
      child: InkWell(
        onTap: item.onPressed,
        customBorder: const CircleBorder(),
        child: Icon(
          item.icon,
          size: (baseSize * scale - 6) * 0.55,
          color: hovered ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
        ),
      ),
    );

    if (item.tooltip != null) {
      cell = Tooltip(message: item.tooltip!, child: cell);
    }
    return Semantics(button: true, label: item.tooltip, child: cell);
  }
}
