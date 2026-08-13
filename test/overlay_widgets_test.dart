import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material3_expressive/material3_expressive.dart';

void main() {
  group('METextField', () {
    testWidgets('accepts text input and reports changes', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      var lastValue = '';

      await tester.pumpWidget(
        _host(
          METextField(
            controller: controller,
            label: 'Name',
            onChanged: (value) => lastValue = value,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Ada');
      await tester.pump();

      expect(controller.text, 'Ada');
      expect(lastValue, 'Ada');
    });
  });

  group('MEDialog', () {
    testWidgets('renders title, content, and actions', (tester) async {
      await tester.pumpWidget(
        _host(
          MEDialog(
            title: const Text('Confirm'),
            content: const Text('Proceed?'),
            actions: [
              MEButton.text(onPressed: () {}, child: const Text('No')),
              MEButton.filled(onPressed: () {}, child: const Text('Yes')),
            ],
          ),
        ),
      );

      expect(find.text('Confirm'), findsOneWidget);
      expect(find.text('Proceed?'), findsOneWidget);
      expect(find.text('Yes'), findsOneWidget);
    });
  });

  group('showMEDialog', () {
    testWidgets('presents dialog overlay', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: METheme(
            data: METhemeData.expressive,
            child: Builder(
              builder: (context) {
                return Scaffold(
                  body: MEButton.filled(
                    onPressed: () {
                      showMEDialog<void>(
                        context: context,
                        builder: (context) => const MEDialog(
                          title: Text('Hello'),
                          content: Text('World'),
                        ),
                      );
                    },
                    child: const Text('Open'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Hello'), findsOneWidget);
      expect(find.text('World'), findsOneWidget);
    });
  });
}

Widget _host(Widget child) {
  return MaterialApp(
    theme: ThemeData(useMaterial3: true),
    builder: (context, child) => METheme(
      data: METhemeData.expressive,
      child: child!,
    ),
    home: Scaffold(
      body: Center(child: child),
    ),
  );
}
