import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../internal/me_pressable.dart';
import '../theme/me_motion.dart';
import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';

/// A tappable die that tumbles to a random face.
///
/// Tapping the die (or calling roll via [MEDiceController]) spins it with
/// a slow spatial spring — it scales down, rotates through several turns
/// while cycling faces, then lands on the result with an overshoot bounce
/// and a haptic. The pip layout matches a physical die.
///
/// ```dart
/// MEDice(onRolled: (value) => score += value)
/// ```
class MEDice extends StatefulWidget {
  const MEDice({
    super.key,
    this.controller,
    this.onRolled,
    this.size = 96,
    this.sides = 6,
    this.semanticLabel,
  });

  final MEDiceController? controller;

  /// Called with the face value (1-based) when the die settles.
  final ValueChanged<int>? onRolled;

  final double size;

  /// Number of faces. Faces above 9 render as numerals instead of pips.
  final int sides;

  final String? semanticLabel;

  @override
  State<MEDice> createState() => _MEDiceState();
}

/// Programmatic control for [MEDice].
class MEDiceController {
  _MEDiceState? _state;

  /// Rolls the die. No-op while a roll is already in flight.
  void roll() => _state?._roll();
}

class _MEDiceState extends State<MEDice> with SingleTickerProviderStateMixin {
  late final AnimationController _tumble = AnimationController.unbounded(
    vsync: this,
    value: 0,
  );
  final math.Random _random = math.Random();

  int _face = 1;
  int _pendingFace = 1;
  bool _rolling = false;

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
  }

  @override
  void didUpdateWidget(MEDice oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._state = null;
      widget.controller?._state = this;
    }
  }

  @override
  void dispose() {
    widget.controller?._state = null;
    _tumble.dispose();
    super.dispose();
  }

  Future<void> _roll() async {
    if (_rolling) return;
    setState(() {
      _rolling = true;
      _pendingFace = _random.nextInt(widget.sides) + 1;
    });
    HapticFeedback.selectionClick();
    _tumble.value = 0;
    await springTo(_tumble, 1, METheme.of(context).motion.slowSpatial);
    if (!mounted) return;
    setState(() {
      _face = _pendingFace;
      _rolling = false;
    });
    HapticFeedback.mediumImpact();
    widget.onRolled?.call(_face);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      label: widget.semanticLabel ?? 'Die showing $_face',
      button: true,
      child: AnimatedBuilder(
        animation: _tumble,
        builder: (context, _) {
          final t = _tumble.value;
          // The slow spatial spring itself decelerates into the landing
          // with a small overshoot — no duration curve on top.
          final spinT = t.clamp(0.0, 1.2);
          final angle = spinT * math.pi * 4;
          final scale = _rolling ? (0.82 + 0.18 * t).clamp(0.7, 1.08) : 1.0;
          // Cycle through random-looking faces while the spring is still
          // climbing; lock the pending face near the settle.
          final shownFace = _rolling && t < 0.85
              ? ((t.clamp(0.0, 1.0) * 17).floor() % widget.sides) + 1
              : (_rolling ? _pendingFace : _face);

          return Transform.rotate(
            angle: _rolling ? angle : 0,
            child: Transform.scale(
              scale: scale,
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: MEPressable(
                  shape: MEShapeScheme.fromCorner(MECorners.extraLarge),
                  color: scheme.primaryContainer,
                  onPressed: () {
                    _roll();
                  },
                  haptics: false,
                  child: Center(
                    child: _MEDiceFace(
                      value: shownFace,
                      color: scheme.onPrimaryContainer,
                      size: widget.size,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MEDiceFace extends StatelessWidget {
  const _MEDiceFace({
    required this.value,
    required this.color,
    required this.size,
  });

  final int value;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (value > 9) {
      return Text(
        '$value',
        style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      );
    }
    return CustomPaint(
      size: Size.square(size * 0.62),
      painter: _MEPipsPainter(value: value, color: color),
    );
  }
}

class _MEPipsPainter extends CustomPainter {
  _MEPipsPainter({required this.value, required this.color});

  final int value;
  final Color color;

  // Pip positions on a 3x3 grid (0..2, 0..2).
  static const Map<int, List<Offset>> _layouts = {
    1: [Offset(1, 1)],
    2: [Offset(0, 0), Offset(2, 2)],
    3: [Offset(0, 0), Offset(1, 1), Offset(2, 2)],
    4: [Offset(0, 0), Offset(2, 0), Offset(0, 2), Offset(2, 2)],
    5: [
      Offset(0, 0),
      Offset(2, 0),
      Offset(1, 1),
      Offset(0, 2),
      Offset(2, 2),
    ],
    6: [
      Offset(0, 0),
      Offset(2, 0),
      Offset(0, 1),
      Offset(2, 1),
      Offset(0, 2),
      Offset(2, 2),
    ],
    7: [
      Offset(0, 0),
      Offset(2, 0),
      Offset(0, 1),
      Offset(1, 1),
      Offset(2, 1),
      Offset(0, 2),
      Offset(2, 2),
    ],
    8: [
      Offset(0, 0),
      Offset(1, 0),
      Offset(2, 0),
      Offset(0, 1),
      Offset(2, 1),
      Offset(0, 2),
      Offset(1, 2),
      Offset(2, 2),
    ],
    9: [
      Offset(0, 0),
      Offset(1, 0),
      Offset(2, 0),
      Offset(0, 1),
      Offset(1, 1),
      Offset(2, 1),
      Offset(0, 2),
      Offset(1, 2),
      Offset(2, 2),
    ],
  };

  @override
  void paint(Canvas canvas, Size size) {
    final pips = _layouts[value] ?? _layouts[1]!;
    final paint = Paint()..color = color;
    final cell = size.width / 3;
    final radius = cell * 0.28;
    for (final pip in pips) {
      canvas.drawCircle(
        Offset(cell * pip.dx + cell / 2, cell * pip.dy + cell / 2),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_MEPipsPainter oldDelegate) =>
      value != oldDelegate.value || color != oldDelegate.color;
}
