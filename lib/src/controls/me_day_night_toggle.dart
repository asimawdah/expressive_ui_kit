import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// A sun/moon day-night toggle with a sky that changes with the switch.
///
/// The thumb slides between ends with the theme's spatial spring
/// (overshooting expressively) while the sun morphs into a crescent
/// moon, stars fade in, and the sky track cross-fades from a day tint
/// to a night tint. Ideal as a theme-mode switch.
///
/// ```dart
/// MEDayNightToggle(
///   night: isDark,
///   onChanged: (v) => setThemeMode(v ? ThemeMode.dark : ThemeMode.light),
/// )
/// ```
class MEDayNightToggle extends StatefulWidget {
  const MEDayNightToggle({
    super.key,
    required this.night,
    this.onChanged,
    this.width = 92,
    this.semanticLabel,
  });

  /// True when night (dark) mode is selected.
  final bool night;

  /// Called with the new state when toggled.
  final ValueChanged<bool>? onChanged;

  /// Track width. Height derives from a 92:40 ratio.
  final double width;

  final String? semanticLabel;

  @override
  State<MEDayNightToggle> createState() => _MEDayNightToggleState();
}

class _MEDayNightToggleState extends State<MEDayNightToggle>
    with SingleTickerProviderStateMixin {
  // Unbounded: the spatial spring overshoots past the ends.
  late final AnimationController _t = AnimationController.unbounded(
    vsync: this,
    value: widget.night ? 1 : 0,
  );

  @override
  void didUpdateWidget(MEDayNightToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.night != oldWidget.night) {
      springTo(
        _t,
        widget.night ? 1 : 0,
        METheme.of(context).motion.defaultSpatial,
      );
    }
  }

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  void _toggle() {
    if (widget.onChanged == null) return;
    HapticFeedback.selectionClick();
    widget.onChanged!(!widget.night);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final height = widget.width * 40 / 92;

    // Day sky: primaryContainer tint. Night sky: inverseSurface.
    final dayTrack = scheme.primaryContainer;
    final nightTrack = scheme.inverseSurface;
    final sun = scheme.tertiary;
    final moon = scheme.surfaceBright;

    return Semantics(
      toggled: widget.night,
      button: true,
      label: widget.semanticLabel ?? 'Dark mode',
      child: GestureDetector(
        onTap: _toggle,
        child: AnimatedBuilder(
          animation: _t,
          builder: (context, _) {
            final t = _t.value;
            final clamped = t.clamp(0.0, 1.0);
            final track = Color.lerp(dayTrack, nightTrack, clamped)!;
            final thumbColor = Color.lerp(sun, moon, clamped)!;
            final pad = height * 0.125;
            final thumbSize = height - pad * 2;
            // Overshootable slide: t may go slightly below 0/above 1.
            final dx = pad +
                (widget.width - thumbSize - pad * 2) * t.clamp(-0.08, 1.08);

            return Container(
              width: widget.width,
              height: height,
              decoration: BoxDecoration(
                color: track,
                borderRadius: BorderRadius.circular(height / 2),
              ),
              child: Stack(
                children: [
                  // Stars fade in at night.
                  Positioned.fill(
                    child: Opacity(
                      opacity: clamped,
                      child: CustomPaint(
                        painter: _StarsPainter(
                          color: moon.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ),
                  // Thumb: sun morphing to crescent moon.
                  Positioned(
                    left: dx,
                    top: pad,
                    child: SizedBox(
                      width: thumbSize,
                      height: thumbSize,
                      child: CustomPaint(
                        painter: _SunMoonPainter(
                          phase: clamped,
                          color: thumbColor,
                          craterColor:
                              scheme.outlineVariant.withValues(alpha: 0.7),
                          rayColor: sun,
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

/// Paints the thumb: a sun with rays at phase 0 morphing into a crescent
/// moon with craters at phase 1. The crescent is cut with a circular
/// mask that slides across; rays shrink away as the phase advances.
class _SunMoonPainter extends CustomPainter {
  _SunMoonPainter({
    required this.phase,
    required this.color,
    required this.craterColor,
    required this.rayColor,
  });

  final double phase;
  final Color color;
  final Color craterColor;
  final Color rayColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.shortestSide / 2 * 0.72;

    // Sun rays (shrink as night approaches).
    final double rayLen = (1.0 - phase * 1.6).clamp(0.0, 1.0);
    if (rayLen > 0) {
      final rayPaint = Paint()
        ..color = rayColor
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      for (int i = 0; i < 8; i++) {
        final a = i * math.pi / 4;
        final dir = Offset(math.cos(a), math.sin(a));
        canvas.drawLine(
          center + dir * (r + 2),
          center + dir * (r + 2 + 4 * rayLen),
          rayPaint,
        );
      }
    }

    // Body with crescent cut. saveLayer so the cut erases cleanly.
    final rect = Rect.fromCircle(center: center, radius: r + 6);
    canvas.saveLayer(rect, Paint());
    canvas.drawCircle(center, r, Paint()..color = color);
    if (phase > 0.01) {
      // The mask circle slides in from the top-right.
      final maskOffset = Offset(r * 2 * (1 - phase), -r * 0.35 * phase);
      canvas.drawCircle(
        center + Offset(r * 0.55, 0) + maskOffset * (1 - phase),
        r * 0.85 * phase.clamp(0.0, 1.0),
        Paint()..blendMode = BlendMode.clear,
      );
    }
    canvas.restore();

    // Craters appear on the moon.
    if (phase > 0.55) {
      final double a = ((phase - 0.55) / 0.45).clamp(0.0, 1.0);
      final craterPaint = Paint()
        ..color = craterColor.withValues(alpha: a * 0.8);
      canvas.drawCircle(
          center + Offset(-r * 0.35, -r * 0.15), r * 0.16, craterPaint);
      canvas.drawCircle(
          center + Offset(-r * 0.05, r * 0.38), r * 0.11, craterPaint);
    }
  }

  @override
  bool shouldRepaint(_SunMoonPainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.color != color;
}

/// A few fixed stars scattered across the night track.
class _StarsPainter extends CustomPainter {
  _StarsPainter({required this.color});

  final Color color;

  static const List<Offset> _stars = [
    Offset(0.18, 0.3),
    Offset(0.3, 0.65),
    Offset(0.42, 0.25),
    Offset(0.55, 0.55),
    Offset(0.68, 0.3),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (int i = 0; i < _stars.length; i++) {
      final pos = Offset(
        _stars[i].dx * size.width,
        _stars[i].dy * size.height,
      );
      canvas.drawCircle(pos, i.isEven ? 1.6 : 1.1, paint);
    }
  }

  @override
  bool shouldRepaint(_StarsPainter oldDelegate) => oldDelegate.color != color;
}
