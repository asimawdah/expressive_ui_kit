import 'package:flutter/material.dart';

import '../theme/me_motion.dart';
import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';

/// A Material 3 Expressive checkbox.
///
/// Replaces [Checkbox]. The container springs between an outlined square
/// and a filled rounded square, with a bouncy check-mark draw-on.
/// Set [tristate] to allow a mixed (indeterminate) state.
class MECheckbox extends StatefulWidget {
  const MECheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.tristate = false,
    this.semanticsLabel,
    this.label,
  }) : assert(tristate || value != null);

  /// `true` checked, `false` unchecked, `null` mixed when [tristate] is true.
  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final bool tristate;
  final String? semanticsLabel;

  /// Optional label that is part of the tap target.
  final Widget? label;

  @override
  State<MECheckbox> createState() => _MECheckboxState();
}

class _MECheckboxState extends State<MECheckbox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController.unbounded(
    vsync: this,
    value: widget.value == true ? 1 : 0,
  );

  bool get _mixed => widget.tristate && widget.value == null;

  @override
  void didUpdateWidget(MECheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      springTo(
        _controller,
        widget.value == true || widget.value == null ? 1 : 0,
        METheme.of(context).motion.defaultSpatial,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _cycle() {
    final onChanged = widget.onChanged;
    if (onChanged == null) return;
    if (!widget.tristate) {
      onChanged(!(widget.value ?? false));
      return;
    }
    // Flutter Checkbox order: false → true → null → false.
    if (widget.value == false) {
      onChanged(true);
    } else if (widget.value == true) {
      onChanged(null);
    } else {
      onChanged(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final enabled = widget.onChanged != null;

    return Semantics(
      checked: widget.value == true,
      mixed: _mixed,
      label: widget.semanticsLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? _cycle : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    final t = _controller.value.clamp(0.0, 1.0);
                    final overshoot = _controller.value.clamp(0.0, 1.5);
                    final scale = 1.0 + (overshoot - t) * 0.3;
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Color.lerp(
                            Colors.transparent,
                            enabled
                                ? colors.primary
                                : colors.onSurface.withValues(alpha: 0.38),
                            t,
                          ),
                          border: Border.all(
                            color: Color.lerp(
                              enabled
                                  ? colors.onSurfaceVariant
                                  : colors.onSurface.withValues(alpha: 0.38),
                              Colors.transparent,
                              t,
                            )!,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(
                            MECorners.extraSmall + 2 * t,
                          ),
                        ),
                        child: CustomPaint(
                          painter: _mixed
                              ? _DashPainter(
                                  progress: t,
                                  color: colors.onPrimary,
                                )
                              : _CheckPainter(
                                  progress: t,
                                  color: colors.onPrimary,
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            if (widget.label != null) ...[
              const SizedBox(width: 4),
              DefaultTextStyle.merge(
                style: Theme.of(context).textTheme.bodyLarge!,
                child: widget.label!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  _CheckPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress < 0.3) return;
    final t = ((progress - 0.3) / 0.7).clamp(0.0, 1.0);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final start = Offset(size.width * 0.22, size.height * 0.53);
    final mid = Offset(size.width * 0.42, size.height * 0.72);
    final end = Offset(size.width * 0.78, size.height * 0.3);

    final path = Path()..moveTo(start.dx, start.dy);
    if (t < 0.5) {
      final p = Offset.lerp(start, mid, t / 0.5)!;
      path.lineTo(p.dx, p.dy);
    } else {
      path.lineTo(mid.dx, mid.dy);
      final p = Offset.lerp(mid, end, (t - 0.5) / 0.5)!;
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _DashPainter extends CustomPainter {
  _DashPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress < 0.2) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.22, size.height * 0.5),
      Offset(size.width * 0.78, size.height * 0.5),
      paint,
    );
  }

  @override
  bool shouldRepaint(_DashPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
