import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// A Material 3 Expressive slide-to-confirm control.
///
/// For destructive or irreversible actions where a plain button is too
/// easy to hit accidentally (send payment, delete account, power off).
/// Drag the thumb to the end to confirm; release early and it springs
/// back with a bounce. On confirmation the track fills, the thumb morphs
/// squarer and swaps to a check, and a success haptic fires.
class MESlideToConfirm extends StatefulWidget {
  const MESlideToConfirm({
    super.key,
    required this.label,
    required this.onConfirmed,
    this.confirmedLabel = 'Confirmed',
    this.icon = Icons.chevron_right,
    this.confirmedIcon = Icons.check,
    this.height = 56,
    this.enabled = true,
    this.color,
    this.thumbColor,
  });

  /// Instruction text shown in the track (e.g. "Slide to send").
  final String label;

  /// Called once when the thumb reaches the end.
  final VoidCallback onConfirmed;

  /// Replaces [label] after confirmation.
  final String confirmedLabel;
  final IconData icon;
  final IconData confirmedIcon;
  final double height;
  final bool enabled;

  /// Track color. Defaults to the secondary container.
  final Color? color;

  /// Thumb color. Defaults to the primary color.
  final Color? thumbColor;

  @override
  State<MESlideToConfirm> createState() => _MESlideToConfirmState();
}

class _MESlideToConfirmState extends State<MESlideToConfirm>
    with SingleTickerProviderStateMixin {
  late final AnimationController _drag =
      AnimationController.unbounded(vsync: this, value: 0);
  bool _confirmed = false;
  bool _dragging = false;

  @override
  void dispose() {
    _drag.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details, double travel) {
    if (_confirmed || !widget.enabled) return;
    _drag.value = (_drag.value + details.delta.dx / travel).clamp(0.0, 1.0);
    if (_drag.value >= 1.0) _confirm();
  }

  void _onDragEnd(DragEndDetails details) {
    setState(() => _dragging = false);
    if (_confirmed) return;
    // Not confirmed: spring back to rest with a bounce.
    springTo(_drag, 0, METheme.of(context).motion.defaultSpatial);
  }

  void _confirm() {
    if (_confirmed) return;
    setState(() {
      _confirmed = true;
      _dragging = false;
    });
    HapticFeedback.mediumImpact();
    springTo(_drag, 1, METheme.of(context).motion.fastSpatial);
    widget.onConfirmed();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final trackColor = widget.color ?? scheme.secondaryContainer;
    final thumbColor = widget.thumbColor ?? scheme.primary;
    final thumbSize = widget.height - 8;

    return Semantics(
      slider: true,
      label: widget.label,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final travel = width - thumbSize - 8;

          return GestureDetector(
            onHorizontalDragStart: widget.enabled && !_confirmed
                ? (_) => setState(() => _dragging = true)
                : null,
            onHorizontalDragUpdate: widget.enabled && !_confirmed
                ? (d) => _onDragUpdate(d, travel)
                : null,
            onHorizontalDragEnd:
                widget.enabled && !_confirmed ? _onDragEnd : null,
            child: AnimatedBuilder(
              animation: _drag,
              builder: (context, _) {
                final t = _drag.value.clamp(0.0, 1.0);
                // Thumb morphs squarer as it travels; squarest when
                // dragging, fully squared + checked when confirmed.
                final thumbRadius =
                    thumbSize / 2 - (thumbSize / 2 - thumbSize * 0.22) * t;
                return Container(
                  height: widget.height,
                  decoration: BoxDecoration(
                    color: Color.lerp(
                        trackColor, scheme.primaryContainer, t * 0.6),
                    borderRadius: BorderRadius.circular(widget.height / 2),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Instruction label fades out as the thumb travels.
                      Opacity(
                        opacity:
                            _confirmed ? 1.0 : (1.0 - t * 1.6).clamp(0.0, 1.0),
                        child: Padding(
                          padding: EdgeInsets.only(left: thumbSize / 2),
                          child: Text(
                            _confirmed ? widget.confirmedLabel : widget.label,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge!
                                .copyWith(
                                  color: widget.enabled
                                      ? scheme.onSecondaryContainer
                                      : scheme.onSurface
                                          .withValues(alpha: 0.38),
                                ),
                          ),
                        ),
                      ),
                      // Filled progress behind the thumb.
                      Positioned(
                        left: 4,
                        top: 4,
                        bottom: 4,
                        width: (thumbSize + travel * t)
                            .clamp(thumbSize, width - 8),
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: thumbColor.withValues(
                                  alpha: _confirmed ? 0.16 : 0.10 * t),
                              borderRadius:
                                  BorderRadius.circular(widget.height / 2 - 4),
                            ),
                          ),
                        ),
                      ),
                      // The draggable thumb.
                      Positioned(
                        left: 4 + travel * t,
                        top: 4,
                        child: MEMotionBuilder(
                          value: _dragging ? 1.06 : 1.0,
                          spec: METheme.of(context).motion.fastSpatial,
                          builder: (context, s, child) =>
                              Transform.scale(scale: s, child: child),
                          child: Container(
                            width: thumbSize,
                            height: thumbSize,
                            decoration: BoxDecoration(
                              color: widget.enabled
                                  ? thumbColor
                                  : scheme.onSurface.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(thumbRadius),
                            ),
                            child: Icon(
                              _confirmed ? widget.confirmedIcon : widget.icon,
                              color: widget.enabled
                                  ? scheme.onPrimary
                                  : scheme.onSurface.withValues(alpha: 0.38),
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
        },
      ),
    );
  }
}
