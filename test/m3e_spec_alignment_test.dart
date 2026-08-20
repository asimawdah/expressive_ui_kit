import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material3_expressive/material3_expressive.dart';

void main() {
  testWidgets('MESwitch uses the 52x32 M3E track', (tester) async {
    await tester.pumpWidget(
      _host(MESwitch(value: false, onChanged: (_) {})),
    );

    final box = tester.getSize(find.byType(MESwitch));
    expect(box, const Size(52, 32));
  });

  testWidgets('MESwitch toggles on tap', (tester) async {
    var on = false;
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            return MESwitch(
              value: on,
              onChanged: (v) => setState(() => on = v),
            );
          },
        ),
      ),
    );

    await tester.tap(find.byType(MESwitch));
    await tester.pump();
    expect(on, isTrue);
  });

  testWidgets('MESplitButton opens an MEMenu', (tester) async {
    Object? selected;
    await tester.pumpWidget(
      _host(
        MESplitButton(
          onPressed: () {},
          menu: const [
            MEMenuEntry(label: 'Draft', value: 'draft'),
          ],
          onSelected: (v) => selected = v,
          child: const Text('Save'),
        ),
      ),
    );

    await tester.tap(find.bySemanticsLabel('More options'));
    await tester.pumpAndSettle();
    expect(find.text('Draft'), findsOneWidget);

    await tester.tap(find.text('Draft'));
    await tester.pumpAndSettle();
    expect(selected, 'draft');
  });

  testWidgets('MECheckbox supports tristate cycling', (tester) async {
    bool? value = false;
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            return MECheckbox(
              tristate: true,
              value: value,
              onChanged: (v) => setState(() => value = v),
            );
          },
        ),
      ),
    );

    await tester.tap(find.byType(MECheckbox));
    await tester.pump();
    expect(value, isTrue);

    await tester.tap(find.byType(MECheckbox));
    await tester.pump();
    expect(value, isNull);

    await tester.tap(find.byType(MECheckbox));
    await tester.pump();
    expect(value, isFalse);
  });

  testWidgets('MELoadingIndicator accepts a determinate value', (tester) async {
    await tester.pumpWidget(
      _host(const MELoadingIndicator(value: 0.4, contained: true)),
    );
    expect(find.byType(MELoadingIndicator), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 50));
  });

  testWidgets('MEFab.extended defaults to the small 56dp size', (tester) async {
    await tester.pumpWidget(
      _host(
        MEFab.extended(
          onPressed: () {},
          icon: const Icon(Icons.edit),
          label: const Text('Compose'),
        ),
      ),
    );

    final box = tester.getSize(find.byType(MEFab));
    expect(box.height, 56);
  });

  testWidgets('MEShapeContainer clips to a MaterialShapes polygon',
      (tester) async {
    await tester.pumpWidget(
      _host(
        MEShapeContainer(
          size: 48,
          polygon: MaterialShapes.pill,
          child: const Icon(Icons.star),
        ),
      ),
    );
    expect(find.byIcon(Icons.star), findsOneWidget);
  });

  testWidgets('MEButtonSize tokens match the M3E scale', (tester) async {
    expect(MEButtonSize.extraSmall.height, 32);
    expect(MEButtonSize.small.height, 40);
    expect(MEButtonSize.medium.height, 56);
    expect(MEButtonSize.large.height, 96);
    expect(MEButtonSize.extraLarge.height, 136);
    expect(MEButtonSize.small.pressedCornerRadius, 8);
    expect(MEButtonSize.medium.pressedCornerRadius, 12);
    expect(MEButtonSize.large.pressedCornerRadius, 16);
  });
}

Widget _host(Widget child) {
  return MaterialApp(
    theme: ThemeData(useMaterial3: true),
    home: METheme(
      data: METhemeData.expressive,
      child: Scaffold(body: Center(child: child)),
    ),
  );
}
