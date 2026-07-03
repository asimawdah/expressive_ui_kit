import 'package:flutter/material.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// A Material 3 Expressive switch.
///
/// Replaces [Switch]. The thumb morphs shape with state: a small circle
/// when off, a large circle when on, and a squashed pill while pressed —
/// driven by spatial springs so the thumb overshoots playfully.
class MESwitch extends StatefulWidget {
  const MESwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.icon,
    this.selectedIcon,
    this.semanticsLabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  /// Optional icon shown in the thumb when off.
  final Widget? icon;

  /// Optional icon shown in the thumb when on.
  final Widget? selectedIcon;
  final String? semanticsLabel;

  @override
  State<MESwitch> createState() => _MESwitchState();
}

class _MESwitchState extends State<MESwitch> with TickerProviderStateMixin {
  late final AnimationController _position = AnimationController.unbounded(
    vsync: this,
    value: widget.value ? 1 : 0,
  );
  late final AnimationController _press = AnimationController.unbounded(
    vsync: this,
    value: 0,
  );

  static const double _trackWidth = 60;
  static const double _trackHeight = 34;

  @override
  void didUpdateWidget(MESwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      springTo(
        _position,
        widget.value ? 1 : 0,
        METheme.of(context).motion.defaultSpatial,
      );
    }
  }

  @override
  void dispose() {
    _position.dispose();
    _press.dispose();
    super.dispose();
  }

  void _setPressed(bool pressed) {
    springTo(
      _press,
      pressed ? 1 : 0,
      pressed
          ? METheme.of(context).motion.fastSpatial
          : METheme.of(context).motion.defaultSpatial,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final enabled = widget.onChanged != null;

    return Semantics(
      toggled: widget.value,
      label: widget.semanticsLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _setPressed(true) : null,
        onTapUp: enabled ? (_) => _setPressed(false) : null,
        onTapCancel: enabled ? () => _setPressed(false) : null,
        onTap: enabled ? () => widget.onChanged!(!widget.value) : null,
        child: AnimatedBuilder(
          animation: Listenable.merge([_position, _press]),
          builder: (context, _) {
            final t = _position.value.clamp(-0.2, 1.2);
            final press = _press.value.clamp(0.0, 1.0);

            final trackColor = Color.lerp(
              enabled
                  ? colors.surfaceContainerHighest
                  : colors.onSurface.withValues(alpha: 0.12),
              enabled ? colors.primary : colors.onSurface.withValues(alpha: 0.12),
              t.clamp(0.0, 1.0),
            )!;
            final borderColor = Color.lerp(
              colors.outline,
              Colors.transparent,
              t.clamp(0.0, 1.0),
            )!;

            // Thumb geometry: off = 16dp dot, on = 24dp; pressed squashes
            // into a wider pill.
            final baseSize = 16.0 + 8.0 * t.clamp(0.0, 1.0);
            final thumbW = baseSize + press * 8;
            final thumbH = baseSize - press * 2;
            final thumbColor = Color.lerp(
              enabled ? colors.outline : colors.onSurface.withValues(alpha: 0.38),
              enabled ? colors.onPrimary : colors.surface,
              t.clamp(0.0, 1.0),
            )!;

            const pad = 5.0;
            final travel = _trackWidth - pad * 2 - thumbW;
            final thumbX = pad + travel * t.clamp(-0.05, 1.05);

            final iconWidget = widget.value ? widget.selectedIcon : widget.icon;

            return SizedBox(
              width: _trackWidth,
              height: _trackHeight,
              child: Stack(
                children: [
                  // Track.
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: trackColor,
                        border: Border.all(color: borderColor, width: 2),
                        borderRadius:
                            BorderRadius.circular(_trackHeight / 2),
                      ),
                    ),
                  ),
                  // Thumb.
                  Positioned(
                    left: thumbX,
                    top: (_trackHeight - thumbH) / 2,
                    child: Container(
                      width: thumbW,
                      height: thumbH,
                      decoration: BoxDecoration(
                        color: thumbColor,
                        borderRadius: BorderRadius.circular(thumbH / 2),
                      ),
                      child: iconWidget == null
                          ? null
                          : Center(
                              child: IconTheme.merge(
                                data: IconThemeData(
                                  size: thumbH * 0.7,
                                  color: widget.value
                                      ? colors.primary
                                      : colors.surfaceContainerHighest,
                                ),
                                child: iconWidget,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
