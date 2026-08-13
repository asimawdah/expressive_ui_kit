import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material3_expressive/material3_expressive.dart';

void main() {
  group('Keyboard navigation', () {
    testWidgets('MENavigationBar moves selection with arrow keys',
        (tester) async {
      var selected = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return MENavigationBar(
                  autofocus: true,
                  selectedIndex: selected,
                  onDestinationSelected: (i) => setState(() => selected = i),
                  destinations: const [
                    MENavigationDestination(
                      icon: Icon(Icons.home_outlined),
                      label: 'Home',
                    ),
                    MENavigationDestination(
                      icon: Icon(Icons.search_outlined),
                      label: 'Search',
                    ),
                    MENavigationDestination(
                      icon: Icon(Icons.settings_outlined),
                      label: 'Settings',
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(selected, 1);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(selected, 2);

      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pumpAndSettle();
      expect(selected, 0);
    });

    testWidgets('METabBar moves selection with arrow keys in RTL',
        (tester) async {
      var selected = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 300,
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      return METabBar(
                        autofocus: true,
                        selectedIndex: selected,
                        onSelected: (i) => setState(() => selected = i),
                        tabs: const [
                          METab(label: 'One'),
                          METab(label: 'Two'),
                          METab(label: 'Three'),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();
      expect(selected, 1);
    });

    testWidgets('MEButton activates on Enter key', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: Center(
              child: MEButton.filled(
                onPressed: () => pressed = true,
                child: const Text('Submit'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
    });

    testWidgets('MENavigationRail moves selection with arrow keys',
        (tester) async {
      var selected = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: SizedBox(
              height: 280,
              child: StatefulBuilder(
                builder: (context, setState) {
                  return MENavigationRail(
                    autofocus: true,
                    selectedIndex: selected,
                    onDestinationSelected: (i) => setState(() => selected = i),
                    destinations: const [
                      MENavigationDestination(
                        icon: Icon(Icons.home_outlined),
                        label: 'Home',
                      ),
                      MENavigationDestination(
                        icon: Icon(Icons.search_outlined),
                        label: 'Search',
                      ),
                      MENavigationDestination(
                        icon: Icon(Icons.settings_outlined),
                        label: 'Settings',
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(selected, 1);

      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pumpAndSettle();
      expect(selected, 2);
    });

    testWidgets('MESegmentedButton moves selection with arrow keys',
        (tester) async {
      var selected = {'a'};

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: Center(
              child: StatefulBuilder(
                builder: (context, setState) {
                  return MESegmentedButton<String>(
                    autofocus: true,
                    segments: const [
                      MESegment(value: 'a', label: Text('A')),
                      MESegment(value: 'b', label: Text('B')),
                      MESegment(value: 'c', label: Text('C')),
                    ],
                    selected: selected,
                    onSelectionChanged: (value) =>
                        setState(() => selected = value),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(selected, {'b'});
    });
  });
}
