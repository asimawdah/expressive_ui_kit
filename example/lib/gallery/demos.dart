import 'package:flutter/material.dart';
import 'package:material3_expressive/material3_expressive.dart';

// Gallery demos include the deprecated [ExpressiveButton] so it can be tried.
// ignore_for_file: deprecated_member_use

class DemoMEButton extends StatelessWidget {
  const DemoMEButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        MEButton.filled(onPressed: () {}, child: const Text('Filled')),
        MEButton.tonal(onPressed: () {}, child: const Text('Tonal')),
        MEButton.elevated(onPressed: () {}, child: const Text('Elevated')),
        MEButton.outlined(onPressed: () {}, child: const Text('Outlined')),
        MEButton.text(onPressed: () {}, child: const Text('Text')),
        MEButton.filled(
          size: MEButtonSize.extraSmall,
          onPressed: () {},
          child: const Text('XS'),
        ),
        MEButton.filled(
          size: MEButtonSize.small,
          onPressed: () {},
          child: const Text('S'),
        ),
        MEButton.filled(
          size: MEButtonSize.medium,
          onPressed: () {},
          child: const Text('M'),
        ),
        MEButton.filled(
          size: MEButtonSize.large,
          icon: const Icon(Icons.send),
          onPressed: () {},
          child: const Text('L'),
        ),
        MEButton.filled(
          size: MEButtonSize.extraLarge,
          onPressed: () {},
          child: const Text('XL'),
        ),
      ],
    );
  }
}

class DemoExpressiveButton extends StatelessWidget {
  const DemoExpressiveButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ExpressiveButton(label: 'Filled', onPressed: () {}),
        ExpressiveButton(
          label: 'Tonal',
          style: ExpressiveButtonStyle.tonal,
          onPressed: () {},
        ),
        ExpressiveButton(
          label: 'Outlined',
          style: ExpressiveButtonStyle.outlined,
          onPressed: () {},
        ),
      ],
    );
  }
}

class DemoMEToggleButton extends StatefulWidget {
  const DemoMEToggleButton({super.key});
  @override
  State<DemoMEToggleButton> createState() => _DemoMEToggleButtonState();
}

class _DemoMEToggleButtonState extends State<DemoMEToggleButton> {
  bool _favorite = false;
  bool _bold = true;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        METoggleButton.filled(
          checked: _favorite,
          icon: const Icon(Icons.favorite_border),
          checkedIcon: const Icon(Icons.favorite),
          label: const Text('Favorite'),
          onCheckedChange: (v) => setState(() => _favorite = v),
        ),
        METoggleButton.text(
          checked: _bold,
          label: const Text('Bold'),
          onCheckedChange: (v) => setState(() => _bold = v),
        ),
        METoggleButton.outlined(
          checked: _favorite,
          icon: const Icon(Icons.star_border),
          checkedIcon: const Icon(Icons.star),
          onCheckedChange: (v) => setState(() => _favorite = v),
        ),
      ],
    );
  }
}

class DemoMEIconButton extends StatefulWidget {
  const DemoMEIconButton({super.key});
  @override
  State<DemoMEIconButton> createState() => _DemoMEIconButtonState();
}

class _DemoMEIconButtonState extends State<DemoMEIconButton> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      children: [
        MEIconButton(
          icon: const Icon(Icons.favorite_border),
          selectedIcon: const Icon(Icons.favorite),
          selected: _selected,
          onPressed: () => setState(() => _selected = !_selected),
        ),
        MEIconButton(
          variant: MEButtonVariant.filled,
          icon: const Icon(Icons.bookmark_border),
          onPressed: () {},
        ),
        MEIconButton(
          variant: MEButtonVariant.outlined,
          icon: const Icon(Icons.share),
          onPressed: () {},
        ),
      ],
    );
  }
}

class DemoMEButtonGroup extends StatefulWidget {
  const DemoMEButtonGroup({super.key});
  @override
  State<DemoMEButtonGroup> createState() => _DemoMEButtonGroupState();
}

class _DemoMEButtonGroupState extends State<DemoMEButtonGroup> {
  Set<int> _selected = {0};

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MEButtonGroup(
          style: MEButtonGroupStyle.connected,
          selectedIndices: _selected,
          onSelectionChanged: (s) => setState(() => _selected = s),
          items: const [
            MEButtonGroupItem(child: Text('Day')),
            MEButtonGroupItem(child: Text('Week')),
            MEButtonGroupItem(child: Text('Month')),
          ],
        ),
        const SizedBox(height: 16),
        MEButtonGroup(
          items: [
            MEButtonGroupItem(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {},
              child: const Text('Edit'),
            ),
            MEButtonGroupItem(
              icon: const Icon(Icons.share_outlined),
              onPressed: () {},
              child: const Text('Share'),
            ),
          ],
        ),
      ],
    );
  }
}

class DemoMESegmentedButton extends StatefulWidget {
  const DemoMESegmentedButton({super.key});
  @override
  State<DemoMESegmentedButton> createState() => _DemoMESegmentedButtonState();
}

class _DemoMESegmentedButtonState extends State<DemoMESegmentedButton> {
  Set<String> _units = const {'day'};

  @override
  Widget build(BuildContext context) {
    return MESegmentedButton<String>(
      segments: const [
        MESegment(value: 'day', label: Text('Day')),
        MESegment(value: 'week', label: Text('Week')),
        MESegment(value: 'month', label: Text('Month')),
      ],
      selected: _units,
      onSelectionChanged: (s) => setState(() => _units = s),
    );
  }
}

class DemoMESplitButton extends StatelessWidget {
  const DemoMESplitButton({super.key});

  @override
  Widget build(BuildContext context) {
    return MESplitButton(
      onPressed: () {},
      menu: const [
        MEMenuEntry(label: 'Save as draft', value: 'draft'),
        MEMenuEntry(label: 'Save a copy', value: 'copy'),
      ],
      onSelected: (_) {},
      child: const Text('Save'),
    );
  }
}

class DemoMEFab extends StatelessWidget {
  const DemoMEFab({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        MEFab(
          size: MEFabSize.small,
          onPressed: () {},
          icon: const Icon(Icons.edit),
        ),
        MEFab(onPressed: () {}, icon: const Icon(Icons.add)),
        MEFab(
          size: MEFabSize.large,
          onPressed: () {},
          icon: const Icon(Icons.create),
        ),
        MEFab.extended(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('Compose'),
        ),
      ],
    );
  }
}

