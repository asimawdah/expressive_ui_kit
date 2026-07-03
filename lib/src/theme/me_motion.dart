import 'dart:math' as math;

import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

/// A spring specification following the Material 3 Expressive motion system.
///
/// M3 Expressive replaces duration/easing pairs with physics-based springs,
/// split into two families:
///
/// * **Spatial** springs animate position, size and shape. They may bounce.
/// * **Effects** springs animate color, opacity and elevation. They are
///   critically damped and never bounce.
@immutable
class MESpringSpec {
  const MESpringSpec({required this.dampingRatio, required this.stiffness});

  /// Damping ratio. 1.0 is critically damped (no bounce), < 1.0 bounces.
  final double dampingRatio;

  /// Spring stiffness. Higher values settle faster.
  final double stiffness;

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
    // Settle time approximation for an underdamped/critically damped spring.
    final double omega = stiffness <= 0 ? 1 : stiffness;
    final double seconds = 8.0 / (dampingRatio * math.sqrt(omega));
    return Duration(milliseconds: (seconds * 1000).clamp(50, 1200).round());
  }

  /// A [Curve] that follows this spring's motion, for use with standard
  /// curve-driven animations (implicit animations, transitions, etc).
  Curve get curve => MESpringCurve(this);
}

/// A [Curve] backed by a [SpringSimulation], allowing spring physics to be
/// used anywhere Flutter expects a curve.
class MESpringCurve extends Curve {
  MESpringCurve(this.spec)
      : _sim = SpringSimulation(
          spec.toSpringDescription(),
          0.0,
          1.0,
          0.0,
        ),
        _settle = spec.approximateDuration.inMilliseconds / 1000.0;

  final MESpringSpec spec;
  final SpringSimulation _sim;
  final double _settle;

  @override
  double transformInternal(double t) {
    if (t >= 1.0) return 1.0;
    return _sim.x(t * _settle);
  }
}

/// The complete Material 3 Expressive motion scheme.
///
/// Mirrors the `MotionScheme` API from Material Design: three speeds
/// (fast, default, slow) for each of the two families (spatial, effects).
@immutable
class MEMotionScheme {
  const MEMotionScheme({
    required this.fastSpatial,
    required this.defaultSpatial,
    required this.slowSpatial,
    required this.fastEffects,
    required this.defaultEffects,
    required this.slowEffects,
  });

  final MESpringSpec fastSpatial;
  final MESpringSpec defaultSpatial;
  final MESpringSpec slowSpatial;
  final MESpringSpec fastEffects;
  final MESpringSpec defaultEffects;
  final MESpringSpec slowEffects;

  /// The expressive motion scheme: spatial springs bounce for a playful,
  /// energetic feel. This is the default for Material 3 Expressive.
  static const MEMotionScheme expressive = MEMotionScheme(
    fastSpatial: MESpringSpec(dampingRatio: 0.6, stiffness: 800),
    defaultSpatial: MESpringSpec(dampingRatio: 0.8, stiffness: 380),
    slowSpatial: MESpringSpec(dampingRatio: 0.8, stiffness: 200),
    fastEffects: MESpringSpec(dampingRatio: 1.0, stiffness: 3800),
    defaultEffects: MESpringSpec(dampingRatio: 1.0, stiffness: 1600),
    slowEffects: MESpringSpec(dampingRatio: 1.0, stiffness: 800),
  );

  /// The standard motion scheme: spatial springs are critically damped and
  /// do not bounce. Use for utilitarian or dense UIs.
  static const MEMotionScheme standard = MEMotionScheme(
    fastSpatial: MESpringSpec(dampingRatio: 0.9, stiffness: 1400),
    defaultSpatial: MESpringSpec(dampingRatio: 0.9, stiffness: 700),
    slowSpatial: MESpringSpec(dampingRatio: 0.9, stiffness: 300),
    fastEffects: MESpringSpec(dampingRatio: 1.0, stiffness: 3800),
    defaultEffects: MESpringSpec(dampingRatio: 1.0, stiffness: 1600),
    slowEffects: MESpringSpec(dampingRatio: 1.0, stiffness: 800),
  );
}

/// Drives an [AnimationController] with a spring simulation toward [target]
/// (0.0 or 1.0), honoring the current velocity so animations are
/// interruptible — a core requirement of M3 Expressive motion.
void springTo(
  AnimationController controller,
  double target,
  MESpringSpec spec,
) {
  final simulation = SpringSimulation(
    spec.toSpringDescription(),
    controller.value,
    target,
    controller.velocity,
  );
  controller.animateWith(simulation);
}
