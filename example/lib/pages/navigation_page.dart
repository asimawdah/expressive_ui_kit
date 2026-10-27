import 'package:flutter/material.dart';
import 'package:expressive_ui_kit/expressive_ui_kit.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _railIndex = 0;

  @override
  Widget build(BuildContext context) {
    final TextStyle? title = Theme.of(context).textTheme.titleMedium;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: <Widget>[
        Text('Toolbar (floating, docked actions)', style: title),
        const SizedBox(height: 16),
        METoolbar(
          children: <Widget>[
            MEIconButton(icon: const Icon(Icons.format_bold), onPressed: () {}),
            MEIconButton(
                icon: const Icon(Icons.format_italic), onPressed: () {}),
            MEIconButton(
                icon: const Icon(Icons.format_underline), onPressed: () {}),
            MEButton.filled(
              size: MEButtonSize.small,
              onPressed: () {},
              child: const Text('Done'),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text('Navigation rail (embedded preview)', style: title),
        const SizedBox(height: 16),
        SizedBox(
          height: 400,
          child: Row(
            children: <Widget>[
              MENavigationRail(
                selectedIndex: _railIndex,
                onDestinationSelected: (i) => setState(() => _railIndex = i),
                destinations: const <MENavigationDestination>[
                  MENavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  MENavigationDestination(
                    icon: Icon(Icons.search),
                    label: 'Search',
                  ),
                  MENavigationDestination(
                    icon: Icon(Icons.settings_outlined),
                    selectedIcon: Icon(Icons.settings),
                    label: 'Settings',
                  ),
                ],
              ),
              Expanded(
                child: Center(
                  child: Text('Rail destination ${_railIndex + 1}'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text('Bottom app bar (embedded preview)', style: title),
        const SizedBox(height: 16),
        MEBottomAppBar(
          actions: <Widget>[
            MEIconButton(
                icon: const Icon(Icons.archive_outlined), onPressed: () {}),
            MEIconButton(
                icon: const Icon(Icons.delete_outline), onPressed: () {}),
            MEIconButton(
                icon: const Icon(Icons.reply_outlined), onPressed: () {}),
          ],
          fab: MEFab(
            size: MEFabSize.small,
            onPressed: () {},
            icon: const Icon(Icons.add),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'The app bar above and the navigation bar below are also '
          'expressive components (MEAppBar, MENavigationBar).',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
