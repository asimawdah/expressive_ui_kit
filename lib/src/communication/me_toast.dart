import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/me_motion.dart';
import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';

/// The visual intent of a toast shown by [showMEToast].
enum METoastKind { info, success, warning, error }

/// Shows a Material 3 Expressive toast: a floating pill that springs down
/// from the top of the screen, pauses, and springs back up.
///
/// Unlike a snack bar it does not participate in scaffold layout — it uses
/// the root [Overlay], so it works from dialogs and sheets too. Successive
/// toasts replace the current one.
///
/// ```dart
/// showMEToast(context, message: 'Profile saved',
///     kind: METoastKind.success);
/// ```
void showMEToast(
  BuildContext context, {
  required String message,
  METoastKind kind = METoastKind.info,
  IconData? icon,
  Duration duration = const Duration(seconds: 3),
  OverlayState? overlay,
}) {
  _METoastController.instance.show(
    context,
    message: message,
    kind: kind,
    icon: icon,
    duration: duration,
    overlay: overlay,
  );
}

/// Singleton managing the single visible toast entry.
class _METoastController {
  _METoastController._();

  static final _METoastController instance = _METoastController._();

  OverlayEntry? _entry;
  Timer? _timer;
  _METoastWidgetState? _ownedState;
  final GlobalKey<_METoastWidgetState> _key = GlobalKey();

  /// Counts every toast the controller has created, and is what a widget
  /// carries back so its end can be refused if it is no longer the
  /// generation being cared for.
  int _epoch = 0;

  void show(
    BuildContext context, {
    required String message,
    required METoastKind kind,
    IconData? icon,
    required Duration duration,
    OverlayState? overlay,
  }) {
    final resolved = overlay ??
        Overlay.maybeOf(context, rootOverlay: true) ??
        Navigator.maybeOf(context, rootNavigator: true)?.overlay;
    if (resolved == null) return;

    _timer?.cancel();
    // Replace any visible toast immediately. The old entry is dropped from
    // the field before the new one is built, so the unmount that follows
    // can never reach anything but an end the controller already finished;
    // the epoch on the widget below closes that ordering in both
    // directions, since whether a removal unmounts before or after a
    // replacement mounts is not something the controller gets to schedule.
    _entry?.remove();
    _entry = OverlayEntry(
      builder: (context) => _METoastWidget(
        key: _key,
        epoch: ++_epoch,
        message: message,
        kind: kind,
        icon: icon,
        onDismissed: _removeEntry,
      ),
    );
    resolved.insert(_entry!);
    _timer = Timer(duration, () {
      _timer = null;
      _key.currentState?.hide();
    });
  }

  /// Ends the toast lifecycle: the visible entry is removed and its
  /// auto-hide timer cancelled.
  ///
  /// A toast outlives the screen that showed it — it lives on the root
  /// overlay while the entry that created it may be long gone — so nothing
  /// in the widget tree owns its end. Without this, dismissal before the
  /// timer fires leaves a pending [Timer] pointing at a state that no
  /// longer exists; with it, a teardown (a test's, or a page's own) can end
  /// the toast rather than leave it dangling.
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry = null;
    _ownedState = null;
  }

  /// Claims [state] as the live toast on behalf of the generation [epoch],
  /// called from the state's [State.initState].
  ///
  /// Claiming is how ownership leaves the [GlobalKey]: by the time a state
  /// is disposed during a tree replacement, the framework has already
  /// released the key, so nothing answers `currentState` at the moment the
  /// ownership question is asked again — only the direct reference does.
  void claim(_METoastWidgetState state, int epoch) {
    if (epoch != _epoch) return;
    _ownedState = state;
  }

  /// Ends the lifecycle when [state]'s own tree dies, which is how the
  /// toast learns it was replaced at any level above the overlay.
  ///
  /// Two guarded comparisons, and the deliberate reason for each: equal
  /// identity, because a stale toast finishing its exit animation must
  /// never end a newer one; equal epoch, because the ordering of "old
  /// entry's state disposes" against "new entry's state init's" inside one
  /// frame is not deterministic either, and a count is cheaper than a
  /// race. In an application this fires only when the root tree is torn
  /// down, which is why visible behaviour never changes; in a test it is
  /// the difference between a clean end and the framework reporting a
  /// pending timer.
  void endWith(_METoastWidgetState expiredState) {
    if (_ownedState != expiredState) return;
    if (expiredState.epoch != _epoch) return;
    dispose();
  }

  void _removeEntry() {
    // The tap-to-dismiss path arrives while the auto-hide timer still runs;
    // cancelling it here is what keeps a dismissed toast from leaving a
    // pending timer behind.
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry = null;
    _ownedState = null;
  }
}