class DemoMEFabMenu extends StatelessWidget {
  const DemoMEFabMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Stack(
        children: [
          Positioned(
            right: 8,
            bottom: 8,
            child: MEFabMenu(
              items: [
                MEFabMenuItem(
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Camera'),
                  onPressed: () {},
                ),
                MEFabMenuItem(
                  icon: const Icon(Icons.image_outlined),
                  label: const Text('Gallery'),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DemoMEFloatingToolbar extends StatefulWidget {
  const DemoMEFloatingToolbar({super.key});
  @override
  State<DemoMEFloatingToolbar> createState() => _DemoMEFloatingToolbarState();
}

class _DemoMEFloatingToolbarState extends State<DemoMEFloatingToolbar> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MEFloatingToolbar(
        selectedIndex: _index,
        onSelected: (i) => setState(() => _index = i),
        actions: const [
          METoolbarAction(icon: Icon(Icons.format_bold), tooltip: 'Bold'),
          METoolbarAction(icon: Icon(Icons.format_italic), tooltip: 'Italic'),
          METoolbarAction(icon: Icon(Icons.link), tooltip: 'Link'),
        ],
      ),
    );
  }
}

class DemoMEHoldButton extends StatelessWidget {
  const DemoMEHoldButton({super.key});

  @override
  Widget build(BuildContext context) {
    return MEHoldButton(
      label: 'Hold to delete',
      confirmedLabel: 'Deleted',
      icon: const Icon(Icons.delete_outline),
      onConfirmed: () => showMEToast(context, message: 'Confirmed'),
    );
  }
}

class DemoMELikeButton extends StatefulWidget {
  const DemoMELikeButton({super.key});
  @override
  State<DemoMELikeButton> createState() => _DemoMELikeButtonState();
}

class _DemoMELikeButtonState extends State<DemoMELikeButton> {
  bool _liked = false;
  int _count = 128;

  @override
  Widget build(BuildContext context) {
    return MELikeButton(
      liked: _liked,
      count: _count,
      onChanged: (v) => setState(() {
        _liked = v;
        _count += v ? 1 : -1;
      }),
    );
  }
}

class DemoMEOrbitMenu extends StatelessWidget {
  const DemoMEOrbitMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MEOrbitMenu(
        actions: [
          MEOrbitAction(
            icon: Icons.edit_outlined,
            onPressed: () {},
          ),
          MEOrbitAction(
            icon: Icons.share_outlined,
            onPressed: () {},
          ),
          MEOrbitAction(
            icon: Icons.delete_outline,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class DemoMEProgressButton extends StatelessWidget {
  const DemoMEProgressButton({super.key});

  @override
  Widget build(BuildContext context) {
    return MEProgressButton(
      icon: const Icon(Icons.cloud_upload_outlined),
      onPressed: () => Future<void>.delayed(const Duration(seconds: 2)),
      child: const Text('Upload'),
    );
  }
}

class DemoMEToolbar extends StatelessWidget {
  const DemoMEToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return METoolbar(
      children: [
        MEIconButton(icon: const Icon(Icons.format_bold), onPressed: () {}),
        MEIconButton(icon: const Icon(Icons.format_italic), onPressed: () {}),
        MEButton.filled(
          size: MEButtonSize.small,
          onPressed: () {},
          child: const Text('Done'),
        ),
      ],
    );
  }
}

class DemoMEActivityRings extends StatelessWidget {
  const DemoMEActivityRings({super.key});

  @override
  Widget build(BuildContext context) {
    return const MEActivityRings(
      showLegend: true,
      rings: [
        MEActivityRing(value: 0.85, label: 'Move'),
        MEActivityRing(value: 0.6, label: 'Exercise'),
        MEActivityRing(value: 0.4, label: 'Stand'),
      ],
    );
  }
}

class DemoMEBarChart extends StatelessWidget {
  const DemoMEBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return const MEBarChart(
      entries: [
        MEBarChartEntry(value: 12, label: 'Mon'),
        MEBarChartEntry(value: 18, label: 'Tue'),
        MEBarChartEntry(value: 9, label: 'Wed'),
        MEBarChartEntry(value: 24, label: 'Thu'),
      ],
    );
  }
}

class DemoMEBubbleChart extends StatelessWidget {
  const DemoMEBubbleChart({super.key});

  @override
  Widget build(BuildContext context) {
    return const MEBubbleChart(
      bubbles: [
        MEBubble(x: 0.2, y: 0.6, size: 0.9, label: 'Web'),
        MEBubble(x: 0.55, y: 0.35, size: 0.6, label: 'iOS'),
        MEBubble(x: 0.8, y: 0.7, size: 0.4, label: 'Mac'),
      ],
    );
  }
}

class DemoMECandlestickChart extends StatelessWidget {
  const DemoMECandlestickChart({super.key});

  @override
  Widget build(BuildContext context) {
    return const MECandlestickChart(
      candles: [
        MECandle(open: 42, close: 48, high: 50, low: 40, label: 'Mon'),
        MECandle(open: 48, close: 45, high: 52, low: 44, label: 'Tue'),
        MECandle(open: 45, close: 53, high: 54, low: 43, label: 'Wed'),
      ],
    );
  }
}

class DemoMEDonutChart extends StatelessWidget {
  const DemoMEDonutChart({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: MEDonutChart(
        segments: [
          MEDonutSegment(value: 42, label: 'Docs'),
          MEDonutSegment(value: 28, label: 'Photos'),
          MEDonutSegment(value: 18, label: 'Video'),
        ],
      ),
    );
  }
}

class DemoMEFunnelChart extends StatelessWidget {
  const DemoMEFunnelChart({super.key});

  @override
  Widget build(BuildContext context) {
    return MEFunnelChart(
      stages: const [
        MEFunnelStage(value: 12400, label: 'Visitors'),
        MEFunnelStage(value: 6800, label: 'Sign-ups'),
        MEFunnelStage(value: 1150, label: 'Customers'),
      ],
    );
  }
}

class DemoMEGauge extends StatelessWidget {
  const DemoMEGauge({super.key});

  @override
  Widget build(BuildContext context) {
    return const MEGauge(value: 0.72, label: Text('Storage'));
  }
}

class DemoMEHeatmap extends StatelessWidget {
  const DemoMEHeatmap({super.key});

  @override
  Widget build(BuildContext context) {
    return MEHeatmap(
      columns: 10,
      cells: [
        for (int i = 0; i < 40; i++)
          MEHeatmapCell(value: ((i * 7919) % 13).toDouble()),
      ],
    );
  }
}

class DemoMELineChart extends StatelessWidget {
  const DemoMELineChart({super.key});

  @override
  Widget build(BuildContext context) {
    return const MELineChart(
      series: [
        MELineSeries(values: [4, 7, 5, 10, 8, 13], label: 'Revenue'),
        MELineSeries(values: [3, 4, 6, 5, 7, 8], label: 'Costs'),
      ],
    );
  }
}

class DemoMERadarChart extends StatelessWidget {
  const DemoMERadarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MERadarChart(
        axes: const [
          MERadarAxis(label: 'Speed', value: 0.9),
          MERadarAxis(label: 'Power', value: 0.6),
          MERadarAxis(label: 'Range', value: 0.75),
          MERadarAxis(label: 'Agility', value: 0.85),
        ],
      ),
    );
  }
}

class DemoMESparkline extends StatelessWidget {
  const DemoMESparkline({super.key});

  @override
  Widget build(BuildContext context) {
    return const MESparkline(
      values: [3, 5, 4, 8, 6, 9, 7, 12],
      height: 72,
    );
  }
}

class DemoMESpeedometer extends StatelessWidget {
  const DemoMESpeedometer({super.key});

  @override
  Widget build(BuildContext context) {
    return const MESpeedometer(value: 42, max: 160, unit: 'km/h');
  }
}

class DemoMEStackedBarChart extends StatelessWidget {
  const DemoMEStackedBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return const MEStackedBarChart(
      height: 180,
      seriesLabels: ['Direct', 'Referral'],
      bars: [
        MEStackedBar(values: [40, 24], label: 'Mon'),
        MEStackedBar(values: [55, 30], label: 'Tue'),
        MEStackedBar(values: [38, 42], label: 'Wed'),
      ],
    );
  }
}

class DemoMEThermometer extends StatelessWidget {
  const DemoMEThermometer({super.key});

  @override
  Widget build(BuildContext context) {
    return const METhermometer(value: 22, min: -10, max: 40, unit: '°C');
  }
}

class DemoMEBadge extends StatefulWidget {
  const DemoMEBadge({super.key});
  @override
  State<DemoMEBadge> createState() => _DemoMEBadgeState();
}

class _DemoMEBadgeState extends State<DemoMEBadge> {
  int _count = 3;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24,
      children: [
        MEBadge(
          count: _count,
          child: MEIconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => setState(() => _count++),
          ),
        ),
        const MEBadge(
          showDot: true,
          alignment: MEBadgeAlignment.topLeft,
          child: Icon(Icons.mail_outline, size: 28),
        ),
        const MEBadge(count: 8, alignment: MEBadgeAlignment.topCenter),
      ],
    );
  }
}

