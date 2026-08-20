import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/me_motion.dart';
import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';

/// Bouncy snap-home after an aborted swipe (380 / 0.6).
const MESpringSpec _kSnapBack = MESpringSpec(
  dampingRatio: 0.6,
  stiffness: 380,
);

/// Fly-off after crossing the dismiss threshold (400 / 0.8).
const MESpringSpec _kFly = MESpringSpec(
  dampingRatio: 0.8,
  stiffness: 400,
);

/// A Material 3 Expressive swipe-to-dismiss wrapper.
///
/// Replaces [Dismissible]. The card follows the finger, morphs rounder as it
/// travels, and reveals a pill action behind it — archive toward [start]
/// (typically right in RTL / left in LTR) and delete toward [end]. Release
/// below the threshold springs home; past the threshold the card flies off
/// with a spatial spring, then collapses.
class MEDismissible extends StatefulWidget {
  const MEDismissible({
    required Key dismissKey,
    required this.child,
    this.onDismissed,
    this.confirmDismiss,
    this.direction = DismissDirection.endToStart,
    this.icon = Icons.delete_outline,
    this.startIcon = Icons.archive_outlined,
    this.endIcon,
    this.backgroundColor,
    this.foregroundColor,
    this.startBackgroundColor,
    this.endBackgroundColor,
    this.dismissThreshold = 0.28,
    this.onDragFraction,
  }) : super(key: dismissKey);

  /// Same as [key] — identifies this row in a list.
  Key get dismissKey => key!;

  final Widget child;
  final ValueChanged<DismissDirection>? onDismissed;
  final ConfirmDismissCallback? confirmDismiss;
  final DismissDirection direction;

  /// Fallback icon used on both sides when [endIcon] is null and no
  /// start/end colors are provided — kept for the original single-action API.
  final IconData icon;

  /// Icon revealed when swiping toward the start edge (archive by default).
  final IconData startIcon;

  /// Icon revealed when swiping toward the end edge. Defaults to [icon].
  final IconData? endIcon;

  /// Fallback color for both action pills. Defaults to the error container.
  final Color? backgroundColor;
  final Color? foregroundColor;

  /// Color of the start-edge pill. Defaults to tertiary container.
  final Color? startBackgroundColor;

  /// Color of the end-edge pill. Defaults to [backgroundColor] / error.
  final Color? endBackgroundColor;

  /// Fraction of width that must be dragged before a release dismisses.
  final double dismissThreshold;

  /// Signed drag progress in **start→end** space: `+1` is a full-width
  /// swipe toward the end, `-1` toward the start. Reported during the
  /// finger drag *and* the settle/fly springs so neighbours can follow.
  final ValueChanged<double>? onDragFraction;

  @override
  State<MEDismissible> createState() => _MEDismissibleState();
}

