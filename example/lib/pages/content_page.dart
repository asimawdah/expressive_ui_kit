import 'package:flutter/material.dart';
import 'package:material3_expressive/material3_expressive.dart';

/// Demos for the content widgets: markdown viewer/editor, chat widgets,
/// rating, and OTP input.
class ContentPage extends StatefulWidget {
  const ContentPage({super.key});

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  double _rating = 3;
  bool _typing = true;
  bool _loading = true;
  int _count = 1024;
  DateTime _selectedDate = DateTime.now();
  List<String> _tags = ['flutter', 'material'];
  Color _pickedColor = const Color(0xFF6750A4);
  List<double> _sparkValues = [3, 5, 4, 8, 6, 9, 7, 12, 10, 14];
  int _toolbarIndex = 0;
  int _revenue = 48250;
  int _quantity = 2;
  int _wheelIndex = 1;
  double _waveProgress = 0.3;
  double _moveRing = 0.85;
  double _exerciseRing = 0.6;
  double _standRing = 0.4;
  final GlobalKey _coachTargetKey = GlobalKey();
  bool _storySeen = false;
  double _knobValue = 0.6;
  bool _eqPlaying = true;
  double _liquidValue = 0.62;
  Offset _joystickValue = Offset.zero;
  final MESpinWheelController _spinController = MESpinWheelController();
  double _compassHeading = 45;
  int _diceTotal = 0;
  double _temperature = 22;
  double _batteryLevel = 0.68;
  bool _batteryCharging = false;
  String _coinResult = '—';
  int _signalLevel = 3;
  bool _signalSearching = false;
  int? _mood = 3;
  int _streak = 12;
  bool _streakActive = true;
  bool _liked = false;
  int _likeCount = 128;
  bool _night = false;
  double _speed = 42;
  METrafficState _trafficState = METrafficState.go;
  final List<int> _lockEntries = [];
  final MEFireworksController _fireworksController = MEFireworksController();
  int _stampsEarned = 6;
  double _wheelHue = 210;
  int _splashKey = 0;
  final MEPinPadController _pinController = MEPinPadController();
  bool _vinylPlaying = false;

  static const List<Color> _palette = [
    Color(0xFF6750A4),
    Color(0xFF386A20),
    Color(0xFF9C4146),
    Color(0xFF006874),
    Color(0xFF7D5260),
    Color(0xFF795548),
    Color(0xFF37474F),
    Color(0xFFB8860B),
  ];
  final List<({String text, bool outgoing})> _messages = [
    (
      text: 'Hey! Have you tried the new **expressive** widgets?',
      outgoing: false
    ),
    (text: 'Just did — the springs feel great.', outgoing: true),
    (text: 'Even supports `inline code` in messages.', outgoing: true),
  ];

  static const String _sampleMarkdown = '''
# Material 3 Expressive

A design language built on **shape morphing** and *spring physics*.

## Highlights

- Springy, interruptible motion
- Shape as a state signal
- New components like the `MELoadingIndicator`

> Expressive design isn't decoration — it's communication.

Check the [Material docs](https://m3.material.io) for details.

```dart
// Syntax-highlighted code blocks with a copy button.
MEButton.filled(
  onPressed: () {},
  child: Text('Get started'),
)
```

[file:design-spec.pdf](https://example.com/design-spec.pdf)
''';

