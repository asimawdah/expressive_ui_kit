import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/me_theme.dart';

/// A row of expressive face glyphs for rating mood or satisfaction.
///
/// Faces range from a frown to a smile. The selected face fills with a
/// mood color (error for the worst, tertiary in the middle, primary for
/// the best) and pops larger with the fast spatial spring. Selection
/// ticks a haptic.
///
/// ```dart
/// MEMoodPicker(
///   value: mood,
///   onChanged: (i) => setState(() => mood = i),
/// )
/// ```
class MEMoodPicker extends StatelessWidget {
  const MEMoodPicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.count = 5,
    this.size = 48,
    this.semanticLabel,
  }) : assert(count >= 2, 'MEMoodPicker needs at least two moods.');

  /// Selected mood index (0 = worst, count-1 = best), or null for none.
  final int? value;

  final ValueChanged<int> onChanged;

  /// Number of faces to render.
  final int count;

  /// Diameter of each face.
  final double size;

  final String? semanticLabel;

  Color _moodColor(ColorScheme scheme, double t) {
    if (t < 0.5) {
      return Color.lerp(scheme.error, scheme.tertiary, t * 2)!;
    }
    return Color.lerp(scheme.tertiary, scheme.primary, (t - 0.5) * 2)!;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: semanticLabel ?? 'Mood picker',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < count; i++) ...[
            if (i > 0) SizedBox(width: size * 0.25),
            _MoodFace(
              t: i / (count - 1),
              selected: value == i,
              size: size,
              fill: _moodColor(scheme, i / (count - 1)),
              idleFill: scheme.surfaceContainerHighest,
              idleInk: scheme.onSurfaceVariant,
              activeInk: scheme.surface,
              onTap: () {
                HapticFeedback.selectionClick();
                onChanged(i);
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _MoodFace extends StatelessWidget {
  const _MoodFace({
    required this.t,
    required this.selected,
    required this.size,
    required this.fill,
    required this.idleFill,
    required this.idleInk,
    required this.activeInk,
    required this.onTap,
  });

  /// Mood position, 0.0 (worst) to 1.0 (best). Shapes the mouth curve.
  final double t;
  final bool selected;
  final double size;
  final Color fill;
  final Color idleFill;
  final Color idleInk;
  final Color activeInk;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final spec = METheme.of(context).motion.fastSpatial;
    return Semantics(
      button: true,
      selected: selected,
      label: 'Mood ${(t * 100).round()} percent',
      child: GestureDetector(
        onTap: onTap,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: selected ? 1.0 : 0.0),
          duration: spec.approximateDuration,
          curve: spec.curve,
          builder: (context, v, _) {
            final clamped = v.clamp(0.0, 1.0);
            return Transform.scale(
              scale: 1.0 + 0.22 * v,
              child: CustomPaint(
                size: Size.square(size),
                painter: _FacePainter(
                  mood: t,
                  fill: Color.lerp(idleFill, fill, clamped)!,
                  ink: Color.lerp(idleInk, activeInk, clamped)!,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FacePainter extends CustomPainter {
  const _FacePainter({
    required this.mood,
    required this.fill,
    required this.ink,
  });

  final double mood;
  final Color fill;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.drawCircle(
      Offset(w / 2, h / 2),
      w / 2,
      Paint()..color = fill,
    );
    final inkPaint = Paint()..color = ink;
    // Eyes.
    canvas.drawCircle(Offset(w * 0.36, h * 0.40), w * 0.06, inkPaint);
    canvas.drawCircle(Offset(w * 0.64, h * 0.40), w * 0.06, inkPaint);
    // Mouth: a quadratic curve bending from frown (mood 0) to smile
    // (mood 1), flat in the middle.
    final bend = (mood * 2 - 1) * h * 0.14;
    final mouthY = h * 0.64 - bend * 0.3;
    final mouth = Path()
      ..moveTo(w * 0.32, mouthY)
      ..quadraticBezierTo(w * 0.5, mouthY + bend, w * 0.68, mouthY);
    canvas.drawPath(
      mouth,
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.07
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_FacePainter oldDelegate) =>
      oldDelegate.mood != mood ||
      oldDelegate.fill != fill ||
      oldDelegate.ink != ink;
}
