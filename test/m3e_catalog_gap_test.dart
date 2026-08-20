import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material3_expressive/material3_expressive.dart';

void main() {
  testWidgets('METopAppBar is 64dp for Scaffold.appBar', (tester) async {
    await tester.pumpWidget(
      _host(
        const Scaffold(
          appBar: METopAppBar(title: Text('Inbox')),
          body: SizedBox.shrink(),
        ),
      ),
    );
    expect(tester.getSize(find.byType(METopAppBar)).height, 64);
    expect(find.text('Inbox'), findsOneWidget);
  });

  testWidgets('METoggleButtonGroup reports selection', (tester) async {
    var selected = {0};
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            return METoggleButtonGroup(
              selected: selected,
              onChanged: (next) => setState(() => selected = next),
              items: const [
                METoggleButtonGroupItem(
                  icon: Icon(Icons.format_bold),
                  tooltip: 'Bold',
                ),
                METoggleButtonGroupItem(
                  icon: Icon(Icons.format_italic),
                  tooltip: 'Italic',
                ),
              ],
            );
          },
        ),
      ),
    );

    await tester.tap(find.byTooltip('Italic'));
    await tester.pump();
    expect(selected, {0, 1});
  });

  testWidgets('MEDropdown.future loads items then opens the menu',
      (tester) async {
    await tester.pumpWidget(
      _host(
        MEDropdown<String>.future(
          value: null,
          itemsLoader: () async => const [
            MEMenuItem(value: 'a', label: 'Alpha'),
          ],
          onChanged: (_) {},
        ),
      ),
    );
    expect(find.text('Loading…'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Select'), findsOneWidget);
  });

  testWidgets('METabBar secondary variant builds', (tester) async {
    await tester.pumpWidget(
      _host(
        METabBar(
          variant: METabBarVariant.secondary,
          selectedIndex: 0,
          onSelected: (_) {},
          tabs: const [
            METab(label: 'Day'),
            METab(label: 'Week'),
          ],
        ),
      ),
    );
    expect(find.text('Day'), findsOneWidget);
    expect(find.text('Week'), findsOneWidget);
  });

  testWidgets('MECarousel contained type builds', (tester) async {
    await tester.pumpWidget(
      _host(
        const MECarousel(
          type: MECarouselType.contained,
          height: 120,
          children: [
            ColoredBox(color: Colors.red),
            ColoredBox(color: Colors.blue),
          ],
        ),
      ),
    );
    expect(find.byType(MECarousel), findsOneWidget);
  });

  testWidgets('METoggleButtonGroup connected style builds', (tester) async {
    await tester.pumpWidget(
      _host(
        METoggleButtonGroup(
          style: MEButtonGroupStyle.connected,
          multiSelect: false,
          selected: const {0},
          onChanged: (_) {},
          items: const [
            METoggleButtonGroupItem(label: Text('Day')),
            METoggleButtonGroupItem(label: Text('Week')),
          ],
        ),
      ),
    );
    expect(find.text('Day'), findsOneWidget);
    expect(find.text('Week'), findsOneWidget);
  });

  testWidgets('MEButtonGroup vertical connected builds', (tester) async {
    await tester.pumpWidget(
      _host(
        const MEButtonGroup(
          direction: Axis.vertical,
          style: MEButtonGroupStyle.connected,
          items: [
            MEButtonGroupItem(child: Text('Top')),
            MEButtonGroupItem(child: Text('Bottom')),
          ],
        ),
      ),
    );
    expect(find.text('Top'), findsOneWidget);
  });

  testWidgets('MEMenu searchHint shows a filter field', (tester) async {
    await tester.pumpWidget(
      _host(
        MEMenu(
          searchHint: 'Filter',
          anchorBuilder: (context, open) => MEButton.outlined(
            onPressed: open,
            child: const Text('Open'),
          ),
          children: const [
            MEMenuEntry(label: 'Alpha', value: 'a'),
            MEMenuEntry(label: 'Beta', value: 'b'),
          ],
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pump();
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Alpha'), findsOneWidget);
  });

  testWidgets('MEDropdown searchEnabled builds', (tester) async {
    await tester.pumpWidget(
      _host(
        MEDropdown<String>(
          searchEnabled: true,
          hintText: 'Filter',
          value: 'a',
          items: const [
            MEMenuItem(value: 'a', label: 'Alpha'),
            MEMenuItem(value: 'b', label: 'Beta'),
          ],
          onChanged: (_) {},
        ),
      ),
    );
    expect(find.text('Alpha'), findsOneWidget);
  });

  testWidgets('MENavigationRail shows section labels when expanded',
      (tester) async {
    await tester.pumpWidget(
      _host(
        SizedBox(
          height: 400,
          child: MENavigationRail(
            expanded: true,
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            destinations: const [
              MENavigationDestination(
                icon: Icon(Icons.home_outlined),
                label: 'Home',
                sectionLabel: 'Mail',
              ),
              MENavigationDestination(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
            ],
          ),
        ),
      ),
    );
    expect(find.text('Mail'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('MEListTile outlined variant builds', (tester) async {
    await tester.pumpWidget(
      _host(
        MEListTile(
          variant: MEListTileVariant.outlined,
          title: const Text('Wireless charging'),
          onPressed: () {},
        ),
      ),
    );
    expect(find.text('Wireless charging'), findsOneWidget);
  });

  testWidgets('MERefreshIndicator.contained is the M3E style', (tester) async {
    const indicator = MERefreshIndicator.contained(
      onRefresh: _noopRefresh,
      child: SizedBox(height: 200, child: Text('list')),
    );
    expect(indicator.contained, isTrue);
  });
}

Future<void> _noopRefresh() async {}

Widget _host(Widget child) {
  return MaterialApp(
    theme: ThemeData(useMaterial3: true),
    home: METheme(
      data: METhemeData.expressive,
      child: child is Scaffold ? child : Scaffold(body: Center(child: child)),
    ),
  );
}
