import 'package:flutter/material.dart';
import 'package:material3_expressive/material3_expressive.dart';

/// Searchable index of expressive widgets and their Material counterparts.
class WidgetCatalogPage extends StatefulWidget {
  const WidgetCatalogPage({super.key});

  @override
  State<WidgetCatalogPage> createState() => _WidgetCatalogPageState();
}

class _WidgetCatalogPageState extends State<WidgetCatalogPage> {
  String _query = '';

  static const List<_CatalogEntry> _entries = <_CatalogEntry>[
    _CatalogEntry('MEButton', 'ElevatedButton / FilledButton', 'Buttons'),
    _CatalogEntry('MEIconButton', 'IconButton', 'Buttons'),
    _CatalogEntry('MESegmentedButton', 'SegmentedButton', 'Buttons'),
    _CatalogEntry('MEFab', 'FloatingActionButton', 'Buttons'),
    _CatalogEntry('MEFabMenu', 'Speed dial', 'Buttons'),
    _CatalogEntry('MESwitch', 'Switch', 'Controls'),
    _CatalogEntry('MECheckbox', 'Checkbox', 'Controls'),
    _CatalogEntry('MERadio', 'Radio', 'Controls'),
    _CatalogEntry('MESlider', 'Slider', 'Controls'),
    _CatalogEntry('MERangeSlider', 'RangeSlider', 'Controls'),
    _CatalogEntry('MENavigationBar', 'NavigationBar', 'Navigation'),
    _CatalogEntry('MENavigationRail', 'NavigationRail', 'Navigation'),
    _CatalogEntry('METabBar', 'TabBar', 'Navigation'),
    _CatalogEntry('MEAppBar', 'AppBar / SliverAppBar', 'Navigation'),
    _CatalogEntry('MEDrawer', 'Drawer', 'Navigation'),
    _CatalogEntry('MECard', 'Card', 'Containers'),
    _CatalogEntry('MEChip', 'Chip', 'Containers'),
    _CatalogEntry('MEDialog', 'AlertDialog', 'Containers'),
    _CatalogEntry('METextField', 'TextField', 'Inputs'),
    _CatalogEntry('MESearchBar', 'SearchBar', 'Inputs'),
    _CatalogEntry('MEAutocomplete', 'Autocomplete', 'Inputs'),
    _CatalogEntry('MEListTile', 'ListTile', 'Lists'),
    _CatalogEntry('MEDataTable', 'DataTable', 'Lists'),
    _CatalogEntry('MEPaginatedDataTable', 'PaginatedDataTable', 'Lists'),
    _CatalogEntry('MEReorderableList', 'ReorderableListView', 'Lists'),
    _CatalogEntry('MEDismissible', 'Dismissible', 'Lists'),
    _CatalogEntry('MEMarkdown', 'Markdown viewer', 'Content'),
    _CatalogEntry('MEChatBubble', 'Chat bubble', 'Content'),
    _CatalogEntry(
        'MELinearProgressIndicator', 'LinearProgressIndicator', 'Progress'),
    _CatalogEntry(
        'MECircularProgressIndicator', 'CircularProgressIndicator', 'Progress'),
    _CatalogEntry('MELoadingIndicator', 'Loading indicator', 'Progress'),
    _CatalogEntry('MESparkline', 'Sparkline chart', 'Charts'),
    _CatalogEntry('MEBarChart', 'Bar chart', 'Charts'),
    _CatalogEntry('MELineChart', 'Line chart', 'Charts'),
    _CatalogEntry('MEDonutChart', 'Donut chart', 'Charts'),
    _CatalogEntry('MESkeleton', 'Skeleton loader', 'Progress'),
    _CatalogEntry('METoast', 'Toast', 'Communication'),
    _CatalogEntry('MESnackBar', 'SnackBar', 'Communication'),
    _CatalogEntry('METooltip', 'Tooltip', 'Communication'),
    _CatalogEntry('MEBadge', 'Badge', 'Communication'),
    _CatalogEntry('MESliverList', 'SliverList', 'Slivers'),
    _CatalogEntry('MESliverGrid', 'SliverGrid', 'Slivers'),
    _CatalogEntry('MESliverScaffold', 'Sliver scaffold', 'Slivers'),
  ];

  List<_CatalogEntry> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _entries;
    return _entries
        .where(
          (e) =>
              e.widget.toLowerCase().contains(q) ||
              e.replaces.toLowerCase().contains(q) ||
              e.category.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<_CatalogEntry>>{};
    for (final entry in _filtered) {
      grouped.putIfAbsent(entry.category, () => <_CatalogEntry>[]).add(entry);
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
                  MEDataTable(
                    columns: const [
                      DataColumn(label: Text('Widget')),
                      DataColumn(label: Text('Replaces')),
                    ],
                    rows: [
                      for (final entry in grouped[category]!)
                        DataRow(
                          cells: [
                            DataCell(Text(entry.widget)),
                            DataCell(Text(entry.replaces)),
                          ],
                        ),
                    ],
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

class _CatalogEntry {
  const _CatalogEntry(this.widget, this.replaces, this.category);

  final String widget;
  final String replaces;
  final String category;
}
