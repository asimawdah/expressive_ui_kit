import 'package:flutter/material.dart';

import '../buttons/me_button.dart';
import '../theme/me_motion.dart';
import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';

/// Shows a Material 3 Expressive coachmark highlighting [targetKey]'s
/// widget: the screen scrims except for a rounded cutout around the
/// target, and a card with [title], [message] and a dismiss button
/// springs in next to it.
///
/// ```dart
/// final fabKey = GlobalKey();
/// // ...attach fabKey to the widget to highlight, then:
/// showMECoachmark(
///   context,
///   targetKey: fabKey,
///   title: 'Create a note',
///   message: 'Tap here to start writing.',
/// );
/// ```
Future<void> showMECoachmark(
  BuildContext context, {
  required GlobalKey targetKey,
  required String title,
  required String message,
  String dismissLabel = 'Got it',
}) async {
  final targetContext = targetKey.currentContext;
  if (targetContext == null) return;
  final box = targetContext.findRenderObject() as RenderBox?;
  if (box == null || !box.attached) return;

  final overlayBox =
      Overlay.of(context).context.findRenderObject() as RenderBox;
  final targetRect = MatrixUtils.transformRect(
    box.getTransformTo(overlayBox),
    Offset.zero & box.size,
  );

  final motion = METheme.of(context).motion;
  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    barrierLabel: title,
    transitionDuration: motion.popup.approximateDuration,
    pageBuilder: (context, animation, secondary) => _MECoachmark(
      targetRect: targetRect,
      title: title,
      message: message,
      dismissLabel: dismissLabel,
    ),
    transitionBuilder: (context, animation, secondary, child) => FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: METheme.of(context).motion.popup.curve,
      ),
      child: child,
    ),
  );
}

class _MECoachmark extends StatefulWidget {
  const _MECoachmark({
    required this.targetRect,
    required this.title,
    required this.message,
    required this.dismissLabel,
  });

  final Rect targetRect;
  final String title;
  final String message;
  final String dismissLabel;

  @override
  State<_MECoachmark> createState() => _MECoachmarkState();
}

class _MECoachmarkState extends State<_MECoachmark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter = AnimationController.unbounded(
    vsync: this,
    value: 0,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      springTo(_enter, 1, METheme.of(context).motion.defaultSpatial);
    });
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final screen = MediaQuery.sizeOf(context);
    final cutout = widget.targetRect.inflate(8);

    // Place the card below the target when there is room, else above.
    final below = cutout.bottom + 220 < screen.height;

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // Scrim with a rounded cutout over the target.
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ScrimPainter(
                  cutout: cutout,
                  color: Colors.black.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
          // The coachmark card.
          Positioned(
            left: 24,
            right: 24,
            top: below ? cutout.bottom + 16 : null,
            bottom: below ? null : screen.height - cutout.top + 16,
            child: AnimatedBuilder(
              animation: _enter,
              builder: (context, child) {
                final t = _enter.value;
                return Transform.translate(
                  offset:
                      Offset(0, (1 - t.clamp(0.0, 1.5)) * (below ? 16 : -16)),
                  child: Transform.scale(
                    scale: 0.9 + 0.1 * t.clamp(0.0, 1.2),
                    child: Opacity(
                      opacity: t.clamp(0.0, 1.0),
                      child: child,
                    ),
                  ),
                );
              },
              child: Align(
                alignment: below ? Alignment.topCenter : Alignment.bottomCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    decoration: ShapeDecoration(
                      color: scheme.inverseSurface,
                      shape: MEShapeScheme.fromCorner(MECorners.extraLarge),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: METypography.emphasize(text.titleMedium!)
                              .copyWith(color: scheme.onInverseSurface),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.message,
                          style: text.bodyMedium!.copyWith(
                            color:
                                scheme.onInverseSurface.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          // The card uses inverseSurface, so remap primary
                          // to inversePrimary for a contrasting text button.
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: scheme.copyWith(
                                primary: scheme.inversePrimary,
                              ),
                            ),
                            child: MEButton.text(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(widget.dismissLabel),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScrimPainter extends CustomPainter {
  _ScrimPainter({required this.cutout, required this.color});

  final Rect cutout;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scrim = Path()..addRect(Offset.zero & size);
    final hole = Path()
      ..addRRect(RRect.fromRectAndRadius(
        cutout,
        const Radius.circular(MECorners.large),
      ));
    canvas.drawPath(
      Path.combine(PathOperation.difference, scrim, hole),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_ScrimPainter old) =>
      old.cutout != cutout || old.color != color;
}
