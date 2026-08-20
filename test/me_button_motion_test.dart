import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material3_expressive/material3_expressive.dart';

void main() {
  Widget host(Widget child) {
    return METheme(
      data: METhemeData.expressive,
      child: MaterialApp(home: Scaffold(body: Center(child: child))),
    );
  }

  testWidgets('MEButton press morphs shape without Transform.scale',
      (tester) async {
    await tester.pumpWidget(
      host(
        MEButton.filled(
          onPressed: () {},
          child: const Text('Send'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(
      find.descendant(
        of: find.byType(MEButton),
        matching: find.byType(Transform),
      ),
      findsNothing,
    );

    Material materialOf() {
      return tester.widget<Material>(
        find
            .descendant(
              of: find.byType(MEButton),
              matching: find.byType(Material),
            )
            .first,
      );
    }

    double radiusOf() {
      return (materialOf().shape! as RoundedRectangleBorder)
          .borderRadius
          .resolve(TextDirection.ltr)
          .topLeft
          .x;
    }

    expect(materialOf().shape, isA<RoundedRectangleBorder>());
    expect(radiusOf(), closeTo(20, 1.5));

    final gesture = await tester.press(find.text('Send'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));
    expect(radiusOf(), lessThan(16));

    await gesture.up();
    await tester.pump();
  });

  testWidgets('MEButtonGroup neighbor-squish uses Align, not Transform.scale',
      (tester) async {
    await tester.pumpWidget(
      host(
        MEButtonGroup(
          items: [
            MEButtonGroupItem(child: const Text('One'), onPressed: () {}),
            MEButtonGroupItem(child: const Text('Two'), onPressed: () {}),
            MEButtonGroupItem(child: const Text('Three'), onPressed: () {}),
          ],
        ),
      ),
    );

    expect(find.byType(Align), findsNWidgets(3));

    final gesture = await tester.press(find.text('Two'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));

    final aligns = tester
        .widgetList<Align>(find.byType(Align))
        .where((align) => align.widthFactor != null)
        .toList();
    expect(aligns.length, 3);
    expect(aligns[1].widthFactor, greaterThan(1.0));
    expect(aligns[0].widthFactor, lessThan(1.0));
    expect(aligns[2].widthFactor, lessThan(1.0));
    final total = aligns
        .map((a) => a.widthFactor ?? 1)
        .fold<double>(0, (sum, f) => sum + f);
    expect(total, closeTo(3.0, 0.08));

    await gesture.up();
    await tester.pump();
  });

  testWidgets('METoggleButtonGroup neighbor-squish grows the pressed item',
      (tester) async {
    await tester.pumpWidget(
      host(
        METoggleButtonGroup(
          selected: const {0},
          onChanged: (_) {},
          items: const [
            METoggleButtonGroupItem(label: Text('Bold')),
            METoggleButtonGroupItem(label: Text('Italic')),
            METoggleButtonGroupItem(label: Text('Underline')),
          ],
        ),
      ),
    );

    final gesture = await tester.press(find.text('Italic'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));

    final aligns = tester
        .widgetList<Align>(find.byType(Align))
        .where((align) => align.widthFactor != null)
        .toList();
    expect(aligns.length, 3);
    expect(aligns[1].widthFactor, greaterThan(1.0));
    expect(aligns[0].widthFactor, lessThan(1.0));
    expect(aligns[2].widthFactor, lessThan(1.0));

    await gesture.up();
    await tester.pump();
  });
}
