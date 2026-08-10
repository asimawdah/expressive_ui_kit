import 'package:flutter/material.dart';

import '../internal/me_keyboard.dart';
import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// How [MENavigationBar] shows destination labels.
enum MENavigationLabelBehavior {
  /// Labels are shown under every icon.
  alwaysShow,

  /// Only the selected destination shows its label.
  onlyShowSelected,

  /// No labels; icons only (shorter 56dp bar).
  alwaysHide,
}

/// A destination in [MENavigationBar] or `MENavigationRail`.
class MENavigationDestination {
  const MENavigationDestination({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.badge,
    this.tooltip,
  });

  final Widget icon;
  final Widget? selectedIcon;
  final String label;

  /// Optional badge (e.g. `MEBadge(count: 3)`) anchored to the icon.
  final Widget? badge;

  /// Tooltip; defaults to [label].
  final String? tooltip;
}

/// A Material 3 Expressive navigation bar.
///
/// Replaces [NavigationBar] / [BottomNavigationBar]. Implements the M3E
/// spec:
///
/// * 80dp bar by default to match Material [NavigationBar]
///   (56dp when labels are hidden); override with [height] or
///   [NavigationBarThemeData.height]
/// * a spring-animated pill indicator that stretches while traveling
///   between destinations and settles with a bounce
/// * icons bounce-scale on selection
/// * badge support anchored to icons
/// * label emphasis (bold) follows selection
/// * keyboard navigation with arrow keys, Home, and End
class MENavigationBar extends StatefulWidget {
  const MENavigationBar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.labelBehavior = MENavigationLabelBehavior.alwaysShow,
    this.backgroundColor,
    this.height,
    this.focusNode,
    this.autofocus = false,
  }) : assert(destinations.length >= 2);

  /// Matches Material [NavigationBar] default height.
  static const double defaultHeight = 80;

  final List<MENavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final MENavigationLabelBehavior labelBehavior;
  final Color? backgroundColor;

  /// Bar content height (excluding safe-area inset).
  /// Defaults to [defaultHeight] with labels, 56 without.
  final double? height;

  /// Optional focus node for keyboard navigation.
  final FocusNode? focusNode;

  /// Whether this bar should request focus when first built.
  final bool autofocus;

  @override
  State<MENavigationBar> createState() => _MENavigationBarState();
}

