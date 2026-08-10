import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/me_motion.dart';
import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';

/// A three-reel slot machine with staggered spring-landing reels.
///
/// Each reel spins as a blur of icons and stops left to right with an
/// overshoot bounce and a haptic tick. When all three land on the same
/// icon, [onJackpot] fires with a heavier haptic. Spin by tapping or via
/// [MESlotMachineController.spin].
class MESlotMachine extends StatefulWidget {
  const MESlotMachine({
    super.key,
    this.icons = const [
      Icons.star,
      Icons.favorite,
      Icons.bolt,
      Icons.diamond,
      Icons.cloud,
    ],
    this.cellSize = 64,
    this.onSettled,
    this.onJackpot,
    this.controller,
    this.semanticLabel,
  }) : assert(icons.length >= 2, 'need at least 2 icons');

  /// Symbols on each reel.
  final List<IconData> icons;

  /// Size of each reel window.
  final double cellSize;

  /// Called with the three landed indices when the last reel stops.
  final void Function(List<int> results)? onSettled;

  /// Called when all reels land on the same symbol.
  final VoidCallback? onJackpot;

  /// Optional controller for programmatic spins.
  final MESlotMachineController? controller;

  final String? semanticLabel;

  @override
  State<MESlotMachine> createState() => _MESlotMachineState();
}

/// Programmatically spins an [MESlotMachine].
class MESlotMachineController {
  _MESlotMachineState? _state;

  /// Starts a spin. Optionally force the outcome with [results].
  void spin({List<int>? results}) => _state?._startSpin(forced: results);
}

class _MESlotMachineState extends State<MESlotMachine>
    with TickerProviderStateMixin {
  static const int _reels = 3;

  late final List<AnimationController> _reelControllers = [
    for (int i = 0; i < _reels; i++)
      AnimationController.unbounded(vsync: this, value: 0),
  ];
  final math.Random _random = math.Random();

  /// Current absolute position of each reel in "rows". The icon shown is
  /// `position % icons.length`.
  late final List<double> _target = List.filled(_reels, 0);
  bool _spinning = false;
  int _landed = 0;

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
  }

  @override
  void didUpdateWidget(MESlotMachine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?._state = null;
      widget.controller?._state = this;
    }
  }

  @override
  void dispose() {
    widget.controller?._state = null;
    for (final c in _reelControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _startSpin({List<int>? forced}) {
    if (_spinning) return;
    final n = widget.icons.length;
    final results =
        forced ?? [for (int i = 0; i < _reels; i++) _random.nextInt(n)];
    setState(() {
      _spinning = true;
      _landed = 0;
    });
    HapticFeedback.lightImpact();

    final motion = METheme.of(context).motion;
    for (int i = 0; i < _reels; i++) {
      // Each reel travels several full loops plus the offset to its result,
      // landing staggered left to right.
      final current = _reelControllers[i].value;
      final currentRow = current.round();
      final loops = (3 + i * 2) * n;
      final offset = (results[i] - (currentRow % n) + n) % n;
      _target[i] = (currentRow + loops + offset).toDouble();

      Future<void>.delayed(Duration(milliseconds: i * 260), () {
        if (!mounted) return;
        springTo(_reelControllers[i], _target[i], motion.slowSpatial);
        _reelControllers[i].addStatusListener(_onReelSettled);
      });
    }
  }

  void _onReelSettled(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    _landed += 1;
    HapticFeedback.selectionClick();
    if (_landed == _reels && _spinning) {
      setState(() => _spinning = false);
      final n = widget.icons.length;
      final results = [
        for (int i = 0; i < _reels; i++) _target[i].round() % n,
      ];
      widget.onSettled?.call(results);
      if (results.toSet().length == 1) {
        HapticFeedback.heavyImpact();
        widget.onJackpot?.call();
      }
      for (final c in _reelControllers) {
        c.removeStatusListener(_onReelSettled);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final cell = widget.cellSize;

    return Semantics(
      label: widget.semanticLabel ?? 'Slot machine',
      button: true,
      child: GestureDetector(
        onTap: _startSpin,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(MECorners.extraLarge),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < _reels; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                _Reel(
                  animation: _reelControllers[i],
                  icons: widget.icons,
                  size: cell,
                  background: scheme.surface,
                  iconColor: scheme.primary,
                  outline: scheme.outlineVariant,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Reel extends StatelessWidget {
  const _Reel({
    required this.animation,
    required this.icons,
    required this.size,
    required this.background,
    required this.iconColor,
    required this.outline,
  });

  final Animation<double> animation;
  final List<IconData> icons;
  final double size;
  final Color background;
  final Color iconColor;
  final Color outline;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(MECorners.medium),
        border: Border.all(color: outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          final n = icons.length;
          final pos = animation.value;
          // The reel shows the icon at `pos`, with neighbors above/below
          // sliding through the window.
          final base = pos.floor();
          final frac = pos - base;
          return Stack(
            children: [
              for (int row = -1; row <= 1; row++)
                Positioned(
                  top: (row - frac) * size,
                  left: 0,
                  right: 0,
                  height: size,
                  child: Center(
                    child: Icon(
                      icons[((base + row) % n + n) % n],
                      size: size * 0.55,
                      color: iconColor,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
