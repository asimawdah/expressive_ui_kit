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
}) {
  _METoastController.instance.show(
    context,
    message: message,
    kind: kind,
    icon: icon,
    duration: duration,
  );
}

/// Singleton managing the single visible toast entry.
class _METoastController {
  _METoastController._();

  static final _METoastController instance = _METoastController._();

  OverlayEntry? _entry;
  Timer? _timer;
  final GlobalKey<_METoastWidgetState> _key = GlobalKey();

  void show(
    BuildContext context, {
    required String message,
    required METoastKind kind,
    IconData? icon,
    required Duration duration,
  }) {
    _timer?.cancel();
    // Replace any visible toast immediately.
    _entry?.remove();
    _entry = OverlayEntry(
      builder: (context) => _METoastWidget(
        key: _key,
        message: message,
        kind: kind,
        icon: icon,
        onDismissed: _removeEntry,
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(_entry!);
    _timer = Timer(duration, () => _key.currentState?.hide());
  }

  void _removeEntry() {
    _entry?.remove();
    _entry = null;
  }
}

class _METoastWidget extends StatefulWidget {
  const _METoastWidget({
    super.key,
    required this.message,
    required this.kind,
    required this.onDismissed,
    this.icon,
  });

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

  @override
  void initState() {
    super.initState();
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
