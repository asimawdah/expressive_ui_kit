import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A tappable coin that flips in 3D and lands on heads or tails.
///
/// The coin spins around the X axis in perspective, rising and falling as
/// it tumbles, decelerating into its landing with a haptic. The result is
/// random unless forced via [MECoinFlipController.flip]. Heads shows
/// [heads] on a primary-container face; tails shows [tails] on a
/// tertiary-container face.
class MECoinFlip extends StatefulWidget {
  const MECoinFlip({
    super.key,
    this.size = 96,
    this.heads,
    this.tails,
    this.onFlipped,
    this.controller,
    this.semanticLabel,
  });

  /// Diameter of the coin.
  final double size;

  /// Widget shown on the heads face. Defaults to an "H" glyph.
  final Widget? heads;

  /// Widget shown on the tails face. Defaults to a "T" glyph.
  final Widget? tails;

  /// Called with `true` for heads, `false` for tails when the coin lands.
  final ValueChanged<bool>? onFlipped;

  /// Optional controller for programmatic flips.
  final MECoinFlipController? controller;

  final String? semanticLabel;

  @override
  State<MECoinFlip> createState() => _MECoinFlipState();
}

/// Programmatically flips an [MECoinFlip].
class MECoinFlipController {
  _MECoinFlipState? _state;

  /// Starts a flip. Optionally force the outcome with [heads].
  void flip({bool? heads}) => _state?._flip(forced: heads);
}

class _MECoinFlipState extends State<MECoinFlip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  final math.Random _random = math.Random();

  /// The face showing while the coin is at rest.
  bool _restingHeads = true;

  /// Half-turns for the current flip.
  int _halfTurns = 0;
  bool _flipping = false;

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
    _spin.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          // Commit the landing face.
          if (_halfTurns.isOdd) _restingHeads = !_restingHeads;
          _flipping = false;
        });
        HapticFeedback.mediumImpact();
        widget.onFlipped?.call(_restingHeads);
      }
    });
  }

  @override
  void didUpdateWidget(MECoinFlip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?._state = null;
      widget.controller?._state = this;
    }
  }

  @override
  void dispose() {
    widget.controller?._state = null;
    _spin.dispose();
    super.dispose();
  }

  void _flip({bool? forced}) {
    if (_flipping) return;
    final result = forced ?? _random.nextBool();
    // 8..12 half-turns, parity-adjusted so we land on [result]: the face
    // flips iff the number of half-turns is odd.
    int turns = 8 + _random.nextInt(5);
    final landsHeads = turns.isEven ? _restingHeads : !_restingHeads;
    if (landsHeads != result) turns += 1;
    setState(() {
      _halfTurns = turns;
      _flipping = true;
    });
    HapticFeedback.lightImpact();
    _spin
      ..value = 0
      ..animateTo(1, curve: Curves.easeOutQuart);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final headsFace = widget.heads ??
        Text(
          'H',
          style: textTheme.headlineMedium!.copyWith(
            color: scheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        );
    final tailsFace = widget.tails ??
        Text(
          'T',
          style: textTheme.headlineMedium!.copyWith(
            color: scheme.onTertiaryContainer,
            fontWeight: FontWeight.bold,
          ),
        );

    return Semantics(
      label: widget.semanticLabel ?? 'Coin flip',
      value: _flipping ? 'Flipping' : (_restingHeads ? 'Heads' : 'Tails'),
      button: true,
      child: GestureDetector(
        onTap: _flip,
        child: AnimatedBuilder(
          animation: _spin,
          builder: (context, _) {
            final angle = _flipping ? _spin.value * _halfTurns * math.pi : 0.0;
            // Which face points at the viewer right now: it alternates
            // every half-turn away from the resting face.
            final elapsed = (angle / math.pi).round();
            final headsUp =
                elapsed.isEven ? _restingHeads : !_restingHeads;
            // Fold the angle so the visible face is always drawn upright.
            final foldedAngle = angle - elapsed * math.pi;
            // The coin lifts mid-flip and comes back down to land.
            final lift = _flipping
                ? -math.sin(_spin.value * math.pi) * widget.size * 0.35
                : 0.0;

            final face = headsUp
                ? _CoinFace(
                    color: scheme.primaryContainer,
                    ring: scheme.primary,
                    child: headsFace,
                  )
                : _CoinFace(
                    color: scheme.tertiaryContainer,
                    ring: scheme.tertiary,
                    child: tailsFace,
                  );

            return Transform.translate(
              offset: Offset(0, lift),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0012)
                  ..rotateX(foldedAngle),
                child: SizedBox(
                  width: widget.size,
                  height: widget.size,
                  child: face,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CoinFace extends StatelessWidget {
  const _CoinFace({
    required this.color,
    required this.ring,
    required this.child,
  });

  final Color color;
  final Color ring;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: ring, width: 3),
      ),
      child: Center(child: child),
    );
  }
}
