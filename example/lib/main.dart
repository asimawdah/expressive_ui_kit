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

class GalleryApp extends StatefulWidget {
  const GalleryApp({super.key});

  @override
  State<GalleryApp> createState() => _GalleryAppState();
}

class _GalleryAppState extends State<GalleryApp> {
  ThemeMode _themeMode = ThemeMode.system;
  METhemeData _meTheme = METhemeData.expressive;

  static ThemeData _themeFor(Brightness brightness) {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF3D6B35),
      brightness: brightness,
    );
    return ThemeData.from(colorScheme: scheme, useMaterial3: true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'M3 Expressive Gallery',
      debugShowCheckedModeBanner: false,
      theme: _themeFor(Brightness.light),
      darkTheme: _themeFor(Brightness.dark),
      themeMode: _themeMode,
      builder: (context, child) => METheme(
        data: _meTheme,
        child: child!,
      ),
      home: GalleryHome(
        themeMode: _themeMode,
        meTheme: _meTheme,
        onThemeModeChanged: (mode) => setState(() => _themeMode = mode),
        onMeThemeChanged: (theme) => setState(() => _meTheme = theme),
      ),
    );
  }
}

class GalleryHome extends StatefulWidget {
  const GalleryHome({
    super.key,
    required this.themeMode,
    required this.meTheme,
    required this.onThemeModeChanged,
    required this.onMeThemeChanged,
  });

  final ThemeMode themeMode;
  final METhemeData meTheme;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<METhemeData> onMeThemeChanged;

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
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Text(
                  'M3 Expressive',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const Divider(height: 1),
              for (var i = 0; i < _titles.length; i++)
                ListTile(
                  selected: _index == i,
                  title: Text(_titles[i]),
                  onTap: () {
                    setState(() => _index = i);
                    Navigator.of(context).pop();
                  },
                ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Appearance',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              RadioListTile<ThemeMode>(
                title: const Text('System theme'),
                value: ThemeMode.system,
                groupValue: widget.themeMode,
                onChanged: (mode) {
                  if (mode != null) widget.onThemeModeChanged(mode);
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Light'),
                value: ThemeMode.light,
                groupValue: widget.themeMode,
                onChanged: (mode) {
                  if (mode != null) widget.onThemeModeChanged(mode);
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Dark'),
                value: ThemeMode.dark,
                groupValue: widget.themeMode,
                onChanged: (mode) {
                  if (mode != null) widget.onThemeModeChanged(mode);
                },
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Motion',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              RadioListTile<bool>(
                title: const Text('Expressive (bouncy)'),
                value: true,
                groupValue: widget.meTheme.motion == MEMotionScheme.expressive,
                onChanged: (_) {
                  widget.onMeThemeChanged(METhemeData.expressive);
                },
              ),
              RadioListTile<bool>(
                title: const Text('Standard (subtle)'),
                value: false,
                groupValue: widget.meTheme.motion == MEMotionScheme.expressive,
                onChanged: (_) {
                  widget.onMeThemeChanged(METhemeData.standard);
                },
              ),
            ],
          ),
        ),
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
