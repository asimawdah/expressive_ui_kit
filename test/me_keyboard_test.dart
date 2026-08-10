import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material3_expressive/src/internal/me_keyboard.dart';

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
}
