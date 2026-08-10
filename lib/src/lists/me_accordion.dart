import 'package:flutter/material.dart';

import '../internal/me_pressable.dart';
import '../theme/me_motion.dart';
import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';

/// One panel of an [MEAccordion].
class MEAccordionItem {
  const MEAccordionItem({
    required this.header,
    required this.body,
    this.icon,
  });

  final Widget header;
  final Widget body;
  final IconData? icon;
}

/// A Material 3 Expressive accordion (expansion panel list).
///
/// Replaces [ExpansionPanelList]. Panels unfold with a spatial spring
/// (bodies overshoot slightly as they open), chevrons rotate with a
/// bounce, and the open panel's container morphs to a larger corner
/// radius and tonal color to lift it from its neighbors.
class MEAccordion extends StatefulWidget {
  const MEAccordion({
    super.key,
    required this.items,
    this.multiExpand = false,
    this.initiallyExpanded = const <int>{},
  });

  final List<MEAccordionItem> items;

  /// Whether several panels may be open at once. When false, opening a
  /// panel closes the others.
  final bool multiExpand;

  /// Indices of the panels open at first build.
  final Set<int> initiallyExpanded;

  @override
  State<MEAccordion> createState() => _MEAccordionState();
}

class _MEAccordionState extends State<MEAccordion>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers = [
    for (var i = 0; i < widget.items.length; i++)
      AnimationController.unbounded(
        vsync: this,
        value: widget.initiallyExpanded.contains(i) ? 1 : 0,
      ),
  ];
  late final Set<int> _openSet = {...widget.initiallyExpanded};

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _toggle(int index) {
    final motion = METheme.of(context).motion;
    setState(() {
      if (_openSet.contains(index)) {
        _openSet.remove(index);
        springTo(_controllers[index], 0, motion.defaultSpatial);
      } else {
        if (!widget.multiExpand) {
          for (final other in _openSet) {
            springTo(_controllers[other], 0, motion.defaultSpatial);
          }
          _openSet.clear();
        }
        _openSet.add(index);
        springTo(_controllers[index], 1, motion.defaultSpatial);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < widget.items.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _Panel(
            item: widget.items[i],
            animation: _controllers[i],
            open: _openSet.contains(i),
            onToggle: () => _toggle(i),
          ),
        ],
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.item,
    required this.animation,
    required this.open,
    required this.onToggle,
  });

  final MEAccordionItem item;
  final AnimationController animation;
  final bool open;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        final clamped = t.clamp(0.0, 1.0);
        final radius = MECorners.medium +
            (MECorners.extraLarge - MECorners.medium) * clamped;
        final bg = Color.lerp(
          colors.surfaceContainerLow,
          colors.secondaryContainer,
          clamped * 0.55,
        )!;
        final fg = Color.lerp(
          colors.onSurface,
          colors.onSecondaryContainer,
          clamped,
        )!;

        return Material(
          color: bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MEPressable(
                onPressed: onToggle,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius),
                ),
                overlayColor: fg.withValues(alpha: 0.08),
                semanticLabel: open ? 'Collapse' : 'Expand',
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      if (item.icon != null) ...[
                        Icon(item.icon, size: 22, color: fg),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: DefaultTextStyle.merge(
                          style: textTheme.titleMedium!.copyWith(color: fg),
                          child: item.header,
                        ),
                      ),
                      // Chevron rotates 180deg with spring overshoot.
                      Transform.rotate(
                        angle: t * 3.14159,
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          size: 24,
                          color: fg,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Body unfolds; heightFactor may overshoot past 1 for bounce.
              ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: t.clamp(0.0, 1.2),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Opacity(
                      opacity: clamped,
                      child: DefaultTextStyle.merge(
                        style: textTheme.bodyMedium!.copyWith(
                          color: fg,
                          height: 1.5,
                        ),
                        child: item.body,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
