import 'package:flutter/material.dart';

import '../theme/me_shapes.dart';

/// A Material 3 Expressive sliver list.
///
/// Replaces [SliverList]. Renders children as an expressive "segmented"
/// group: the first child gets a large top radius, the last a large bottom
/// radius, middle children stay nearly square, and every item is separated
/// by a small gap — the M3E grouped-list container style.
class MESliverList extends StatelessWidget {
  const MESliverList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.gap = 2,
    this.backgroundColor,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double gap;
  final Color? backgroundColor;

  BorderRadius _radiusFor(int index) {
    const large = Radius.circular(MECorners.large);
    const small = Radius.circular(MECorners.extraSmall);
    if (itemCount == 1) return const BorderRadius.all(large);
    if (index == 0) {
      return const BorderRadius.vertical(top: large, bottom: small);
    }
    if (index == itemCount - 1) {
      return const BorderRadius.vertical(top: small, bottom: large);
    }
    return const BorderRadius.all(small);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = backgroundColor ?? scheme.surfaceContainerLow;

    return SliverList.separated(
      itemCount: itemCount,
      separatorBuilder: (_, __) => SizedBox(height: gap),
      itemBuilder: (context, index) => Material(
        color: color,
        borderRadius: _radiusFor(index),
        clipBehavior: Clip.antiAlias,
        child: itemBuilder(context, index),
      ),
    );
  }
}

/// A Material 3 Expressive sliver grid.
///
/// Replaces [SliverGrid]. Every tile is clipped to the expressive large
/// corner radius with uniform gaps.
class MESliverGrid extends StatelessWidget {
  const MESliverGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.crossAxisCount = 2,
    this.spacing = 8,
    this.childAspectRatio = 1,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final int crossAxisCount;
  final double spacing;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return SliverGrid.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => ClipRRect(
        borderRadius: BorderRadius.circular(MECorners.large),
        child: itemBuilder(context, index),
      ),
    );
  }
}

/// A Material 3 Expressive pinned sliver header.
///
/// Replaces [SliverPersistentHeader] boilerplate. Pins a pill-shaped
/// section header that gains a surface container background once content
/// scrolls beneath it.
class MESliverPinnedHeader extends StatelessWidget {
  const MESliverPinnedHeader({
    super.key,
    required this.title,
    this.trailing,
    this.height = 56,
  });

  final Widget title;
  final Widget? trailing;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _MEPinnedHeaderDelegate(
        title: title,
        trailing: trailing,
        height: height,
      ),
    );
  }
}

class _MEPinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _MEPinnedHeaderDelegate({
    required this.title,
    required this.trailing,
    required this.height,
  });

  final Widget title;
  final Widget? trailing;
  final double height;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final scheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: overlapsContent ? scheme.surfaceContainer : scheme.surface,
        borderRadius: overlapsContent
            ? const BorderRadius.vertical(
                bottom: Radius.circular(MECorners.large),
              )
            : BorderRadius.zero,
      ),
      child: Row(
        children: [
          Expanded(
            child: DefaultTextStyle.merge(
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
              child: title,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_MEPinnedHeaderDelegate oldDelegate) =>
      title != oldDelegate.title ||
      trailing != oldDelegate.trailing ||
      height != oldDelegate.height;
}

/// A Material 3 Expressive section header sliver (non-pinned).
///
/// Use above an [MESliverList] to label a group.
class MESliverSectionHeader extends StatelessWidget {
  const MESliverSectionHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}
