import 'package:flutter/material.dart';

import 'me_waved_progress.dart';

/// Split-track linear progress, with an optional waved stroke variant.
class MECustomProgressIndicator extends StatefulWidget {
  const MECustomProgressIndicator({
    super.key,
    required this.percent,
    this.waved = true,
    this.wavedOptions = MEWavedProgressOptions.defaultOptions,
    this.linearOptions = MELinearProgressOptions.defaultOptions,
    this.disableStartupAnimation = false,
  });

  final double percent;
  final bool waved;
  final MEWavedProgressOptions wavedOptions;
  final MELinearProgressOptions linearOptions;
  final bool disableStartupAnimation;

  @override
  State<MECustomProgressIndicator> createState() =>
      _MECustomProgressIndicatorState();
}

class _MECustomProgressIndicatorState extends State<MECustomProgressIndicator> {
  late final ValueNotifier<bool> _isAfterFirstFrame;

  @override
  void initState() {
    super.initState();
    _isAfterFirstFrame = ValueNotifier<bool>(widget.disableStartupAnimation);
    if (widget.disableStartupAnimation) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _isAfterFirstFrame.value = true;
    });
  }

  @override
  void dispose() {
    _isAfterFirstFrame.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return _buildProgressIndicator(context, constraints.maxWidth);
      },
    );
  }

  Widget _buildProgressIndicator(BuildContext context, double maxWidth) {
    final scheme = Theme.of(context).colorScheme;
    final percent = widget.percent.clamp(0.0, 1.0);
    if (widget.waved) {
      final boundedWidth = maxWidth.isFinite ? maxWidth : 0.0;
      final frequency = (boundedWidth ~/ widget.wavedOptions.frequency)
          .clamp(5.0, 15.0)
          .toDouble();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: MEWavedProgressIndicator.linear(
          disableStartupAnimation: widget.disableStartupAnimation,
          enabled: widget.wavedOptions.animated && percent < 1.0,
          progress: percent,
          frequency: frequency,
          maxWaveHeight: widget.wavedOptions.maxWaveHeight,
          waveStrokeWidth: widget.wavedOptions.waveStrokeWidth,
          lineStrokeWidth: widget.wavedOptions.lineStrokeWidth,
          enabledColor: scheme.primary,
          disabledColor: scheme.secondaryContainer,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.linearOptions.radius),
      child: ValueListenableBuilder<bool>(
        valueListenable: _isAfterFirstFrame,
        builder: (context, ready, child) {
          final target = ready ? percent : 0.0;
          return TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: target),
            duration: widget.disableStartupAnimation
                ? Duration.zero
                : Durations.medium4,
            curve: Curves.easeOut,
            builder: (context, t, child) {
              final filled = t.clamp(0.0, 1.0);
              final filledFlex = (filled * 1000).round().clamp(0, 1000);
              final restFlex = 1000 - filledFlex;
              final gap = filledFlex > 0 && restFlex > 0 ? 3.0 : 0.0;
              return SizedBox(
                height: widget.linearOptions.height,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (filledFlex > 0)
                      Expanded(
                        flex: filledFlex,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            borderRadius: BorderRadius.circular(
                              widget.linearOptions.innerRadius,
                            ),
                          ),
                        ),
                      ),
                    if (restFlex > 0)
                      Expanded(
                        flex: restFlex,
                        child: Padding(
                          padding: EdgeInsetsDirectional.only(start: gap),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: scheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(
                                widget.linearOptions.innerRadius,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class MELinearProgressOptions {
  const MELinearProgressOptions({
    required this.height,
    required this.radius,
    required this.innerRadius,
  });

  final double height;
  final double radius;
  final double innerRadius;

  static const MELinearProgressOptions defaultOptions =
      MELinearProgressOptions(
        height: 18,
        radius: 100,
        innerRadius: 4,
      );

  MELinearProgressOptions copyWith({
    double? height,
    double? radius,
    double? innerRadius,
  }) {
    return MELinearProgressOptions(
      height: height ?? this.height,
      radius: radius ?? this.radius,
      innerRadius: innerRadius ?? this.innerRadius,
    );
  }
}

class MEWavedProgressOptions {
  const MEWavedProgressOptions({
    required this.frequency,
    required this.maxWaveHeight,
    required this.waveStrokeWidth,
    required this.lineStrokeWidth,
    required this.animated,
  });

  final double frequency;
  final double maxWaveHeight;
  final double waveStrokeWidth;
  final double lineStrokeWidth;
  final bool animated;

  static const MEWavedProgressOptions defaultOptions = MEWavedProgressOptions(
    frequency: 30,
    maxWaveHeight: 4,
    waveStrokeWidth: 8,
    lineStrokeWidth: 8,
    animated: true,
  );

  MEWavedProgressOptions copyWith({
    double? frequency,
    double? maxWaveHeight,
    double? waveStrokeWidth,
    double? lineStrokeWidth,
    bool? animated,
  }) {
    return MEWavedProgressOptions(
      frequency: frequency ?? this.frequency,
      maxWaveHeight: maxWaveHeight ?? this.maxWaveHeight,
      waveStrokeWidth: waveStrokeWidth ?? this.waveStrokeWidth,
      lineStrokeWidth: lineStrokeWidth ?? this.lineStrokeWidth,
      animated: animated ?? this.animated,
    );
  }
}
