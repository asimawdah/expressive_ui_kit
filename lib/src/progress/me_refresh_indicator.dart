import 'package:flutter/material.dart';

import 'me_loading_indicator.dart';

/// A Material 3 Expressive pull-to-refresh indicator.
///
/// Replaces [RefreshIndicator]. Overscroll pulls down a contained pill
/// that scales in with the drag; while refreshing it shows the M3E
/// shape-morphing [MELoadingIndicator] instead of the classic circular
/// spinner.
class MERefreshIndicator extends StatefulWidget {
  const MERefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
    this.triggerDistance = 96,
  });

  final RefreshCallback onRefresh;

  /// The scrollable content. Must contain a scrollable descendant that
  /// dispatches [ScrollNotification]s (e.g. a [ListView] with
  /// [AlwaysScrollableScrollPhysics]).
  final Widget child;

  /// Overscroll distance required to trigger a refresh.
  final double triggerDistance;

  @override
  State<MERefreshIndicator> createState() => _MERefreshIndicatorState();
}

class _MERefreshIndicatorState extends State<MERefreshIndicator> {
  double _pull = 0;
  bool _refreshing = false;

  bool _handleNotification(ScrollNotification notification) {
    if (_refreshing) return false;

    if (notification is OverscrollNotification &&
        notification.overscroll < 0) {
      setState(() {
        _pull = (_pull - notification.overscroll)
            .clamp(0.0, widget.triggerDistance * 1.5);
      });
    } else if (notification is ScrollUpdateNotification &&
        _pull > 0 &&
        (notification.dragDetails == null)) {
      // Drag released.
      if (_pull >= widget.triggerDistance) {
        _startRefresh();
      } else {
        setState(() => _pull = 0);
      }
    } else if (notification is ScrollEndNotification && _pull > 0) {
      if (_pull >= widget.triggerDistance) {
        _startRefresh();
      } else {
        setState(() => _pull = 0);
      }
    }
    return false;
  }

  Future<void> _startRefresh() async {
    if (_refreshing) return;
    setState(() {
      _refreshing = true;
      _pull = widget.triggerDistance;
    });
    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        setState(() {
          _refreshing = false;
          _pull = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = (_pull / widget.triggerDistance).clamp(0.0, 1.0);

    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: _handleNotification,
          child: widget.child,
        ),
        if (_pull > 0)
          Positioned(
            top: 16 + _pull * 0.35,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Center(
                child: Transform.scale(
                  scale: _refreshing ? 1.0 : (0.5 + 0.5 * t),
                  child: Opacity(
                    opacity: t,
                    child: const MELoadingIndicator(
                      size: 28,
                      contained: true,
                      semanticsLabel: 'Refreshing',
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
