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

  testWidgets('MEMenu opens from the overlay without a route delay',
      (tester) async {
    await tester.pumpWidget(
      host(
        MEMenu(
          anchorBuilder: (context, open) => MEButton.outlined(
            onPressed: open,
            child: const Text('Open menu'),
          ),
          children: const [
            MEMenuEntry(label: 'Edit', value: 'edit'),
            MEMenuEntry(label: 'Share', value: 'share'),
          ],
        ),
      ),
    );

    await tester.tap(find.text('Open menu'));
    await tester.pump();

    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);
  });

  testWidgets('MEMenu reports the selected entry and dismisses',
      (tester) async {
    Object? selected;

    await tester.pumpWidget(
      host(
        MEMenu(
          anchorBuilder: (context, open) => TextButton(
            onPressed: open,
            child: const Text('Open'),
          ),
          onSelected: (value) => selected = value,
          children: const [
            MEMenuEntry(label: 'Copy', value: 'copy'),
          ],
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    await tester.tap(find.text('Copy'));
    await tester.pumpAndSettle();

    expect(selected, 'copy');
    expect(find.text('Copy'), findsNothing);
  });

  testWidgets('MEMenuAnchor still opens on child tap', (tester) async {
    String? selected;

    await tester.pumpWidget(
      host(
        MEMenuAnchor<String>(
          items: const [
            MEMenuItem(value: 'edit', label: 'Edit'),
          ],
          onSelected: (value) => selected = value,
          child: const Text('More'),
        ),
      ),
    );

    await tester.tap(find.text('More'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    expect(find.text('Edit'), findsOneWidget);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(selected, 'edit');
  });
}
