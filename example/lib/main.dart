import 'package:flutter/material.dart';
import 'package:material3_expressive/material3_expressive.dart';

import 'gallery/catalog.dart';
import 'gallery/playground_page.dart';
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
  String _query = '';

  List<CatalogEntry> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return kCatalog;
    return kCatalog
        .where(
          (e) =>
              e.name.toLowerCase().contains(q) ||
              e.replaces.toLowerCase().contains(q) ||
              e.category.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<CatalogEntry>>{};
    for (final entry in _filtered) {
      grouped.putIfAbsent(entry.category, () => <CatalogEntry>[]).add(entry);
    }

    return Scaffold(
      drawer: _GalleryDrawer(
        themeMode: widget.themeMode,
        meTheme: widget.meTheme,
        onThemeModeChanged: widget.onThemeModeChanged,
        onMeThemeChanged: widget.onMeThemeChanged,
      ),
      body: CustomScrollView(
        slivers: [
          MEAppBar(
            title: const Text('Widget gallery'),
            subtitle: Text('${kCatalog.length} components'),
            size: MEAppBarSize.medium,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: MESearchBar(
                hintText: 'Search every widget…',
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
          ),
          if (_filtered.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: MEEmptyState(
                icon: Icons.search_off,
                title: Text('No widgets match your search'),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverList.list(
                children: [
                  for (final category in grouped.keys) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                      child: Text(
                        '${category.toUpperCase()} · ${grouped[category]!.length}',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    MECardList(
                      itemCount: grouped[category]!.length,
                      onTap: (i) {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => PlaygroundPage(
                              entry: grouped[category]![i],
                            ),
                          ),
                        );
                      },
                      itemBuilder: (context, i) {
                        final entry = grouped[category]![i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    Text(
                                      entry.replaces,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _GalleryDrawer extends StatelessWidget {
  const _GalleryDrawer({
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
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Text(
                'M3 Expressive',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(height: 1),
            const _DrawerLabel('Tours'),
            const _TourTile(
              title: 'Buttons & FABs',
              page: ButtonsPage(),
            ),
            const _TourTile(
              title: 'Progress & Loading',
              page: ProgressPage(),
            ),
            const _TourTile(
              title: 'Sliders & Controls',
              page: ControlsPage(),
            ),
            const _TourTile(
              title: 'Navigation',
              page: NavigationPage(),
            ),
            const _TourTile(
              title: 'Cards, Chips & Dialogs',
              page: ContainersPage(),
            ),
            const _TourTile(
              title: 'Inputs, Lists & More',
              page: InputsPage(),
            ),
            const _TourTile(
              title: 'Markdown, Chat & Content',
              page: ContentPage(),
            ),
            const _TourTile(
              title: 'Slivers',
              page: SliversPage(),
              sliver: true,
            ),
            const Divider(height: 1),
            const _DrawerLabel('Appearance'),
            ListTile(
              selected: themeMode == ThemeMode.system,
              title: const Text('System theme'),
              onTap: () => onThemeModeChanged(ThemeMode.system),
            ),
            ListTile(
              selected: themeMode == ThemeMode.light,
              title: const Text('Light'),
              onTap: () => onThemeModeChanged(ThemeMode.light),
            ),
            ListTile(
              selected: themeMode == ThemeMode.dark,
              title: const Text('Dark'),
              onTap: () => onThemeModeChanged(ThemeMode.dark),
            ),
            const Divider(height: 1),
            const _DrawerLabel('Motion'),
            ListTile(
              selected: meTheme.motion == MEMotionScheme.expressive,
              title: const Text('Expressive (bouncy)'),
              onTap: () => onMeThemeChanged(METhemeData.expressive),
            ),
            ListTile(
              selected: meTheme.motion == MEMotionScheme.standard,
              title: const Text('Standard (subtle)'),
              onTap: () => onMeThemeChanged(METhemeData.standard),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerLabel extends StatelessWidget {
  const _DrawerLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(text, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}

class _TourTile extends StatelessWidget {
  const _TourTile({
    required this.title,
    required this.page,
    this.sliver = false,
  });

  final String title;
  final Widget page;
  final bool sliver;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      onTap: () {
        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => sliver
                ? Scaffold(body: page)
                : Scaffold(
                    appBar: AppBar(title: Text(title)),
                    body: page,
                  ),
          ),
        );
      },
    );
  }
}
