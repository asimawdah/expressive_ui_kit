import 'package:flutter/material.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// A branded splash / launch screen with a staged expressive reveal.
///
/// The reveal plays in phases:
///
/// 1. Expanding ripple rings bloom outward behind the logo.
/// 2. The logo container springs in from zero scale (slow spatial spring,
///    so it overshoots) while morphing from a circle toward a rounded
///    square.
/// 3. The title slides up and fades in, followed by the tagline.
/// 4. After [holdDuration], the whole screen scales up slightly and fades
///    out, then [onFinished] fires (if provided).
///
/// Works full-screen or embedded in any bounded box. Set
/// [autoDismiss] to false to keep the splash on screen (e.g. while
/// loading), then rebuild with `dismissed: true` or simply remove it.
class MESplashScreen extends StatefulWidget {
  const MESplashScreen({
    super.key,
    required this.logo,
    this.title,
    this.tagline,
    this.holdDuration = const Duration(milliseconds: 1600),
    this.autoDismiss = true,
    this.onFinished,
    this.backgroundColor,
    this.logoSize = 96,
  });

  /// The brand mark shown in the center container.
  final Widget logo;

  /// Optional app name shown below the logo.
  final Widget? title;

  /// Optional tagline shown below the title.
  final Widget? tagline;

  /// How long the fully revealed splash holds before dismissing.
  final Duration holdDuration;

  /// Whether the splash automatically plays its exit and calls
  /// [onFinished]. When false the splash stays revealed.
  final bool autoDismiss;

  /// Called after the exit animation completes.
  final VoidCallback? onFinished;

  /// Background color. Defaults to the primary container color.
  final Color? backgroundColor;

  /// Diameter of the logo container.
  final double logoSize;

  @override
  State<MESplashScreen> createState() => _MESplashScreenState();
}

class _MESplashScreenState extends State<MESplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logo = AnimationController.unbounded(
    vsync: this,
    value: 0,
  );
  late final AnimationController _text = AnimationController.unbounded(
    vsync: this,
    value: 0,
  );
  late final AnimationController _ripple = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  late final AnimationController _exit = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );
  bool _exiting = false;

  @override
  void initState() {
    super.initState();
    _ripple.repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) => _play());
  }

  Future<void> _play() async {
    if (!mounted) return;
    final motion = METheme.of(context).motion;
    springTo(_logo, 1, motion.slowSpatial);
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    springTo(_text, 1, motion.defaultSpatial);
    if (!widget.autoDismiss) return;
    await Future<void>.delayed(widget.holdDuration);
    if (!mounted) return;
    setState(() => _exiting = true);
    await _exit.forward();
    widget.onFinished?.call();
  }

  @override
  void dispose() {
    _logo.dispose();
    _text.dispose();
    _ripple.dispose();
    _exit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = widget.backgroundColor ?? scheme.primaryContainer;
    final onBackground = widget.backgroundColor == null
        ? scheme.onPrimaryContainer
        : scheme.onSurface;

    return AnimatedBuilder(
      animation: Listenable.merge([_logo, _text, _ripple, _exit]),
      builder: (context, _) {
        final logoT = _logo.value.clamp(0.0, 1.4);
        final textT = _text.value.clamp(0.0, 1.0);
        final exitT = Curves.easeIn.transform(_exit.value);

        return Opacity(
          opacity: (1 - exitT).clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 1 + exitT * 0.08,
            child: ColoredBox(
              color: background,
              child: Stack(
                alignment: Alignment.center,
                fit: StackFit.expand,
                children: [
                  // Ripple rings blooming behind the logo.
                  CustomPaint(
                    painter: _RipplePainter(
                      progress: _ripple.value,
                      visible: logoT.clamp(0.0, 1.0),
                      color: onBackground.withValues(alpha: 0.10),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo container: springs in, circle -> rounded square.
                      Transform.scale(
                        scale: logoT,
                        child: Container(
                          width: widget.logoSize,
                          height: widget.logoSize,
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            borderRadius: BorderRadius.circular(
                              widget.logoSize *
                                  (0.5 - 0.22 * logoT.clamp(0.0, 1.0)),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: scheme.shadow.withValues(alpha: 0.2),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: IconTheme(
                            data: IconThemeData(
                              color: scheme.onPrimary,
                              size: widget.logoSize * 0.5,
                            ),
                            child: widget.logo,
                          ),
                        ),
                      ),
                      if (widget.title != null) ...[
                        const SizedBox(height: 24),
                        // Title slides up and fades in.
                        Opacity(
                          opacity: textT,
                          child: Transform.translate(
                            offset: Offset(0, 16 * (1 - textT)),
                            child: DefaultTextStyle(
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(color: onBackground),
                              child: widget.title!,
                            ),
                          ),
                        ),
                      ],
                      if (widget.tagline != null) ...[
                        const SizedBox(height: 8),
                        Opacity(
                          opacity: (textT - 0.3).clamp(0.0, 1.0) / 0.7,
                          child: Transform.translate(
                            offset: Offset(0, 12 * (1 - textT)),
                            child: DefaultTextStyle(
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color:
                                        onBackground.withValues(alpha: 0.7),
                                  ),
                              child: widget.tagline!,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (_exiting) const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RipplePainter extends CustomPainter {
  _RipplePainter({
    required this.progress,
    required this.visible,
    required this.color,
  });

  final double progress;
  final double visible;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (visible <= 0) return;
    final center = size.center(Offset.zero);
    final maxRadius = size.shortestSide * 0.75;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Three staggered rings, each fading as it expands.
    for (int i = 0; i < 3; i++) {
      final t = (progress + i / 3) % 1.0;
      final radius = 60 + (maxRadius - 60) * t;
      paint.color = color.withValues(
        alpha: color.a * (1 - t) * visible,
      );
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_RipplePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.visible != visible;
}