class DemoMEBanner extends StatelessWidget {
  const DemoMEBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return MEBanner(
      icon: const Icon(Icons.wifi_off_outlined),
      content: const Text('You are offline.'),
      actions: [
        MEButton.text(onPressed: () {}, child: const Text('Retry')),
      ],
    );
  }
}

class DemoMEBattery extends StatefulWidget {
  const DemoMEBattery({super.key});
  @override
  State<DemoMEBattery> createState() => _DemoMEBatteryState();
}

class _DemoMEBatteryState extends State<DemoMEBattery> {
  final double _level = 0.68;
  bool _charging = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MEBattery(value: _level, charging: _charging),
        const SizedBox(width: 16),
        MEButton.text(
          onPressed: () => setState(() => _charging = !_charging),
          child: Text(_charging ? 'Unplug' : 'Charge'),
        ),
      ],
    );
  }
}

class DemoMECountdown extends StatelessWidget {
  DemoMECountdown({super.key});

  final DateTime _target =
      DateTime.now().add(const Duration(hours: 6, minutes: 30));

  @override
  Widget build(BuildContext context) => MECountdown(target: _target);
}

class DemoMEDivider extends StatelessWidget {
  const DemoMEDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Section A'),
        MEDivider(),
        Text('Section B'),
        MEDivider.full(),
        Row(
          children: [
            Text('Left'),
            MEDivider.vertical(),
            Text('Right'),
          ],
        ),
      ],
    );
  }
}

class DemoMEEqualizer extends StatefulWidget {
  const DemoMEEqualizer({super.key});
  @override
  State<DemoMEEqualizer> createState() => _DemoMEEqualizerState();
}

class _DemoMEEqualizerState extends State<DemoMEEqualizer> {
  bool _playing = true;

  @override
  Widget build(BuildContext context) {
    return MECard(
      onPressed: () => setState(() => _playing = !_playing),
      child: Row(
        children: [
          MEEqualizer(playing: _playing, size: 28),
          const SizedBox(width: 16),
          Text(_playing ? 'Playing' : 'Paused'),
        ],
      ),
    );
  }
}

class DemoMEFireworks extends StatefulWidget {
  const DemoMEFireworks({super.key});
  @override
  State<DemoMEFireworks> createState() => _DemoMEFireworksState();
}

class _DemoMEFireworksState extends State<DemoMEFireworks> {
  final MEFireworksController _controller = MEFireworksController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MEFireworks(controller: _controller),
        MEButton.tonal(
          onPressed: () => _controller.celebrate(),
          child: const Text('Celebrate'),
        ),
      ],
    );
  }
}

class DemoMEMarquee extends StatelessWidget {
  const DemoMEMarquee({super.key});

  @override
  Widget build(BuildContext context) {
    return MEMarquee(
      child: Text(
        'An Extraordinarily Long Song Title That Cannot Possibly Fit',
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }
}

class DemoMENumberTicker extends StatefulWidget {
  const DemoMENumberTicker({super.key});
  @override
  State<DemoMENumberTicker> createState() => _DemoMENumberTickerState();
}

class _DemoMENumberTickerState extends State<DemoMENumberTicker> {
  int _count = 1024;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MENumberTicker(
          value: _count,
          style: Theme.of(context).textTheme.displaySmall,
        ),
        MEIconButton(
          icon: const Icon(Icons.add),
          onPressed: () => setState(() => _count += 37),
        ),
      ],
    );
  }
}

class DemoMEPageIndicator extends StatefulWidget {
  const DemoMEPageIndicator({super.key});
  @override
  State<DemoMEPageIndicator> createState() => _DemoMEPageIndicatorState();
}

class _DemoMEPageIndicatorState extends State<DemoMEPageIndicator> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MEPageIndicator(
        count: 4,
        index: _page,
        onDotPressed: (i) => setState(() => _page = i),
      ),
    );
  }
}

class DemoMESignalStrength extends StatefulWidget {
  const DemoMESignalStrength({super.key});
  @override
  State<DemoMESignalStrength> createState() => _DemoMESignalStrengthState();
}

class _DemoMESignalStrengthState extends State<DemoMESignalStrength> {
  int _level = 3;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MESignalStrength(level: _level),
        MEButton.text(
          onPressed: () => setState(() => _level = (_level + 1) % 5),
          child: const Text('Change'),
        ),
      ],
    );
  }
}

class DemoMEStreakFlame extends StatefulWidget {
  const DemoMEStreakFlame({super.key});
  @override
  State<DemoMEStreakFlame> createState() => _DemoMEStreakFlameState();
}

class _DemoMEStreakFlameState extends State<DemoMEStreakFlame> {
  int _streak = 12;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MEStreakFlame(count: _streak),
        MEButton.text(
          onPressed: () => setState(() => _streak++),
          child: const Text('+1 day'),
        ),
      ],
    );
  }
}

class DemoMETrafficLight extends StatefulWidget {
  const DemoMETrafficLight({super.key});
  @override
  State<DemoMETrafficLight> createState() => _DemoMETrafficLightState();
}

class _DemoMETrafficLightState extends State<DemoMETrafficLight> {
  METrafficState _state = METrafficState.go;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        METrafficLight(state: _state),
        MEButton.tonal(
          onPressed: () => setState(() {
            _state = METrafficState
                .values[(_state.index + 1) % METrafficState.values.length];
          }),
          child: const Text('Next'),
        ),
      ],
    );
  }
}

class DemoMECompass extends StatefulWidget {
  const DemoMECompass({super.key});
  @override
  State<DemoMECompass> createState() => _DemoMECompassState();
}

class _DemoMECompassState extends State<DemoMECompass> {
  double _heading = 45;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MECompass(heading: _heading),
        MEButton.text(
          onPressed: () => setState(() => _heading = (_heading + 137) % 360),
          child: const Text('New bearing'),
        ),
      ],
    );
  }
}

class DemoShowMECoachmark extends StatefulWidget {
  const DemoShowMECoachmark({super.key});
  @override
  State<DemoShowMECoachmark> createState() => _DemoShowMECoachmarkState();
}

class _DemoShowMECoachmarkState extends State<DemoShowMECoachmark> {
  final GlobalKey _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MEButton.filled(
          key: _key,
          onPressed: () {},
          child: const Text('New feature'),
        ),
        const SizedBox(width: 12),
        MEButton.outlined(
          onPressed: () => showMECoachmark(
            context,
            targetKey: _key,
            title: 'Try the new feature',
            message: 'Shape morphing with a spatial spring.',
          ),
          child: const Text('Show coachmark'),
        ),
      ],
    );
  }
}

class DemoShowMESnackBar extends StatelessWidget {
  const DemoShowMESnackBar({super.key});

