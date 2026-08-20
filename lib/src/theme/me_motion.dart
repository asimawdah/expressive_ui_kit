import 'dart:math' as math;

import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';
import 'package:motor/motor.dart';

/// A spring specification following the Material 3 Expressive motion system.
///
/// Backed by the same [motor] physics that `m3e_core` uses
/// ([MaterialSpringMotion] tokens). M3 Expressive replaces duration/easing
/// pairs with physics-based springs, split into two families:
///
/// * **Spatial** springs animate position, size and shape. They may bounce.
/// * **Effects** springs animate color, opacity and elevation. They are
///   critically damped and never bounce.
@immutable
class MESpringSpec {
  const MESpringSpec({
    required this.dampingRatio,
    required this.stiffness,
    this.instant = false,
  });

  /// A zero-duration spec used when the platform requests reduced motion.
  static const zero = MESpringSpec(
    dampingRatio: 1.0,
    stiffness: 1.0,
    instant: true,
  );

  /// Snappy expressive spatial spring — [MaterialSpringMotion.expressiveSpatialFast].
  static const expressiveSpatialFast =
      MESpringSpec(dampingRatio: 0.6, stiffness: 800);

  /// Balanced expressive spatial spring — [MaterialSpringMotion.expressiveSpatialDefault].
  static const expressiveSpatialDefault =
      MESpringSpec(dampingRatio: 0.8, stiffness: 380);

  /// Slow expressive spatial spring — [MaterialSpringMotion.expressiveSpatialSlow].
  static const expressiveSpatialSlow =
      MESpringSpec(dampingRatio: 0.8, stiffness: 200);

  /// Snappy standard spatial spring — [MaterialSpringMotion.standardSpatialFast].
  static const standardSpatialFast =
      MESpringSpec(dampingRatio: 0.9, stiffness: 1400);

  /// Balanced standard spatial spring — [MaterialSpringMotion.standardSpatialDefault].
  static const standardSpatialDefault =
      MESpringSpec(dampingRatio: 0.9, stiffness: 700);

  /// Slow standard spatial spring — [MaterialSpringMotion.standardSpatialSlow].
  static const standardSpatialSlow =
      MESpringSpec(dampingRatio: 0.9, stiffness: 300);

  /// Fast effects (opacity/color) — [MaterialSpringMotion.standardEffectsFast].
  static const standardEffectsFast =
      MESpringSpec(dampingRatio: 1.0, stiffness: 3800);

  /// Default effects — [MaterialSpringMotion.standardEffectsDefault].
  static const standardEffectsDefault =
      MESpringSpec(dampingRatio: 1.0, stiffness: 1600);

  /// Slow effects — [MaterialSpringMotion.standardEffectsSlow].
  static const standardEffectsSlow =
      MESpringSpec(dampingRatio: 1.0, stiffness: 800);

  /// Same physics as [standardEffectsFast] — [MaterialSpringMotion.expressiveEffectsFast].
  static const expressiveEffectsFast = standardEffectsFast;

  /// Same physics as [standardEffectsDefault] — [MaterialSpringMotion.expressiveEffectsDefault].
  static const expressiveEffectsDefault = standardEffectsDefault;

  /// Same physics as [standardEffectsSlow] — [MaterialSpringMotion.expressiveEffectsSlow].
  static const expressiveEffectsSlow = standardEffectsSlow;

  /// Overflow menu spring used by `m3e_core` button groups (1600 / 0.85).
  static const standardOverflow =
      MESpringSpec(dampingRatio: 0.85, stiffness: 1600);

  /// Popup / dropdown bounce used by `m3e_core` menus (1000 / 0.6).
  static const standardPopup = MESpringSpec(dampingRatio: 0.6, stiffness: 1000);

  /// Damping ratio. 1.0 is critically damped (no bounce), < 1.0 bounces.
  /// Same meaning as [MaterialSpringMotion.damping].
  final double dampingRatio;

  /// Spring stiffness. Higher values settle faster.
  /// Same meaning as [MaterialSpringMotion.stiffness].
  final double stiffness;

  /// When true, animations snap to their target with no spring simulation.
  final bool instant;

