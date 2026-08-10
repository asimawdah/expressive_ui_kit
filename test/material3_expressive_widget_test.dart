import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material3_expressive/material3_expressive.dart';

void main() {
  group('MEButton', () {
    testWidgets('fires onPressed when tapped', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        _host(
          MEButton.filled(
            onPressed: () => pressed = true,
            child: const Text('Tap me'),
          ),
        ),
      );

      await tester.tap(find.text('Tap me'));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('does not fire when disabled', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        _host(
          const MEButton.filled(
            onPressed: null,
            child: Text('Disabled'),
          ),
        ),
      );

      await tester.tap(find.text('Disabled'));
      await tester.pump();

      expect(pressed, isFalse);
    });
  });

  group('MESwitch', () {
    testWidgets('toggles value on tap', (tester) async {
      var value = false;

      await tester.pumpWidget(
        _host(
          StatefulBuilder(
            builder: (context, setState) {
              return MESwitch(
                value: value,
                semanticsLabel: 'Notifications',
                onChanged: (v) => setState(() => value = v),
              );
            },
          ),
        ),
      );

      expect(value, isFalse);
      expect(find.bySemanticsLabel('Notifications'), findsOneWidget);

      await tester.tap(find.byType(MESwitch));
      await tester.pump();

      expect(value, isTrue);
    });
  });

  group('Reduced motion', () {
    testWidgets('METheme.of returns reduced motion when animations disabled',
        (tester) async {
      MEMotionScheme? motion;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: METheme(
              data: METhemeData.expressive,
              child: Builder(
                builder: (context) {
                  motion = METheme.of(context).motion;
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );

      expect(motion, MEMotionScheme.reduced);
      expect(motion!.defaultSpatial.instant, isTrue);
    });

    testWidgets('MEButton snaps instantly with reduced motion', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: METheme(
              data: METhemeData.expressive,
              child: Scaffold(
                body: Center(
                  child: MEButton.filled(
                    onPressed: () {},
                    child: const Text('Press'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Press'));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(
          METheme.of(
            tester.element(find.text('Press')),
          ).motion,
          MEMotionScheme.reduced);
    });
  });

  testWidgets('MECheckbox emits toggled values', (tester) async {
    var checked = false;

    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            return MECheckbox(
              value: checked,
              semanticsLabel: 'Accept terms',
              onChanged: (value) => setState(() => checked = value),
            );
          },
        ),
      ),
    );

    expect(find.bySemanticsLabel('Accept terms'), findsOneWidget);
    expect(checked, isFalse);

    await tester.tap(find.byType(MECheckbox));
    await tester.pump();

    expect(checked, isTrue);

    await tester.tap(find.byType(MECheckbox));
    await tester.pump();

    expect(checked, isFalse);
  });

  testWidgets('MERadio selects the tapped option', (tester) async {
    var selected = 0;

    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final value in [0, 1, 2])
                  MERadio<int>(
                    key: ValueKey('radio-$value'),
                    value: value,
                    groupValue: selected,
                    semanticsLabel: 'Option ${value + 1}',
                    onChanged: (value) => setState(() => selected = value),
                  ),
              ],
            );
          },
        ),
      ),
    );

    expect(find.bySemanticsLabel('Option 1'), findsOneWidget);
    expect(selected, 0);

    await tester.tap(find.byKey(const ValueKey('radio-2')));
    await tester.pump();

    expect(selected, 2);
  });

  testWidgets('METooltip shows its configured message', (tester) async {
    await tester.pumpWidget(
      _host(
        const METooltip(
          message: 'Expressive tooltip',
          child: Icon(Icons.help_outline),
        ),
      ),
    );

    expect(find.text('Expressive tooltip'), findsNothing);

    final tooltip = tester.state<TooltipState>(find.byType(Tooltip));
    expect(tooltip.ensureTooltipVisible(), isTrue);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Expressive tooltip'), findsOneWidget);
  });

  testWidgets('METabBar RTL keeps pill under the tapped tab', (tester) async {
    var selected = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Center(
              child: SizedBox(
                width: 240,
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return METabBar(
                      tabs: const [
                        METab(label: 'Import'),
                        METab(label: 'Export'),
                      ],
                      selectedIndex: selected,
                      onSelected: (i) => setState(() => selected = i),
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

    final bar = tester.getRect(find.byType(METabBar));

    // RTL: logical index 0 is on the right. Tap right → Import.
    await tester.tapAt(Offset(bar.right - 30, bar.center.dy));
    await tester.pumpAndSettle();
    expect(selected, 0);

    // Tap left → Export.
    await tester.tapAt(Offset(bar.left + 30, bar.center.dy));
    await tester.pumpAndSettle();
    expect(selected, 1);

    // With Export selected, tap the pill side (start/right for index 1 = left)
    // again must stay on Export — not flip to Import.
    await tester.tapAt(Offset(bar.left + 30, bar.center.dy));
    await tester.pumpAndSettle();
    expect(selected, 1);
  });

  testWidgets('MEDataTable renders headers and rows', (tester) async {
    await tester.pumpWidget(
      _host(
        const MEDataTable(
          columns: [
            DataColumn(label: Text('Widget')),
            DataColumn(label: Text('Replaces')),
          ],
          rows: [
            DataRow(
              cells: [
                DataCell(Text('MEButton')),
                DataCell(Text('ElevatedButton')),
              ],
            ),
            DataRow(
              cells: [
                DataCell(Text('MECheckbox')),
                DataCell(Text('Checkbox')),
              ],
            ),
          ],
        ),
      ),
    );

    expect(find.text('Widget'), findsOneWidget);
    expect(find.text('Replaces'), findsOneWidget);
    expect(find.text('MEButton'), findsOneWidget);
    expect(find.text('MECheckbox'), findsOneWidget);
  });

  testWidgets('METreeView unmounts collapsed leaf nodes safely',
      (tester) async {
    await tester.pumpWidget(
      _host(
        const METreeView(
          nodes: [
            METreeNode(label: Text('Leaf')),
          ],
        ),
      ),
    );

    await tester.pumpWidget(_host(const SizedBox.shrink()));

    expect(tester.takeException(), isNull);
  });

  testWidgets('MEFunnelChart keeps trailing labels inside narrow widths',
      (tester) async {
    await tester.pumpWidget(
      _host(
        SizedBox(
          width: 140,
          child: MEFunnelChart(
            stages: const [
              MEFunnelStage(value: 100, label: 'Visitors'),
              MEFunnelStage(value: 96, label: 'Qualified'),
              MEFunnelStage(value: 84, label: 'Converted'),
            ],
          ),
        ),
      ),
    );

    await tester.pump();
    expect(tester.takeException(), isNull);

    await tester.pump(const Duration(milliseconds: 900));
    expect(tester.takeException(), isNull);
  });

  testWidgets('MEStackedBarChart reserves label height during growth',
      (tester) async {
    await tester.pumpWidget(
      _host(
        const SizedBox(
          width: 160,
          child: MEStackedBarChart(
            height: 80,
            bars: [
              MEStackedBar(values: [60, 30, 10], label: 'Mon'),
              MEStackedBar(values: [45, 35, 20], label: 'Tue'),
            ],
          ),
        ),
      ),
    );

    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 120));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('MEDice roll settles without curve range exceptions',
      (tester) async {
    final controller = MEDiceController();
    int? rolled;

    await tester.pumpWidget(
      _host(
        MEDice(
          controller: controller,
          onRolled: (value) => rolled = value,
        ),
      ),
    );

    controller.roll();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 1));

    expect(tester.takeException(), isNull);
    expect(rolled, isNotNull);
    expect(rolled, inInclusiveRange(1, 6));
  });

  testWidgets('MEStampCard completion callbacks can show overlays safely',
      (tester) async {
    var completed = false;

    Widget stampHost(int earned) {
      return MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: MEStampCard(
                total: 3,
                earned: earned,
                haptics: false,
                onCompleted: () {
                  completed = true;
                  showMEToast(
                    context,
                    message: 'Reward earned',
                    kind: METoastKind.success,
                    duration: const Duration(milliseconds: 1),
                  );
                },
              ),
            );
          },
        ),
      );
    }

    await tester.pumpWidget(stampHost(2));
    await tester.pumpWidget(stampHost(3));

    expect(tester.takeException(), isNull);
    expect(completed, isTrue);

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(tester.takeException(), isNull);
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
