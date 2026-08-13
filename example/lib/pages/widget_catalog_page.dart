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
    _CatalogEntry('MEButton', 'ElevatedButton/FilledButton', 'Buttons'),
    _CatalogEntry('MEButtonGroup', 'toggle button rows', 'Buttons'),
    _CatalogEntry('MEFab', 'FloatingActionButton', 'Buttons'),
    _CatalogEntry('MEFabMenu', 'speed dial patterns', 'Buttons'),
    _CatalogEntry('MEFloatingToolbar', '—', 'Buttons'),
    _CatalogEntry('MEHoldButton', '—', 'Buttons'),
    _CatalogEntry('MEIconButton', 'IconButton', 'Buttons'),
    _CatalogEntry('MELikeButton', '—', 'Buttons'),
    _CatalogEntry('MEOrbitMenu', '—', 'Buttons'),
    _CatalogEntry('MEProgressButton', '—', 'Buttons'),
    _CatalogEntry('MESegmentedButton', 'SegmentedButton', 'Buttons'),
    _CatalogEntry('MESplitButton', '—', 'Buttons'),
    _CatalogEntry('METoolbar', 'floating action clusters', 'Buttons'),
    _CatalogEntry('MEActivityRings', '—', 'Charts'),
    _CatalogEntry('MEBarChart', '—', 'Charts'),
    _CatalogEntry('MEBubbleChart', '—', 'Charts'),
    _CatalogEntry('MECandlestickChart', '—', 'Charts'),
    _CatalogEntry('MEDonutChart', '—', 'Charts'),
    _CatalogEntry('MEFunnelChart', '—', 'Charts'),
    _CatalogEntry('MEGauge', '—', 'Charts'),
    _CatalogEntry('MEHeatmap', '—', 'Charts'),
    _CatalogEntry('MELineChart', '—', 'Charts'),
    _CatalogEntry('MERadarChart', '—', 'Charts'),
    _CatalogEntry('MESparkline', '—', 'Charts'),
    _CatalogEntry('MESpeedometer', '—', 'Charts'),
    _CatalogEntry('MEStackedBarChart', '—', 'Charts'),
    _CatalogEntry('METhermometer', '—', 'Charts'),
    _CatalogEntry('MEBadge', 'Badge', 'Communication'),
    _CatalogEntry('MEBanner', 'MaterialBanner', 'Communication'),
    _CatalogEntry('MEBattery', '—', 'Communication'),
    _CatalogEntry('MEBreathingRing', '—', 'Communication'),
    _CatalogEntry('MECountdown', '—', 'Communication'),
    _CatalogEntry('MEDivider', 'Divider', 'Communication'),
    _CatalogEntry('MEEqualizer', '—', 'Communication'),
    _CatalogEntry('MEFireworks', '—', 'Communication'),
    _CatalogEntry('MEHourglass', '—', 'Communication'),
    _CatalogEntry('MELavaLamp', '—', 'Communication'),
    _CatalogEntry('MEMarquee', '—', 'Communication'),
    _CatalogEntry('MENumberTicker', '—', 'Communication'),
    _CatalogEntry('MEPomodoro', '—', 'Communication'),
    _CatalogEntry('MESignalStrength', '—', 'Communication'),
    _CatalogEntry('MESonar', '—', 'Communication'),
    _CatalogEntry('MEStreakFlame', '—', 'Communication'),
    _CatalogEntry('MESuccessCheck', '—', 'Communication'),
    _CatalogEntry('METooltip', 'Tooltip', 'Communication'),
    _CatalogEntry('METrafficLight', '—', 'Communication'),
    _CatalogEntry('METypewriter', '—', 'Communication'),
    _CatalogEntry('MEVuMeter', '—', 'Communication'),
    _CatalogEntry('showMECoachmark', '—', 'Communication'),
    _CatalogEntry('showMESnackBar', 'SnackBar', 'Communication'),
    _CatalogEntry('showMEToast', '—', 'Communication'),
    _CatalogEntry('MEAvatar', 'CircleAvatar', 'Containers'),
    _CatalogEntry('MEBoardingPass', '—', 'Containers'),
    _CatalogEntry('MECard', 'Card', 'Containers'),
    _CatalogEntry('MECarousel', 'CarouselView', 'Containers'),
    _CatalogEntry('MEChip', 'Chip/FilterChip/InputChip', 'Containers'),
    _CatalogEntry('MECreditCard', '—', 'Containers'),
    _CatalogEntry('MEDialog', 'AlertDialog + showDialog', 'Containers'),
    _CatalogEntry('MEEmptyState', '—', 'Containers'),
    _CatalogEntry('MEFileCard', '—', 'Containers'),
    _CatalogEntry('MEFlipCard', '—', 'Containers'),
    _CatalogEntry('MEImage', 'Image.network', 'Containers'),
    _CatalogEntry('MEMorphingShape', '—', 'Containers'),
    _CatalogEntry('MEPolaroid', '—', 'Containers'),
    _CatalogEntry('MEReceipt', '—', 'Containers'),
    _CatalogEntry('MESplashScreen', '—', 'Containers'),
    _CatalogEntry('MEStatCard', '—', 'Containers'),
    _CatalogEntry('MEStickyNote', '—', 'Containers'),
    _CatalogEntry('MEStoryRing', '—', 'Containers'),
    _CatalogEntry('MESwipeDeck', '—', 'Containers'),
    _CatalogEntry('METiltCard', '—', 'Containers'),
    _CatalogEntry('showMEDialog', 'AlertDialog + showDialog', 'Containers'),
    _CatalogEntry('MEChatBubble', '—', 'Content'),
    _CatalogEntry('MEChatInput', '—', 'Content'),
    _CatalogEntry('MEChatTypingIndicator', '—', 'Content'),
    _CatalogEntry('MECodeView', '—', 'Content'),
    _CatalogEntry('MEMarkdown', '—', 'Content'),
    _CatalogEntry('MEMarkdownEditor', '—', 'Content'),
    _CatalogEntry('MECheckbox', 'Checkbox', 'Controls'),
    _CatalogEntry('MECoinFlip', '—', 'Controls'),
    _CatalogEntry('MEColorPicker', '—', 'Controls'),
    _CatalogEntry('MEColorWheel', '—', 'Controls'),
    _CatalogEntry('MECompareSlider', '—', 'Controls'),
    _CatalogEntry('MECompass', '—', 'Controls'),
    _CatalogEntry('MEDayNightToggle', '—', 'Controls'),
    _CatalogEntry('MEDice', '—', 'Controls'),
    _CatalogEntry('MEFlipClock', '—', 'Controls'),
    _CatalogEntry('MEJoystick', '—', 'Controls'),
    _CatalogEntry('MEKnob', '—', 'Controls'),
    _CatalogEntry('MELockDial', '—', 'Controls'),
    _CatalogEntry('MEMetronome', '—', 'Controls'),
    _CatalogEntry('MEMoodPicker', '—', 'Controls'),
    _CatalogEntry('MEOtpInput', '—', 'Controls'),
    _CatalogEntry('MEPinPad', '—', 'Controls'),
    _CatalogEntry('MEQuantityStepper', '—', 'Controls'),
    _CatalogEntry('MERadio', 'Radio', 'Controls'),
    _CatalogEntry('MERangeSlider', 'RangeSlider', 'Controls'),
    _CatalogEntry('MERating', '—', 'Controls'),
    _CatalogEntry('MEScratchCard', '—', 'Controls'),
    _CatalogEntry('MESlideToConfirm', '—', 'Controls'),
    _CatalogEntry('MESlider', 'Slider', 'Controls'),
    _CatalogEntry('MESlotMachine', '—', 'Controls'),
    _CatalogEntry('MESpinWheel', '—', 'Controls'),
    _CatalogEntry('MEStampCard', '—', 'Controls'),
    _CatalogEntry('MEStopwatch', '—', 'Controls'),
    _CatalogEntry('MESwitch', 'Switch', 'Controls'),
    _CatalogEntry('MEVinyl', '—', 'Controls'),
    _CatalogEntry('MEWaveform', '—', 'Controls'),
    _CatalogEntry('MEWheelPicker', 'CupertinoPicker', 'Controls'),
    _CatalogEntry('MEAutocomplete', 'Autocomplete', 'Inputs'),
    _CatalogEntry('MEPasswordField', '—', 'Inputs'),
    _CatalogEntry('MESearchBar', 'SearchBar', 'Inputs'),
    _CatalogEntry('METagInput', '—', 'Inputs'),
    _CatalogEntry('METextField', 'TextField/TextFormField', 'Inputs'),
    _CatalogEntry('MEAccordion', 'ExpansionPanelList', 'Lists'),
    _CatalogEntry('MEDataTable', 'DataTable', 'Lists'),
    _CatalogEntry('MEDismissible', 'Dismissible', 'Lists'),
    _CatalogEntry('MEDropdown', 'DropdownButton/DropdownMenu', 'Lists'),
    _CatalogEntry('MEExpansionTile', 'ExpansionTile', 'Lists'),
    _CatalogEntry('MEListGroup', 'ListTile', 'Lists'),
    _CatalogEntry('MEListTile', 'ListTile', 'Lists'),
    _CatalogEntry('MEMenuAnchor', 'PopupMenuButton/MenuAnchor', 'Lists'),
    _CatalogEntry('MEPaginatedDataTable', 'PaginatedDataTable', 'Lists'),
    _CatalogEntry('MEReorderableList', 'ReorderableListView', 'Lists'),
    _CatalogEntry('MEStepper', 'Stepper', 'Lists'),
    _CatalogEntry('METimeline', '—', 'Lists'),
    _CatalogEntry('METreeView', '—', 'Lists'),
    _CatalogEntry('MEAppBar', 'AppBar/SliverAppBar', 'Navigation'),
    _CatalogEntry('MEBottomAppBar', 'BottomAppBar', 'Navigation'),
    _CatalogEntry('MEBreadcrumbs', '—', 'Navigation'),
    _CatalogEntry('MEDock', '—', 'Navigation'),
    _CatalogEntry('MEDrawer', 'Drawer/NavigationDrawer', 'Navigation'),
    _CatalogEntry('MENavigationBar', 'NavigationBar', 'Navigation'),
    _CatalogEntry('MENavigationRail', 'NavigationRail + drawer', 'Navigation'),
    _CatalogEntry('METabBar', 'TabBar', 'Navigation'),
    _CatalogEntry('MEAvatarGroup', 'CircleAvatar', 'Containers'),
    _CatalogEntry('MEPageIndicator', '—', 'Communication'),
    _CatalogEntry('MECalendar', 'CalendarDatePicker', 'Pickers'),
    _CatalogEntry('showMEBottomSheet', 'showModalBottomSheet', 'Pickers'),
    _CatalogEntry('showMECommandPalette', '—', 'Pickers'),
    _CatalogEntry('showMEDatePicker', 'showDatePicker', 'Pickers'),
    _CatalogEntry('showMESideSheet', '—', 'Pickers'),
    _CatalogEntry('showMETimePicker', 'showTimePicker', 'Pickers'),
    _CatalogEntry(
        'MECircularProgressIndicator', 'CircularProgressIndicator', 'Progress'),
    _CatalogEntry(
        'MELinearProgressIndicator', 'LinearProgressIndicator', 'Progress'),
    _CatalogEntry('MELiquidProgress', '—', 'Progress'),
    _CatalogEntry(
        'MELoadingIndicator', 'short indeterminate waits', 'Progress'),
    _CatalogEntry('MERefreshIndicator', 'RefreshIndicator', 'Progress'),
    _CatalogEntry('MESkeleton', '—', 'Progress'),
    _CatalogEntry('MESkeletonizer', '—', 'Progress'),
    _CatalogEntry('MESliverGrid', 'SliverGrid', 'Slivers'),
    _CatalogEntry('MESliverList', 'SliverList', 'Slivers'),
    _CatalogEntry('MESliverPinnedHeader', 'SliverPersistentHeader', 'Slivers'),
    _CatalogEntry('MESliverScaffold', 'Scaffold + CustomScrollView', 'Slivers'),
    _CatalogEntry('MESliverSectionHeader', '—', 'Slivers'),
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
