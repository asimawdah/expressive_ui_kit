import 'package:flutter/material.dart';

/// Size variants for [MEAppBar], per the M3 Expressive app bar spec.
enum MEAppBarSize {
  /// 64dp toolbar row only.
  small,

  /// Flexible: expands to 112dp with an emphasized headline.
  medium,

  /// Flexible: expands to 152dp with a display-scale headline.
  large,
}

/// A Material 3 Expressive top app bar.
///
/// Replaces [AppBar] / [SliverAppBar]. The medium and large variants
/// ("flexible" app bars in M3E) show an emphasized headline that scales
/// and fades into the toolbar row as content scrolls, and the bar
/// surface switches to a container color once content is beneath it.
///
/// Use inside a [CustomScrollView]:
///
/// ```dart
/// CustomScrollView(
///   slivers: [
///     MEAppBar(
///       title: const Text('Headline'),
///       subtitle: const Text('Supporting text'),
///       size: MEAppBarSize.large,
///     ),
///     ...
///   ],
/// )
/// ```
class MEAppBar extends StatelessWidget {
  const MEAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions = const [],
    this.size = MEAppBarSize.small,
    this.backgroundColor,
    this.pinned = true,
    this.centerTitle = false,
    this.bottom,
  });

  final Widget title;

  /// An optional subtitle, new in M3 Expressive app bars.
  final Widget? subtitle;
  final Widget? leading;
  final List<Widget> actions;
  final MEAppBarSize size;
  final Color? backgroundColor;
  final bool pinned;

  /// Whether the collapsed title row is centered.
  final bool centerTitle;

  /// A widget below the toolbar row, typically an `METabBar`.
  final PreferredSizeWidget? bottom;

  static const double _toolbarHeight = 64;

  double get _expandedHeight => switch (size) {
        MEAppBarSize.small => _toolbarHeight,
        MEAppBarSize.medium => 112,
        MEAppBarSize.large => 152,
      };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (size == MEAppBarSize.small) {
      return SliverAppBar(
        pinned: pinned,
        leading: leading,
        actions: actions,
        toolbarHeight: _toolbarHeight,
        centerTitle: centerTitle,
        backgroundColor: backgroundColor ?? colors.surface,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: bottom,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: centerTitle
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            DefaultTextStyle.merge(
              style: textTheme.titleLarge!.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
              child: title,
            ),
            if (subtitle != null)
              DefaultTextStyle.merge(
                style: textTheme.labelMedium!
                    .copyWith(color: colors.onSurfaceVariant),
                child: subtitle!,
              ),
          ],
        ),
      );
    }

    final headlineStyle = (size == MEAppBarSize.medium
            ? textTheme.headlineMedium
            : textTheme.displaySmall)!
        .copyWith(
      color: colors.onSurface,
      // Emphasized weight is the M3E signature for flexible app bars.
      fontWeight: FontWeight.w700,
      letterSpacing: -0.25,
    );
    final collapsedStyle = textTheme.titleLarge!.copyWith(
      color: colors.onSurface,
      fontWeight: FontWeight.w600,
    );

    final bottomHeight = bottom?.preferredSize.height ?? 0;

    return SliverAppBar(
      pinned: pinned,
      expandedHeight: _expandedHeight + bottomHeight,
      collapsedHeight: _toolbarHeight,
      toolbarHeight: _toolbarHeight,
      leading: leading,
      actions: actions,
      backgroundColor: backgroundColor ?? colors.surface,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      bottom: bottom,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final currentHeight = constraints.maxHeight - bottomHeight;
          // t: 1.0 fully expanded -> 0.0 fully collapsed.
          final t = ((currentHeight - _toolbarHeight) /
                  (_expandedHeight - _toolbarHeight))
              .clamp(0.0, 1.0);

          // Headline: scales down and fades out as the bar collapses.
          final headlineOpacity = ((t - 0.35) / 0.65).clamp(0.0, 1.0);
          // Collapsed title: fades in only near the collapsed state.
          final collapsedOpacity = (1 - t / 0.3).clamp(0.0, 1.0);

          return ColoredBox(
            // Scrolled-under surface change happens as the bar collapses.
            color: backgroundColor ??
                Color.lerp(
                    colors.surfaceContainer, colors.surface, t.clamp(0, 1))!,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Expanded emphasized headline, bottom-aligned.
                PositionedDirectional(
                  start: 16,
                  end: 16,
                  bottom: 16 + bottomHeight,
                  child: Opacity(
                    opacity: headlineOpacity,
                    child: Transform.scale(
                      scale: 0.8 + 0.2 * t,
                      alignment: AlignmentDirectional.bottomStart,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DefaultTextStyle.merge(
                            style: headlineStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            child: title,
                          ),
                          if (subtitle != null)
                            DefaultTextStyle.merge(
                              style: textTheme.bodyMedium!
                                  .copyWith(color: colors.onSurfaceVariant),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              child: subtitle!,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Collapsed toolbar title.
                Positioned(
                  // Clear the leading widget.
                  left: leading != null ? 56 : 16,
                  right: 16,
                  top: 0,
                  height: _toolbarHeight,
                  child: Opacity(
                    opacity: collapsedOpacity,
                    child: Align(
                      alignment: centerTitle
                          ? Alignment.center
                          : AlignmentDirectional.centerStart,
                      child: DefaultTextStyle.merge(
                        style: collapsedStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        child: title,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
