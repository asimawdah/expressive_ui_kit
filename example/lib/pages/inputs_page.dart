import 'package:flutter/material.dart';
import 'package:material3_expressive/material3_expressive.dart';

/// Demonstrates text inputs, search, lists, menus, pickers and
/// communication widgets.
class InputsPage extends StatefulWidget {
  const InputsPage({super.key});

  @override
  State<InputsPage> createState() => _InputsPageState();
}

class _InputsPageState extends State<InputsPage> {
  int _tab = 0;
  String? _flavor = 'vanilla';
  int _selectedTile = 0;
  int _badgeCount = 3;
  int _step = 1;
  Set<String> _units = const {'day'};
  int _selectedAvatar = -1;
  int _page = 0;
  final List<String> _emails =
      List.generate(3, (i) => 'Swipe me away — message ${i + 1}');
  final List<Key> _taskKeys = List.generate(
    4,
    (i) => ValueKey<String>('task-$i'),
  );
  final List<String> _taskLabels = const [
    'Review pull request',
    'Update documentation',
    'Ship release candidate',
    'Plan sprint demo',
  ];

  static const List<String> _fruits = [
    'Apple',
    'Apricot',
    'Banana',
    'Blueberry',
    'Cherry',
    'Grape',
    'Mango',
    'Orange',
    'Peach',
    'Pear',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Tabs', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        METabBar(
          tabs: const [
            METab(label: 'Inputs', icon: Icons.edit_outlined),
            METab(label: 'Lists', icon: Icons.list),
            METab(label: 'More', icon: Icons.more_horiz),
          ],
          selectedIndex: _tab,
          onSelected: (i) => setState(() => _tab = i),
        ),
        const SizedBox(height: 24),
        Text('Text field', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        const METextField(
          label: 'Name',
          hintText: 'Jane Doe',
          helperText: 'Focus me to see the shape morph',
        ),
        const SizedBox(height: 16),
        Text('Search bar', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        const MESearchBar(hintText: 'Search widgets'),
        const SizedBox(height: 24),
        Text('Dropdown', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        MEDropdown<String>(
          label: 'Flavor',
          value: _flavor,
          items: const [
            MEMenuItem(
                value: 'vanilla', label: 'Vanilla', icon: Icons.icecream),
            MEMenuItem(value: 'mint', label: 'Mint', icon: Icons.icecream),
            MEMenuItem(value: 'mocha', label: 'Mocha', icon: Icons.icecream),
          ],
          onChanged: (v) => setState(() => _flavor = v),
        ),
        const SizedBox(height: 24),
        Text('List group', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        MEListGroup(
          children: [
            for (var i = 0; i < 3; i++)
              MEListTile(
                leading: const Icon(Icons.folder_outlined),
                title: Text('Item ${i + 1}'),
                subtitle: const Text('Segmented expressive tile'),
                trailing: const Icon(Icons.chevron_right),
                selected: _selectedTile == i,
                onPressed: () => setState(() => _selectedTile = i),
              ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Expansion tile', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        const MEExpansionTile(
          title: Text('Show details'),
          subtitle: Text('Springs open with overshoot'),
          leading: Icon(Icons.info_outline),
          children: [
            Text('Expanded content lives here. The container morphs from '
                'a pill into a large-radius rectangle as it opens.'),
          ],
        ),
        const SizedBox(height: 24),
        const MEDivider(),
        Text('Communication', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            MEBadge(
              count: _badgeCount,
              child: MEIconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => setState(() => _badgeCount++),
              ),
            ),
            const METooltip(
              message: 'Expressive tooltip',
              child: Icon(Icons.help_outline),
            ),
            MEButton.tonal(
              onPressed: () => showMESnackBar(
                context,
                message: 'Expressive snackbar',
                actionLabel: 'Undo',
              ),
              child: const Text('Snackbar'),
            ),
            MEButton.tonal(
              onPressed: () => showMEBottomSheet<void>(
                context: context,
                builder: (context) => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('An expressive bottom sheet with a spring '
                      'slide-up and extra-large top corners.'),
                ),
              ),
              child: const Text('Bottom sheet'),
            ),
            MEButton.tonal(
              onPressed: () => showMEDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              ),
              child: const Text('Date picker'),
            ),
            MEButton.tonal(
              onPressed: () => showMETimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              ),
              child: const Text('Time picker'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Banner', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        MEBanner(
          icon: const Icon(Icons.wifi_off_outlined),
          content: const Text('You are offline. Some data may be stale.'),
          actions: [
            MEButton.text(onPressed: () {}, child: const Text('Dismiss')),
            MEButton.text(onPressed: () {}, child: const Text('Retry')),
          ],
        ),
        const SizedBox(height: 24),
        Text('Stepper', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        MEStepper(
          currentStep: _step,
          onStepTapped: (i) => setState(() => _step = i),
          steps: const [
            MEStep(
              title: Text('Account'),
              subtitle: Text('Completed'),
              content: Text('Account details go here.'),
            ),
            MEStep(
              title: Text('Shipping'),
              content: Text('Shipping address form goes here.'),
            ),
            MEStep(
              title: Text('Payment'),
              content: Text('Payment method form goes here.'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Reorderable list',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SizedBox(
          height: 220,
          child: MEReorderableList(
            keys: _taskKeys,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                final key = _taskKeys.removeAt(oldIndex);
                final label = _taskLabels.removeAt(oldIndex);
                _taskKeys.insert(newIndex, key);
                _taskLabels.insert(newIndex, label);
              });
            },
            itemBuilder: (context, index, position) => MEListTile(
              position: position,
              leading: const Icon(Icons.task_alt_outlined),
              title: Text(_taskLabels[index]),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('Paginated data table',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        MEPaginatedDataTable(
          columns: const [
            DataColumn(label: Text('Widget')),
            DataColumn(label: Text('Category')),
          ],
          source: _WidgetCatalogSource(),
          rowsPerPage: 5,
          showCheckboxColumn: false,
        ),
        const SizedBox(height: 24),
        Text('Data table', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        const MEDataTable(
          columns: [
            DataColumn(label: Text('Widget')),
            DataColumn(label: Text('Replaces')),
          ],
          rows: [
            DataRow(cells: [
              DataCell(Text('MEButton')),
              DataCell(Text('ElevatedButton')),
            ]),
            DataRow(cells: [
              DataCell(Text('MESlider')),
              DataCell(Text('Slider')),
            ]),
            DataRow(cells: [
              DataCell(Text('MEDataTable')),
              DataCell(Text('DataTable')),
            ]),
          ],
        ),
        const SizedBox(height: 24),
        Text('Segmented button',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        MESegmentedButton<String>(
          segments: const [
            MESegment(value: 'day', label: Text('Day')),
            MESegment(value: 'week', label: Text('Week')),
            MESegment(value: 'month', label: Text('Month')),
          ],
          selected: _units,
          onSelectionChanged: (s) => setState(() => _units = s),
        ),
        const SizedBox(height: 24),
        Text('Avatars', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var i = 0; i < 3; i++) ...[
              MEAvatar(
                selected: _selectedAvatar == i,
                onPressed: () => setState(
                    () => _selectedAvatar = _selectedAvatar == i ? -1 : i),
                child: Text(String.fromCharCode(65 + i)),
              ),
              const SizedBox(width: 12),
            ],
            const SizedBox(width: 12),
            MEAvatarGroup(
              avatars: [
                for (var i = 0; i < 6; i++)
                  MEAvatar(child: Text(String.fromCharCode(65 + i))),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Autocomplete', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        MEAutocomplete<String>(
          label: 'Fruit',
          hintText: 'Type to search',
          leadingIcon: const Icon(Icons.search),
          optionsBuilder: (value) {
            if (value.text.isEmpty) return const Iterable<String>.empty();
            return _fruits.where(
              (f) => f.toLowerCase().contains(value.text.toLowerCase()),
            );
          },
        ),
        const SizedBox(height: 24),
        Text('Dismissible', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final email in _emails)
          MEDismissible(
            dismissKey: ValueKey(email),
            onDismissed: (_) => setState(() => _emails.remove(email)),
            child: MEListTile(
              leading: const Icon(Icons.mail_outline),
              title: Text(email),
              onPressed: () {},
            ),
          ),
        const SizedBox(height: 24),
        Text('Side sheet', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        MEButton.tonal(
          onPressed: () => showMESideSheet<void>(
            context: context,
            title: const Text('Filters'),
            builder: (context) => const Text(
              'A modal side sheet sliding in from the trailing edge with '
              'a spring curve and an expressive leading-edge corner.',
            ),
          ),
          child: const Text('Open side sheet'),
        ),
        const SizedBox(height: 24),
        Text('Carousel', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        MECarousel(
          height: 160,
          children: [
            for (final color in [
              Colors.green,
              Colors.teal,
              Colors.amber,
              Colors.deepOrange,
            ])
              ColoredBox(
                color: color.shade200,
                child: Center(
                  child: Icon(Icons.image_outlined,
                      size: 48, color: color.shade900),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Center(
          child: MEPageIndicator(
            count: 4,
            index: _page,
            onDotPressed: (i) => setState(() => _page = i),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _WidgetCatalogSource extends DataTableSource {
  static const _rows = <(String, String)>[
    ('MEButton', 'Buttons'),
    ('MESwitch', 'Controls'),
    ('MENavigationBar', 'Navigation'),
    ('MECard', 'Containers'),
    ('METextField', 'Inputs'),
    ('MEDataTable', 'Lists'),
    ('MEMarkdown', 'Content'),
    ('MELineChart', 'Charts'),
    ('MESliverList', 'Slivers'),
    ('METoast', 'Communication'),
    ('MELoadingIndicator', 'Progress'),
    ('MEAvatar', 'Containers'),
    ('MESegmentedButton', 'Buttons'),
    ('MEDialog', 'Containers'),
    ('MERefreshIndicator', 'Progress'),
    ('MEStepper', 'Lists'),
    ('MEOtpInput', 'Inputs'),
    ('MEGauge', 'Charts'),
    ('MEFabMenu', 'Buttons'),
    ('MESwipeDeck', 'Containers'),
  ];

  @override
  DataRow? getRow(int index) {
    if (index >= _rows.length) return null;
    final row = _rows[index];
    return DataRow(
      cells: [
        DataCell(Text(row.$1)),
        DataCell(Text(row.$2)),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _rows.length;

  @override
  int get selectedRowCount => 0;
}
