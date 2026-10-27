import 'package:flutter/material.dart';

import '../theme/me_shapes.dart';

/// A Material 3 Expressive skeleton loading placeholder.
///
/// Renders a shaped surface with a soft traveling shimmer highlight.
/// Compose primitives ([MESkeleton.line], [MESkeleton.circle],
/// [MESkeleton.box]) to sketch the layout of loading content, or wrap a
/// subtree in [MESkeletonizer] to fade between skeleton and content.
class MESkeleton extends StatefulWidget {
  const MESkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.shape,
  });

  /// A text-line placeholder.
  const MESkeleton.line({super.key, this.width, this.height = 14})
      : shape = null;

  /// A circular placeholder (avatar, icon).
  const MESkeleton.circle({super.key, double size = 40})
      : width = size,
        height = size,
        shape = const CircleBorder();

  /// A rectangular block placeholder (image, card).
  const MESkeleton.box({super.key, this.width, this.height = 96})
      : shape = const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(MECorners.large)),
        );

  final double? width;
  final double height;
  final ShapeBorder? shape;

  @override
  State<MESkeleton> createState() => _MESkeletonState();
}

class _MESkeletonState extends State<MESkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = scheme.surfaceContainerHigh;
    final highlight = scheme.surfaceContainerLowest;
    final shape = widget.shape ??
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.height / 2),
        );

    return Semantics(
      label: 'Loading',
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          // The highlight band travels from -1 to 2 so it fully enters
          // and exits the surface each cycle.
          final dx = -1.0 + 3.0 * _controller.value;
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: ShapeDecoration(
              shape: shape,
              gradient: LinearGradient(
                begin: Alignment(dx - 1, 0),
                end: Alignment(dx + 1, 0),
                colors: [base, highlight, base],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Cross-fades between a skeleton sketch and real content using the
/// theme's effects spring timing.
class MESkeletonizer extends StatelessWidget {
  const MESkeletonizer({
    super.key,
    required this.loading,
    required this.skeleton,
    required this.child,
  });

  final bool loading;
  final Widget skeleton;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: loading
          ? KeyedSubtree(key: const ValueKey('skeleton'), child: skeleton)
          : KeyedSubtree(key: const ValueKey('content'), child: child),
    );
  }
}
