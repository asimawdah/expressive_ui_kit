import 'package:flutter/material.dart';

import '../theme/me_motion.dart';
import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';

/// A Material 3 Expressive checkbox.
///
/// Replaces [Checkbox]. The container springs between an outlined square
/// and a filled rounded square, with a bouncy check-mark draw-on.
class MECheckbox extends StatefulWidget {
  const MECheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticsLabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? semanticsLabel;

  @override
  State<MECheckbox> createState() => _MECheckboxState();
}

class _MECheckboxState extends State<MECheckbox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController.unbounded(
    vsync: this,
    value: widget.value ? 1 : 0,
  );

  @override
  void didUpdateWidget(MECheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      springTo(
        _controller,
        widget.value ? 1 : 0,
        METheme.of(context).motion.defaultSpatial,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final enabled = widget.onChanged != null;

    return Semantics(
      checked: widget.value,
      label: widget.semanticsLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? () => widget.onChanged!(!widget.value) : null,
        child: SizedBox(
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
                      painter: _CheckPainter(
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