  /// The [motor] motion that drives this spec — the same conversion
  /// `m3e_core`'s `M3EMotion.toMotion()` uses (`MaterialSpringMotion.copyWith`).
  Motion toMotion({bool snapToEnd = false}) {
    if (instant) return const NoMotion();
    return const MaterialSpringMotion.expressiveEffectsFast().copyWith(
      stiffness: stiffness,
      damping: dampingRatio,
      snapToEnd: snapToEnd,
    );
  }

  /// Converts this spec into a [SpringDescription] usable with
  /// [SpringSimulation] or `AnimationController.animateWith`.
  SpringDescription toSpringDescription({double mass = 1.0}) {
    return SpringDescription.withDampingRatio(
      mass: mass,
      stiffness: stiffness,
      ratio: dampingRatio,
    );
  }

  /// An approximate [Duration] for the spring to settle, useful when a
  /// widget needs a bounded [AnimationController].
  Duration get approximateDuration {
    if (instant) return Duration.zero;
    // Settle time approximation for an underdamped/critically damped spring.
    final double omega = stiffness <= 0 ? 1 : stiffness;
    final double seconds = 8.0 / (dampingRatio * math.sqrt(omega));
    return Duration(milliseconds: (seconds * 1000).clamp(50, 1200).round());
  }

  /// A [Curve] that follows this spring's motion, for use with standard
  /// curve-driven animations (implicit animations, transitions, etc).
  Curve get curve => instant ? const Threshold(0.0) : MESpringCurve(this);

  @override
  bool operator ==(Object other) {
    return other is MESpringSpec &&
        other.dampingRatio == dampingRatio &&
        other.stiffness == stiffness &&
        other.instant == instant;
  }

  @override
  int get hashCode => Object.hash(dampingRatio, stiffness, instant);
}

/// A [Curve] backed by a [motor] spring simulation, allowing spring physics
/// to be used anywhere Flutter expects a curve.
class MESpringCurve extends Curve {
  MESpringCurve(this.spec)
      : _sim = spec.toMotion().createSimulation(),
        _settle = spec.approximateDuration.inMilliseconds / 1000.0;

  final MESpringSpec spec;
  final Simulation _sim;
  final double _settle;

  @override
  double transformInternal(double t) {
    if (t >= 1.0) return 1.0;
    return _sim.x(t * _settle);
  }
}

/// The complete Material 3 Expressive motion scheme.
///
/// Mirrors the `MotionScheme` API from Material Design plus the extra
/// overflow/popup springs from `m3e_core`. Three speeds (fast, default,
/// slow) for each of the two families (spatial, effects).
@immutable
class MEMotionScheme {
  const MEMotionScheme({
    required this.fastSpatial,
    required this.defaultSpatial,
    required this.slowSpatial,
    required this.fastEffects,
    required this.defaultEffects,
    required this.slowEffects,
    this.overflow = MESpringSpec.standardOverflow,
    this.popup = MESpringSpec.standardPopup,
  });

  final MESpringSpec fastSpatial;
  final MESpringSpec defaultSpatial;
  final MESpringSpec slowSpatial;
  final MESpringSpec fastEffects;
  final MESpringSpec defaultEffects;
  final MESpringSpec slowEffects;

  /// Spring for overflow menus and extra actions sliding into view.
  final MESpringSpec overflow;

  /// Spring for popups and dropdowns (bouncier than spatial default).
  final MESpringSpec popup;

  /// The expressive motion scheme: spatial springs bounce for a playful,
  /// energetic feel. This is the default for Material 3 Expressive.
  ///
  /// Tokens match [MaterialSpringMotion] expressive spatial / effects.
  static const MEMotionScheme expressive = MEMotionScheme(
    fastSpatial: MESpringSpec.expressiveSpatialFast,
    defaultSpatial: MESpringSpec.expressiveSpatialDefault,
    slowSpatial: MESpringSpec.expressiveSpatialSlow,
    fastEffects: MESpringSpec.standardEffectsFast,
    defaultEffects: MESpringSpec.standardEffectsDefault,
    slowEffects: MESpringSpec.standardEffectsSlow,
  );