  @override
  Widget build(BuildContext context) {
    return MEButton.tonal(
      onPressed: () => showMESnackBar(
        context,
        message: 'Expressive snackbar',
        actionLabel: 'Undo',
      ),
      child: const Text('Show snackbar'),
    );
  }
}

class DemoShowMEToast extends StatelessWidget {
  const DemoShowMEToast({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        MEButton.tonal(
          onPressed: () => showMEToast(
            context,
            message: 'Saved',
            kind: METoastKind.success,
          ),
          child: const Text('Success'),
        ),
        MEButton.tonal(
          onPressed: () => showMEToast(
            context,
            message: 'Failed',
            kind: METoastKind.error,
          ),
          child: const Text('Error'),
        ),
      ],
    );
  }
}

class DemoMEAvatar extends StatefulWidget {
  const DemoMEAvatar({super.key});
  @override
  State<DemoMEAvatar> createState() => _DemoMEAvatarState();
}

class _DemoMEAvatarState extends State<DemoMEAvatar> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < 3; i++) ...[
          MEAvatar(
            selected: _selected == i,
            onPressed: () => setState(() => _selected = i),
            child: Text(String.fromCharCode(65 + i)),
          ),
          const SizedBox(width: 12),
        ],
      ],
    );
  }
}

class DemoMECard extends StatelessWidget {
  const DemoMECard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        MECard(child: Text('Filled card — press me')),
        SizedBox(height: 12),
        MECard.elevated(child: Text('Elevated card')),
        SizedBox(height: 12),
        MECard.outlined(child: Text('Outlined card')),
      ],
    );
  }
}

class DemoMECarousel extends StatelessWidget {
  const DemoMECarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return MECarousel(
      height: 160,
      children: [
        for (final color in [Colors.green, Colors.teal, Colors.amber])
          ColoredBox(color: color.shade200),
      ],
    );
  }
}

class DemoMEChip extends StatefulWidget {
  const DemoMEChip({super.key});
  @override
  State<DemoMEChip> createState() => _DemoMEChipState();
}

class _DemoMEChipState extends State<DemoMEChip> {
  final Set<int> _selected = {0};

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        MEChip(
          type: MEChipType.assist,
          icon: const Icon(Icons.edit),
          label: const Text('Assist'),
          onPressed: () {},
        ),
        for (var i = 0; i < 3; i++)
          MEChip(
            type: MEChipType.filter,
            label: Text(['Design', 'Motion', 'Shape'][i]),
            selected: _selected.contains(i),
            onPressed: () => setState(() {
              _selected.contains(i) ? _selected.remove(i) : _selected.add(i);
            }),
          ),
        MEChip(
          type: MEChipType.input,
          label: const Text('Flutter'),
          onPressed: () {},
          onDeleted: () {},
        ),
        MEChip(
          type: MEChipType.suggestion,
          label: const Text('Try wavy sliders'),
          onPressed: () {},
        ),
      ],
    );
  }
}

class DemoMEDialog extends StatelessWidget {
  const DemoMEDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return MEButton.tonal(
      onPressed: () => showMEDialog<void>(
        context: context,
        builder: (context) => MEDialog(
          icon: const Icon(Icons.celebration_outlined),
          title: const Text('Expressive dialog'),
          content: const Text('Spring-driven scale and shape morph.'),
          actions: [
            MEButton.text(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            MEButton.filled(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
      child: const Text('Show dialog'),
    );
  }
}

class DemoShowMEFullScreenDialog extends StatelessWidget {
  const DemoShowMEFullScreenDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return MEButton.tonal(
      onPressed: () => showMEFullScreenDialog<void>(
        context: context,
        title: const Text('New event'),
        body: const Padding(
          padding: EdgeInsets.all(24),
          child: Text('Full-screen dialog body.'),
        ),
      ),
      child: const Text('Open full-screen dialog'),
    );
  }
}

class DemoShowMESelectionDialog extends StatelessWidget {
  const DemoShowMESelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return MEButton.tonal(
      onPressed: () async {
        final picked = await showMESelectionDialog<String>(
          context: context,
          title: 'Choose a plan',
          options: const ['Standard', 'Pro', 'Team'],
        );
        if (context.mounted && picked != null) {
          showMEToast(context, message: 'Picked ${picked.join(', ')}');
        }
      },
      child: const Text('Open selection dialog'),
    );
  }
}

class DemoMEScratchCard extends StatelessWidget {
  const DemoMEScratchCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const MEScratchCard(
      child: Center(child: Text('You won 20% off!')),
    );
  }
}

class DemoMEFlipCard extends StatelessWidget {
  const DemoMEFlipCard({super.key});

  @override
  Widget build(BuildContext context) {
    return MEFlipCard(
      front: MEFlipCardFace(
        child:
            Text('Tap to flip', style: Theme.of(context).textTheme.titleMedium),
      ),
      back: MEFlipCardFace(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        child: Text('The back face',
            style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}

class DemoMEStoryRing extends StatefulWidget {
  const DemoMEStoryRing({super.key});
  @override
  State<DemoMEStoryRing> createState() => _DemoMEStoryRingState();
}

class _DemoMEStoryRingState extends State<DemoMEStoryRing> {
  bool _seen = false;

  @override
  Widget build(BuildContext context) {
    return MEStoryRing(
      segments: 3,
      seen: _seen,
      child: MEAvatar(
        size: 56,
        onPressed: () => setState(() => _seen = !_seen),
        child: const Text('AB'),
      ),
    );
  }
}

class DemoMESwipeDeck extends StatelessWidget {
  const DemoMESwipeDeck({super.key});

  @override
  Widget build(BuildContext context) {
    return MESwipeDeck(
      itemCount: 3,
      height: 220,
      itemBuilder: (context, i) => Center(child: Text('Card ${i + 1}')),
    );
  }
}

class DemoMEStampCard extends StatefulWidget {
  const DemoMEStampCard({super.key});
  @override
  State<DemoMEStampCard> createState() => _DemoMEStampCardState();
}

class _DemoMEStampCardState extends State<DemoMEStampCard> {
  int _earned = 6;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MEStampCard(
          total: 10,
          earned: _earned,
          title: const Text('Coffee club'),
        ),
        MEButton.text(
          onPressed: _earned < 10 ? () => setState(() => _earned++) : null,
          child: const Text('Add stamp'),
        ),
      ],
    );
  }
}

class DemoMECompareSlider extends StatelessWidget {
  const DemoMECompareSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return MECompareSlider(
      beforeLabel: 'Before',
      afterLabel: 'After',
      before: ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        child: const Center(child: Icon(Icons.crop_square, size: 48)),
      ),
      after: ColoredBox(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: const Center(child: Icon(Icons.auto_awesome, size: 48)),
      ),
    );
  }
}

class DemoShowMEBottomSheet extends StatelessWidget {
  const DemoShowMEBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return MEButton.tonal(
      onPressed: () => showMEBottomSheet<void>(
        context: context,
        builder: (context) => const Padding(
          padding: EdgeInsets.all(24),
          child: Text('An expressive bottom sheet.'),
        ),
      ),
      child: const Text('Open bottom sheet'),
    );
  }
}

class DemoShowMESideSheet extends StatelessWidget {
  const DemoShowMESideSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return MEButton.tonal(
      onPressed: () => showMESideSheet<void>(
        context: context,
        title: const Text('Filters'),
        builder: (context) => const Text('Side sheet content.'),
      ),
      child: const Text('Open side sheet'),
    );
  }
}

