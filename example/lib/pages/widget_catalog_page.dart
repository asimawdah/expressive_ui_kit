import 'package:flutter/material.dart';
import 'package:material3_expressive/material3_expressive.dart';

import '../gallery/catalog.dart';
import '../gallery/playground_page.dart';

/// Searchable index of expressive widgets. Tapping a row opens that
/// widget's live playground.
class WidgetCatalogPage extends StatefulWidget {
  const WidgetCatalogPage({super.key});

  @override
  State<WidgetCatalogPage> createState() => _WidgetCatalogPageState();
}

class _WidgetCatalogPageState extends State<WidgetCatalogPage> {
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
      appBar: AppBar(title: const Text('Widget catalog')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: MESearchBar(
              hintText: 'Search widgets…',
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                for (final category in grouped.keys) ...[
                  Text(
                    category.toUpperCase(),
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entry.name,
                                style: Theme.of(context).textTheme.titleMedium),
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
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
                if (_filtered.isEmpty)
                  const MEEmptyState(
                    icon: Icons.search_off,
                    title: Text('No widgets match your search'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