class _MEDismissibleState extends State<MEDismissible>
    with TickerProviderStateMixin {
  late final AnimationController _slide = AnimationController.unbounded(
    vsync: this,
    value: 0,
  );
  late final AnimationController _collapse = AnimationController.unbounded(
    vsync: this,
    value: 1,
  );

  double _width = 1;
  bool _dragging = false;
  bool _settling = false;
  bool _crossed = false;

  @override
  void initState() {
    super.initState();
    _slide.addListener(_reportDrag);
  }

  @override
  void dispose() {
    _slide.removeListener(_reportDrag);
    _slide.dispose();
    _collapse.dispose();
    super.dispose();
  }

  void _reportDrag() {
    widget.onDragFraction?.call(_slide.value);
  }

  double _clampToDirection(double signed) {
    return switch (widget.direction) {
      DismissDirection.startToEnd => signed.clamp(0.0, 1.4),
      DismissDirection.endToStart => signed.clamp(-1.4, 0.0),
      DismissDirection.horizontal => signed.clamp(-1.4, 1.4),
      _ => 0,
    };
  }

  void _onDragStart(DragStartDetails _) {
    if (_settling) return;
    _slide.stop();
    _dragging = true;
    _crossed = false;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_dragging || _width <= 0) return;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    // Positive [signed] = toward the *end* edge (Material startToEnd).
    final delta = (rtl ? -details.delta.dx : details.delta.dx) / _width;
    final next = _clampToDirection(_slide.value + delta);
    _slide.value = next;
    final crossed = next.abs() >= widget.dismissThreshold;
    if (crossed != _crossed) {
      _crossed = crossed;
      HapticFeedback.selectionClick();
    }
  }

  Future<void> _onDragEnd(DragEndDetails details) async {
    if (!_dragging) return;
    _dragging = false;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final vx = (rtl
            ? -details.velocity.pixelsPerSecond.dx
            : details.velocity.pixelsPerSecond.dx) /
        _width;
    final signed = _slide.value;
    final shouldDismiss = signed.abs() >= widget.dismissThreshold ||
        (signed.abs() > 0.08 && vx.abs() > 1.2 && signed.sign == vx.sign);

    if (!shouldDismiss) {
      _settling = true;
      await springTo(_slide, 0, _kSnapBack, velocity: vx);
      _settling = false;
      widget.onDragFraction?.call(0);
      return;
    }

    final direction =
        signed >= 0 ? DismissDirection.startToEnd : DismissDirection.endToStart;
    if (widget.confirmDismiss != null) {
      final ok = await widget.confirmDismiss!(direction);
      if (!mounted) return;
      if (ok != true) {
        _settling = true;
        await springTo(_slide, 0, _kSnapBack, velocity: vx);
        _settling = false;
        widget.onDragFraction?.call(0);
        return;
      }
    }

    _settling = true;
    final flyTo = signed >= 0 ? 1.35 : -1.35;
    await springTo(_slide, flyTo, _kFly, velocity: vx);
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    await springTo(_collapse, 0, METheme.of(context).motion.fastSpatial);
    if (!mounted) return;
    widget.onDismissed?.call(direction);
    widget.onDragFraction?.call(0);
    _settling = false;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final startBg = widget.startBackgroundColor ?? scheme.tertiaryContainer;
    final endBg = widget.endBackgroundColor ??
        widget.backgroundColor ??
        scheme.errorContainer;
    final startFg = scheme.onTertiaryContainer;
    final endFg = widget.foregroundColor ?? scheme.onErrorContainer;
    final endIcon = widget.endIcon ?? widget.icon;

    return ClipRect(
      child: AnimatedBuilder(
        animation: Listenable.merge([_slide, _collapse]),
        builder: (context, _) {
          final t = _slide.value;
          final collapse = _collapse.value.clamp(0.0, 1.2);
          if (collapse <= 0.001) return const SizedBox.shrink();

          final progress = t.abs().clamp(0.0, 1.0);
          final towardEnd = t >= 0;
          final bg = towardEnd ? startBg : endBg;
          final fg = towardEnd ? startFg : endFg;
          final actionIcon = towardEnd ? widget.startIcon : endIcon;
          final iconScale = (0.55 + 0.7 * (progress / widget.dismissThreshold))
              .clamp(0.5, 1.25);

          return Align(
            alignment: Alignment.topCenter,
            heightFactor: collapse < 0.02 ? 0.02 : collapse,
            child: Opacity(
              opacity: collapse.clamp(0.0, 1.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  _width =
                      constraints.hasBoundedWidth && constraints.maxWidth > 0
                          ? constraints.maxWidth
                          : MediaQuery.sizeOf(context).width.clamp(1, 4000);
                  final dx = t *
                      _width *
                      (Directionality.of(context) == TextDirection.rtl
                          ? -1
                          : 1);
                  final restRadius = MECorners.large;
                  final dragRadius = MECorners.extraLargeIncreased;
                  final radius = restRadius +
                      (dragRadius - restRadius) * progress.clamp(0.0, 1.0);

                  return Stack(
                    fit: StackFit.passthrough,
                    children: [
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: bg,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Align(
                              alignment: towardEnd
                                  ? AlignmentDirectional.centerStart
                                  : AlignmentDirectional.centerEnd,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                ),
                                child: Transform.scale(
                                  scale: iconScale,
                                  child: Icon(actionIcon, color: fg),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onHorizontalDragStart: _onDragStart,
                        onHorizontalDragUpdate: _onDragUpdate,
                        onHorizontalDragEnd: _onDragEnd,
                        behavior: HitTestBehavior.translucent,
                        child: Transform.translate(
                          offset: Offset(dx, 0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(radius),
                            child: widget.child,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Broadcasts the in-flight swipe of one row so neighbours can be pulled.
class MEDismissibleDragScope extends InheritedWidget {
  const MEDismissibleDragScope({
    super.key,
    required this.dragIndex,
    required this.fraction,
    this.pull = 10,
    this.reach = 3,
    required super.child,
  });

  final int? dragIndex;

  /// Signed start→end fraction of the dragged row.
  final double fraction;
  final double pull;
  final int reach;

  static MEDismissibleDragScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MEDismissibleDragScope>();
  }

  /// Horizontal neighbour offset in logical pixels (start→end space).
  double offsetFor(int index, TextDirection direction) {
    final dragged = dragIndex;
    if (dragged == null || index == dragged) return 0;
    final distance = (index - dragged).abs();
    if (distance > reach) return 0;
    final falloff = 1.0 - distance / (reach + 1);
    final along = fraction.clamp(-1.0, 1.0) * pull * falloff;
    return direction == TextDirection.rtl ? -along : along;
  }

  @override
  bool updateShouldNotify(MEDismissibleDragScope oldWidget) {
    return dragIndex != oldWidget.dragIndex ||
        fraction != oldWidget.fraction ||
        pull != oldWidget.pull ||
        reach != oldWidget.reach;
  }
}