class DemoMEChat extends StatefulWidget {
  const DemoMEChat({super.key});
  @override
  State<DemoMEChat> createState() => _DemoMEChatState();
}

class _DemoMEChatState extends State<DemoMEChat> {
  final _messages = [
    (text: 'Tried the new widgets?', outgoing: false),
    (text: 'The springs feel great.', outgoing: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final m in _messages)
          MEChatBubble(
            text: m.text,
            outgoing: m.outgoing,
            animateIn: false,
          ),
        MEChatInput(
          onSend: (text) =>
              setState(() => _messages.add((text: text, outgoing: true))),
        ),
      ],
    );
  }
}

class DemoMECheckbox extends StatefulWidget {
  const DemoMECheckbox({super.key});
  @override
  State<DemoMECheckbox> createState() => _DemoMECheckboxState();
}

class _DemoMECheckboxState extends State<DemoMECheckbox> {
  bool _value = true;

  @override
  Widget build(BuildContext context) {
    return MECheckbox(
      value: _value,
      label: Text(_value ? 'Checked' : 'Unchecked'),
      onChanged: (v) => setState(() => _value = v ?? false),
    );
  }
}

class DemoMERadio extends StatefulWidget {
  const DemoMERadio({super.key});
  @override
  State<DemoMERadio> createState() => _DemoMERadioState();
}

class _DemoMERadioState extends State<DemoMERadio> {
  String _plan = 'pro';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MERadio<String>(
          value: 'free',
          groupValue: _plan,
          label: const Text('Free'),
          onChanged: (v) => setState(() => _plan = v),
        ),
        MERadio<String>(
          value: 'pro',
          groupValue: _plan,
          label: const Text('Pro'),
          onChanged: (v) => setState(() => _plan = v),
        ),
      ],
    );
  }
}

class DemoMESwitch extends StatefulWidget {
  const DemoMESwitch({super.key});
  @override
  State<DemoMESwitch> createState() => _DemoMESwitchState();
}

class _DemoMESwitchState extends State<DemoMESwitch> {
  bool _value = true;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MESwitch(
          value: _value,
          onChanged: (v) => setState(() => _value = v),
        ),
        const SizedBox(width: 12),
        Text(_value ? 'On' : 'Off'),
      ],
    );
  }
}

class DemoMESlider extends StatefulWidget {
  const DemoMESlider({super.key});
  @override
  State<DemoMESlider> createState() => _DemoMESliderState();
}

class _DemoMESliderState extends State<DemoMESlider> {
  double _standard = 0.4;
  double _wavy = 0.55;
  double _centered = 0;
  double _vertical = 0.6;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Standard'),
        MESlider(
          value: _standard,
          onChanged: (v) => setState(() => _standard = v),
        ),
        const SizedBox(height: 16),
        const Text('Wavy'),
        MESlider.wavy(
          value: _wavy,
          onChanged: (v) => setState(() => _wavy = v),
        ),
        const SizedBox(height: 16),
        const Text('Centered'),
        MESlider.centered(
          value: _centered,
          min: -1,
          max: 1,
          onChanged: (v) => setState(() => _centered = v),
        ),
        const SizedBox(height: 16),
        const Text('Vertical'),
        SizedBox(
          height: 160,
          child: MESlider.vertical(
            value: _vertical,
            onChanged: (v) => setState(() => _vertical = v),
          ),
        ),
      ],
    );
  }
}

class DemoMERangeSlider extends StatefulWidget {
  const DemoMERangeSlider({super.key});
  @override
  State<DemoMERangeSlider> createState() => _DemoMERangeSliderState();
}

class _DemoMERangeSliderState extends State<DemoMERangeSlider> {
  RangeValues _range = const RangeValues(0.2, 0.7);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MERangeSlider(
          values: _range,
          onChanged: (v) => setState(() => _range = v),
        ),
        MERangeSlider.wavy(
          values: _range,
          onChanged: (v) => setState(() => _range = v),
        ),
      ],
    );
  }
}

class DemoMERating extends StatefulWidget {
  const DemoMERating({super.key});
  @override
  State<DemoMERating> createState() => _DemoMERatingState();
}

class _DemoMERatingState extends State<DemoMERating> {
  double _value = 3.5;

  @override
  Widget build(BuildContext context) {
    return MERating(
      value: _value,
      onChanged: (v) => setState(() => _value = v),
    );
  }
}

class DemoMEQuantityStepper extends StatefulWidget {
  const DemoMEQuantityStepper({super.key});
  @override
  State<DemoMEQuantityStepper> createState() => _DemoMEQuantityStepperState();
}

class _DemoMEQuantityStepperState extends State<DemoMEQuantityStepper> {
  int _value = 2;

  @override
  Widget build(BuildContext context) {
    return MEQuantityStepper(
      value: _value,
      min: 1,
      max: 10,
      onChanged: (v) => setState(() => _value = v),
    );
  }
}

class DemoMEKnob extends StatefulWidget {
  const DemoMEKnob({super.key});
  @override
  State<DemoMEKnob> createState() => _DemoMEKnobState();
}

class _DemoMEKnobState extends State<DemoMEKnob> {
  double _value = 0.6;

  @override
  Widget build(BuildContext context) {
    return MEKnob(
      value: _value,
      onChanged: (v) => setState(() => _value = v),
      label: const Icon(Icons.volume_up_outlined),
    );
  }
}

class DemoMEJoystick extends StatefulWidget {
  const DemoMEJoystick({super.key});
  @override
  State<DemoMEJoystick> createState() => _DemoMEJoystickState();
}

class _DemoMEJoystickState extends State<DemoMEJoystick> {
  Offset _value = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MEJoystick(
          size: 140,
          onChanged: (v) => setState(() => _value = v),
        ),
        Text(
          'x ${_value.dx.toStringAsFixed(2)}\ny ${_value.dy.toStringAsFixed(2)}',
        ),
      ],
    );
  }
}

class DemoMEDayNightToggle extends StatefulWidget {
  const DemoMEDayNightToggle({super.key});
  @override
  State<DemoMEDayNightToggle> createState() => _DemoMEDayNightToggleState();
}

class _DemoMEDayNightToggleState extends State<DemoMEDayNightToggle> {
  bool _night = false;

  @override
  Widget build(BuildContext context) {
    return MEDayNightToggle(
      night: _night,
      onChanged: (v) => setState(() => _night = v),
    );
  }
}

class DemoMEMoodPicker extends StatefulWidget {
  const DemoMEMoodPicker({super.key});
  @override
  State<DemoMEMoodPicker> createState() => _DemoMEMoodPickerState();
}

class _DemoMEMoodPickerState extends State<DemoMEMoodPicker> {
  int? _mood = 3;

  @override
  Widget build(BuildContext context) {
    return MEMoodPicker(
      value: _mood,
      onChanged: (i) => setState(() => _mood = i),
    );
  }
}

class DemoMESpinWheel extends StatefulWidget {
  const DemoMESpinWheel({super.key});
  @override
  State<DemoMESpinWheel> createState() => _DemoMESpinWheelState();
}

class _DemoMESpinWheelState extends State<DemoMESpinWheel> {
  final MESpinWheelController _controller = MESpinWheelController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MESpinWheel(
          controller: _controller,
          segments: const [
            MESpinSegment(label: 'Coffee'),
            MESpinSegment(label: 'Tea'),
            MESpinSegment(label: 'Juice'),
          ],
        ),
        MEButton.tonal(
          onPressed: _controller.spin,
          child: const Text('Spin'),
        ),
      ],
    );
  }
}

