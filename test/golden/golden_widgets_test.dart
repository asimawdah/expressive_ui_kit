import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material3_expressive/material3_expressive.dart';

import 'golden_utils.dart';

void main() {
  group('golden', () {
    testWidgets('MEButton variants', (tester) async {
      await pumpGolden(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MEButton.filled(
              onPressed: () {},
              child: const Text('Filled'),
            ),
            const SizedBox(height: 8),
            MEButton.tonal(
              onPressed: () {},
              child: const Text('Tonal'),
            ),
            const SizedBox(height: 8),
            MEButton.outlined(
              onPressed: () {},
              child: const Text('Outlined'),
            ),
          ],
        ),
      );

      await expectLater(
        find.byType(Column),
        matchesGoldenFile('goldens/me_button_variants.png'),
      );
    });

    testWidgets('MESwitch on and off', (tester) async {
      await pumpGolden(
        tester,
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MESwitch(value: false, onChanged: _noop),
            SizedBox(width: 16),
            MESwitch(value: true, onChanged: _noop),
          ],
        ),
      );

      await expectLater(
        find.byType(Row),
        matchesGoldenFile('goldens/me_switch_states.png'),
      );
    });
  });
}

void _noop(bool _) {}
