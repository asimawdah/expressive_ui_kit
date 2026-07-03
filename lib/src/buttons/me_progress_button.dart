import 'package:flutter/material.dart';

import '../internal/me_pressable.dart';
import '../progress/me_loading_indicator.dart';
import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// A Material 3 Expressive button that runs an async action and morphs
/// into a loading state while it is pending.
///
/// On press the label fades out and the pill spring-shrinks toward a
/// circle containing an [MELoadingIndicator]; when the future completes
/// the button springs back. Repeated presses are ignored while pending.
class MEProgressButton extends StatefulWidget {
  const MEProgressButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.icon,
    this.height = 40,
  });

  final Widget child;

  /// The async action. The button shows the loading state until the
  /// returned future completes (or errors).
  final Future<void> Function()? onPressed;
  final Widget? icon;
  final double height;

  @override
  State<MEProgressButton> createState() => _MEProgressButtonState();
}

class _MEProgressButtonState extends State<MEProgressButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim =
      AnimationController.unbounded(vsync: this, value: 0);
  bool _pending = false;

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    if (_pending || widget.onPressed == null) return;
    setState(() => _pending = true);
    springTo(_anim, 1, METheme.of(context).motion.defaultSpatial);
    try {
      await widget.onPressed!();
    } finally {
      if (mounted) {
        setState(() => _pending = false);
        springTo(_anim, 0, METheme.of(context).motion.defaultSpatial);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final enabled = widget.onPressed != null && !_pending;

    final fg = widget.onPressed == null
        ? colors.onSurface.withValues(alpha: 0.38)
        : colors.onPrimary;

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        final t = _anim.value.clamp(0.0, 1.0);
        return MEPressable(
          onPressed: enabled ? _run : null,
          enabled: enabled,
          shape: const StadiumBorder(),
          color: widget.onPressed == null
              ? colors.onSurface.withValues(alpha: 0.12)
              : Color.lerp(
                  colors.primary, colors.primaryContainer, t * 0.35)!,
          overlayColor: fg.withValues(alpha: 0.1),
          haptics: true,
          child: SizedBox(
            height: widget.height,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Label row fades and shrinks away while pending.
                Opacity(
                  opacity: (1 - t * 1.6).clamp(0.0, 1.0),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      // Pill shrinks toward a circle as padding collapses.
                      horizontal: 24 - 12 * t,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          IconTheme.merge(
                            data: IconThemeData(size: 18, color: fg),
                            child: widget.icon!,
                          ),
                          const SizedBox(width: 8),
                        ],
                        DefaultTextStyle.merge(
                          style: textTheme.labelLarge!.copyWith(color: fg),
                          child: widget.child,
                        ),
                      ],
                    ),
                  ),
                ),
                // Loading indicator scales in.
                if (t > 0.05)
                  Transform.scale(
                    scale: t.clamp(0.0, 1.1),
                    child: SizedBox(
                      width: widget.height * 0.6,
                      height: widget.height * 0.6,
                      child: MELoadingIndicator(
                        size: widget.height * 0.6,
                        color: fg,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