  @override
  Widget build(BuildContext context) {
    final title = Theme.of(context).textTheme.titleMedium;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: <Widget>[
        Text('Markdown viewer', style: title),
        const SizedBox(height: 8),
        MECard(
          onPressed: null,
          child: MEMarkdown(
            data: _sampleMarkdown,
            onLinkTap: (_) {},
            onFileTap: (url) => showMESnackBar(
              context,
              message: 'Open file: $url',
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text('Markdown editor', style: title),
        const SizedBox(height: 8),
        MEMarkdownEditor(
          hintText: 'Write some markdown, then hit Preview...',
          onAttachFile: () async => const MEMarkdownAttachment(
            name: 'quarterly-report.xlsx',
            url: 'https://example.com/quarterly-report.xlsx',
          ),
        ),
        const SizedBox(height: 32),
        Text('File cards', style: title),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MEFileCard(
              name: 'annual-report.pdf',
              size: '2.4 MB',
              onPressed: () {},
            ),
            const SizedBox(height: 8),
            MEFileCard(
              name: 'soundtrack.mp3',
              size: '8.1 MB',
              onPressed: () {},
            ),
            const SizedBox(height: 8),
            MEFileCard(
              name: 'archive.zip',
              size: '148 MB',
              dense: true,
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text('Chat', style: title),
        const SizedBox(height: 8),
        for (var i = 0; i < _messages.length; i++)
          MEChatBubble(
            text: _messages[i].text,
            markdown: true,
            outgoing: _messages[i].outgoing,
            animateIn: false,
            position: _groupPosition(i),
            avatar:
                _messages[i].outgoing ? null : const MEAvatar(child: Text('A')),
            timestamp: i == _messages.length - 1 ? '2:44 PM' : null,
          ),
        if (_typing)
          const Padding(
            padding: EdgeInsets.only(left: 44, top: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: MEChatTypingIndicator(),
            ),
          ),
        const SizedBox(height: 12),
        MEChatInput(
          leading: MEIconButton(
            icon: const Icon(Icons.add),
            variant: MEButtonVariant.text,
            onPressed: () {},
          ),
          onSend: (text) => setState(() {
            _messages.add((text: text, outgoing: true));
            _typing = false;
          }),
        ),
        const SizedBox(height: 32),
        Text('Rating', style: title),
        const SizedBox(height: 8),
        Row(
          children: [
            MERating(
              value: _rating,
              onChanged: (v) => setState(() => _rating = v),
            ),
            const SizedBox(width: 16),
            Text('$_rating', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 12),
        const MERating(value: 3.5),
        const SizedBox(height: 32),
        Text('OTP input', style: title),
        const SizedBox(height: 8),
        MEOtpInput(
          onCompleted: (code) => showMESnackBar(
            context,
            message: 'Code entered: $code',
          ),
        ),
        const SizedBox(height: 32),
        Text('Skeleton loading', style: title),
        const SizedBox(height: 8),
        MESkeletonizer(
          loading: _loading,
          skeleton: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MESkeleton.circle(size: 48),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MESkeleton.line(width: 160),
                    SizedBox(height: 8),
                    MESkeleton.line(),
                    SizedBox(height: 8),
                    MESkeleton.line(width: 220),
                  ],
                ),
              ),
            ],
          ),
          child: MEListTile(
            leading: const MEAvatar(child: Text('M3')),
            title: const Text('Content loaded'),
            subtitle: const Text('Toggle the switch to reload'),
            onPressed: () {},
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            MESwitch(
              value: _loading,
              onChanged: (v) => setState(() => _loading = v),
            ),
            const SizedBox(width: 12),
            const Text('Loading'),
          ],
        ),
        const SizedBox(height: 32),
        Text('Number ticker', style: title),
        const SizedBox(height: 8),
        Row(
          children: [
            MENumberTicker(
              value: _count,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(width: 16),
            MEIconButton(
              icon: const Icon(Icons.remove),
              onPressed: () => setState(() => _count -= 37),
            ),
            const SizedBox(width: 4),
            MEIconButton(
              icon: const Icon(Icons.add),
              onPressed: () => setState(() => _count += 37),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text('Timeline', style: title),
        const SizedBox(height: 8),
        const METimeline(
          activeIndex: 2,
          entries: [
            METimelineEntry(
              title: Text('Order placed'),
              subtitle: Text('March 2, 10:12 AM'),
            ),
            METimelineEntry(
              title: Text('Payment confirmed'),
              subtitle: Text('March 2, 10:14 AM'),
            ),
            METimelineEntry(
              title: Text('Out for delivery'),
              subtitle: Text('Arriving today'),
              icon: Icons.local_shipping_outlined,
            ),
            METimelineEntry(
              title: Text('Delivered'),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text('Calendar', style: title),
        const SizedBox(height: 8),
        MECard(
          onPressed: null,
          child: MECalendar(
            selectedDate: _selectedDate,
            onDateSelected: (d) => setState(() => _selectedDate = d),
          ),
        ),
        const SizedBox(height: 32),
        Text('Tag input', style: title),
        const SizedBox(height: 8),
        METagInput(
          tags: _tags,
          label: 'Topics',
          hintText: 'Add a tag and press enter',
          onChanged: (tags) => setState(() => _tags = tags),
        ),
        const SizedBox(height: 32),
        Text('Tree view', style: title),
        const SizedBox(height: 8),
        const METreeView(
          nodes: [
            METreeNode(
              label: Text('lib'),
              icon: Icons.folder_outlined,
              initiallyExpanded: true,
              children: [
                METreeNode(
                  label: Text('src'),
                  icon: Icons.folder_outlined,
                  children: [
                    METreeNode(
                        label: Text('buttons.dart'),
                        icon: Icons.description_outlined),
                    METreeNode(
                        label: Text('theme.dart'),
                        icon: Icons.description_outlined),
                  ],
                ),
                METreeNode(
                    label: Text('main.dart'), icon: Icons.description_outlined),
              ],
            ),
            METreeNode(
                label: Text('pubspec.yaml'), icon: Icons.description_outlined),
          ],
        ),
        const SizedBox(height: 32),
        Text('Progress button', style: title),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: MEProgressButton(
            icon: const Icon(Icons.cloud_upload_outlined),
            onPressed: () => Future<void>.delayed(const Duration(seconds: 2)),
            child: const Text('Upload'),
          ),
        ),
        const SizedBox(height: 32),
        Text('Empty state', style: title),
        const SizedBox(height: 8),
        MECard(
          onPressed: null,
          child: MEEmptyState(
            icon: Icons.inbox_outlined,
            title: const Text('No messages yet'),
            message: const Text(
                'When someone writes to you, their message will show up here.'),
            action: MEButton.tonal(
              onPressed: () {},
              child: const Text('Start a conversation'),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text('Color picker', style: title),
        const SizedBox(height: 8),
        MEColorPicker(
          colors: _palette,
          selected: _pickedColor,
          onChanged: (c) => setState(() => _pickedColor = c),
        ),
        const SizedBox(height: 32),
        Text('Password field', style: title),
        const SizedBox(height: 8),
        const MEPasswordField(
          showStrengthMeter: true,
          helperText: 'Use 12+ characters with numbers and symbols',
        ),
        const SizedBox(height: 32),
        Text('Sparkline', style: title),
        const SizedBox(height: 8),
        MECard(
          onPressed: null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Weekly activity',
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 12),
              MESparkline(values: _sparkValues, height: 72),
              const SizedBox(height: 12),
              MEButton.text(
                onPressed: () => setState(() {
                  _sparkValues = [
                    for (final v in _sparkValues)
                      (v + (v.hashCode % 7) - 3).clamp(1, 20).toDouble(),
                  ];
                }),
                child: const Text('Shuffle data'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text('Bar chart', style: title),
        const SizedBox(height: 8),
        const MECard(
          onPressed: null,
          child: MEBarChart(
            entries: [
              MEBarChartEntry(value: 12, label: 'Mon'),
              MEBarChartEntry(value: 18, label: 'Tue'),
              MEBarChartEntry(value: 9, label: 'Wed'),
              MEBarChartEntry(value: 24, label: 'Thu'),
              MEBarChartEntry(value: 16, label: 'Fri'),
              MEBarChartEntry(value: 6, label: 'Sat'),
              MEBarChartEntry(value: 11, label: 'Sun'),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text('Flip card', style: title),
        const SizedBox(height: 8),
        MEFlipCard(
          front: MEFlipCardFace(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.credit_card,
                    color: Theme.of(context).colorScheme.onPrimaryContainer),
                const SizedBox(height: 24),
                Text(
                  'Tap to flip',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
              ],
            ),
          ),
          back: MEFlipCardFace(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.qr_code_2,
                    color: Theme.of(context).colorScheme.onTertiaryContainer),
                const SizedBox(height: 24),
                Text(
                  'The back face',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color:
                            Theme.of(context).colorScheme.onTertiaryContainer,
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text('Countdown', style: title),
        const SizedBox(height: 8),
        MECountdown(
          target: DateTime.now().add(
            const Duration(days: 2, hours: 6, minutes: 30, seconds: 45),
          ),
        ),
        const SizedBox(height: 32),
        Text('Gauge', style: title),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            MEGauge(value: 0.72, label: Text('Storage')),
            MEGauge(value: 0.35, size: 120, thickness: 10),
          ],
        ),
        const SizedBox(height: 32),
        Text('Donut chart', style: title),
        const SizedBox(height: 8),
        const Center(
          child: MEDonutChart(
            segments: [
              MEDonutSegment(value: 42, label: 'Documents'),
              MEDonutSegment(value: 28, label: 'Photos'),
              MEDonutSegment(value: 18, label: 'Video'),
              MEDonutSegment(value: 12, label: 'Other'),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text('Toast', style: title),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            MEButton.tonal(
              onPressed: () => showMEToast(
                context,
                message: 'Profile saved',
                kind: METoastKind.success,
              ),
              child: const Text('Success'),
            ),
            MEButton.tonal(
              onPressed: () => showMEToast(
                context,
                message: 'New version available',
              ),
              child: const Text('Info'),
            ),
            MEButton.tonal(
              onPressed: () => showMEToast(
                context,
                message: 'Storage almost full',
                kind: METoastKind.warning,
              ),
              child: const Text('Warning'),
            ),
            MEButton.tonal(
              onPressed: () => showMEToast(
                context,
                message: 'Upload failed',
                kind: METoastKind.error,
              ),
              child: const Text('Error'),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text('Breadcrumbs', style: title),
        const SizedBox(height: 8),
        MEBreadcrumbs(
          crumbs: const [
            MEBreadcrumb(label: 'Home', icon: Icons.home_outlined),
            MEBreadcrumb(label: 'Projects'),
            MEBreadcrumb(label: 'Material 3'),
            MEBreadcrumb(label: 'Expressive'),
          ],
          onCrumbPressed: (i) => showMEToast(
            context,
            message: 'Navigate to crumb $i',
          ),
        ),
        const SizedBox(height: 32),
        Text('Swipe deck', style: title),
        const SizedBox(height: 8),
        MESwipeDeck(
          itemCount: 5,
          height: 280,
          onSwiped: (i, dir) => showMEToast(
            context,
            message:
                'Card ${i + 1} swiped ${dir == MESwipeDirection.right ? 'right' : 'left'}',
            kind: dir == MESwipeDirection.right
                ? METoastKind.success
                : METoastKind.info,
          ),
          itemBuilder: (context, i) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  [
                    Icons.landscape_outlined,
                    Icons.beach_access_outlined,
                    Icons.forest_outlined,
                    Icons.location_city_outlined,
                    Icons.water_outlined,
                  ][i],
                  size: 56,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  'Card ${i + 1} of 5',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Drag me left or right',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text('FAB menu', style: title),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: MEFabMenu(
            items: [
              MEFabMenuItem(
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Compose'),
                onPressed: () =>
                    showMEToast(context, message: 'Compose pressed'),
              ),
              MEFabMenuItem(
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Camera'),
                onPressed: () =>
                    showMEToast(context, message: 'Camera pressed'),
              ),
              MEFabMenuItem(
                icon: const Icon(Icons.mic_none),
                label: const Text('Record'),
                onPressed: () =>
                    showMEToast(context, message: 'Record pressed'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text('Floating toolbar', style: title),
        const SizedBox(height: 8),
        Center(
          child: MEFloatingToolbar(
            selectedIndex: _toolbarIndex,
            onSelected: (i) => setState(() => _toolbarIndex = i),
            actions: const [
              METoolbarAction(
                icon: Icon(Icons.format_bold),
                tooltip: 'Bold',
              ),
              METoolbarAction(
                icon: Icon(Icons.format_italic),
                tooltip: 'Italic',
              ),
              METoolbarAction(
                icon: Icon(Icons.format_underline),
                tooltip: 'Underline',
              ),
              METoolbarAction(
                icon: Icon(Icons.link),
                tooltip: 'Link',
              ),
              METoolbarAction(
                icon: Icon(Icons.image_outlined),
                tooltip: 'Image',
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text('Accordion', style: title),
        const SizedBox(height: 8),
        const MEAccordion(
          initiallyExpanded: {0},
          items: [
            MEAccordionItem(
              icon: Icons.animation,
              header: Text('What makes motion expressive?'),
              body: Text(
                'Physics-based springs replace duration curves. Motion is '
                'interruptible, and spatial springs overshoot slightly for '
                'a natural, energetic feel.',
              ),
            ),
            MEAccordionItem(
              icon: Icons.category_outlined,
              header: Text('How does shape signal state?'),
              body: Text(
                'Components morph between round and square shapes on press '
                'and selection, making state changes legible at a glance.',
              ),
            ),
            MEAccordionItem(
              icon: Icons.palette_outlined,
              header: Text('Which color roles are used?'),
              body: Text(
                'Everything derives from the Material color scheme, so the '
                'widgets adapt to light, dark, and dynamic color themes.',
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text('Stat cards', style: title),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: MEStatCard(
                label: const Text('Revenue'),
                icon: Icons.payments_outlined,
                value: _revenue,
                prefix: '\$',
                delta: 12.4,
                sparkline: const [8, 10, 9, 14, 12, 16, 18, 17, 21, 24],
                onPressed: () => setState(() => _revenue += 1375),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: MEStatCard(
                label: Text('Churn'),
                icon: Icons.trending_down,
                value: 42,
                suffix: ' users',
                delta: -3.2,
                sparkline: [12, 10, 11, 9, 8, 9, 7, 6, 7, 5],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text('Slide to confirm', style: title),
        const SizedBox(height: 8),
        MESlideToConfirm(
          label: 'Slide to send payment',
          confirmedLabel: 'Payment sent',
          onConfirmed: () => showMEToast(
            context,
            message: 'Payment confirmed',
            kind: METoastKind.success,
          ),
        ),
        const SizedBox(height: 32),
        Text('Heatmap', style: title),
        const SizedBox(height: 8),
        MEHeatmap(
          columns: 12,
          cells: [
            for (int i = 0; i < 48; i++)
              MEHeatmapCell(
                value: ((i * 7919) % 13).toDouble(),
                tooltip: '${(i * 7919) % 13} contributions in week ${i + 1}',
              ),
          ],
        ),
        const SizedBox(height: 32),
        Text('Quantity stepper', style: title),
        const SizedBox(height: 8),
        Row(
          children: [
            MEQuantityStepper(
              value: _quantity,
              min: 1,
              max: 10,
              onChanged: (v) => setState(() => _quantity = v),
            ),
            const SizedBox(width: 16),
            Text(
              '$_quantity in cart',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text('Compare slider', style: title),
        const SizedBox(height: 8),
        MECompareSlider(
          beforeLabel: 'Standard',
          afterLabel: 'Expressive',
          before: ColoredBox(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            child: Center(
              child: Icon(
                Icons.crop_square,
                size: 72,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          after: ColoredBox(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Center(
              child: Icon(
                Icons.auto_awesome,
                size: 72,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text('Wheel picker', style: title),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: MEWheelPicker(
                items: const [
                  'Extra small',
                  'Small',
                  'Medium',
                  'Large',
                  'Extra large',
                ],
                initialIndex: _wheelIndex,
                onSelected: (i) => setState(() => _wheelIndex = i),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Selected: ${const [
                  'Extra small',
                  'Small',
                  'Medium',
                  'Large',
                  'Extra large',
                ][_wheelIndex]}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text('Line chart', style: title),
        const SizedBox(height: 8),
        const MECard(
          onPressed: null,
          child: MELineChart(
            series: [
              MELineSeries(
                values: [4, 7, 5, 10, 8, 13, 11, 16, 14, 18],
                label: 'Revenue',
              ),
              MELineSeries(
                values: [3, 4, 6, 5, 7, 8, 7, 9, 10, 9],
                label: 'Costs',
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text('Coachmark', style: title),
        const SizedBox(height: 8),
        Row(
          children: [
            MEButton.filled(
              key: _coachTargetKey,
              icon: const Icon(Icons.auto_awesome),
              onPressed: () {},
              child: const Text('New feature'),
            ),
            const SizedBox(width: 12),
            MEButton.outlined(
              onPressed: () => showMECoachmark(
                context,
                targetKey: _coachTargetKey,
                title: 'Try the new feature',
                message: 'This button now supports expressive shape morphing. '
                    'Tap it to see the spring animation.',
              ),
              child: const Text('Show coachmark'),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text('Success check', style: title),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            MESuccessCheck(size: 88),
            MESuccessCheck.error(size: 88),
          ],
        ),
        const SizedBox(height: 32),
        Text('Activity rings', style: title),
        const SizedBox(height: 8),
        Column(
          children: [
            MEActivityRings(
              rings: [
                MEActivityRing(value: _moveRing, label: 'Move'),
                MEActivityRing(value: _exerciseRing, label: 'Exercise'),
                MEActivityRing(value: _standRing, label: 'Stand'),
              ],
              showLegend: true,
              center: const Icon(Icons.directions_run),
            ),
            const SizedBox(height: 8),
            MEButton.text(
              onPressed: () => setState(() {
                _moveRing = (_moveRing + 0.3) % 1.0;
                _exerciseRing = (_exerciseRing + 0.45) % 1.0;
                _standRing = (_standRing + 0.6) % 1.0;
              }),
              child: const Text('Randomize'),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text('Radar chart', style: title),
        const SizedBox(height: 8),
        Center(
          child: MERadarChart(
            axes: const [
              MERadarAxis(label: 'Speed', value: 0.9),
              MERadarAxis(label: 'Power', value: 0.6),
              MERadarAxis(label: 'Range', value: 0.75),
              MERadarAxis(label: 'Agility', value: 0.85),
              MERadarAxis(label: 'Defense', value: 0.5),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text('Waveform', style: title),
        const SizedBox(height: 8),
        MEWaveform(
          samples: [
            for (int i = 0; i < 64; i++)
              0.2 + 0.8 * (0.5 + 0.5 * ((i * 2654435761) % 100) / 100) % 1.0,
          ],
          progress: _waveProgress,
          onChanged: (v) => setState(() => _waveProgress = v),
        ),
        const SizedBox(height: 32),
        Text('Marquee', style: title),
        const SizedBox(height: 8),
        MECard(
          onPressed: null,
          child: Row(
            children: [
              Icon(
                Icons.music_note,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MEMarquee(
                  child: Text(
                    'Now playing: An Extraordinarily Long Song Title That '
                    'Cannot Possibly Fit In This Row — Extended Remix',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text('Command palette', style: title),
        const SizedBox(height: 8),
        MEButton.outlined(
          icon: const Icon(Icons.keyboard_command_key),
          onPressed: () => showMECommandPalette(
            context,
            commands: [
              MECommand(
                label: 'New document',
                icon: Icons.note_add_outlined,
                shortcut: 'Ctrl N',
                keywords: const ['create', 'file'],
                onSelected: () => showMEToast(context, message: 'New document'),
              ),
              MECommand(
                label: 'Toggle dark mode',
                icon: Icons.dark_mode_outlined,
                keywords: const ['theme', 'appearance'],
                onSelected: () =>
                    showMEToast(context, message: 'Theme toggled'),
              ),
              MECommand(
                label: 'Open settings',
                icon: Icons.settings_outlined,
                shortcut: 'Ctrl ,',
                onSelected: () =>
                    showMEToast(context, message: 'Settings opened'),
              ),
              MECommand(
                label: 'Share project',
                icon: Icons.share_outlined,
                keywords: const ['export', 'send'],
                onSelected: () => showMEToast(context, message: 'Share dialog'),
              ),
            ],
          ),
          child: const Text('Open command palette'),
        ),
        const SizedBox(height: 32),
        Text('Dock', style: title),
        const SizedBox(height: 8),
        Center(
          child: MEDock(
            items: [
              MEDockItem(
                icon: Icons.home_outlined,
                tooltip: 'Home',
                onPressed: () => showMEToast(context, message: 'Home'),
              ),
              MEDockItem(
                icon: Icons.search,
                tooltip: 'Search',
                onPressed: () => showMEToast(context, message: 'Search'),
              ),
              MEDockItem(
                icon: Icons.folder_outlined,
                tooltip: 'Files',
                onPressed: () => showMEToast(context, message: 'Files'),
              ),
              MEDockItem(
                icon: Icons.photo_outlined,
                tooltip: 'Photos',
                onPressed: () => showMEToast(context, message: 'Photos'),
              ),
              MEDockItem(
                icon: Icons.settings_outlined,
                tooltip: 'Settings',
                onPressed: () => showMEToast(context, message: 'Settings'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text('Tilt card', style: title),
        const SizedBox(height: 8),
        METiltCard(
          height: 180,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.threed_rotation,
                  size: 40,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  'Move your pointer over me',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  'Release and I spring back flat',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text('Story ring', style: title),
        const SizedBox(height: 8),
        Row(
          children: [
            MEStoryRing(
              segments: 3,
              seen: _storySeen,
              child: MEAvatar(
                size: 56,
                onPressed: () => setState(() => _storySeen = !_storySeen),
                child: const Text('AB'),
              ),
            ),
            const SizedBox(width: 16),
            MEStoryRing(
              segments: 1,
              seen: _storySeen,
              child: MEAvatar(
                size: 56,
                onPressed: () => setState(() => _storySeen = !_storySeen),
                child: const Text('CD'),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Tap to mark ${_storySeen ? 'unseen' : 'seen'}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text('Knob', style: title),
        const SizedBox(height: 8),
        Row(
          children: [
            MEKnob(
              value: _knobValue,
              onChanged: (v) => setState(() => _knobValue = v),
              label: const Icon(Icons.volume_up_outlined),
              semanticLabel: 'Volume',
            ),
            const SizedBox(width: 24),
            Text(
              'Volume ${(_knobValue * 100).round()}%',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text('Equalizer', style: title),
        const SizedBox(height: 8),
        MECard(
          onPressed: () => setState(() => _eqPlaying = !_eqPlaying),
          child: Row(
            children: [
              MEEqualizer(playing: _eqPlaying, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  _eqPlaying
                      ? 'Now playing — tap to pause'
                      : 'Paused — tap to play',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Icon(
                _eqPlaying ? Icons.pause : Icons.play_arrow,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text('Liquid progress', style: title),
        const SizedBox(height: 8),
        Column(
          children: [
            MELiquidProgress(
              value: _liquidValue,
              size: 130,
              label: Text('${(_liquidValue * 100).round()}%'),
              semanticLabel: 'Download progress',
            ),
            const SizedBox(height: 8),
            MEButton.text(
              onPressed: () => setState(() {
                _liquidValue = _liquidValue >= 0.9
                    ? 0.15
                    : (_liquidValue + 0.25).clamp(0.0, 1.0).toDouble();
              }),
              child: const Text('Add progress'),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text('Typewriter', style: title),
        const SizedBox(height: 8),
        METypewriter(
          phrases: const [
            'Build expressively.',
            'Ship with springs.',
            'Morph every shape.',
          ],
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 32),
        Text('Hold button', style: title),
        const SizedBox(height: 8),
        MEHoldButton(
          label: 'Hold to delete account',
          confirmedLabel: 'Account deleted',
          icon: const Icon(Icons.delete_outline),
          onConfirmed: () => showMEToast(
            context,
            message: 'Hold confirmed',
            kind: METoastKind.error,
          ),
        ),
        const SizedBox(height: 32),
        Text('Stopwatch', style: title),
        const SizedBox(height: 8),
        MEStopwatch(
          onLap: (elapsed) => showMEToast(
            context,
            message: 'Lap at ${elapsed.inSeconds}.'
                '${(elapsed.inMilliseconds % 1000) ~/ 100}s',
          ),
        ),
        const SizedBox(height: 32),
        Text('Joystick', style: title),
        const SizedBox(height: 8),
        Row(
          children: [
            MEJoystick(
              size: 140,
              onChanged: (v) => setState(() => _joystickValue = v),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Text(
                'x: ${_joystickValue.dx.toStringAsFixed(2)}\n'
                'y: ${_joystickValue.dy.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text('Flip clock', style: title),
        const SizedBox(height: 8),
        const Center(child: MEFlipClock()),
        const SizedBox(height: 32),
        Text('Spin wheel', style: title),
        const SizedBox(height: 8),
        Column(
          children: [
            MESpinWheel(
              controller: _spinController,
              segments: const [
                MESpinSegment(label: 'Coffee'),
                MESpinSegment(label: 'Tea'),
                MESpinSegment(label: 'Juice'),
                MESpinSegment(label: 'Water'),
                MESpinSegment(label: 'Soda'),
                MESpinSegment(label: 'Nothing'),
              ],
              onSettled: (i) => showMEToast(
                context,
                message: 'Landed on ${const [
                  'Coffee',
                  'Tea',
                  'Juice',
                  'Water',
                  'Soda',
                  'Nothing',
                ][i]}',
                kind: METoastKind.success,
              ),
            ),
            const SizedBox(height: 8),
            MEButton.tonal(
              onPressed: _spinController.spin,
              child: const Text('Spin'),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text('Scratch card', style: title),
        const SizedBox(height: 8),
        MEScratchCard(
          onRevealed: () => showMEToast(
            context,
            message: 'Prize revealed',
            kind: METoastKind.success,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.card_giftcard,
                  size: 40,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  'You won 20% off!',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text('Funnel chart', style: title),
        const SizedBox(height: 8),
        MEFunnelChart(
          stages: const [
            MEFunnelStage(value: 12400, label: 'Visitors'),
            MEFunnelStage(value: 6800, label: 'Sign-ups'),
            MEFunnelStage(value: 2900, label: 'Trials'),
            MEFunnelStage(value: 1150, label: 'Customers'),
          ],
        ),
        const SizedBox(height: 32),
        Text('Compass', style: title),
        const SizedBox(height: 8),
        Column(
          children: [
            MECompass(heading: _compassHeading),
            const SizedBox(height: 8),
            MEButton.text(
              onPressed: () => setState(() {
                _compassHeading = (_compassHeading + 137) % 360;
              }),
              child: const Text('New bearing'),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text('Dice', style: title),
        const SizedBox(height: 8),
        Row(
          children: [
            MEDice(
              onRolled: (v) => setState(() => _diceTotal += v),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Text(
                'Total rolled: $_diceTotal',
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text('Breathing ring', style: title),
        const SizedBox(height: 8),
        const Center(child: MEBreathingRing(size: 180)),
        const SizedBox(height: 32),
        Text('Stacked bar chart', style: title),
        const SizedBox(height: 8),
        const MEStackedBarChart(
          height: 180,
          seriesLabels: ['Direct', 'Referral', 'Social'],
          bars: [
            MEStackedBar(values: [40, 24, 10], label: 'Mon'),
            MEStackedBar(values: [55, 30, 14], label: 'Tue'),
            MEStackedBar(values: [38, 42, 20], label: 'Wed'),
            MEStackedBar(values: [64, 28, 12], label: 'Thu'),
            MEStackedBar(values: [50, 36, 26], label: 'Fri'),
          ],
        ),
        const SizedBox(height: 32),
        Text('Thermometer', style: title),
        const SizedBox(height: 8),
        Row(
          children: [
            METhermometer(
              value: _temperature,
              min: -10,
              max: 40,
              unit: '°C',
            ),
            const SizedBox(width: 16),
            MEButton.text(
              onPressed: () => setState(() {
                _temperature = _temperature >= 35 ? -5 : _temperature + 12;
              }),
              child: const Text('Change reading'),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text('Battery', style: title),
        const SizedBox(height: 8),
        Row(
          children: [
            MEBattery(
              value: _batteryLevel,
              charging: _batteryCharging,
            ),
            const SizedBox(width: 16),
            MEButton.text(
              onPressed: () => setState(() {
                _batteryLevel = _batteryLevel <= 0.15
                    ? 0.95
                    : (_batteryLevel - 0.25).clamp(0.0, 1.0).toDouble();
              }),
              child: const Text('Drain'),
            ),
            MEButton.text(
              onPressed: () =>
                  setState(() => _batteryCharging = !_batteryCharging),
              child: Text(_batteryCharging ? 'Unplug' : 'Charge'),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text('Coin flip', style: title),
        const SizedBox(height: 8),
        Row(
          children: [
            MECoinFlip(
              onFlipped: (heads) => setState(
                () => _coinResult = heads ? 'Heads' : 'Tails',
              ),
            ),
            const SizedBox(width: 24),
            Text(
              'Result: $_coinResult\nTap the coin to flip',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text('Slot machine', style: title),
        const SizedBox(height: 8),
        Center(
          child: MESlotMachine(
            onJackpot: () => showMEToast(
              context,
              message: 'Jackpot!',
              kind: METoastKind.success,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Tap the reels to spin',
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        const SizedBox(height: 32),
        Text('Metronome', style: title),
        const SizedBox(height: 8),
        const Center(child: MEMetronome(bpm: 96)),
        const SizedBox(height: 32),
        Text('Signal strength', style: title),
        const SizedBox(height: 8),
        Row(
          children: [
            MESignalStrength(
              level: _signalLevel,
              searching: _signalSearching,
            ),
            const SizedBox(width: 16),
            MEButton.text(
              onPressed: () => setState(() {
                _signalLevel = (_signalLevel + 1) % 5;
              }),
              child: const Text('Change level'),
            ),
            MEButton.text(
              onPressed: () => setState(
                () => _signalSearching = !_signalSearching,
              ),
              child: Text(_signalSearching ? 'Stop search' : 'Search'),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text('Credit card', style: title),
        const SizedBox(height: 8),
        const Center(
          child: MECreditCard(
            number: '4242424242424242',
            holder: 'Alex Rivera',
            expiry: '09/28',
            cvc: '314',
            brand: Text('Expressive'),
          ),
        ),
        const SizedBox(height: 32),
        Text('Orbit menu', style: title),
        const SizedBox(height: 8),
        Center(
          child: MEOrbitMenu(
            startAngle: 30,
            sweepAngle: 120,
            actions: [
              MEOrbitAction(
                icon: Icons.edit_outlined,
                tooltip: 'Edit',
                onPressed: () => showMEToast(context, message: 'Edit'),
              ),
              MEOrbitAction(
                icon: Icons.share_outlined,
                tooltip: 'Share',
                onPressed: () => showMEToast(context, message: 'Share'),
              ),
              MEOrbitAction(
                icon: Icons.delete_outline,
                tooltip: 'Delete',
                onPressed: () => showMEToast(context, message: 'Delete'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text('Sticky note', style: title),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            MEStickyNote(
              color: MEStickyNoteColor.tertiary,
              angle: -2,
              onPressed: () => showMEToast(context, message: 'Note tapped'),
              child: Text(
                'Pick up groceries\n\n- Oat milk\n- Coffee beans\n- Basil',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            MEStickyNote(
              color: MEStickyNoteColor.primary,
              angle: 1.5,
              onPressed: () => showMEToast(context, message: 'Note tapped'),
              child: Text(
                'Ship the widget batch by Friday!',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text('Mood picker', style: title),
        const SizedBox(height: 8),
        MEMoodPicker(
          value: _mood,
          onChanged: (i) => setState(() => _mood = i),
        ),
        const SizedBox(height: 32),
        Text('Streak flame', style: title),
        const SizedBox(height: 8),
        Row(
          children: [
            MEStreakFlame(count: _streak, active: _streakActive),
            const SizedBox(width: 16),
            MEButton.text(
              onPressed: () => setState(() => _streak += 1),
              child: const Text('+1 day'),
            ),
            MEButton.text(
              onPressed: () => setState(() => _streakActive = !_streakActive),
              child: Text(_streakActive ? 'Break streak' : 'Revive'),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text('Polaroid', style: title),
        const SizedBox(height: 8),
        Center(
          child: MEPolaroid(
            caption: 'Golden hour, June 2026',
            onPressed: () => showMEToast(context, message: 'Photo tapped'),
            child: ColoredBox(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.landscape_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text('Like button', style: title),
        const SizedBox(height: 8),
        Row(
          children: [
            MELikeButton(
              liked: _liked,
              count: _likeCount,
              onChanged: (v) => setState(() {
                _liked = v;
                _likeCount += v ? 1 : -1;
              }),
            ),
            const SizedBox(width: 16),
            Text(
              'Tap to ${_liked ? 'unlike' : 'like'}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text('VU meter', style: title),
        const SizedBox(height: 8),
        const Center(child: MEVuMeter(active: true, label: 'VU')),
        const SizedBox(height: 32),
        Text('Sonar', style: title),
        const SizedBox(height: 8),
        const Center(
          child: MESonar(
            blips: [
              MESonarBlip(angle: 40, distance: 0.55),
              MESonarBlip(angle: 130, distance: 0.35),
              MESonarBlip(angle: 210, distance: 0.8),
              MESonarBlip(angle: 300, distance: 0.6),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text('Day-night toggle', style: title),
        const SizedBox(height: 8),
        Row(
          children: [
            MEDayNightToggle(
              night: _night,
              onChanged: (v) => setState(() => _night = v),
            ),
            const SizedBox(width: 16),
            Text(
              _night ? 'Night mode' : 'Day mode',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text('Speedometer', style: title),
        const SizedBox(height: 8),
        Column(
          children: [
            MESpeedometer(
              value: _speed,
              max: 160,
              unit: 'km/h',
            ),
            const SizedBox(height: 8),
            MEButton.text(
              onPressed: () => setState(() {
                _speed = _speed >= 140 ? 20 : _speed + 45;
              }),
              child: const Text('Accelerate'),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text('Hourglass', style: title),
        const SizedBox(height: 8),
        Center(
          child: MEHourglass(
            duration: const Duration(seconds: 15),
            onEmpty: () => showMEToast(
              context,
              message: 'Time is up',
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Tap to flip and restart',
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        const SizedBox(height: 32),
        Text('Traffic light', style: title),
        const SizedBox(height: 8),
        Row(
          children: [
            METrafficLight(state: _trafficState),
            const SizedBox(width: 16),
            MEButton.tonal(
              onPressed: () => setState(() {
                _trafficState = METrafficState.values[
                    (_trafficState.index + 1) % METrafficState.values.length];
              }),
              child: const Text('Next state'),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text('Lock dial', style: title),
        const SizedBox(height: 8),
        Column(
          children: [
            MELockDial(
              onEntry: (n) => setState(() {
                _lockEntries.add(n);
                if (_lockEntries.length > 3) _lockEntries.removeAt(0);
              }),
            ),
            const SizedBox(height: 8),
            Text(
              _lockEntries.isEmpty
                  ? 'Drag the dial to enter a combination'
                  : 'Entries: ${_lockEntries.join(' - ')}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text('Bubble chart', style: title),
        const SizedBox(height: 8),
        const MEBubbleChart(
          bubbles: [
            MEBubble(x: 0.15, y: 0.6, size: 0.9, label: 'Web'),
            MEBubble(x: 0.4, y: 0.35, size: 0.6, label: 'iOS'),
            MEBubble(x: 0.6, y: 0.7, size: 0.75, label: 'Android'),
            MEBubble(x: 0.82, y: 0.4, size: 0.4, label: 'Mac'),
            MEBubble(x: 0.3, y: 0.85, size: 0.3),
            MEBubble(x: 0.72, y: 0.15, size: 0.25),
          ],
        ),
        const SizedBox(height: 32),
        Text('Candlestick chart', style: title),
        const SizedBox(height: 8),
        const MECandlestickChart(
          candles: [
            MECandle(open: 42, close: 48, high: 50, low: 40, label: 'Mon'),
            MECandle(open: 48, close: 45, high: 52, low: 44, label: 'Tue'),
            MECandle(open: 45, close: 53, high: 54, low: 43, label: 'Wed'),
            MECandle(open: 53, close: 51, high: 57, low: 49, label: 'Thu'),
            MECandle(open: 51, close: 59, high: 60, low: 50, label: 'Fri'),
            MECandle(open: 59, close: 56, high: 61, low: 54, label: 'Sat'),
            MECandle(open: 56, close: 62, high: 63, low: 55, label: 'Sun'),
          ],
        ),
        const SizedBox(height: 32),
        Text('Fireworks', style: title),
        const SizedBox(height: 8),
        MEFireworks(controller: _fireworksController),
        const SizedBox(height: 8),
        Center(
          child: MEButton.tonal(
            onPressed: () => _fireworksController.celebrate(),
            child: const Text('Celebrate'),
          ),
        ),
        const SizedBox(height: 32),
        Text('Stamp card', style: title),
        const SizedBox(height: 8),
        MEStampCard(
          total: 10,
          earned: _stampsEarned,
          title: Text(
            'Coffee club',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          onCompleted: () => showMEToast(
            context,
            message: 'Free coffee earned!',
            kind: METoastKind.success,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            MEButton.text(
              onPressed: _stampsEarned < 10
                  ? () => setState(() => _stampsEarned += 1)
                  : null,
              child: const Text('Add stamp'),
            ),
            MEButton.text(
              onPressed: () => setState(() => _stampsEarned = 0),
              child: const Text('Reset'),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text('Lava lamp', style: title),
        const SizedBox(height: 8),
        Center(
          child: MELavaLamp(
            width: 200,
            height: 260,
            child: Text(
              'Ambient',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text('Pomodoro', style: title),
        const SizedBox(height: 8),
        Center(
          child: MEPomodoro(
            focusDuration: const Duration(seconds: 20),
            breakDuration: const Duration(seconds: 8),
            onSessionEnd: (wasFocus) => showMEToast(
              context,
              message: wasFocus ? 'Focus done, take a break' : 'Back to work',
              kind: METoastKind.success,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text('Boarding pass', style: title),
        const SizedBox(height: 8),
        Center(
          child: MEBoardingPass(
            header: const Text('SFO -> NRT'),
            body: const Text('Alex Rivera\nGate B22 - Boarding 10:40'),
            stub: const Text('12A'),
            onTornOff: () => showMEToast(
              context,
              message: 'Checked in',
              kind: METoastKind.success,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Swipe the stub right to tear it off',
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        const SizedBox(height: 32),
        Text('Color wheel', style: title),
        const SizedBox(height: 8),
        Center(
          child: MEColorWheel(
            hue: _wheelHue,
            onChanged: (h) => setState(() => _wheelHue = h),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Hue: ${_wheelHue.round()} deg',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: 32),
        Text('Splash screen', style: title),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(MECorners.large),
          child: SizedBox(
            height: 320,
            child: MESplashScreen(
              key: ValueKey(_splashKey),
              logo: const Icon(Icons.auto_awesome),
              title: const Text('Expressive'),
              tagline: const Text('Material 3 Expressive for Flutter'),
              autoDismiss: false,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: MEButton.text(
            onPressed: () => setState(() => _splashKey++),
            child: const Text('Replay'),
          ),
        ),
        const SizedBox(height: 32),
        Text('PIN pad', style: title),
        const SizedBox(height: 8),
        Center(
          child: MEPinPad(
            controller: _pinController,
            onCompleted: (pin) {
              if (pin == '1234') {
                showMEToast(
                  context,
                  message: 'Unlocked',
                  kind: METoastKind.success,
                );
                _pinController.clear();
              } else {
                showMEToast(
                  context,
                  message: 'Wrong PIN, try 1234',
                  kind: METoastKind.error,
                );
                _pinController.reject();
              }
            },
          ),
        ),
        const SizedBox(height: 32),
        Text('Receipt', style: title),
        const SizedBox(height: 8),
        const Center(
          child: MEReceipt(
            header: Text('EXPRESSIVE CAFE'),
            lines: [
              MEReceiptLine('Flat white', '4.50'),
              MEReceiptLine('Croissant', '3.80'),
              MEReceiptLine('Sparkling water', '2.20'),
              MEReceiptLine.divider(),
              MEReceiptLine('Subtotal', '10.50'),
              MEReceiptLine('Tax', '0.95'),
              MEReceiptLine.divider(),
              MEReceiptLine('Total', '11.45', emphasized: true),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text('Vinyl', style: title),
        const SizedBox(height: 8),
        Center(
          child: MEVinyl(
            playing: _vinylPlaying,
            onChanged: (v) => setState(() => _vinylPlaying = v),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            _vinylPlaying ? 'Now spinning - tap to stop' : 'Tap to play',
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        const SizedBox(height: 32),
        Text('Morphing shape', style: title),
        const SizedBox(height: 8),
        Center(
          child: MEMorphingShape(
            size: 160,
            child: Icon(
              Icons.music_note,
              size: 48,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  MEChatGroupPosition _groupPosition(int i) {
    final current = _messages[i].outgoing;
    final prevSame = i > 0 && _messages[i - 1].outgoing == current;
    final nextSame =
        i < _messages.length - 1 && _messages[i + 1].outgoing == current;
    if (prevSame && nextSame) return MEChatGroupPosition.middle;
    if (prevSame) return MEChatGroupPosition.last;
    if (nextSame) return MEChatGroupPosition.first;
    return MEChatGroupPosition.single;
  }
}
