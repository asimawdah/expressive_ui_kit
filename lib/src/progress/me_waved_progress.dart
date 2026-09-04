import 'dart:math';
import 'package:flutter/material.dart';

class MEWavedProgressIndicator extends StatefulWidget {
  final bool enabled;
  final bool animateWave;
  final Color? enabledColor;
  final Color? disabledColor;
  final double frequency;
  final double maxWaveHeight;
  final double waveStrokeWidth;
  final double lineStrokeWidth;
  final double? radius;
  final double? progress;
  final double spaceBetween;
  final Duration waveAnimationDuration;
  final Duration transitionAnimationDuration;
  final Duration progressAnimationDuration;
  final Gradient? gradient;
  final Widget? child;
  final bool _isCircular;
  final bool disableStartupAnimation;

  // Private constructor
  const MEWavedProgressIndicator._({
    super.key,
    this.animateWave = true,
    this.enabled = true,
    this.enabledColor,
    this.disabledColor,
    this.frequency = 2.0,
    this.maxWaveHeight = 8.0,
    this.waveStrokeWidth = 4,
    this.lineStrokeWidth = 4,
    this.radius,
    this.progress,
    this.spaceBetween = 5.0,
    this.waveAnimationDuration = const Duration(milliseconds: 2000),
    this.transitionAnimationDuration = const Duration(milliseconds: 300),
    this.progressAnimationDuration = const Duration(milliseconds: 800),
    this.gradient,
    this.disableStartupAnimation = false,
    this.child,
    required bool isCircular,
  }) : _isCircular = isCircular;

  factory MEWavedProgressIndicator.linear({
    Key? key,
    bool animateWave = true,
    bool enabled = true,
    Color? enabledColor,
    Color? disabledColor,
    double frequency = 2.0,
    double maxWaveHeight = 8.0,
    double waveStrokeWidth = 4,
    double lineStrokeWidth = 4,
    double? progress,
    double spaceBetween = 5.0,
    Duration waveAnimationDuration = const Duration(milliseconds: 2000),
    Duration transitionAnimationDuration = const Duration(milliseconds: 300),
    Duration progressAnimationDuration = const Duration(milliseconds: 800),
    bool disableStartupAnimation = false,
    Gradient? gradient,
  }) {
    assert(
      gradient == null || (enabledColor == null && disabledColor == null),
      'Provide a gradient or at least one of enabledColor or disabledColor.',
    );
    return MEWavedProgressIndicator._(
      key: key,
      animateWave: animateWave,
      enabled: enabled,
      enabledColor: enabledColor,
      disabledColor: disabledColor,
      frequency: frequency,
      maxWaveHeight: maxWaveHeight,
      waveStrokeWidth: waveStrokeWidth,
      lineStrokeWidth: lineStrokeWidth,
      progress: progress,
      spaceBetween: spaceBetween,
      waveAnimationDuration: waveAnimationDuration,
      transitionAnimationDuration: transitionAnimationDuration,
      progressAnimationDuration: progressAnimationDuration,
      gradient: gradient,
      disableStartupAnimation: disableStartupAnimation,
      isCircular: false,
    );
  }

  factory MEWavedProgressIndicator.circular({
    Key? key,
    bool animateWave = true,
    bool enabled = true,
    Color? enabledColor,
    Color? disabledColor,
    double frequency = 2.0,
    double maxWaveHeight = 8.0,
    double waveStrokeWidth = 4,
    double lineStrokeWidth = 4,
    double radius = 50,
    double? progress,
    double spaceBetween = 5.0,
    Duration waveAnimationDuration = const Duration(milliseconds: 2000),
    Duration transitionAnimationDuration = const Duration(milliseconds: 300),
    Duration progressAnimationDuration = const Duration(milliseconds: 800),
    Gradient? gradient,
    bool disableStartupAnimation = false,
    Widget? child,
  }) {
    assert(
      gradient == null || (enabledColor == null && disabledColor == null),
      'Provide a gradient or at least one of enabledColor or disabledColor.',
    );
    return MEWavedProgressIndicator._(
      key: key,
      animateWave: animateWave,
      enabled: enabled,
      enabledColor: enabledColor,
      disabledColor: disabledColor,
      frequency: frequency,
      maxWaveHeight: maxWaveHeight,
      waveStrokeWidth: waveStrokeWidth,
      lineStrokeWidth: lineStrokeWidth,
      radius: radius,
      progress: progress,
      spaceBetween: spaceBetween,
      waveAnimationDuration: waveAnimationDuration,
      transitionAnimationDuration: transitionAnimationDuration,
      progressAnimationDuration: progressAnimationDuration,
      gradient: gradient,
      disableStartupAnimation: disableStartupAnimation,
      isCircular: true,
      child: child,
    );
  }

