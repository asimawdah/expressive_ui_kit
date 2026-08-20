import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material3_expressive/material3_expressive.dart';
import 'package:motor/motor.dart';

void main() {
  test('expressive tokens match motor MaterialSpringMotion', () {
    expect(
        _matches(MESpringSpec.expressiveSpatialFast,
            const MaterialSpringMotion.expressiveSpatialFast()),
        isTrue);
    expect(
        _matches(MESpringSpec.expressiveSpatialDefault,
            const MaterialSpringMotion.expressiveSpatialDefault()),
        isTrue);
    expect(
        _matches(MESpringSpec.expressiveSpatialSlow,
            const MaterialSpringMotion.expressiveSpatialSlow()),
        isTrue);
    expect(
        _matches(MESpringSpec.standardSpatialFast,
            const MaterialSpringMotion.standardSpatialFast()),
        isTrue);
    expect(
        _matches(MESpringSpec.standardSpatialDefault,
            const MaterialSpringMotion.standardSpatialDefault()),
        isTrue);
    expect(
        _matches(MESpringSpec.standardSpatialSlow,
            const MaterialSpringMotion.standardSpatialSlow()),
        isTrue);
    expect(
        _matches(MESpringSpec.standardEffectsFast,
            const MaterialSpringMotion.standardEffectsFast()),
        isTrue);
    expect(
        _matches(MESpringSpec.standardEffectsDefault,
            const MaterialSpringMotion.standardEffectsDefault()),
        isTrue);
    expect(
        _matches(MESpringSpec.standardEffectsSlow,
            const MaterialSpringMotion.standardEffectsSlow()),
        isTrue);
  });

  test('toMotion returns the matching MaterialSpringMotion token', () {
    expect(
      MESpringSpec.expressiveSpatialFast.toMotion(),
      const MaterialSpringMotion.expressiveSpatialFast(),
    );
    expect(
      MESpringSpec.standardEffectsDefault.toMotion(),
      const MaterialSpringMotion.standardEffectsDefault(),
    );
    expect(
      MESpringSpec.expressiveEffectsFast.toMotion(),
      const MaterialSpringMotion.expressiveEffectsFast(),
    );
    expect(
      MESpringSpec.standardPopup.toMotion(),
      isA<MaterialSpringMotion>(),
    );
    expect(MESpringSpec.zero.toMotion(), isA<NoMotion>());
  });

  test('expressive scheme uses m3e_core popup and overflow springs', () {
    expect(MEMotionScheme.expressive.popup, MESpringSpec.standardPopup);
    expect(MEMotionScheme.expressive.overflow, MESpringSpec.standardOverflow);
    expect(MESpringSpec.standardPopup.stiffness, 1000);
    expect(MESpringSpec.standardPopup.dampingRatio, 0.6);
    expect(MESpringSpec.standardOverflow.stiffness, 1600);
    expect(MESpringSpec.standardOverflow.dampingRatio, 0.85);
  });

  test('reduced scheme zeros popup and overflow', () {
    expect(MEMotionScheme.reduced.popup, MESpringSpec.zero);
    expect(MEMotionScheme.reduced.overflow, MESpringSpec.zero);
    expect(MEMotionScheme.reduced.popup.instant, isTrue);
  });

  test('springTo snaps instantly for reduced motion', () {
    final controller = AnimationController.unbounded(
      vsync: const TestVSync(),
      value: 0.25,
    );
    addTearDown(controller.dispose);
    springTo(controller, 1, MESpringSpec.zero);
    expect(controller.value, 1);
  });

  testWidgets('springTo drives a motor simulation for spatial springs',
      (tester) async {
    final controller = AnimationController.unbounded(
      vsync: tester,
      value: 0,
    );
    addTearDown(controller.dispose);
    springTo(controller, 1, MESpringSpec.expressiveSpatialDefault);
    expect(controller.isAnimating, isTrue);
    expect(controller.value, isNot(1));
    controller.stop();
  });
}

bool _matches(MESpringSpec spec, MaterialSpringMotion motion) {
  return spec.dampingRatio == motion.damping &&
      spec.stiffness == motion.stiffness;
}
