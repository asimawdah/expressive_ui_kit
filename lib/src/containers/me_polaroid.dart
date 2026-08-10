import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// An instant-photo frame that "develops" its picture on mount.
///
/// The photo area starts under a dark scrim that slowly fades out with
/// the slow effects spring, like film developing. The frame rests at a
/// slight [angle]; pressing straightens and squashes it, releasing
/// springs back with a wobble.
///
/// ```dart
/// MEPolaroid(
///   caption: 'Golden hour',
///   child: Image.network(url, fit: BoxFit.cover),
/// )
/// ```
class MEPolaroid extends StatefulWidget {
  const MEPolaroid({
    super.key,
    required this.child,
    this.caption,
    this.angle = 2.0,
    this.width = 220,
    this.onPressed,
    this.semanticLabel,
  });

  /// The photo content, clipped to a square.
  final Widget child;

  /// Optional handwritten-style caption below the photo.
  final String? caption;

  /// Resting tilt, in degrees.
  final double angle;

  final double width;
  final VoidCallback? onPressed;
  final String? semanticLabel;

  @override
  State<MEPolaroid> createState() => _MEPolaroidState();
}

class _MEPolaroidState extends State<MEPolaroid> with TickerProviderStateMixin {
  late final AnimationController _develop =
      AnimationController.unbounded(vsync: this, value: 0);
  late final AnimationController _press =
      AnimationController.unbounded(vsync: this, value: 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      springTo(_develop, 1, METheme.of(context).motion.slowEffects);
    });
  }

  @override
  void dispose() {
    _develop.dispose();
    _press.dispose();
    super.dispose();
  }

  void _setPressed(bool pressed) {
    if (pressed) HapticFeedback.lightImpact();
    final motion = METheme.of(context).motion;
    springTo(
      _press,
      pressed ? 1 : 0,
      pressed ? motion.fastSpatial : motion.defaultSpatial,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final restAngle = widget.angle * math.pi / 180;
    final interactive = widget.onPressed != null;

    return Semantics(
      label: widget.semanticLabel ?? widget.caption,
      button: interactive,
      image: true,
      child: GestureDetector(
        onTapDown: interactive ? (_) => _setPressed(true) : null,
        onTapUp: interactive
            ? (_) {
                _setPressed(false);
                widget.onPressed!();
              }
            : null,
        onTapCancel: interactive ? () => _setPressed(false) : null,
        child: AnimatedBuilder(
          animation: Listenable.merge([_develop, _press]),
          builder: (context, child) {
            final p = _press.value.clamp(0.0, 1.2);
            // Pressing straightens the tilt and squashes slightly; the
            // underdamped release swings it past rest for a wobble.
            final angle = restAngle * (1.0 - _press.value.clamp(-0.3, 1.0));
            final scale = 1.0 - 0.03 * p;
            return Transform.rotate(
              angle: angle,
              child: Transform.scale(scale: scale, child: child),
            );
          },
          child: Material(
            color: scheme.surface,
            elevation: 3,
            shadowColor: scheme.shadow,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: widget.width - 24,
                    height: widget.width - 24,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ColoredBox(
                            color: scheme.surfaceContainerHighest,
                            child: widget.child,
                          ),
                          // Developing scrim fades out on mount.
                          AnimatedBuilder(
                            animation: _develop,
                            builder: (context, _) {
                              final visible =
                                  (1.0 - _develop.value).clamp(0.0, 1.0);
                              if (visible == 0) {
                                return const SizedBox.shrink();
                              }
                              return ColoredBox(
                                color: scheme.scrim
                                    .withValues(alpha: 0.9 * visible),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (widget.caption != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      widget.caption!,
                      style: textTheme.bodyMedium!.copyWith(
                        fontStyle: FontStyle.italic,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
