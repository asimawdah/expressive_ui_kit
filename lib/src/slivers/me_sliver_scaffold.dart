import 'package:flutter/material.dart';

import '../progress/me_refresh_indicator.dart';

/// A scaffold tuned for screens built from slivers.
///
/// It supports a regular body or a [CustomScrollView] body, optional large
/// sliver app bars, pull-to-refresh, sliver spacing, and bottom navigation.
class MESliverScaffold extends StatefulWidget {
  MESliverScaffold({
    super.key,
    this.title,
    this.withoutAppBar = false,
    this.spacer = 12.0,
    this.slivers = const [],
    this.appBarBottom,
    this.leadingAppBar,
    this.hideAppBar = false,
    this.appBarActions = const [],
    this.extendedAppBar = true,
    this.bottomNavigationBar,
    this.padding,
    this.body,
    this.resizeToAvoidBottomInset = true,
    this.onRefresh,
    this.onNoMoreToScroll,
    this.shrinkWrap = false,
    this.centerTitle = false,
    this.backgroundColor,
    this.floatingActionButton,
    this.customAppBar,
  }) : assert(
          slivers.isEmpty || body == null,
          'Only slivers or body can be passed',
        );

  final String? title;
  final List<Widget> slivers;
  final double spacer;
  final Widget? leadingAppBar;
  final List<Widget> appBarActions;
  final bool extendedAppBar;
  final bool centerTitle;
  final bool hideAppBar;
  final bool withoutAppBar;
  final Widget? appBarBottom;
  final Widget? body;
  final Widget? bottomNavigationBar;
  final EdgeInsetsGeometry? padding;
  final bool resizeToAvoidBottomInset;
  final VoidCallback? onNoMoreToScroll;
  final Future<void> Function()? onRefresh;
  final bool shrinkWrap;
  final Color? backgroundColor;
  final Widget? floatingActionButton;
  final Widget? customAppBar;

  @override
  State<MESliverScaffold> createState() => _MESliverScaffoldState();
}

/// Compatibility name for apps that already use `SliverScaffold`.
class SliverScaffold extends MESliverScaffold {
  SliverScaffold({
    super.key,
    super.title,
    super.withoutAppBar,
    super.spacer,
    super.slivers,
    super.appBarBottom,
    super.leadingAppBar,
    super.hideAppBar,
    super.appBarActions,
    super.extendedAppBar,
    super.bottomNavigationBar,
    super.padding,
    super.body,
    super.resizeToAvoidBottomInset,
    super.onRefresh,
    super.onNoMoreToScroll,
    super.shrinkWrap,
    super.centerTitle,
    super.backgroundColor,
    super.floatingActionButton,
    super.customAppBar,
  });
}