class DemoMEVinyl extends StatefulWidget {
  const DemoMEVinyl({super.key});
  @override
  State<DemoMEVinyl> createState() => _DemoMEVinylState();
}

class _DemoMEVinylState extends State<DemoMEVinyl> {
  bool _playing = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MEVinyl(
        playing: _playing,
        onChanged: (v) => setState(() => _playing = v),
      ),
    );
  }
}

class DemoMEWaveform extends StatefulWidget {
  const DemoMEWaveform({super.key});
  @override
  State<DemoMEWaveform> createState() => _DemoMEWaveformState();
}

class _DemoMEWaveformState extends State<DemoMEWaveform> {
  double _progress = 0.3;

  @override
  Widget build(BuildContext context) {
    return MEWaveform(
      samples: [
        for (int i = 0; i < 48; i++) 0.2 + 0.8 * ((i * 17) % 100) / 100,
      ],
      progress: _progress,
      onChanged: (v) => setState(() => _progress = v),
    );
  }
}

class DemoMEWheelPicker extends StatefulWidget {
  const DemoMEWheelPicker({super.key});
  @override
  State<DemoMEWheelPicker> createState() => _DemoMEWheelPickerState();
}

class _DemoMEWheelPickerState extends State<DemoMEWheelPicker> {
  int _index = 2;

  @override
  Widget build(BuildContext context) {
    return MEWheelPicker(
      items: const ['XS', 'S', 'M', 'L', 'XL'],
      initialIndex: _index,
      onSelected: (i) => setState(() => _index = i),
    );
  }
}

class DemoMEColorPicker extends StatefulWidget {
  const DemoMEColorPicker({super.key});
  @override
  State<DemoMEColorPicker> createState() => _DemoMEColorPickerState();
}

class _DemoMEColorPickerState extends State<DemoMEColorPicker> {
  Color _color = const Color(0xFF6750A4);

  @override
  Widget build(BuildContext context) {
    return MEColorPicker(
      colors: const [
        Color(0xFF6750A4),
        Color(0xFF386A20),
        Color(0xFF9C4146),
        Color(0xFF006874),
      ],
      selected: _color,
      onChanged: (c) => setState(() => _color = c),
    );
  }
}

class DemoMEColorWheel extends StatefulWidget {
  const DemoMEColorWheel({super.key});
  @override
  State<DemoMEColorWheel> createState() => _DemoMEColorWheelState();
}

class _DemoMEColorWheelState extends State<DemoMEColorWheel> {
  double _hue = 210;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MEColorWheel(
          hue: _hue,
          onChanged: (h) => setState(() => _hue = h),
        ),
        Text('Hue ${_hue.round()}°'),
      ],
    );
  }
}

class DemoMETextField extends StatelessWidget {
  const DemoMETextField({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        METextField(
          label: 'Name',
          hintText: 'Jane Doe',
          helperText: 'Filled — focus to morph the shape',
        ),
        SizedBox(height: 16),
        METextField(
          label: 'Email',
          variant: METextFieldVariant.outlined,
          hintText: 'you@example.com',
        ),
      ],
    );
  }
}

class DemoMESearchAnchor extends StatelessWidget {
  const DemoMESearchAnchor({super.key});

  static const _names = ['Buttons', 'Slider', 'Dialog', 'Search', 'Cards'];

  @override
  Widget build(BuildContext context) {
    return MESearchAnchor.bar(
      barHintText: 'Search components',
      suggestionsBuilder: (context, controller) {
        final q = controller.text.toLowerCase();
        return [
          for (final name in _names.where((n) => n.toLowerCase().contains(q)))
            ListTile(
              title: Text(name),
              onTap: () => controller.closeView(name),
            ),
        ];
      },
    );
  }
}

class DemoMESearchAppBar extends StatelessWidget {
  const DemoMESearchAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: MESearchAppBar(
        hintText: 'Search mail',
        suggestionsBuilder: (context, controller) => [
          ListTile(
            title: const Text('Inbox'),
            onTap: () => controller.closeView('Inbox'),
          ),
        ],
      ),
    );
  }
}

class DemoMEAutocomplete extends StatelessWidget {
  const DemoMEAutocomplete({super.key});

  static const _fruits = ['Apple', 'Apricot', 'Banana', 'Cherry', 'Mango'];

  @override
  Widget build(BuildContext context) {
    return MEAutocomplete<String>(
      label: 'Fruit',
      hintText: 'Type to search',
      optionsBuilder: (value) {
        if (value.text.isEmpty) return const Iterable<String>.empty();
        return _fruits.where(
          (f) => f.toLowerCase().contains(value.text.toLowerCase()),
        );
      },
    );
  }
}

class DemoMETagInput extends StatefulWidget {
  const DemoMETagInput({super.key});
  @override
  State<DemoMETagInput> createState() => _DemoMETagInputState();
}

class _DemoMETagInputState extends State<DemoMETagInput> {
  List<String> _tags = ['flutter', 'material'];

  @override
  Widget build(BuildContext context) {
    return METagInput(
      tags: _tags,
      label: 'Topics',
      onChanged: (tags) => setState(() => _tags = tags),
    );
  }
}

class DemoMEListTile extends StatefulWidget {
  const DemoMEListTile({super.key});
  @override
  State<DemoMEListTile> createState() => _DemoMEListTileState();
}

class _DemoMEListTileState extends State<DemoMEListTile> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return MEListGroup(
      children: [
        for (var i = 0; i < 3; i++)
          MEListTile(
            leading: const Icon(Icons.folder_outlined),
            title: Text('Item ${i + 1}'),
            subtitle: const Text('Segmented tile'),
            trailing: const Icon(Icons.chevron_right),
            selected: _selected == i,
            onPressed: () => setState(() => _selected = i),
          ),
      ],
    );
  }
}

class DemoMECardList extends StatelessWidget {
  const DemoMECardList({super.key});

  @override
  Widget build(BuildContext context) {
    return MECardList(
      outlined: true,
      itemCount: 3,
      onTap: (_) {},
      itemBuilder: (context, i) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text(['Inbox', 'Starred', 'Snoozed'][i]),
      ),
    );
  }
}

class DemoMESelection extends StatefulWidget {
  const DemoMESelection({super.key});
  @override
  State<DemoMESelection> createState() => _DemoMESelectionState();
}

class _DemoMESelectionState extends State<DemoMESelection> {
  final MESelectionController _controller = MESelectionController();
  static const _items = ['Design spec', 'Motion notes', 'Shape tokens'];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360,
      child: MESelection(
        controller: _controller,
        itemCount: _items.length,
        appBar: MESelectionAppBar(
          controller: _controller,
          itemCount: _items.length,
          idle: const MESelectionIdleBar(title: Text('Inbox')),
        ),
        body: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            return ListView(
              padding: const EdgeInsets.all(12),
              children: [
                for (var i = 0; i < _items.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: MESelectionTile(
                      index: i,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            MESelectionLeading(
                              selected: _controller.isSelected(i),
                              onTap: () => _controller.toggle(i),
                              child: CircleAvatar(child: Text('${i + 1}')),
                            ),
                            const SizedBox(width: 16),
                            Text(_items[i]),
                          ],
                        ),
                      ),
                    ),
                  ),
                const Text('Long-press a row to enter selection.'),
              ],
            );
          },
        ),
      ),
    );
  }
}

