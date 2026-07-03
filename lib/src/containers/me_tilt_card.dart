import 'package:flutter/material.dart';

import '../theme/me_motion.dart';
import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';

/// A Material 3 Expressive 3D tilt card.
///
/// The card tilts in perspective toward the pointer (or finger) position,
/// with a subtle sheen that tracks the light angle. On release the card
/// springs back to flat with the theme's underdamped spatial spring, giving
/// a satisfying wobble.
class METiltCard extends StatefulWidget {
  const METiltCard({
    super.key,
    required this.child,
    this.maxTilt = 0.12,
    this.color,
    this.onPressed,
    this.height,
  });

  final Widget child;

  /// Maximum tilt angle in radians toward each edge.
  final double maxTilt;

  /// Card surface color. Defaults to surfaceContainerLow.
  final Color? color;
  final VoidCallback? onPressed;

  /// Optional fixed height for the card.
  final double? height;

  @override
  State<METiltCard> createState() => _METiltCardState();
}

class _METiltCardState extends State<METiltCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _settle = AnimationController.unbounded(
    vsync: this,
    value: 1,
  );

  /// Target tilt, normalized -1..1 on both axes.
  Offset _target = Offset.zero;

  /// Tilt currently rendered (drags follow directly; release springs back).
  Offset _current = Offset.zero;

  @override
  void initState() {
    super.initState();
    _settle.addListener(() {
      setState(() {
        // While the settle spring runs, interpolate the tilt back to zero.
        _current = _target * _settle.value.clamp(0.0, 1.5);
      });
    });
  }

  @override
  void dispose() {
    _settle.dispose();
    super.dispose();
  }

  void _updateFromLocal(Offset local, Size size) {
    _settle.stop();
    _settle.value = 1;
    setState(() {
      _target = Offset(
        (local.dx / size.width * 2 - 1).clamp(-1.0, 1.0),
        (local.dy / size.height * 2 - 1).clamp(-1.0, 1.0),
      );
      _current = _target;
    });
  }

  void _release(MEMotionScheme motion) {
    // Spring the settle factor 1 -> 0; the underdamped spring overshoots
    // below zero which flips the tilt slightly past flat: the wobble.
    springTo(_settle, 0, motion.defaultSpatial);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final motion = METheme.of(context).motion;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(
          constraints.maxWidth,
          widget.height ?? 200,
        );
        return GestureDetector(
          onPanDown: (d) => _updateFromLocal(d.localPosition, size),
          onPanUpdate: (d) => _updateFromLocal(d.localPosition, size),
          onPanEnd: (_) => _release(motion),
          onPanCancel: () => _release(motion),
          onTap: widget.onPressed,
          child: MouseRegion(
            onHover: (e) => _updateFromLocal(e.localPosition, size),
            onExit: (_) => _release(motion),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0012)
                ..rotateX(-_current.dy * widget.maxTilt)
                ..rotateY(_current.dx * widget.maxTilt),
              child: SizedBox(
                width: size.width,
                height: size.height,
                child: Material(
                  color: widget.color ?? scheme.surfaceContainerLow,
                  elevation: 2 + _current.distance * 6,
                  shadowColor: Colors.black45,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(MECorners.extraLarge),
                    side: BorderSide(color: scheme.outlineVariant),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      widget.child,
                      // Sheen: a soft highlight opposite the tilt direction.
                      IgnorePointer(
                        child: Opacity(
                          opacity:
                              (_current.distance * 0.10).clamp(0.0, 0.10),
                          child: Align(
                            alignment: Alignment(
                              -_current.dx.clamp(-1.0, 1.0),
                              -_current.dy.clamp(-1.0, 1.0),
                            ),
                            child: Container(
                              width: size.width * 0.9,
                              height: size.height * 0.9,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                // Soft radial falloff so the sheen has no
                                // hard edge.
                                gradient: RadialGradient(
                                  colors: [
                                    scheme.onSurface,
                                    scheme.onSurface.withValues(alpha: 0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