class _MESliverScaffoldState extends State<MESliverScaffold> {
  late final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      floatingActionButton: widget.floatingActionButton,
      bottomNavigationBar: widget.bottomNavigationBar,
      backgroundColor: widget.backgroundColor,
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (widget.body != null) {
      return NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return widget.withoutAppBar ? [] : [_buildAppBar(context)];
        },
        body: widget.body!,
      );
    }

    // One CustomScrollView (app bar + content) so overscroll reaches the
    // refresh indicator — NestedScrollView splits header/body and breaks
    // pull-to-refresh with collapsing large app bars. Indicator UX matches
    // maham's forked Material RefreshIndicator.
    final scrollView = CustomScrollView(
      controller: _scrollController,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.onRefresh != null
          ? const AlwaysScrollableScrollPhysics()
          : null,
      slivers: [
        if (!(widget.hideAppBar || widget.withoutAppBar))
          _buildAppBar(context),
        if (widget.spacer > 0)
          SliverToBoxAdapter(child: SizedBox(height: widget.spacer)),
        ..._buildSlivers(widget.slivers),
        SliverToBoxAdapter(child: SizedBox(height: widget.spacer)),
      ],
    );

    final onRefresh = widget.onRefresh;
    if (onRefresh == null) return scrollView;

    return MERefreshIndicator(
      // Sit below the status bar + pinned app bar, not over the device chrome.
      edgeOffset: _refreshIndicatorEdgeOffset(context),
      displacement: 16,
      onRefresh: () async {
        // Fire page reload, then hold the spinner briefly (maham pattern).
        await onRefresh();
        await Future<void>.delayed(const Duration(seconds: 3));
      },
      child: scrollView,
    );
  }

  /// Top inset so [MERefreshIndicator] settles under the app bar.
  double _refreshIndicatorEdgeOffset(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    if (widget.hideAppBar || widget.withoutAppBar) return topPadding;

    final custom = widget.customAppBar;
    if (custom is AppBar) {
      var offset = topPadding + (custom.toolbarHeight ?? kToolbarHeight);
      final bottom = custom.bottom;
      if (bottom != null) offset += bottom.preferredSize.height;
      return offset;
    }
    if (custom is PreferredSizeWidget) {
      return topPadding + custom.preferredSize.height;
    }

    var offset = topPadding + kToolbarHeight;
    if (widget.appBarBottom != null) offset += 60;
    // Expanded large app bars still collapse to the toolbar while pinned;
    // pull-to-refresh at the top edge uses the collapsed chrome height.
    return offset;
  }

  List<Widget> _buildSlivers(List<Widget> slivers) {
    final spacer = widget.spacer > 0
        ? SliverToBoxAdapter(child: SizedBox(height: widget.spacer))
        : null;

    Widget wrapPadding(Widget sliver) => widget.padding != null
        ? SliverPadding(padding: widget.padding!, sliver: sliver)
        : sliver;

    final result = <Widget>[];
    for (var i = 0; i < slivers.length; i++) {
      if (i > 0 && spacer != null) result.add(spacer);
      result.add(wrapPadding(slivers[i]));
    }
    return result;
  }

  Widget _buildAppBar(BuildContext context) {
    final actions = [...widget.appBarActions, const SizedBox(width: 12)];

    if (widget.customAppBar != null) {
      final child = widget.customAppBar!;

      if (child is AppBar) {
        return SliverAppBar(
          key: child.key,
          pinned: true,
          automaticallyImplyLeading: false,
          leading: child.leading,
          title: child.title,
          actions: child.actions,
          centerTitle: child.centerTitle,
          titleSpacing: child.titleSpacing,
          toolbarHeight: child.toolbarHeight ?? kToolbarHeight,
          surfaceTintColor: Colors.transparent,
          bottom: child.bottom,
        );
      }

      final toolbarHeight = child is PreferredSizeWidget
          ? child.preferredSize.height
          : kToolbarHeight;

      return SliverAppBar(
        toolbarHeight: toolbarHeight,
        pinned: true,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        surfaceTintColor: Colors.transparent,
        title: child,
      );
    }

    if (widget.extendedAppBar) {
      return SliverAppBar.large(
        leading: widget.leadingAppBar,
        automaticallyImplyLeading: false,
        centerTitle: widget.centerTitle,
        backgroundColor: widget.backgroundColor,
        surfaceTintColor: Colors.transparent,
        title: widget.title != null
            ? Text(
                widget.title!,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
              )
            : null,
        actions: actions,
        bottom: widget.appBarBottom != null
            ? PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: widget.appBarBottom ?? const SizedBox.shrink(),
              )
            : null,
      );
    }

    return SliverAppBar(
      leading: widget.leadingAppBar,
      automaticallyImplyLeading: false,
      centerTitle: widget.centerTitle,
      title: widget.title != null
          ? Text(
              widget.title!,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.1,
                  ),
            )
          : null,
      actions: actions,
      pinned: true,
      surfaceTintColor: Colors.transparent,
      backgroundColor: widget.backgroundColor,
      bottom: widget.appBarBottom != null
          ? PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: widget.appBarBottom ?? const SizedBox.shrink(),
            )
          : null,
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) widget.onNoMoreToScroll?.call();
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= maxScroll * 0.5;
  }
}