  /// The standard motion scheme: spatial springs are nearly critically
  /// damped and do not bounce. Use for utilitarian or dense UIs.
  static const MEMotionScheme standard = MEMotionScheme(
    fastSpatial: MESpringSpec.standardSpatialFast,
    defaultSpatial: MESpringSpec.standardSpatialDefault,
    slowSpatial: MESpringSpec.standardSpatialSlow,
    fastEffects: MESpringSpec.standardEffectsFast,
    defaultEffects: MESpringSpec.standardEffectsDefault,
    slowEffects: MESpringSpec.standardEffectsSlow,
  );

  /// Instant motion for reduced-motion accessibility settings. All springs
  /// snap to their targets with no bounce or overshoot.
  static const MEMotionScheme reduced = MEMotionScheme(
    fastSpatial: MESpringSpec.zero,
    defaultSpatial: MESpringSpec.zero,
    slowSpatial: MESpringSpec.zero,
    fastEffects: MESpringSpec.zero,
    defaultEffects: MESpringSpec.zero,
    slowEffects: MESpringSpec.zero,
    overflow: MESpringSpec.zero,
    popup: MESpringSpec.zero,
  );
}

/// Drives an [AnimationController] with a [motor] spring simulation toward
/// [target], honoring the current velocity so animations are interruptible —
/// a core requirement of M3 Expressive motion (same engine as `m3e_core`).
///
/// Returns the same [TickerFuture] as [AnimationController.animateWith], so
/// callers can `await` settlement (splash exit, dice landing, coin flip).
TickerFuture springTo(
  AnimationController controller,
  double target,
  MESpringSpec spec, {
  double? velocity,
}) {
  if (spec.instant) {
    controller.value = target;
    return TickerFuture.complete();
  }
  return controller.animateWith(
    spec.toMotion().createSimulation(
          start: controller.value,
          end: target,
          velocity: velocity ?? controller.velocity,
        ),
  );
}

/// Animates a scalar with the same [SingleMotionBuilder] widget `m3e_core`
/// uses. Overshoot is left unclamped so expressive springs can bounce.
class MEMotionBuilder extends StatelessWidget {
  const MEMotionBuilder({
    super.key,
    required this.value,
    required this.spec,
    required this.builder,
    this.from,
    this.child,
  });

  final double value;
  final MESpringSpec spec;
  final ValueWidgetBuilder<double> builder;

  /// Starting value for the first animation — same as motor's
  /// [SingleMotionBuilder.from]. When null, the builder starts at [value].
  final double? from;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    if (spec.instant) return builder(context, value, child);
    return SingleMotionBuilder(
      value: value,
      from: from,
      motion: spec.toMotion(),
      builder: builder,
      child: child,
    );
  }
}

/// Springs [child] open/closed along [axis] — the motor equivalent of
/// [AnimatedSize] used by `m3e_core` expandables and filter chips.
class MEMotionReveal extends StatelessWidget {
  const MEMotionReveal({
    super.key,
    required this.visible,
    required this.spec,
    required this.child,
    this.axis = Axis.horizontal,
    this.alignment = Alignment.center,
  });

  final bool visible;
  final MESpringSpec spec;
  final Widget child;
  final Axis axis;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return MEMotionBuilder(
      value: visible ? 1.0 : 0.0,
      spec: spec,
      builder: (context, t, child) {
        if (t <= 0.001) return const SizedBox.shrink();
        return ClipRect(
          child: Align(
            alignment: alignment,
            widthFactor: axis == Axis.horizontal ? t : null,
            heightFactor: axis == Axis.vertical ? t : null,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Springs a width constraint — used instead of [AnimatedContainer] width.
class MEMotionWidth extends StatelessWidget {
  const MEMotionWidth({
    super.key,
    required this.width,
    required this.spec,
    required this.child,
  });

  final double width;
  final MESpringSpec spec;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MEMotionBuilder(
      value: width,
      spec: spec,
      builder: (context, w, child) => SizedBox(width: w, child: child),
      child: child,
    );
  }
}

/// Springs opacity — used instead of [AnimatedOpacity] / [FadeTransition].
class MEMotionOpacity extends StatelessWidget {
  const MEMotionOpacity({
    super.key,
    required this.opacity,
    required this.spec,
    required this.child,
  });

  final double opacity;
  final MESpringSpec spec;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MEMotionBuilder(
      value: opacity,
      spec: spec,
      builder: (context, t, child) =>
          Opacity(opacity: t.clamp(0.0, 1.0), child: child),
      child: child,
    );
  }
}
