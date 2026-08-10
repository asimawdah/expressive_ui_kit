import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// A hue color wheel picker: drag around the ring to choose a hue. The
/// thumb rides the ring with a spring, grows while grabbed, and ticks
/// haptically every 30 degrees. The chosen color fills the center puck,
/// which pops on change.
///
/// ```dart
/// MEColorWheel(
///   hue: hue,
///   onChanged: (h) => setState(() => hue = h),
/// )
/// ```
class MEColorWheel extends StatefulWidget {
  const MEColorWheel({
    super.key,
    required this.hue,
    required this.onChanged,
    this.size = 200,
    this.saturation = 0.75,
    this.lightness = 0.55,
  });

  /// Current hue in degrees (0..360).
  final double hue;

  /// Called continuously as the user drags.
  final ValueChanged<double> onChanged;

  /// Diameter of the wheel.
  final double size;

  /// Saturation and lightness used for the ring gradient and the
  /// resolved color.
  final double saturation;
  final double lightness;

  @override
  State<MEColorWheel> createState() => _MEColorWheelState();
}

class _MEColorWheelState extends State<MEColorWheel>
    with TickerProviderStateMixin {
  /// Thumb grab scale: 0 = rest, 1 = grabbed.
  late final AnimationController _grab = AnimationController.unbounded(
    vsync: this,
    value: 0,
  );

  /// Center puck pop on hue change.
  late final AnimationController _pop = AnimationController.unbounded(
    vsync: this,
    value: 0,
  );

  int _lastTickSector = -1;

  @override
  void initState() {
    super.initState();
    _grab.addListener(() => setState(() {}));
    _pop.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _grab.dispose();
    _pop.dispose();
    super.dispose();
  }

  void _update(Offset local) {
    final center = Offset(widget.size / 2, widget.size / 2);
    final v = local - center;
    if (v.distance < 1e-3) return;
    double deg = math.atan2(v.dy, v.dx) * 180 / math.pi + 90;
    deg = (deg + 360) % 360;

    // Haptic tick every 30 degree sector.
    final sector = deg ~/ 30;
    if (sector != _lastTickSector) {
      _lastTickSector = sector;
      HapticFeedback.selectionClick();
    }

    // Pop the center puck with the fast spring.
    final motion = METheme.of(context).motion;
    _pop.value = 1;
    springTo(_pop, 0, motion.fastEffects);

    widget.onChanged(deg);
  }

  void _setGrabbed(bool grabbed) {
    final motion = METheme.of(context).motion;
    springTo(_grab, grabbed ? 1 : 0,
        grabbed ? motion.fastSpatial : motion.defaultSpatial);
  }

  Color get _color => HSLColor.fromAHSL(
        1,
        widget.hue % 360,
        widget.saturation,
        widget.lightness,
      ).toColor();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final double ringWidth = widget.size * 0.14;
    final double radius = widget.size / 2 - ringWidth / 2;
    final double angleRad = (widget.hue - 90) * math.pi / 180;
    final center = Offset(widget.size / 2, widget.size / 2);
    final thumbCenter = center +
        Offset(math.cos(angleRad) * radius, math.sin(angleRad) * radius);
    final double grabT = _grab.value.clamp(-0.2, 1.3);
    final double thumbR = ringWidth * 0.62 * (1.0 + 0.25 * grabT);
    final double popT = _pop.value.clamp(0.0, 1.0);

    return Semantics(
      label: 'Color wheel, hue ${widget.hue.round()} degrees',
      slider: true,
      child: GestureDetector(
        onPanDown: (d) {
          _setGrabbed(true);
          _update(d.localPosition);
        },
        onPanUpdate: (d) => _update(d.localPosition),
        onPanEnd: (_) => _setGrabbed(false),
        onPanCancel: () => _setGrabbed(false),
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            children: [
              // Hue ring.
              Positioned.fill(
                child: CustomPaint(
                  painter: _HueRingPainter(
                    ringWidth: ringWidth,
                    saturation: widget.saturation,
                    lightness: widget.lightness,
                  ),
                ),
              ),
              // Center puck showing the resolved color.
              Center(
                child: Transform.scale(
                  scale: 1.0 + 0.12 * popT,
                  child: Container(
                    width: widget.size * 0.38,
                    height: widget.size * 0.38,
                    decoration: BoxDecoration(
                      color: _color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: scheme.outlineVariant,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              // Thumb.
              Positioned(
                left: thumbCenter.dx - thumbR,
                top: thumbCenter.dy - thumbR,
                child: Container(
                  width: thumbR * 2,
                  height: thumbR * 2,
                  decoration: BoxDecoration(
                    color: _color,
                    shape: BoxShape.circle,
                    border: Border.all(color: scheme.surface, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HueRingPainter extends CustomPainter {
  _HueRingPainter({
    required this.ringWidth,
    required this.saturation,
    required this.lightness,
  });

  final double ringWidth;
  final double saturation;
  final double lightness;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - ringWidth / 2;

    final colors = List<Color>.generate(
      13,
      (i) =>
          HSLColor.fromAHSL(1, (i * 30) % 360, saturation, lightness).toColor(),
    );
    final shader = SweepGradient(
      colors: colors,
      transform: const GradientRotation(-math.pi / 2),
    ).createShader(Rect.fromCircle(center: center, radius: radius));

    final paint = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringWidth;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_HueRingPainter oldDelegate) =>
      oldDelegate.ringWidth != ringWidth ||
      oldDelegate.saturation != saturation ||
      oldDelegate.lightness != lightness;
}