class DemoMEDismissible extends StatefulWidget {
  const DemoMEDismissible({super.key});
  @override
  State<DemoMEDismissible> createState() => _DemoMEDismissibleState();
}

class _DemoMEDismissibleState extends State<DemoMEDismissible> {
  final List<String> _emails = ['Message 1', 'Message 2', 'Message 3'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final email in _emails)
          MEDismissible(
            dismissKey: ValueKey(email),
            onDismissed: (_) => setState(() => _emails.remove(email)),
            child: MEListTile(
              title: Text(email),
              onPressed: () {},
            ),
          ),
      ],
    );
  }
}

class DemoMEDismissibleColumn extends StatefulWidget {
  const DemoMEDismissibleColumn({super.key});
  @override
  State<DemoMEDismissibleColumn> createState() =>
      _DemoMEDismissibleColumnState();
}

class _DemoMEDismissibleColumnState extends State<DemoMEDismissibleColumn> {
  int _count = 3;

  @override
  Widget build(BuildContext context) {
    return MEDismissibleColumn(
      itemCount: _count,
      onDismiss: (i, _) async {
        setState(() => _count--);
        return true;
      },
      itemBuilder: (context, i) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Swipe to dismiss $i'),
      ),
    );
  }
}

class DemoMEDismissibleList extends StatelessWidget {
  const DemoMEDismissibleList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: MEDismissibleList(
        itemCount: 5,
        onDismiss: (i, _) async => true,
        itemBuilder: (context, i) => Center(child: Text('Card $i')),
      ),
    );
  }
}

class DemoMEExpandableList extends StatelessWidget {
  const DemoMEExpandableList({super.key});

  @override
  Widget build(BuildContext context) {
    return const MEExpandableList(
      data: [
        MEExpandableData(
          title: 'Battery level low',
          subtitle: 'Plug in your device.',
          body: Text('Your battery is at 10%.'),
          initiallyExpanded: true,
        ),
        MEExpandableData(
          title: 'Storage almost full',
          body: Text('Free up space in Settings.'),
        ),
      ],
    );
  }
}

class DemoMEDropdown extends StatefulWidget {
  const DemoMEDropdown({super.key});
  @override
  State<DemoMEDropdown> createState() => _DemoMEDropdownState();
}

class _DemoMEDropdownState extends State<DemoMEDropdown> {
  String? _flavor = 'vanilla';

  @override
  Widget build(BuildContext context) {
    return MEDropdown<String>(
      label: 'Flavor',
      value: _flavor,
      items: const [
        MEMenuItem(value: 'vanilla', label: 'Vanilla'),
        MEMenuItem(value: 'mint', label: 'Mint'),
        MEMenuItem(value: 'mocha', label: 'Mocha'),
      ],
      onChanged: (v) => setState(() => _flavor = v),
    );
  }
}

class DemoMEMenuAnchor extends StatelessWidget {
  const DemoMEMenuAnchor({super.key});

  @override
  Widget build(BuildContext context) {
    return MEMenu(
      anchorBuilder: (context, open) => MEButton.outlined(
        icon: const Icon(Icons.arrow_drop_down),
        onPressed: open,
        child: const Text('Open menu'),
      ),
      children: const [
        MEMenuGroup.entries(
          entries: [
            MEMenuEntry(
              label: 'Edit',
              leading: Icon(Icons.edit_outlined),
              value: 'edit',
            ),
            MEMenuEntry(label: 'Disabled', enabled: false),
          ],
        ),
        MEMenuGroup.entries(
          label: 'More',
          entries: [
            MEMenuEntry(
              label: 'Copy',
              trailingText: '⌘C',
              value: 'copy',
            ),
            MEMenuEntry(
              label: 'Share',
              leading: Icon(Icons.share_outlined),
              supportingText: 'Send a link',
              value: 'share',
            ),
          ],
        ),
      ],
      onSelected: (v) => showMEToast(context, message: '$v'),
    );
  }
}

class DemoMEPaginatedDataTable extends StatelessWidget {
  const DemoMEPaginatedDataTable({super.key});

  @override
  Widget build(BuildContext context) {
    return MEPaginatedDataTable(
      columns: const [
        DataColumn(label: Text('Widget')),
        DataColumn(label: Text('Category')),
      ],
      source: _Source(),
      rowsPerPage: 4,
      showCheckboxColumn: false,
    );
  }
}

class _Source extends DataTableSource {
  static const _rows = [
    ('MEButton', 'Buttons'),
    ('MESlider', 'Controls'),
    ('MECard', 'Containers'),
    ('MESearchAnchor', 'Inputs'),
    ('MESelection', 'Lists'),
  ];

  @override
  DataRow? getRow(int index) {
    if (index >= _rows.length) return null;
    return DataRow(cells: [
      DataCell(Text(_rows[index].$1)),
      DataCell(Text(_rows[index].$2)),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => _rows.length;
  @override
  int get selectedRowCount => 0;
}

class DemoMEReorderableList extends StatefulWidget {
  const DemoMEReorderableList({super.key});
  @override
  State<DemoMEReorderableList> createState() => _DemoMEReorderableListState();
}

class _DemoMEReorderableListState extends State<DemoMEReorderableList> {
  final _keys = List.generate(3, (i) => ValueKey('t$i'));
  final _labels = ['Review PR', 'Update docs', 'Ship RC'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: MEReorderableList(
        keys: _keys,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            final key = _keys.removeAt(oldIndex);
            final label = _labels.removeAt(oldIndex);
            _keys.insert(newIndex, key);
            _labels.insert(newIndex, label);
          });
        },
        itemBuilder: (context, index, position) => MEListTile(
          position: position,
          title: Text(_labels[index]),
        ),
      ),
    );
  }
}

class DemoMEStepper extends StatefulWidget {
  const DemoMEStepper({super.key});
  @override
  State<DemoMEStepper> createState() => _DemoMEStepperState();
}

class _DemoMEStepperState extends State<DemoMEStepper> {
  int _step = 1;

  @override
  Widget build(BuildContext context) {
    return MEStepper(
      currentStep: _step,
      onStepTapped: (i) => setState(() => _step = i),
      steps: const [
        MEStep(title: Text('Account'), content: Text('Account details')),
        MEStep(title: Text('Shipping'), content: Text('Address')),
        MEStep(title: Text('Payment'), content: Text('Card')),
      ],
    );
  }
}

class DemoMEAppBar extends StatelessWidget {
  const DemoMEAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: CustomScrollView(
        slivers: [
          const MEAppBar(
            title: Text('Inbox'),
            subtitle: Text('Flexible large app bar'),
            size: MEAppBarSize.medium,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Scroll this preview to collapse the bar.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DemoMEDrawer extends StatefulWidget {
  const DemoMEDrawer({super.key});
  @override
  State<DemoMEDrawer> createState() => _DemoMEDrawerState();
}

class _DemoMEDrawerState extends State<DemoMEDrawer> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: MEDrawer(
        header: const Text('Mail'),
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          MEDrawerDestination(icon: Icons.inbox, label: 'Inbox'),
          MEDrawerDestination(icon: Icons.send_outlined, label: 'Sent'),
          MEDrawerDestination(icon: Icons.star_outline, label: 'Starred'),
        ],
      ),
    );
  }
}