/// Ends any toast [showMEToast] is still animating, and cancels its timer.
///
/// The pair of the module's entry point: `showMEToast` starts a lifecycle
/// that no widget can own, because the entry lives on the root overlay.
/// Call it where that lifecycle should end — a test tear-down, or an app
/// teardown that must not leave timers running.
void disposeMEToast() => _METoastController.instance.dispose();

class _METoastWidget extends StatefulWidget {
  const _METoastWidget({
    super.key,
    required this.epoch,
    required this.message,
    required this.kind,
    required this.onDismissed,
    this.icon,
  });

  /// The generation this widget belongs to, matched against the
  /// controller's counter so a replaced toast can never retire its
  /// successor's timer.
  final int epoch;

  final String message;
  final METoastKind kind;
  final IconData? icon;
  final VoidCallback onDismissed;

  @override
  State<_METoastWidget> createState() => _METoastWidgetState();
}

class _METoastWidgetState extends State<_METoastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _slide = AnimationController.unbounded(
    vsync: this,
    value: 0,
  );
  bool _hiding = false;

  /// The generation this state was built for; see [_METoastWidget.epoch].
  int get epoch => widget.epoch;

  @override
  void initState() {
    super.initState();
    _METoastController.instance.claim(this, widget.epoch);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        springTo(_slide, 1, METheme.of(context).motion.defaultSpatial);
      }
    });
    _slide.addListener(() {
      if (_hiding && _slide.value <= 0.02) {
        widget.onDismissed();
      }
    });
  }

  void hide() {
    if (_hiding || !mounted) return;
    _hiding = true;
    springTo(_slide, 0, METheme.of(context).motion.defaultEffects);
  }

  @override
  void dispose() {
    // The tree this state lived in is gone, whatever replaced it. If this
    // toast is still the current one, its auto-hide timer would otherwise
    // keep running against a state that no longer exists, which the test
    // framework reports as a pending timer and a real application would
    // carry as a dead callback.
    _METoastController.instance.endWith(this);
    _slide.dispose();
    super.dispose();
  }

  (Color, Color, IconData) _palette(ColorScheme scheme) {
    switch (widget.kind) {
      case METoastKind.info:
        return (
          scheme.inverseSurface,
          scheme.onInverseSurface,
          Icons.info_outline,
        );
      case METoastKind.success:
        return (
          scheme.primaryContainer,
          scheme.onPrimaryContainer,
          Icons.check_circle_outline,
        );
      case METoastKind.warning:
        return (
          scheme.tertiaryContainer,
          scheme.onTertiaryContainer,
          Icons.warning_amber_outlined,
        );
      case METoastKind.error:
        return (
          scheme.errorContainer,
          scheme.onErrorContainer,
          Icons.error_outline,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final (bg, fg, defaultIcon) = _palette(scheme);
    final topInset = MediaQuery.paddingOf(context).top;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: _slide,
          builder: (context, child) {
            final t = _slide.value;
            return Transform.translate(
              offset: Offset(0, (t - 1) * (topInset + 72)),
              child: Opacity(
                opacity: t.clamp(0.0, 1.0),
                child: child,
              ),
            );
          },
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: GestureDetector(
                onTap: hide,
                child: Material(
                  color: bg,
                  elevation: 6,
                  shadowColor: Colors.black26,
                  shape: MEShapeScheme.fromCorner(MECorners.full),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(widget.icon ?? defaultIcon, size: 20, color: fg),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            widget.message,
                            style: text.bodyMedium!.copyWith(color: fg),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