class _MENavigationBarState extends State<MENavigationBar>
    with TickerProviderStateMixin {
  late final AnimationController _indicator = AnimationController.unbounded(
    vsync: this,
    value: widget.selectedIndex.toDouble(),
  );

  /// Bounce-scale controller for the newly selected icon.
  late final AnimationController _iconBounce = AnimationController.unbounded(
    vsync: this,
    value: 1,
  );

  @override
  void didUpdateWidget(MENavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      final motion = METheme.of(context).motion;
      springTo(
          _indicator, widget.selectedIndex.toDouble(), motion.defaultSpatial);
      // Kick the icon slightly small, then spring back to 1 with overshoot.
      _iconBounce.value = 0.8;
      springTo(_iconBounce, 1, motion.fastSpatial);
    }
  }

  @override
  void dispose() {
    _indicator.dispose();
    _iconBounce.dispose();
    super.dispose();
  }

  bool get _showLabels =>
      widget.labelBehavior != MENavigationLabelBehavior.alwaysHide;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final navigationBarTheme = NavigationBarTheme.of(context);
    final count = widget.destinations.length;
    final backgroundColor = widget.backgroundColor ??
        navigationBarTheme.backgroundColor ??
        colors.surfaceContainer;
    final barHeight = widget.height ??
        navigationBarTheme.height ??
        (_showLabels ? MENavigationBar.defaultHeight : 56);

    return Focus(
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      onKeyEvent: (node, event) => MEKeyboard.handleHorizontalSelection(
        event: event,
        current: widget.selectedIndex,
        count: count,
        direction: Directionality.of(context),
        onSelected: widget.onDestinationSelected,
      ),
      child: Material(
        color: backgroundColor,
        elevation: navigationBarTheme.elevation ?? 3,
        shadowColor: navigationBarTheme.shadowColor ?? Colors.transparent,
        surfaceTintColor:
            navigationBarTheme.surfaceTintColor ?? Colors.transparent,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: barHeight,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = constraints.maxWidth / count;
                final isRtl = Directionality.of(context) == TextDirection.rtl;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedBuilder(
                      animation: Listenable.merge([_indicator, _iconBounce]),
                      builder: (context, _) {
                        final pos = _indicator.value;
                        // Stretch the pill while it travels; the amount of
                        // stretch tracks how far it still has to go.
                        final remaining = (pos - widget.selectedIndex).abs();
                        final stretch = 1.0 + remaining.clamp(0.0, 1.0) * 0.55;
                        // Row mirrors children in RTL, so map logical index →
                        // visual x using the mirrored position.
                        final visualPos = isRtl ? (count - 1) - pos : pos;
                        final cx = itemWidth * visualPos + itemWidth / 2;

                        const indicatorHeight = 32.0;
                        final indicatorWidth =
                            (itemWidth - 24).clamp(40.0, 64.0);
                        // The pill squashes vertically as it stretches, like a
                        // liquid blob.
                        final squash = 1.0 - (stretch - 1.0) * 0.25;
                        // Keep the pill aligned with the icon row as bar height
                        // changes (Material NavigationBar default is 80).
                        const iconSlot = 32.0;
                        const labelBlock = 16.0; // gap + label
                        final iconAreaTop = _showLabels
                            ? (barHeight - iconSlot - labelBlock) / 2
                            : (barHeight - iconSlot) / 2;

                        return Positioned(
                          left: cx - indicatorWidth * stretch / 2,
                          top: iconAreaTop + indicatorHeight * (1 - squash) / 2,
                          child: IgnorePointer(
                            child: Container(
                              width: indicatorWidth * stretch,
                              height: indicatorHeight * squash,
                              decoration: BoxDecoration(
                                color: colors.secondaryContainer,
                                borderRadius: BorderRadius.circular(
                                    indicatorHeight * squash / 2),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Row(
                      children: [
                        for (var i = 0; i < count; i++)
                          Expanded(child: _buildItem(context, i)),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int i) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final destination = widget.destinations[i];
    final selected = i == widget.selectedIndex;
    final iconColor =
        selected ? colors.onSecondaryContainer : colors.onSurfaceVariant;

    final showLabel = switch (widget.labelBehavior) {
      MENavigationLabelBehavior.alwaysShow => true,
      MENavigationLabelBehavior.onlyShowSelected => selected,
      MENavigationLabelBehavior.alwaysHide => false,
    };

    Widget iconWidget = IconTheme.merge(
      data: IconThemeData(size: 24, color: iconColor),
      child: selected && destination.selectedIcon != null
          ? destination.selectedIcon!
          : destination.icon,
    );

    if (selected) {
      iconWidget = AnimatedBuilder(
        animation: _iconBounce,
        builder: (context, child) {
          return Transform.scale(
            scale: _iconBounce.value.clamp(0.7, 1.15),
            child: child,
          );
        },
        child: iconWidget,
      );
    }

    if (destination.badge != null) {
      iconWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          iconWidget,
          PositionedDirectional(
            top: -4,
            end: -6,
            child: destination.badge!,
          ),
        ],
      );
    }

    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      label: destination.label,
      button: true,
      child: Tooltip(
        message: destination.tooltip ?? destination.label,
        waitDuration: const Duration(milliseconds: 800),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => widget.onDestinationSelected(i),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 32, child: Center(child: iconWidget)),
              if (showLabel) ...[
                const SizedBox(height: 2),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 150),
                  style: textTheme.labelMedium!.copyWith(
                    color:
                        selected ? colors.onSurface : colors.onSurfaceVariant,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  child: Text(destination.label),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
