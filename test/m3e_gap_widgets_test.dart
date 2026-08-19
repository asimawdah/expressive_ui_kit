import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material3_expressive/material3_expressive.dart';

void main() {
  group('METoggleButton', () {
    testWidgets('toggles checked state on tap', (tester) async {
      var checked = false;

      await tester.pumpWidget(
        _host(
          StatefulBuilder(
            builder: (context, setState) {
              return METoggleButton.filled(
                checked: checked,
                icon: const Icon(Icons.favorite_border),
                checkedIcon: const Icon(Icons.favorite),
                label: const Text('Favorite'),
                onCheckedChange: (v) => setState(() => checked = v),
              );
            },
          ),
        ),
      );

      expect(checked, isFalse);
      await tester.tap(find.text('Favorite'));
      await tester.pump();
      expect(checked, isTrue);
    });
  });

  group('MESearchAnchor', () {
    testWidgets('opens search view from the bar', (tester) async {
      await tester.pumpWidget(
        _host(
          MESearchAnchor.bar(
            barHintText: 'Search mail',
            suggestionsBuilder: (context, controller) {
              return [
                ListTile(
                  title: const Text('Inbox'),
                  onTap: () => controller.closeView('Inbox'),
                ),
              ];
            },
          ),
        ),
      );

      await tester.tap(find.byType(MESearchBar));
      await tester.pumpAndSettle();

      expect(find.text('Inbox'), findsOneWidget);

      await tester.tap(find.text('Inbox'));
      await tester.pumpAndSettle();
    });
  });

  group('MECardList', () {
    testWidgets('lays out segmented cards', (tester) async {
      var tapped = -1;
      await tester.pumpWidget(
        _host(
          MECardList(
            itemCount: 3,
            onTap: (i) => tapped = i,
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Card $i'),
            ),
          ),
        ),
      );

      expect(find.text('Card 0'), findsOneWidget);
      expect(find.text('Card 2'), findsOneWidget);
      await tester.tap(find.text('Card 1'));
      await tester.pump();
      expect(tapped, 1);
    });
  });

  group('MESelection', () {
    testWidgets('toggles items and reports selection mode', (tester) async {
      final controller = MESelectionController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 400,
            height: 600,
            child: MESelection(
              controller: controller,
              itemCount: 3,
              appBar: MESelectionAppBar(
                controller: controller,
                itemCount: 3,
                idle: const MESelectionIdleBar(title: Text('Inbox')),
              ),
              body: ListView(
                children: [
                  for (var i = 0; i < 3; i++)
                    MESelectionTile(
                      index: i,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('Item $i'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(controller.isSelectionMode, isFalse);
      await tester.longPress(find.text('Item 1'));
      await tester.pumpAndSettle();
      expect(controller.isSelected(1), isTrue);
      expect(find.text('1 selected'), findsOneWidget);
    });
  });

  group('MEExpandableList', () {
    testWidgets('expands a card on tap', (tester) async {
      await tester.pumpWidget(
        _host(
          const MEExpandableList(
            data: [
              MEExpandableData(
                title: 'Battery level low',
                subtitle: 'Plug in your device.',
                body: Text('Your battery is at 10%.'),
              ),
            ],
          ),
        ),
      );

      expect(find.text('Your battery is at 10%.'), findsNothing);
      await tester.tap(find.text('Battery level low'));
      await tester.pumpAndSettle();
      expect(find.text('Your battery is at 10%.'), findsOneWidget);
    });
  });

  group('MESlider variants', () {
    testWidgets('wavy and centered sliders report changes', (tester) async {
      var wavy = 0.4;
      var centered = 0.0;

      await tester.pumpWidget(
        _host(
          StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  SizedBox(
                    width: 300,
                    child: MESlider.wavy(
                      value: wavy,
                      onChanged: (v) => setState(() => wavy = v),
                    ),
                  ),
                  SizedBox(
                    width: 300,
                    child: MESlider.centered(
                      value: centered,
                      min: -1,
                      max: 1,
                      onChanged: (v) => setState(() => centered = v),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );

      await tester.tap(find.byType(MESlider).first);
      await tester.pump();
      expect(wavy, isNot(0.4));
    });
  });

  group('MERadio label', () {
    testWidgets('label is part of the tap target', (tester) async {
      var plan = 'free';
      await tester.pumpWidget(
        _host(
          StatefulBuilder(
            builder: (context, setState) {
              return MERadio<String>(
                value: 'pro',
                groupValue: plan,
                label: const Text('Pro'),
                onChanged: (v) => setState(() => plan = v),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Pro'));
      await tester.pump();
      expect(plan, 'pro');
    });
  });

  group('MEDivider', () {
    testWidgets('builds vertical variant', (tester) async {
      await tester.pumpWidget(
        _host(
          const Row(
            children: [
              Text('Left'),
              MEDivider.vertical(),
              Text('Right'),
            ],
          ),
        ),
      );
      expect(find.byType(MEDivider), findsOneWidget);
    });
  });

  group('showMESelectionDialog', () {
    testWidgets('returns the confirmed choice', (tester) async {
      List<String>? picked;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: METheme(
            data: METhemeData.expressive,
            child: Builder(
              builder: (context) {
                return Scaffold(
                  body: MEButton.filled(
                    onPressed: () async {
                      picked = await showMESelectionDialog<String>(
                        context: context,
                        title: 'Choose a plan',
                        options: const ['Standard', 'Pro'],
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
      await tester.tap(find.text('Pro'));
      await tester.pump();
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(picked, ['Pro']);
    });
  });

  group('MEDialTimePicker', () {
    testWidgets('renders hour and minute digits', (tester) async {
      await tester.pumpWidget(
        _host(
          MEDialTimePicker(
            value: const TimeOfDay(hour: 9, minute: 30),
            onChanged: (_) {},
          ),
        ),
      );
      expect(find.text('09'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
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
