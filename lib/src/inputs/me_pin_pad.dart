import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../internal/me_pressable.dart';
import '../theme/me_motion.dart';
import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';

/// A numeric PIN entry pad with expressive feedback.
///
/// Dots fill with a spring pop as digits are entered. When the full
/// [length] is entered, [onCompleted] fires with the PIN. Call shake on
/// a wrong PIN via [MEPinPadController.reject] — the dots shake side to
/// side with a heavy haptic and the entry clears.
class MEPinPadController {
  _MEPinPadState? _state;

  /// Rejects the current entry: shakes the dots, clears the PIN.
  void reject() => _state?._reject();

  /// Clears the current entry without the rejection shake.
  void clear() => _state?._clear();
}

class MEPinPad extends StatefulWidget {
  const MEPinPad({
    super.key,
    this.length = 4,
    this.onCompleted,
    this.onChanged,
    this.controller,
    this.obscure = true,
  });

  /// Number of digits in the PIN.
  final int length;

  /// Called when [length] digits have been entered.
  final ValueChanged<String>? onCompleted;

  /// Called on every digit change with the current entry.
  final ValueChanged<String>? onChanged;

  /// Optional controller for rejecting/clearing entries.
  final MEPinPadController? controller;

  /// Whether entered digits render as dots (true) or numerals.
  final bool obscure;

  @override
  State<MEPinPad> createState() => _MEPinPadState();
}

class _MEPinPadState extends State<MEPinPad> with TickerProviderStateMixin {
  String _entry = '';
  late final AnimationController _pop = AnimationController.unbounded(
    vsync: this,
    value: 1,
  );
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
  }

  @override
  void didUpdateWidget(MEPinPad oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?._state = null;
      widget.controller?._state = this;
    }
  }

  @override
  void dispose() {
    widget.controller?._state = null;
    _pop.dispose();
    _shake.dispose();
    super.dispose();
  }

  void _input(String digit) {
    if (_entry.length >= widget.length) return;
    HapticFeedback.selectionClick();
    setState(() => _entry += digit);
    _pop.value = 0;
    springTo(_pop, 1, METheme.of(context).motion.fastSpatial);
    widget.onChanged?.call(_entry);
    if (_entry.length == widget.length) {
      widget.onCompleted?.call(_entry);
    }
  }

  void _backspace() {
    if (_entry.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() => _entry = _entry.substring(0, _entry.length - 1));
    widget.onChanged?.call(_entry);
  }

  void _reject() {
    HapticFeedback.heavyImpact();
    _shake.forward(from: 0).whenComplete(_clear);
  }

  void _clear() {
    if (!mounted) return;
    setState(() => _entry = '');
    widget.onChanged?.call(_entry);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Entry dots with shake on rejection.
        AnimatedBuilder(
          animation: Listenable.merge([_pop, _shake]),
          builder: (context, _) {
            // Damped sine shake: ~3 swings decaying to zero.
            final s = _shake.value;
            final dx = s == 0 || s == 1
                ? 0.0
                : 12 * (1 - s) * math.sin(s * 6 * math.pi);
            return Transform.translate(
              offset: Offset(dx, 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < widget.length; i++) ...[
                    if (i > 0) const SizedBox(width: 16),
                    _Dot(
                      filled: i < _entry.length,
                      // Newest dot pops with the spring.
                      scale: i == _entry.length - 1
                          ? 0.6 + 0.4 * _pop.value.clamp(0.0, 1.5)
                          : 1.0,
                      digit: widget.obscure || i >= _entry.length
                          ? null
                          : _entry[i],
                    ),
                  ],
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        // Keypad grid.
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ]) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final d in row)
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: _Key(
                    label: Text(d, style: textTheme.headlineSmall),
                    onPressed: () => _input(d),
                    semanticLabel: d,
                  ),
                ),
            ],
          ),
        ],
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 76),
            Padding(
              padding: const EdgeInsets.all(6),
              child: _Key(
                label: Text('0', style: textTheme.headlineSmall),
                onPressed: () => _input('0'),
                semanticLabel: '0',
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6),
              child: _Key(
                label: Icon(
                  Icons.backspace_outlined,
                  color: scheme.onSurfaceVariant,
                ),
                onPressed: _backspace,
                semanticLabel: 'Backspace',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.filled, required this.scale, this.digit});

  final bool filled;
  final double scale;
  final String? digit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (digit != null) {
      return Transform.scale(
        scale: scale,
        child: Text(
          digit!,
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(color: scheme.primary),
        ),
      );
    }
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? scheme.primary : Colors.transparent,
          border: Border.all(
            color: filled ? scheme.primary : scheme.outline,
            width: 2,
          ),
        ),
      ),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({
    required this.label,
    required this.onPressed,
    required this.semanticLabel,
  });

  final Widget label;
  final VoidCallback onPressed;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 64,
      height: 64,
      child: MEPressable(
        shape: const CircleBorder(),
        pressedShape: MEShapeScheme.fromCorner(MECorners.large),
        color: scheme.surfaceContainerHighest,
        onPressed: onPressed,
        semanticLabel: semanticLabel,
        haptics: false,
        child: Center(child: label),
      ),
    );
  }
}