class DemoMENavigationBar extends StatefulWidget {
  const DemoMENavigationBar({super.key});
  @override
  State<DemoMENavigationBar> createState() => _DemoMENavigationBarState();
}

class _DemoMENavigationBarState extends State<DemoMENavigationBar> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return MENavigationBar(
      selectedIndex: _index,
      onDestinationSelected: (i) => setState(() => _index = i),
      destinations: const [
        MENavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        MENavigationDestination(icon: Icon(Icons.search), label: 'Search'),
        MENavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}

class DemoMENavigationRail extends StatefulWidget {
  const DemoMENavigationRail({super.key});
  @override
  State<DemoMENavigationRail> createState() => _DemoMENavigationRailState();
}

class _DemoMENavigationRailState extends State<DemoMENavigationRail> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Row(
        children: [
          MENavigationRail(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: const [
              MENavigationDestination(
                icon: Icon(Icons.home_outlined),
                label: 'Home',
              ),
              MENavigationDestination(
                  icon: Icon(Icons.search), label: 'Search'),
            ],
          ),
          Expanded(child: Center(child: Text('Destination ${_index + 1}'))),
        ],
      ),
    );
  }
}

class DemoMETabBar extends StatefulWidget {
  const DemoMETabBar({super.key});
  @override
  State<DemoMETabBar> createState() => _DemoMETabBarState();
}

class _DemoMETabBarState extends State<DemoMETabBar> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return METabBar(
      tabs: const [
        METab(label: 'Overview'),
        METab(label: 'Specs'),
        METab(label: 'Reviews'),
      ],
      selectedIndex: _tab,
      onSelected: (i) => setState(() => _tab = i),
    );
  }
}

class DemoShowMECommandPalette extends StatelessWidget {
  const DemoShowMECommandPalette({super.key});

  @override
  Widget build(BuildContext context) {
    return MEButton.outlined(
      icon: const Icon(Icons.keyboard_command_key),
      onPressed: () => showMECommandPalette(
        context,
        commands: [
          MECommand(
            label: 'New document',
            icon: Icons.note_add_outlined,
            onSelected: () {},
          ),
          MECommand(
            label: 'Open settings',
            icon: Icons.settings_outlined,
            onSelected: () {},
          ),
        ],
      ),
      child: const Text('Open command palette'),
    );
  }
}

class DemoMECalendar extends StatefulWidget {
  const DemoMECalendar({super.key});
  @override
  State<DemoMECalendar> createState() => _DemoMECalendarState();
}

class _DemoMECalendarState extends State<DemoMECalendar> {
  DateTime _date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return MECalendar(
      selectedDate: _date,
      onDateSelected: (d) => setState(() => _date = d),
    );
  }
}

class DemoMEDialTimePicker extends StatefulWidget {
  const DemoMEDialTimePicker({super.key});
  @override
  State<DemoMEDialTimePicker> createState() => _DemoMEDialTimePickerState();
}

class _DemoMEDialTimePickerState extends State<DemoMEDialTimePicker> {
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 30);

  @override
  Widget build(BuildContext context) {
    return MEDialTimePicker(
      value: _time,
      onChanged: (t) => setState(() => _time = t),
    );
  }
}

class DemoShowMEDatePicker extends StatelessWidget {
  const DemoShowMEDatePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return MEButton.tonal(
      onPressed: () => showMEDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
      ),
      child: const Text('Date picker'),
    );
  }
}

class DemoShowMEDateRangePicker extends StatelessWidget {
  const DemoShowMEDateRangePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return MEButton.tonal(
      onPressed: () => showMEDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
      ),
      child: const Text('Date range picker'),
    );
  }
}

class DemoShowMETimePicker extends StatelessWidget {
  const DemoShowMETimePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return MEButton.tonal(
      onPressed: () => showMETimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      ),
      child: const Text('Time picker'),
    );
  }
}

class DemoMEProgress extends StatefulWidget {
  const DemoMEProgress({super.key});
  @override
  State<DemoMEProgress> createState() => _DemoMEProgressState();
}

class _DemoMEProgressState extends State<DemoMEProgress> {
  double _value = 0.6;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MELinearProgressIndicator(value: _value),
        const SizedBox(height: 12),
        const MELinearProgressIndicator(),
        const SizedBox(height: 16),
        Row(
          children: [
            MECircularProgressIndicator(value: _value),
            const SizedBox(width: 24),
            const MECircularProgressIndicator(),
          ],
        ),
        MESlider(
          value: _value,
          onChanged: (v) => setState(() => _value = v),
        ),
      ],
    );
  }
}

class DemoMERefreshIndicator extends StatelessWidget {
  const DemoMERefreshIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: MERefreshIndicator(
        onRefresh: () => Future<void>.delayed(const Duration(seconds: 1)),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            ListTile(title: Text('Pull down to refresh')),
            ListTile(title: Text('Item 2')),
            ListTile(title: Text('Item 3')),
          ],
        ),
      ),
    );
  }
}

class DemoMESkeleton extends StatefulWidget {
  const DemoMESkeleton({super.key});
  @override
  State<DemoMESkeleton> createState() => _DemoMESkeletonState();
}

class _DemoMESkeletonState extends State<DemoMESkeleton> {
  bool _loading = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MESkeletonizer(
          loading: _loading,
          skeleton: const Row(
            children: [
              MESkeleton.circle(size: 48),
              SizedBox(width: 12),
              Expanded(child: MESkeleton.line()),
            ],
          ),
          child: const MEListTile(
            leading: MEAvatar(child: Text('M3')),
            title: Text('Content loaded'),
          ),
        ),
        MESwitch(
          value: _loading,
          onChanged: (v) => setState(() => _loading = v),
        ),
      ],
    );
  }
}

class DemoMESlivers extends StatelessWidget {
  const DemoMESlivers({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360,
      child: CustomScrollView(
        slivers: [
          const MEAppBar(title: Text('Slivers'), size: MEAppBarSize.medium),
          const MESliverSectionHeader(title: 'LIST'),
          MESliverList(
            itemCount: 4,
            itemBuilder: (context, i) => ListTile(title: Text('Item ${i + 1}')),
          ),
          const MESliverPinnedHeader(title: Text('PINNED')),
          MESliverGrid(
            itemCount: 4,
            crossAxisCount: 2,
            itemBuilder: (context, i) => Center(child: Text('Tile ${i + 1}')),
          ),
        ],
      ),
    );
  }
}

class DemoExpressiveIconContainer extends StatelessWidget {
  const DemoExpressiveIconContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: [
        for (final shape in ExpressiveShape.values)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExpressiveIconContainer(
                size: 64,
                shape: shape,
                child: Icon(
                  Icons.auto_awesome,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                shape.name,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
      ],
    );
  }
}

class DemoMETheme extends StatelessWidget {
  const DemoMETheme({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = METheme.of(context);
    final bounce = theme.motion.defaultSpatial.stiffness ==
        MEMotionScheme.expressive.defaultSpatial.stiffness;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          bounce
              ? 'Expressive springs (bounce on)'
              : 'Standard / reduced motion',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Switch expressive vs standard motion from the gallery drawer, '
          'then press the button to feel the spring.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        MEButton.filled(
          onPressed: () {},
          child: const Text('Press me'),
        ),
        const SizedBox(height: 24),
        Text(
          'Emphasized type',
          style: METypography.emphasize(
            Theme.of(context).textTheme.headlineSmall!,
          ),
        ),
      ],
    );
  }
}
