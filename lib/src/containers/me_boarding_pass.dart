import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// A ticket-shaped boarding pass with notched edges, a dashed perforation
/// line, and a tear-off stub that detaches with a spring when swiped.
///
/// Drag the stub past the threshold to tear it off: it springs away,
/// rotates and fades, then fires [onTornOff]. Under the threshold the
/// stub snaps back with an overshoot wobble.
///
/// ```dart
/// MEBoardingPass(
///   header: Text('SFO -> NRT'),
///   body: Text('Alex Rivera, Seat 12A'),
///   stub: Text('12A'),
///   onTornOff: checkIn,
/// )
/// ```
class MEBoardingPass extends StatefulWidget {
  const MEBoardingPass({
    super.key,
    required this.header,
    required this.body,
    required this.stub,
    this.onTornOff,
    this.width = 340,
    this.height = 140,
    this.stubWidth = 92,
  });

  /// Top-left content (route, event name...).
  final Widget header;

  /// Main content area of the pass.
  final Widget body;

  /// Content inside the tear-off stub.
  final Widget stub;

  /// Called once when the stub is torn off.
  final VoidCallback? onTornOff;

  final double width;
  final double height;
  final double stubWidth;

  @override
  State<MEBoardingPass> createState() => _MEBoardingPassState();
}

class _MEBoardingPassState extends State<MEBoardingPass>
    with SingleTickerProviderStateMixin {
  /// 0 = attached, 1 = fully torn.
  late final AnimationController _tear = AnimationController.unbounded(
    vsync: this,
    value: 0,
  );

  bool _torn = false;
  double _dragX = 0;

  static const double _threshold = 0.55;

  @override
  void initState() {
    super.initState();
    _tear.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tear.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_torn) return;
    setState(() {
      _dragX = (_dragX + details.delta.dx).clamp(0.0, widget.stubWidth * 1.4);
      _tear.value = _dragX / widget.stubWidth;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_torn) return;
    final motion = METheme.of(context).motion;
    if (_tear.value >= _threshold) {
      _torn = true;
      HapticFeedback.mediumImpact();
      springTo(_tear, 2.2, motion.defaultSpatial);
      widget.onTornOff?.call();
    } else {
      _dragX = 0;
      springTo(_tear, 0, motion.defaultSpatial);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final double t = _tear.value.clamp(0.0, 2.2);
    final double stubOffset = t * widget.stubWidth * 0.9;
    final double stubAngle = t * 0.18;
    final double stubOpacity = (1.0 - (t - 0.8) / 1.2).clamp(0.0, 1.0);

    return Semantics(
      label: 'Boarding pass. Swipe the stub right to tear it off.',
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Row(
          children: [
            // Main pass body.
            Expanded(
              child: Material(
                color: scheme.primaryContainer,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DefaultTextStyle(
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(color: scheme.onPrimaryContainer),
                        child: widget.header,
                      ),
                      const Spacer(),
                      DefaultTextStyle(
                        style: Theme.of(context).textTheme.bodyMedium!
                            .copyWith(color: scheme.onPrimaryContainer),
                        child: widget.body,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Perforation column with notches.
            CustomPaint(
              size: Size(1, widget.height),
              painter: _PerforationPainter(
                color: scheme.onPrimaryContainer.withValues(alpha: 0.4),
                background: scheme.primaryContainer,
                surface: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
            // Tear-off stub.
            Opacity(
              opacity: stubOpacity,
              child: Transform.translate(
                offset: Offset(stubOffset, -stubOffset * 0.15),
                child: Transform.rotate(
                  angle: stubAngle,
                  child: GestureDetector(
                    onHorizontalDragUpdate: _onDragUpdate,
                    onHorizontalDragEnd: _onDragEnd,
                    child: Material(
                      color: scheme.primaryContainer,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.horizontal(
                          right: Radius.circular(20),
                        ),
                      ),
                      child: SizedBox(
                        width: widget.stubWidth,
                        height: widget.height,
                        child: Center(
                          child: DefaultTextStyle(
                            style: Theme.of(context).textTheme.titleLarge!
                                .copyWith(color: scheme.onPrimaryContainer),
                            child: widget.stub,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PerforationPainter extends CustomPainter {
  _PerforationPainter({
    required this.color,
    required this.background,
    required this.surface,
  });

  final Color color;
  final Color background;
  final Color surface;

  @override
  void paint(Canvas canvas, Size size) {
    // Dashed vertical line.
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    const dash = 5.0;
    const gap = 4.0;
    double y = 10;
    while (y < size.height - 10) {
      canvas.drawLine(Offset(0, y), Offset(0, y + dash), paint);
      y += dash + gap;
    }

    // Semicircular notches at the top and bottom, punched out with the
    // page surface color so the ticket silhouette reads correctly.
    final notch = Paint()..color = surface;
    canvas.drawCircle(Offset(0, 0), 10, notch);
    canvas.drawCircle(Offset(0, size.height), 10, notch);
  }

  @override
  bool shouldRepaint(_PerforationPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.background != background ||
      oldDelegate.surface != surface;
}
