import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// A Material 3 Expressive switch.
///
/// Replaces [Switch]. Track is 52×32. The thumb is a 16dp circle when off,
/// 24dp when on, and stretches toward the track height while pressed —
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

  /// Official M3 Expressive switch tokens.
  static const double _trackWidth = 52;
  static const double _trackHeight = 32;
  static const double _thumbOff = 16;
  static const double _thumbOn = 24;
  static const double _pad = 4;
  static const double _stateLayer = 40;

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

  void _commit(bool next) {
    if (widget.onChanged == null || next == widget.value) return;
    HapticFeedback.selectionClick();
    widget.onChanged!(next);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (widget.onChanged == null) return;
    final dx = Directionality.of(context) == TextDirection.rtl
        ? -details.delta.dx
        : details.delta.dx;
    final next =
        (_position.value + dx / (_trackWidth - _pad * 2)).clamp(0.0, 1.0);
    _position.value = next;
  }

  void _handleDragEnd(DragEndDetails details) {
    _setPressed(false);
    _commit(_position.value >= 0.5);
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
        onTap: enabled ? () => _commit(!widget.value) : null,
        onHorizontalDragStart: enabled ? (_) => _setPressed(true) : null,
        onHorizontalDragUpdate: enabled ? _handleDragUpdate : null,
        onHorizontalDragEnd: enabled ? _handleDragEnd : null,
        onHorizontalDragCancel: enabled ? () => _setPressed(false) : null,
        child: AnimatedBuilder(
          animation: Listenable.merge([_position, _press]),
          builder: (context, _) {
            final t = _position.value.clamp(-0.2, 1.2);
            final press = _press.value.clamp(0.0, 1.0);
            final selectedT = t.clamp(0.0, 1.0);

            final trackColor = Color.lerp(
              enabled
                  ? colors.surfaceContainerHighest
                  : colors.onSurface.withValues(alpha: 0.12),
              enabled
                  ? colors.primary
                  : colors.onSurface.withValues(alpha: 0.12),
              selectedT,
            )!;
            final borderColor = Color.lerp(
              colors.outline,
              Colors.transparent,
              selectedT,
            )!;

            final baseSize = _thumbOff + (_thumbOn - _thumbOff) * selectedT;
            // Pressed thumb stretches toward the track height.
            final thumbH = (baseSize - press * (baseSize - _trackHeight + 8))
                .clamp(14.0, _trackHeight - 4);
            final thumbW = baseSize + press * (_trackHeight - baseSize);
            final thumbColor = Color.lerp(
              enabled
                  ? colors.outline
                  : colors.onSurface.withValues(alpha: 0.38),
              enabled ? colors.onPrimary : colors.surface,
              selectedT,
            )!;

            final travel = _trackWidth - _pad * 2 - thumbW;
            final thumbX = _pad + travel * t.clamp(-0.05, 1.05);

            final iconWidget = widget.value ? widget.selectedIcon : widget.icon;

            return SizedBox(
              width: _trackWidth,
              height: _trackHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: trackColor,
                        border: Border.all(color: borderColor, width: 2),
                        borderRadius: BorderRadius.circular(_trackHeight / 2),
                      ),
                    ),
                  ),
                  Positioned(
                    left: thumbX + thumbW / 2 - _stateLayer / 2,
                    top: (_trackHeight - _stateLayer) / 2,
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: press * 0.12,
                        child: Container(
                          width: _stateLayer,
                          height: _stateLayer,
                          decoration: BoxDecoration(
                            color: thumbColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
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