  // Getters for type checking
  bool get isCircular => _isCircular;
  bool get isLinear => !_isCircular;

  @override
  State<MEWavedProgressIndicator> createState() =>
      MEWavedProgressIndicatorState();
}

class MEWavedProgressIndicatorState
    extends State<MEWavedProgressIndicator>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _transitionController;
  late AnimationController _progressController;
  late Animation<double> _waveTransition;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _progressAnimation;

  late ValueNotifier<bool> _isAfterFirstFrame;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _isAfterFirstFrame = ValueNotifier<bool>(widget.disableStartupAnimation);
    if (widget.disableStartupAnimation) {
      _progressController.value = 1.0;
    }

    // Trigger progress animation after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isAfterFirstFrame.value = true;
      if (!widget.disableStartupAnimation &&
          widget.progress != null &&
          widget.progress! > 0) {
        _progressController.forward();
      }
    });

    if (widget.enabled) _startWave();
  }

  void _initializeAnimations() {
    _waveController = AnimationController(
      vsync: this,
      duration: widget.waveAnimationDuration,
    );

    _transitionController = AnimationController(
      vsync: this,
      duration: widget.transitionAnimationDuration,
    );

    _progressController = AnimationController(
      vsync: this,
      duration: widget.progressAnimationDuration,
    );

    _waveTransition = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _transitionController, curve: Curves.easeInOut),
    );

    _colorAnimation = widget.gradient != null
        ? const AlwaysStoppedAnimation<Color?>(null)
        : ColorTween(
            begin: widget.disabledColor,
            end: widget.enabledColor,
          ).animate(
            CurvedAnimation(
              parent: _transitionController,
              curve: Curves.easeInOut,
            ),
          );

    _progressAnimation = Tween<double>(begin: 0.0, end: widget.progress ?? 1.0)
        .animate(
          CurvedAnimation(
            parent: _progressController,
            curve: Curves.fastOutSlowIn,
          ),
        );
  }

  @override
  void didUpdateWidget(MEWavedProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update animation duration if changed
    if (oldWidget.waveAnimationDuration != widget.waveAnimationDuration) {
      _waveController.dispose();
      _waveController = AnimationController(
        vsync: this,
        duration: widget.waveAnimationDuration,
      );
      if (widget.enabled && widget.animateWave) {
        _waveController.repeat();
      }
    }

    // Update progress animation duration if changed
    if (oldWidget.progressAnimationDuration !=
        widget.progressAnimationDuration) {
      _progressController.dispose();
      _progressController = AnimationController(
        vsync: this,
        duration: widget.progressAnimationDuration,
      );
    }

    // Update progress animation if progress value changed
    if (oldWidget.progress != widget.progress) {
      _progressAnimation =
          Tween<double>(
            begin: _progressAnimation.value,
            end: widget.progress ?? 1.0,
          ).animate(
            CurvedAnimation(
              parent: _progressController,
              curve: Curves.fastOutSlowIn,
            ),
          );

      _progressController.reset();
      if (_isAfterFirstFrame.value) {
        _progressController.forward();
      }
    }

    // Update color animation
    _colorAnimation =
        ColorTween(
          begin: widget.disabledColor ?? Theme.of(context).disabledColor,
          end: widget.enabledColor ?? Theme.of(context).colorScheme.primary,
        ).animate(
          CurvedAnimation(
            parent: _transitionController,
            curve: Curves.easeInOut,
          ),
        );

    if (widget.enabled) {
      _startWave();
    } else {
      _stopWave();
    }
  }

  void _startWave() async {
    _transitionController.forward();
    if (widget.animateWave) _waveController.repeat();
  }

  void _stopWave() {
    _transitionController.reverse().whenComplete(() => _waveController.stop());
  }

  // Public methods for external control
  void pauseWave() => _waveController.stop();
  void resumeWave() => widget.animateWave ? _waveController.repeat() : null;
  void resetWave() {
    _waveController.reset();
    if (widget.animateWave) _waveController.repeat();
  }

  // New method to manually trigger progress animation
  void animateToProgress() {
    _progressController.reset();
    _progressController.forward();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _transitionController.dispose();
    _progressController.dispose();
    _isAfterFirstFrame.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _waveController,
        _waveTransition,
        _colorAnimation,
        _progressAnimation, // Add progress animation to the listener
      ]),
      builder: (context, child) {
        return widget.isCircular ? _buildCircularWave() : _buildLinearWave();
      },
    );
  }

  Widget _buildCircularWave() {
    final double radius = widget.radius ?? 50;
    Size size = Size(
      radius * 2 + widget.maxWaveHeight * 1.5,
      radius * 2 + widget.maxWaveHeight * 1.5,
    );
    return SizedBox.fromSize(
      size: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: CustomPaint(
              size: size,
              painter: _WavePainter.circular(
                animationValue: _waveController.value,
                waveFactor: _waveTransition.value,
                waveColor:
                    _colorAnimation.value ??
                    widget.enabledColor ??
                    Theme.of(context).primaryColor,
                lineColor:
                    widget.disabledColor ?? Theme.of(context).dividerColor,
                progress: _progressAnimation.value,
                frequency: widget.frequency,
                maxWaveHeight: widget.maxWaveHeight,
                waveStrokeWidth: widget.waveStrokeWidth,
                lineStrokeWidth: widget.lineStrokeWidth,
                radius: radius,
                spaceBetween: widget.spaceBetween,
                gradient: widget.gradient,
                enabled: widget.enabled,
                enabledColor:
                    widget.enabledColor ?? Theme.of(context).primaryColor,
              ),
            ),
          ),
          if (widget.child != null)
            Positioned(child: Center(child: widget.child)),
        ],
      ),
    );
  }

  Widget _buildLinearWave() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, (widget.maxWaveHeight * 2) + 10),
          painter: _WavePainter.linear(
            animationValue: _waveController.value,
            waveFactor: _waveTransition.value,
            waveColor:
                _colorAnimation.value ??
                widget.enabledColor ??
                Theme.of(context).colorScheme.primary,
            lineColor:
                widget.disabledColor ??
                Theme.of(context).colorScheme.secondaryContainer,
            maxWaveHeight: widget.maxWaveHeight,
            frequency: widget.frequency,
            waveStrokeWidth: widget.waveStrokeWidth,
            lineStrokeWidth: widget.lineStrokeWidth,
            gradient: widget.gradient,
            progress: _progressAnimation.value,
            spaceBetween: widget.spaceBetween,
            enabled: widget.enabled,
            enabledColor:
                widget.enabledColor ?? Theme.of(context).colorScheme.primary,
          ),
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  final double animationValue;
  final double waveFactor;
  final Color waveColor;
  final Color lineColor;
  final double frequency;
  final double maxWaveHeight;
  final double waveStrokeWidth;
  final double lineStrokeWidth;
  final Gradient? gradient;
  final double? progress;
  final double spaceBetween;
  final bool enabled;
  final Color enabledColor;

  final double? radius;
  final double? startAngle;

  final bool _isCircular;

  // Private constructor
  _WavePainter._({
    required this.animationValue,
    required this.waveFactor,
    required this.waveColor,
    required this.lineColor,
    required this.frequency,
    required this.maxWaveHeight,
    required this.waveStrokeWidth,
    required this.lineStrokeWidth,
    required this.gradient,
    required this.progress,
    required this.spaceBetween,
    required bool isCircular,
    required this.enabled,
    required this.enabledColor,
    this.radius,
    this.startAngle,
  }) : _isCircular = isCircular;

  factory _WavePainter.circular({
    required double animationValue,
    required double waveFactor,
    required Color waveColor,
    required Color lineColor,
    required double frequency,
    required double maxWaveHeight,
    required double waveStrokeWidth,
    required double lineStrokeWidth,
    required double radius,
    required bool enabled,
    required Color enabledColor,
    double? progress,
    double spaceBetween = 5.0,
    double startAngle = -pi / 2,
    Gradient? gradient,
  }) {
    return _WavePainter._(
      animationValue: animationValue,
      waveFactor: waveFactor,
      waveColor: waveColor,
      lineColor: lineColor,
      frequency: frequency,
      maxWaveHeight: maxWaveHeight,
      waveStrokeWidth: waveStrokeWidth,
      lineStrokeWidth: lineStrokeWidth,
      gradient: gradient,
      progress: progress,
      spaceBetween: spaceBetween,
      radius: radius,
      startAngle: startAngle,
      isCircular: true,
      enabled: enabled,
      enabledColor: enabledColor,
    );
  }

  factory _WavePainter.linear({
    required double animationValue,
    required double waveFactor,
    required Color waveColor,
    required Color lineColor,
    required double frequency,
    required double maxWaveHeight,
    required double waveStrokeWidth,
    required double lineStrokeWidth,
    required bool enabled,
    required Color enabledColor,
    double? progress,
    double spaceBetween = 5.0,
    Gradient? gradient,
  }) {
    return _WavePainter._(
      animationValue: animationValue,
      waveFactor: waveFactor,
      waveColor: waveColor,
      lineColor: lineColor,
      frequency: frequency,
      maxWaveHeight: maxWaveHeight,
      waveStrokeWidth: waveStrokeWidth,
      lineStrokeWidth: lineStrokeWidth,
      gradient: gradient,
      progress: progress,
      spaceBetween: spaceBetween,
      isCircular: false,
      enabled: enabled,
      enabledColor: enabledColor,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (_isCircular) {
      _paintCircularWave(canvas, size);
    } else {
      _paintLinearWave(canvas, size);
    }
  }

  void _paintCircularWave(Canvas canvas, Size size) {
    final Paint progressPaint = _createProgressPaint(size);
    final Paint linePaint = _createLinePaint();

    final double progressAngle = (progress ?? 1.0) * 2 * pi;
    final double waveHeight = maxWaveHeight * (enabled ? waveFactor : 0);
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double circleRadius = radius!;
    final double startAngleRad = startAngle ?? -pi / 2;

    // Calculate effective space between based on progress
    final double effectiveSpaceBetween = _getEffectiveSpaceBetween();
    final double spaceAngle = effectiveSpaceBetween / circleRadius;

    // Calculate the end angle for the wave considering space
    final double waveEndAngle = progressAngle == 0
        ? 0
        : (progressAngle >= 2 * pi ? 2 * pi : progressAngle - spaceAngle);

    if (waveEndAngle > 0) {
      final Path progressPath = Path();
      bool isFirstProgressPoint = true;
      const double angleStep = 0.005;

      for (double angle = 0; angle < waveEndAngle; angle += angleStep) {
        final double currentAngle = startAngleRad + angle;
        final double waveOffset = enabled
            ? sin(angle * frequency + animationValue * 2 * pi) * waveHeight
            : 0;
        final double r = circleRadius + waveOffset;
        final double x = centerX + r * cos(currentAngle);
        final double y = centerY + r * sin(currentAngle);

        if (isFirstProgressPoint) {
          progressPath.moveTo(x, y);
          isFirstProgressPoint = false;
        } else {
          progressPath.lineTo(x, y);
        }
      }

      if (!isFirstProgressPoint) {
        canvas.drawPath(progressPath, progressPaint);
      }
    }

    // Draw remaining line part
    if (progressAngle < 2 * pi) {
      final Path linePath = Path();
      final double lineStartAngle = progressAngle + spaceAngle;
      final double lineEndAngle = 2 * pi - spaceAngle;

      if (lineStartAngle < lineEndAngle) {
        bool isFirstLinePoint = true;
        const double angleStep = 0.005;

        for (
          double angle = lineStartAngle;
          angle < lineEndAngle;
          angle += angleStep
        ) {
          final double currentAngle = startAngleRad + angle;
          final double x = centerX + circleRadius * cos(currentAngle);
          final double y = centerY + circleRadius * sin(currentAngle);

          if (isFirstLinePoint) {
            linePath.moveTo(x, y);
            isFirstLinePoint = false;
          } else {
            linePath.lineTo(x, y);
          }
        }

        if (!isFirstLinePoint) canvas.drawPath(linePath, linePaint);
      }
    }
  }

  void _paintLinearWave(Canvas canvas, Size size) {
    final Paint linePaint = _createLinePaint();
    final Paint progressPaint = _createProgressPaint(size);
    final Paint dotPaint = Paint()..style = PaintingStyle.fill;

    if (gradient != null) {
      dotPaint.shader = gradient!.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );
    } else {
      dotPaint.color = enabledColor;
    }

    final double centerY = size.height / 2;
    final double progressWidth = (progress ?? 1.0) * size.width;
    // Only animate wave when enabled
    final double waveHeight = maxWaveHeight * (enabled ? waveFactor : 0);
    final double phaseShift = animationValue * 2 * pi;

    // Calculate effective space between based on progress
    final double effectiveSpaceBetween = _getEffectiveSpaceBetween();

    // Draw progress part (always in enabled color)
    if (progressWidth > 0) {
      final Path progressPath = Path();
      const double step = 0.005;

      double firstY = centerY + (enabled ? sin(phaseShift) * waveHeight : 0);
      progressPath.moveTo(0, firstY);

      // Calculate the end position for the wave considering space
      final double waveEndX = progressWidth >= size.width
          ? size.width
          : (progressWidth <= 0 ? 0 : progressWidth - effectiveSpaceBetween);

      for (double x = step; x <= waveEndX; x += step) {
        final double normalizedX = x / size.width;
        final double waveY =
            centerY +
            (enabled
                ? sin(normalizedX * frequency * 2 * pi + phaseShift) *
                      waveHeight
                : 0);
        progressPath.lineTo(x, waveY);
      }

      canvas.drawPath(progressPath, progressPaint);
    }

    // Draw line part only if progress is not complete and not empty
    if (progressWidth < size.width) {
      final double lineStart = progressWidth + effectiveSpaceBetween;
      if (lineStart < size.width) {
        final Path linePath = Path();
        linePath.moveTo(lineStart, centerY);
        linePath.lineTo(size.width, centerY);
        canvas.drawPath(linePath, linePaint);
        canvas.drawCircle(
          Offset(size.width * .995, centerY),
          lineStrokeWidth / 3,
          dotPaint,
        );
      }
    }
  }

  // Helper method to calculate effective space between based on progress
  double _getEffectiveSpaceBetween() {
    final double currentProgress = progress ?? 1.0;
    // Remove space when progress is 0% or 100%
    if (currentProgress <= 0.0 || currentProgress >= 1.0) return 0.0;

    return spaceBetween;
  }

  // New method to create progress paint (always uses enabled color)
  Paint _createProgressPaint(Size size) {
    final Paint paint = Paint()
      ..strokeWidth = waveStrokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (gradient != null) {
      paint.shader = gradient!.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );
    } else {
      paint.color = enabledColor; // Always use enabled color for progress
    }

    return paint;
  }

  Paint _createLinePaint() {
    return Paint()
      ..color = lineColor
      ..strokeWidth = lineStrokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
