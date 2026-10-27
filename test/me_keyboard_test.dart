import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expressive_ui_kit/src/internal/me_keyboard.dart';

void main() {
  group('MEKeyboard.horizontalDelta', () {
    test('LTR left is -1 and right is +1', () {
      expect(
        MEKeyboard.horizontalDelta(
          LogicalKeyboardKey.arrowLeft,
          TextDirection.ltr,
        ),
        -1,
      );
      expect(
        MEKeyboard.horizontalDelta(
          LogicalKeyboardKey.arrowRight,
          TextDirection.ltr,
        ),
        1,
      );
    });

    test('RTL left is +1 and right is -1', () {
      expect(
        MEKeyboard.horizontalDelta(
          LogicalKeyboardKey.arrowLeft,
          TextDirection.rtl,
        ),
        1,
      );
      expect(
        MEKeyboard.horizontalDelta(
          LogicalKeyboardKey.arrowRight,
          TextDirection.rtl,
        ),
        -1,
      );
    });
  });

  group('MEKeyboard.verticalDelta', () {
    test('up is -1 and down is +1', () {
      expect(
        MEKeyboard.verticalDelta(LogicalKeyboardKey.arrowUp),
        -1,
      );
      expect(
        MEKeyboard.verticalDelta(LogicalKeyboardKey.arrowDown),
        1,
      );
    });
  });

  group('MEKeyboard.resolveVerticalSelection', () {
    test('moves within range and wraps by default', () {
      final down = const KeyDownEvent(
        physicalKey: PhysicalKeyboardKey.arrowDown,
        logicalKey: LogicalKeyboardKey.arrowDown,
        timeStamp: Duration.zero,
      );
      expect(
        MEKeyboard.resolveVerticalSelection(
          event: down,
          current: 1,
          count: 3,
        ),
        2,
      );

      final upFromStart = const KeyDownEvent(
        physicalKey: PhysicalKeyboardKey.arrowUp,
        logicalKey: LogicalKeyboardKey.arrowUp,
        timeStamp: Duration.zero,
      );
      expect(
        MEKeyboard.resolveVerticalSelection(
          event: upFromStart,
          current: 0,
          count: 3,
        ),
        2,
      );
    });
  });
}
