import 'package:flutter/material.dart';
import 'package:material3_expressive/material3_expressive.dart';

import 'pages/buttons_page.dart';
import 'pages/containers_page.dart';
import 'pages/content_page.dart';
import 'pages/controls_page.dart';
import 'pages/inputs_page.dart';
import 'pages/navigation_page.dart';
import 'pages/progress_page.dart';
import 'pages/slivers_page.dart';

void main() => runApp(const GalleryApp());

class GalleryApp extends StatelessWidget {
  const GalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF3D6B35),
      brightness: Brightness.dark,
    );
    return MaterialApp(
      title: 'M3 Expressive Gallery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.from(colorScheme: scheme, useMaterial3: true),
      themeMode: ThemeMode.dark,
      builder: (context, child) => METheme(
        data: METhemeData.expressive,
        child: child!,
      ),
      home: const GalleryHome(),
    );
  }
}

class GalleryHome extends StatefulWidget {
  const GalleryHome({super.key});

  @override
  State<GalleryHome> createState() => _GalleryHomeState();
}

class _GalleryHomeState extends State<GalleryHome> {
  int _index = 0;

  static const List<Widget> _pages = <Widget>[
    ButtonsPage(),
    ProgressPage(),
    ControlsPage(),
    NavigationPage(),
    ContainersPage(),
    InputsPage(),
    ContentPage(),
    SliversPage(),
  ];

  static const List<String> _titles = <String>[
    'Buttons & FABs',
    'Progress & Loading',
    'Sliders & Controls',
    'Navigation',
    'Cards, Chips & Dialogs',
    'Inputs, Lists & More',
    'Markdown, Chat & Content',
    'Slivers',
  ];

  static const int _sliversIndex = 7;

  @override
  Widget build(BuildContext context) {
    // SliversPage brings its own CustomScrollView (including MEAppBar), so
    // it is rendered directly; every other page nests below a shared
    // MEAppBar sliver.
    final Widget body = _index == _sliversIndex
        ? _pages[_index]
        : CustomScrollView(
            slivers: <Widget>[
              MEAppBar(title: Text(_titles[_index])),
              SliverFillRemaining(child: _pages[_index]),
            ],
          );

    return Scaffold(
      drawer: MEDrawer(
        header: Text(
          'M3 Expressive',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        selectedIndex: _index,
        onDestinationSelected: (i) {
          setState(() => _index = i);
          Navigator.of(context).pop();
        },
        destinations: const <MEDrawerDestination>[
          MEDrawerDestination(
            icon: Icons.smart_button_outlined,
            selectedIcon: Icons.smart_button,
            label: 'Buttons & FABs',
          ),
          MEDrawerDestination(
            icon: Icons.downloading_outlined,
            selectedIcon: Icons.downloading,
            label: 'Progress & Loading',
          ),
          MEDrawerDestination(
            icon: Icons.tune_outlined,
            selectedIcon: Icons.tune,
            label: 'Sliders & Controls',
          ),
          MEDrawerDestination(
            icon: Icons.navigation_outlined,
            selectedIcon: Icons.navigation,
            label: 'Navigation',
          ),
          MEDrawerDestination(
            icon: Icons.dashboard_outlined,
            selectedIcon: Icons.dashboard,
            label: 'Cards, Chips & Dialogs',
          ),
          MEDrawerDestination(
            icon: Icons.edit_outlined,
            selectedIcon: Icons.edit,
            label: 'Inputs, Lists & More',
          ),
          MEDrawerDestination(
            icon: Icons.chat_outlined,
            selectedIcon: Icons.chat,
            label: 'Markdown, Chat & Content',
          ),
          MEDrawerDestination(
            icon: Icons.view_agenda_outlined,
            selectedIcon: Icons.view_agenda,
            label: 'Slivers',
          ),
        ],
      ),
      body: body,
      bottomNavigationBar: MENavigationBar(
        selectedIndex: _index.clamp(0, 4),
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const <MENavigationDestination>[
          MENavigationDestination(
            icon: Icon(Icons.smart_button_outlined),
            selectedIcon: Icon(Icons.smart_button),
            label: 'Buttons',
          ),
          MENavigationDestination(
            icon: Icon(Icons.downloading_outlined),
            selectedIcon: Icon(Icons.downloading),
            label: 'Progress',
          ),
          MENavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune),
            label: 'Controls',
          ),
          MENavigationDestination(
            icon: Icon(Icons.navigation_outlined),
            selectedIcon: Icon(Icons.navigation),
            label: 'Navigation',
          ),
          MENavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Containers',
          ),
        ],
      ),
    );
  }
}
