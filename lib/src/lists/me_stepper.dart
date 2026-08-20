import 'package:flutter/material.dart';

import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';

/// A step in an [MEStepper].
class MEStep {
  const MEStep({
    required this.title,
    this.subtitle,
    required this.content,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget content;
}

/// A Material 3 Expressive vertical stepper.
///
/// Replaces [Stepper]. Steps are numbered pills that fill with the
/// primary color when completed; the active step's content expands with
/// a spring.
class MEStepper extends StatelessWidget {
  const MEStepper({
    super.key,
    required this.steps,
    required this.currentStep,
    this.onStepTapped,
  });

  final List<MEStep> steps;
  final int currentStep;
  final ValueChanged<int>? onStepTapped;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final motion = METheme.of(context).motion;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          InkWell(
            onTap: onStepTapped == null ? null : () => onStepTapped!(i),
            borderRadius: BorderRadius.circular(MECorners.medium),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                children: [
                  _StepIndicator(
                    index: i,
                    state: i < currentStep
                        ? _StepState.complete
                        : i == currentStep
                            ? _StepState.active
                            : _StepState.upcoming,
                    colors: colors,
                    textTheme: textTheme,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DefaultTextStyle.merge(
                          style: textTheme.titleSmall!.copyWith(
                            color: i <= currentStep
                                ? colors.onSurface
                                : colors.onSurfaceVariant,
                            fontWeight: i == currentStep
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                          child: steps[i].title,
                        ),
                        if (steps[i].subtitle != null)
                          DefaultTextStyle.merge(
                            style: textTheme.bodySmall!
                                .copyWith(color: colors.onSurfaceVariant),
                            child: steps[i].subtitle!,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content + connector line.
          AnimatedSize(
            duration: motion.defaultSpatial.approximateDuration,
            curve: motion.defaultSpatial.curve,
            alignment: Alignment.topCenter,
            child: i == currentStep
                ? Padding(
                    padding: const EdgeInsetsDirectional.only(
                        start: 44, top: 4, bottom: 12),
                    child: steps[i].content,
                  )
                : const SizedBox(width: double.infinity),
          ),
          if (i < steps.length - 1)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 19),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Container(
                  width: 2,
                  height: 12,
                  decoration: BoxDecoration(
                    color: i < currentStep
                        ? colors.primary
                        : colors.outlineVariant,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

enum _StepState { complete, active, upcoming }

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.index,
    required this.state,
    required this.colors,
    required this.textTheme,
  });

  final int index;
  final _StepState state;
  final ColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (state) {
      _StepState.complete => (colors.primary, colors.onPrimary),
      _StepState.active => (colors.primaryContainer, colors.onPrimaryContainer),
      _StepState.upcoming => (
          colors.surfaceContainerHighest,
          colors.onSurfaceVariant
        ),
    };

    return AnimatedContainer(
      duration: METheme.of(context).motion.fastSpatial.approximateDuration,
      curve: METheme.of(context).motion.fastSpatial.curve,
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bg,
        // Active step is a squircle; others are circles — shape signals
        // state per M3E.
        borderRadius: BorderRadius.circular(
            state == _StepState.active ? MECorners.medium : 18),
      ),
      child: Center(
        child: state == _StepState.complete
            ? Icon(Icons.check, size: 18, color: fg)
            : Text(
                '${index + 1}',
                style: textTheme.labelLarge!.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
