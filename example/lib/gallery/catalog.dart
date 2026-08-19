import 'package:flutter/material.dart';
import 'package:material3_expressive/material3_expressive.dart';

import 'demos.dart';

class CatalogEntry {
  const CatalogEntry({
    required this.name,
    required this.replaces,
    required this.category,
    required this.demo,
  });

  final String name;
  final String replaces;
  final String category;
  final WidgetBuilder demo;
}

final List<CatalogEntry> kCatalog = [
  // Buttons
  CatalogEntry(
      name: 'MEButton',
      replaces: 'ElevatedButton / FilledButton',
      category: 'Buttons',
      demo: (_) => const DemoMEButton()),
  CatalogEntry(
      name: 'ExpressiveButton',
      replaces: 'legacy MEButton',
      category: 'Buttons',
      demo: (_) => const DemoExpressiveButton()),
  CatalogEntry(
      name: 'METoggleButton',
      replaces: 'Toggleable filled/tonal buttons',
      category: 'Buttons',
      demo: (_) => const DemoMEToggleButton()),
  CatalogEntry(
      name: 'MEIconButton',
      replaces: 'IconButton',
      category: 'Buttons',
      demo: (_) => const DemoMEIconButton()),
  CatalogEntry(
      name: 'MEButtonGroup',
      replaces: 'Toggle button rows',
      category: 'Buttons',
      demo: (_) => const DemoMEButtonGroup()),
  CatalogEntry(
      name: 'MESegmentedButton',
      replaces: 'SegmentedButton',
      category: 'Buttons',
      demo: (_) => const DemoMESegmentedButton()),
  CatalogEntry(
      name: 'MESplitButton',
      replaces: 'Primary action + menu',
      category: 'Buttons',
      demo: (_) => const DemoMESplitButton()),
  CatalogEntry(
      name: 'MEFab',
      replaces: 'FloatingActionButton',
      category: 'Buttons',
      demo: (_) => const DemoMEFab()),
  CatalogEntry(
      name: 'MEFab.extended',
      replaces: 'FloatingActionButton.extended',
      category: 'Buttons',
      demo: (_) => const DemoMEFab()),
  CatalogEntry(
      name: 'MEFabMenu',
      replaces: 'Speed dial',
      category: 'Buttons',
      demo: (_) => const DemoMEFabMenu()),
  CatalogEntry(
      name: 'MEFloatingToolbar',
      replaces: '—',
      category: 'Buttons',
      demo: (_) => const DemoMEFloatingToolbar()),
  CatalogEntry(
      name: 'MEHoldButton',
      replaces: '—',
      category: 'Buttons',
      demo: (_) => const DemoMEHoldButton()),
  CatalogEntry(
      name: 'MELikeButton',
      replaces: '—',
      category: 'Buttons',
      demo: (_) => const DemoMELikeButton()),
  CatalogEntry(
      name: 'MEOrbitMenu',
      replaces: '—',
      category: 'Buttons',
      demo: (_) => const DemoMEOrbitMenu()),
  CatalogEntry(
      name: 'MEProgressButton',
      replaces: '—',
      category: 'Buttons',
      demo: (_) => const DemoMEProgressButton()),
  CatalogEntry(
      name: 'METoolbar',
      replaces: 'Floating action clusters',
      category: 'Buttons',
      demo: (_) => const DemoMEToolbar()),
  // Charts
  CatalogEntry(
      name: 'MEActivityRings',
      replaces: '—',
      category: 'Charts',
      demo: (_) => const DemoMEActivityRings()),
  CatalogEntry(
      name: 'MEBarChart',
      replaces: '—',
      category: 'Charts',
      demo: (_) => const DemoMEBarChart()),
  CatalogEntry(
      name: 'MEBubbleChart',
      replaces: '—',
      category: 'Charts',
      demo: (_) => const DemoMEBubbleChart()),
  CatalogEntry(
      name: 'MECandlestickChart',
      replaces: '—',
      category: 'Charts',
      demo: (_) => const DemoMECandlestickChart()),
  CatalogEntry(
      name: 'MEDonutChart',
      replaces: '—',
      category: 'Charts',
      demo: (_) => const DemoMEDonutChart()),
  CatalogEntry(
      name: 'MEFunnelChart',
      replaces: '—',
      category: 'Charts',
      demo: (_) => const DemoMEFunnelChart()),
  CatalogEntry(
      name: 'MEGauge',
      replaces: '—',
      category: 'Charts',
      demo: (_) => const DemoMEGauge()),
  CatalogEntry(
      name: 'MEHeatmap',
      replaces: '—',
      category: 'Charts',
      demo: (_) => const DemoMEHeatmap()),
  CatalogEntry(
      name: 'MELineChart',
      replaces: '—',
      category: 'Charts',
      demo: (_) => const DemoMELineChart()),
  CatalogEntry(
      name: 'MERadarChart',
      replaces: '—',
      category: 'Charts',
      demo: (_) => const DemoMERadarChart()),
  CatalogEntry(
      name: 'MESparkline',
      replaces: '—',
      category: 'Charts',
      demo: (_) => const DemoMESparkline()),
  CatalogEntry(
      name: 'MESpeedometer',
      replaces: '—',
      category: 'Charts',
      demo: (_) => const DemoMESpeedometer()),
  CatalogEntry(
      name: 'MEStackedBarChart',
      replaces: '—',
      category: 'Charts',
      demo: (_) => const DemoMEStackedBarChart()),
  CatalogEntry(
      name: 'METhermometer',
      replaces: '—',
      category: 'Charts',
      demo: (_) => const DemoMEThermometer()),
  // Communication
  CatalogEntry(
      name: 'MEBadge',
      replaces: 'Badge',
      category: 'Communication',
      demo: (_) => const DemoMEBadge()),
  CatalogEntry(
      name: 'MEBanner',
      replaces: 'MaterialBanner',
      category: 'Communication',
      demo: (_) => const DemoMEBanner()),
  CatalogEntry(
      name: 'MEBattery',
      replaces: '—',
      category: 'Communication',
      demo: (_) => const DemoMEBattery()),
  CatalogEntry(
      name: 'MEBreathingRing',
      replaces: '—',
      category: 'Communication',
      demo: (_) => const Center(child: MEBreathingRing(size: 180))),
  CatalogEntry(
      name: 'MECountdown',
      replaces: '—',
      category: 'Communication',
      demo: (_) => DemoMECountdown()),
  CatalogEntry(
      name: 'MEDivider',
      replaces: 'Divider / VerticalDivider',
      category: 'Communication',
      demo: (_) => const DemoMEDivider()),
  CatalogEntry(
      name: 'MEEqualizer',
      replaces: '—',
      category: 'Communication',
      demo: (_) => const DemoMEEqualizer()),
  CatalogEntry(
      name: 'MEFireworks',
      replaces: '—',
      category: 'Communication',
      demo: (_) => const DemoMEFireworks()),
  CatalogEntry(
      name: 'MEFlipClock',
      replaces: '—',
      category: 'Communication',
      demo: (_) => const Center(child: MEFlipClock())),
  CatalogEntry(
      name: 'MEHourglass',
      replaces: '—',
      category: 'Communication',
      demo: (_) =>
          const Center(child: MEHourglass(duration: Duration(seconds: 15)))),
  CatalogEntry(
      name: 'MELavaLamp',
      replaces: '—',
      category: 'Communication',
      demo: (_) => const Center(child: MELavaLamp(width: 200, height: 260))),
  CatalogEntry(
      name: 'MEMarquee',
      replaces: '—',
      category: 'Communication',
      demo: (_) => const DemoMEMarquee()),
  CatalogEntry(
      name: 'MENumberTicker',
      replaces: '—',
      category: 'Communication',
      demo: (_) => const DemoMENumberTicker()),
  CatalogEntry(
      name: 'MEPageIndicator',
      replaces: '—',
      category: 'Communication',
      demo: (_) => const DemoMEPageIndicator()),
  CatalogEntry(
      name: 'MEPomodoro',
      replaces: '—',
      category: 'Communication',
      demo: (_) => const Center(
            child: MEPomodoro(
              focusDuration: Duration(seconds: 20),
              breakDuration: Duration(seconds: 8),
            ),
          )),
  CatalogEntry(
      name: 'MESignalStrength',
      replaces: '—',
      category: 'Communication',
      demo: (_) => const DemoMESignalStrength()),
  CatalogEntry(
      name: 'MESonar',
      replaces: '—',
      category: 'Communication',
      demo: (_) => const Center(
            child: MESonar(blips: [
              MESonarBlip(angle: 40, distance: 0.55),
              MESonarBlip(angle: 210, distance: 0.8),
            ]),
          )),
  CatalogEntry(
      name: 'MEStopwatch',
      replaces: '—',
      category: 'Communication',
      demo: (_) => const MEStopwatch()),
  CatalogEntry(
      name: 'MEStreakFlame',
      replaces: '—',
      category: 'Communication',
      demo: (_) => const DemoMEStreakFlame()),
  CatalogEntry(
      name: 'MESuccessCheck',
      replaces: '—',
      category: 'Communication',
      demo: (_) => const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MESuccessCheck(size: 88),
              MESuccessCheck.error(size: 88),
            ],
          )),
  CatalogEntry(
      name: 'METooltip',
      replaces: 'Tooltip',
      category: 'Communication',
      demo: (_) => const Center(
            child: METooltip(
              message: 'Expressive tooltip',
              child: Icon(Icons.help_outline, size: 36),
            ),
          )),
  CatalogEntry(
      name: 'METrafficLight',
      replaces: '—',
      category: 'Communication',
      demo: (_) => const DemoMETrafficLight()),
  CatalogEntry(
      name: 'METypewriter',
      replaces: '—',
      category: 'Communication',
      demo: (context) => METypewriter(
            phrases: const ['Build expressively.', 'Ship with springs.'],
            style: Theme.of(context).textTheme.headlineSmall,
          )),
  CatalogEntry(
      name: 'MEVuMeter',
      replaces: '—',
      category: 'Communication',
      demo: (_) => const Center(child: MEVuMeter(active: true, label: 'VU'))),
  CatalogEntry(
      name: 'MECompass',
      replaces: '—',
      category: 'Communication',
      demo: (_) => const DemoMECompass()),
  CatalogEntry(
      name: 'showMECoachmark',
      replaces: '—',
      category: 'Communication',
      demo: (_) => const DemoShowMECoachmark()),
  CatalogEntry(
      name: 'showMESnackBar',
      replaces: 'SnackBar',
      category: 'Communication',
      demo: (_) => const DemoShowMESnackBar()),
  CatalogEntry(
      name: 'showMEToast',
      replaces: '—',
      category: 'Communication',
      demo: (_) => const DemoShowMEToast()),
  // Containers
  CatalogEntry(
      name: 'MEAvatar',
      replaces: 'CircleAvatar',
      category: 'Containers',
      demo: (_) => const DemoMEAvatar()),
  CatalogEntry(
      name: 'ExpressiveIconContainer',
      replaces: 'cookie-shaped icon well',
      category: 'Containers',
      demo: (_) => const DemoExpressiveIconContainer()),
  CatalogEntry(
      name: 'MEAvatarGroup',
      replaces: 'CircleAvatar group',
      category: 'Containers',
      demo: (_) => MEAvatarGroup(
            avatars: [
              for (var i = 0; i < 6; i++)
                MEAvatar(child: Text(String.fromCharCode(65 + i))),
            ],
          )),
  CatalogEntry(
      name: 'MEBoardingPass',
      replaces: '—',
      category: 'Containers',
      demo: (_) => const Center(
            child: MEBoardingPass(
              header: Text('SFO -> NRT'),
              body: Text('Alex Rivera\nGate B22'),
              stub: Text('12A'),
            ),
          )),
  CatalogEntry(
      name: 'MECard',
      replaces: 'Card',
      category: 'Containers',
      demo: (_) => const DemoMECard()),
  CatalogEntry(
      name: 'MECarousel',
      replaces: 'CarouselView',
      category: 'Containers',
      demo: (_) => const DemoMECarousel()),
  CatalogEntry(
      name: 'MEChip',
      replaces: 'Chip / FilterChip / InputChip',
      category: 'Containers',
      demo: (_) => const DemoMEChip()),
  CatalogEntry(
      name: 'MECreditCard',
      replaces: '—',
      category: 'Containers',
      demo: (_) => const Center(
            child: MECreditCard(
              number: '4242424242424242',
              holder: 'Alex Rivera',
              expiry: '09/28',
              cvc: '314',
            ),
          )),
  CatalogEntry(
      name: 'MEDialog',
      replaces: 'AlertDialog',
      category: 'Containers',
      demo: (_) => const DemoMEDialog()),
  CatalogEntry(
      name: 'showMEFullScreenDialog',
      replaces: 'fullscreen dialog',
      category: 'Containers',
      demo: (_) => const DemoShowMEFullScreenDialog()),
  CatalogEntry(
      name: 'showMESelectionDialog',
      replaces: 'selection dialog',
      category: 'Containers',
      demo: (_) => const DemoShowMESelectionDialog()),
  CatalogEntry(
      name: 'MEEmptyState',
      replaces: '—',
      category: 'Containers',
      demo: (_) => MEEmptyState(
            icon: Icons.inbox_outlined,
            title: const Text('No messages yet'),
            action: MEButton.tonal(
                onPressed: () {}, child: const Text('Start a conversation')),
          )),
  CatalogEntry(
      name: 'MEFileCard',
      replaces: '—',
      category: 'Containers',
      demo: (_) => MEFileCard(
            name: 'annual-report.pdf',
            size: '2.4 MB',
            onPressed: () {},
          )),
  CatalogEntry(
      name: 'MEFlipCard',
      replaces: '—',
      category: 'Containers',
      demo: (_) => const DemoMEFlipCard()),
  CatalogEntry(
      name: 'MEImage',
      replaces: 'Image.network',
      category: 'Containers',
      demo: (_) => const MEImage(
            url: 'https://picsum.photos/seed/me/640/360',
            height: 180,
          )),
  CatalogEntry(
      name: 'MEMorphingShape',
      replaces: '—',
      category: 'Containers',
      demo: (context) => Center(
            child: MEMorphingShape(
              size: 160,
              child: Icon(Icons.music_note,
                  size: 48,
                  color: Theme.of(context).colorScheme.onPrimaryContainer),
            ),
          )),
  CatalogEntry(
      name: 'MEPolaroid',
      replaces: '—',
      category: 'Containers',
      demo: (_) => const Center(
            child: MEPolaroid(
              caption: 'Golden hour',
              child: SizedBox(
                height: 140,
                child: ColoredBox(color: Color(0xFFC8E6C9)),
              ),
            ),
          )),
  CatalogEntry(
      name: 'MEReceipt',
      replaces: '—',
      category: 'Containers',
      demo: (_) => const Center(
            child: MEReceipt(lines: [
              MEReceiptLine('Flat white', '4.50'),
              MEReceiptLine('Total', '4.50', emphasized: true),
            ]),
          )),
  CatalogEntry(
      name: 'MEScratchCard',
      replaces: '—',
      category: 'Containers',
      demo: (_) => const DemoMEScratchCard()),
  CatalogEntry(
      name: 'MESplashScreen',
      replaces: '—',
      category: 'Containers',
      demo: (_) => const SizedBox(
            height: 280,
            child: MESplashScreen(
              autoDismiss: false,
              logo: Icon(Icons.auto_awesome),
              title: Text('Expressive'),
            ),
          )),
  CatalogEntry(
      name: 'MEStatCard',
      replaces: '—',
      category: 'Containers',
      demo: (_) => const MEStatCard(
            label: Text('Revenue'),
            icon: Icons.payments_outlined,
            value: 48250,
            prefix: r'$',
            delta: 12.4,
            sparkline: [8, 10, 9, 14, 12, 16],
          )),
  CatalogEntry(
      name: 'MEStickyNote',
      replaces: '—',
      category: 'Containers',
      demo: (context) => MEStickyNote(
            child: Text('Pick up groceries',
                style: Theme.of(context).textTheme.bodyMedium),
          )),
  CatalogEntry(
      name: 'MEStoryRing',
      replaces: '—',
      category: 'Containers',
      demo: (_) => const DemoMEStoryRing()),
  CatalogEntry(
      name: 'MESwipeDeck',
      replaces: '—',
      category: 'Containers',
      demo: (_) => const DemoMESwipeDeck()),
  CatalogEntry(
      name: 'METiltCard',
      replaces: '—',
      category: 'Containers',
      demo: (_) => const METiltCard(
            height: 160,
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('Move your pointer over me'),
            ),
          )),
  CatalogEntry(
      name: 'MEStampCard',
      replaces: '—',
      category: 'Containers',
      demo: (_) => const DemoMEStampCard()),
  CatalogEntry(
      name: 'MECompareSlider',
      replaces: '—',
      category: 'Containers',
      demo: (_) => const DemoMECompareSlider()),
  CatalogEntry(
      name: 'showMEDialog',
      replaces: 'showDialog',
      category: 'Containers',
      demo: (_) => const DemoMEDialog()),
  CatalogEntry(
      name: 'showMEBottomSheet',
      replaces: 'showModalBottomSheet',
      category: 'Containers',
      demo: (_) => const DemoShowMEBottomSheet()),
  CatalogEntry(
      name: 'showMESideSheet',
      replaces: '—',
      category: 'Containers',
      demo: (_) => const DemoShowMESideSheet()),
  // Content
  CatalogEntry(
      name: 'MEChatBubble',
      replaces: '—',
      category: 'Content',
      demo: (_) => const DemoMEChat()),
  CatalogEntry(
      name: 'MEChatInput',
      replaces: '—',
      category: 'Content',
      demo: (_) => const DemoMEChat()),
  CatalogEntry(
      name: 'MEChatTypingIndicator',
      replaces: '—',
      category: 'Content',
      demo: (_) => const Align(
            alignment: Alignment.centerLeft,
            child: MEChatTypingIndicator(),
          )),
  CatalogEntry(
      name: 'MECodeView',
      replaces: '—',
      category: 'Content',
      demo: (_) => const MECodeView(
            code:
                "MEButton.filled(\n  onPressed: () {},\n  child: Text('Hi'),\n)",
            language: 'dart',
          )),
  CatalogEntry(
      name: 'MEMarkdown',
      replaces: '—',
      category: 'Content',
      demo: (_) => const MEMarkdown(
            data: '# Expressive\nSpring **motion** and *shape* morphing.',
          )),
  CatalogEntry(
      name: 'MEMarkdownEditor',
      replaces: '—',
      category: 'Content',
      demo: (_) => const MEMarkdownEditor(hintText: 'Write markdown…')),
  // Controls
  CatalogEntry(
      name: 'MECheckbox',
      replaces: 'Checkbox',
      category: 'Controls',
      demo: (_) => const DemoMECheckbox()),
  CatalogEntry(
      name: 'MERadio',
      replaces: 'Radio',
      category: 'Controls',
      demo: (_) => const DemoMERadio()),
  CatalogEntry(
      name: 'MESwitch',
      replaces: 'Switch',
      category: 'Controls',
      demo: (_) => const DemoMESwitch()),
  CatalogEntry(
      name: 'MESlider',
      replaces: 'Slider',
      category: 'Controls',
      demo: (_) => const DemoMESlider()),
  CatalogEntry(
      name: 'MERangeSlider',
      replaces: 'RangeSlider',
      category: 'Controls',
      demo: (_) => const DemoMERangeSlider()),
  CatalogEntry(
      name: 'MERating',
      replaces: '—',
      category: 'Controls',
      demo: (_) => const DemoMERating()),
  CatalogEntry(
      name: 'MEQuantityStepper',
      replaces: '—',
      category: 'Controls',
      demo: (_) => const DemoMEQuantityStepper()),
  CatalogEntry(
      name: 'MESlideToConfirm',
      replaces: '—',
      category: 'Controls',
      demo: (_) => MESlideToConfirm(
            label: 'Slide to confirm',
            onConfirmed: () {},
          )),
  CatalogEntry(
      name: 'MEKnob',
      replaces: '—',
      category: 'Controls',
      demo: (_) => const DemoMEKnob()),
  CatalogEntry(
      name: 'MEJoystick',
      replaces: '—',
      category: 'Controls',
      demo: (_) => const DemoMEJoystick()),
  CatalogEntry(
      name: 'MEDayNightToggle',
      replaces: '—',
      category: 'Controls',
      demo: (_) => const DemoMEDayNightToggle()),
  CatalogEntry(
      name: 'MEMoodPicker',
      replaces: '—',
      category: 'Controls',
      demo: (_) => const DemoMEMoodPicker()),
  CatalogEntry(
      name: 'MECoinFlip',
      replaces: '—',
      category: 'Controls',
      demo: (_) => const Center(child: MECoinFlip())),
  CatalogEntry(
      name: 'MEDice',
      replaces: '—',
      category: 'Controls',
      demo: (_) => const Center(child: MEDice())),
  CatalogEntry(
      name: 'MELockDial',
      replaces: '—',
      category: 'Controls',
      demo: (_) => const Center(child: MELockDial())),
  CatalogEntry(
      name: 'MEMetronome',
      replaces: '—',
      category: 'Controls',
      demo: (_) => const Center(child: MEMetronome(bpm: 96))),
  CatalogEntry(
      name: 'MESlotMachine',
      replaces: '—',
      category: 'Controls',
      demo: (_) => Center(child: MESlotMachine())),
  CatalogEntry(
      name: 'MESpinWheel',
      replaces: '—',
      category: 'Controls',
      demo: (_) => const DemoMESpinWheel()),
  CatalogEntry(
      name: 'MEVinyl',
      replaces: '—',
      category: 'Controls',
      demo: (_) => const DemoMEVinyl()),
  CatalogEntry(
      name: 'MEWaveform',
      replaces: '—',
      category: 'Controls',
      demo: (_) => const DemoMEWaveform()),
  CatalogEntry(
      name: 'MEWheelPicker',
      replaces: 'CupertinoPicker',
      category: 'Controls',
      demo: (_) => const DemoMEWheelPicker()),
  CatalogEntry(
      name: 'MEColorPicker',
      replaces: '—',
      category: 'Controls',
      demo: (_) => const DemoMEColorPicker()),
  CatalogEntry(
      name: 'MEColorWheel',
      replaces: '—',
      category: 'Controls',
      demo: (_) => const DemoMEColorWheel()),
  CatalogEntry(
      name: 'MEOtpInput',
      replaces: '—',
      category: 'Controls',
      demo: (_) => MEOtpInput(onCompleted: (_) {})),
  CatalogEntry(
      name: 'MEPinPad',
      replaces: '—',
      category: 'Controls',
      demo: (_) => Center(child: MEPinPad(onCompleted: (_) {}))),
  // Inputs
  CatalogEntry(
      name: 'METextField',
      replaces: 'TextField / TextFormField',
      category: 'Inputs',
      demo: (_) => const DemoMETextField()),
  CatalogEntry(
      name: 'MEPasswordField',
      replaces: '—',
      category: 'Inputs',
      demo: (_) => const MEPasswordField(showStrengthMeter: true)),
  CatalogEntry(
      name: 'MESearchBar',
      replaces: 'SearchBar',
      category: 'Inputs',
      demo: (_) => const MESearchBar(hintText: 'Search widgets')),
  CatalogEntry(
      name: 'MESearchAnchor',
      replaces: 'SearchAnchor',
      category: 'Inputs',
      demo: (_) => const DemoMESearchAnchor()),
  CatalogEntry(
      name: 'MESearchAppBar',
      replaces: 'search app bar',
      category: 'Inputs',
      demo: (_) => const DemoMESearchAppBar()),
  CatalogEntry(
      name: 'MEAutocomplete',
      replaces: 'Autocomplete',
      category: 'Inputs',
      demo: (_) => const DemoMEAutocomplete()),
  CatalogEntry(
      name: 'METagInput',
      replaces: '—',
      category: 'Inputs',
      demo: (_) => const DemoMETagInput()),
  // Lists
  CatalogEntry(
      name: 'MEListTile',
      replaces: 'ListTile',
      category: 'Lists',
      demo: (_) => const DemoMEListTile()),
  CatalogEntry(
      name: 'MEListGroup',
      replaces: 'grouped ListTile',
      category: 'Lists',
      demo: (_) => const DemoMEListTile()),
  CatalogEntry(
      name: 'MECardList',
      replaces: 'stacked cards',
      category: 'Lists',
      demo: (_) => const DemoMECardList()),
  CatalogEntry(
      name: 'MESelection',
      replaces: 'multi-select host',
      category: 'Lists',
      demo: (_) => const DemoMESelection()),
  CatalogEntry(
      name: 'MEDismissible',
      replaces: 'Dismissible',
      category: 'Lists',
      demo: (_) => const DemoMEDismissible()),
  CatalogEntry(
      name: 'MEDismissibleColumn',
      replaces: 'swipeable card column',
      category: 'Lists',
      demo: (_) => const DemoMEDismissibleColumn()),
  CatalogEntry(
      name: 'MEDismissibleList',
      replaces: 'horizontal swipe cards',
      category: 'Lists',
      demo: (_) => const DemoMEDismissibleList()),
  CatalogEntry(
      name: 'MEExpandableList',
      replaces: 'expandable cards',
      category: 'Lists',
      demo: (_) => const DemoMEExpandableList()),
  CatalogEntry(
      name: 'MEExpansionTile',
      replaces: 'ExpansionTile',
      category: 'Lists',
      demo: (_) => const MEExpansionTile(
            title: Text('Show details'),
            children: [Text('Expanded content')],
          )),
  CatalogEntry(
      name: 'MEAccordion',
      replaces: 'ExpansionPanelList',
      category: 'Lists',
      demo: (_) => const MEAccordion(
            initiallyExpanded: {0},
            items: [
              MEAccordionItem(
                header: Text('What is expressive motion?'),
                body: Text('Physics-based springs replace duration curves.'),
              ),
            ],
          )),
  CatalogEntry(
      name: 'MEDropdown',
      replaces: 'DropdownButton',
      category: 'Lists',
      demo: (_) => const DemoMEDropdown()),
  CatalogEntry(
      name: 'MEMenuAnchor',
      replaces: 'PopupMenuButton',
      category: 'Lists',
      demo: (_) => const DemoMEMenuAnchor()),
  CatalogEntry(
      name: 'MEDataTable',
      replaces: 'DataTable',
      category: 'Lists',
      demo: (_) => const MEDataTable(
            columns: [
              DataColumn(label: Text('Widget')),
              DataColumn(label: Text('Replaces')),
            ],
            rows: [
              DataRow(cells: [
                DataCell(Text('MEButton')),
                DataCell(Text('FilledButton')),
              ]),
            ],
          )),
  CatalogEntry(
      name: 'MEPaginatedDataTable',
      replaces: 'PaginatedDataTable',
      category: 'Lists',
      demo: (_) => const DemoMEPaginatedDataTable()),
  CatalogEntry(
      name: 'MEReorderableList',
      replaces: 'ReorderableListView',
      category: 'Lists',
      demo: (_) => const DemoMEReorderableList()),
  CatalogEntry(
      name: 'MEStepper',
      replaces: 'Stepper',
      category: 'Lists',
      demo: (_) => const DemoMEStepper()),
  CatalogEntry(
      name: 'METimeline',
      replaces: '—',
      category: 'Lists',
      demo: (_) => const METimeline(
            activeIndex: 1,
            entries: [
              METimelineEntry(title: Text('Placed')),
              METimelineEntry(title: Text('Shipped')),
              METimelineEntry(title: Text('Delivered')),
            ],
          )),
  CatalogEntry(
      name: 'METreeView',
      replaces: '—',
      category: 'Lists',
      demo: (_) => const METreeView(
            nodes: [
              METreeNode(
                label: Text('lib'),
                initiallyExpanded: true,
                children: [METreeNode(label: Text('main.dart'))],
              ),
            ],
          )),
  // Navigation
  CatalogEntry(
      name: 'MEAppBar',
      replaces: 'AppBar / SliverAppBar',
      category: 'Navigation',
      demo: (_) => const DemoMEAppBar()),
  CatalogEntry(
      name: 'MEBottomAppBar',
      replaces: 'BottomAppBar',
      category: 'Navigation',
      demo: (_) => MEBottomAppBar(
            actions: [
              MEIconButton(
                  icon: const Icon(Icons.archive_outlined), onPressed: () {}),
              MEIconButton(
                  icon: const Icon(Icons.delete_outline), onPressed: () {}),
            ],
            fab: MEFab(
              size: MEFabSize.small,
              onPressed: () {},
              icon: const Icon(Icons.add),
            ),
          )),
  CatalogEntry(
      name: 'MEBreadcrumbs',
      replaces: '—',
      category: 'Navigation',
      demo: (_) => MEBreadcrumbs(
            crumbs: const [
              MEBreadcrumb(label: 'Home'),
              MEBreadcrumb(label: 'Gallery'),
              MEBreadcrumb(label: 'Widget'),
            ],
            onCrumbPressed: (_) {},
          )),
  CatalogEntry(
      name: 'MEDock',
      replaces: '—',
      category: 'Navigation',
      demo: (_) => Center(
            child: MEDock(
              items: [
                MEDockItem(icon: Icons.home_outlined, onPressed: () {}),
                MEDockItem(icon: Icons.search, onPressed: () {}),
                MEDockItem(icon: Icons.settings_outlined, onPressed: () {}),
              ],
            ),
          )),
  CatalogEntry(
      name: 'MEDrawer',
      replaces: 'Drawer / NavigationDrawer',
      category: 'Navigation',
      demo: (_) => const DemoMEDrawer()),
  CatalogEntry(
      name: 'MENavigationBar',
      replaces: 'NavigationBar',
      category: 'Navigation',
      demo: (_) => const DemoMENavigationBar()),
  CatalogEntry(
      name: 'MENavigationRail',
      replaces: 'NavigationRail',
      category: 'Navigation',
      demo: (_) => const DemoMENavigationRail()),
  CatalogEntry(
      name: 'METabBar',
      replaces: 'TabBar',
      category: 'Navigation',
      demo: (_) => const DemoMETabBar()),
  CatalogEntry(
      name: 'showMECommandPalette',
      replaces: '—',
      category: 'Navigation',
      demo: (_) => const DemoShowMECommandPalette()),
  // Pickers
  CatalogEntry(
      name: 'MECalendar',
      replaces: 'CalendarDatePicker',
      category: 'Pickers',
      demo: (_) => const DemoMECalendar()),
  CatalogEntry(
      name: 'MEDialTimePicker',
      replaces: 'TimePicker dial',
      category: 'Pickers',
      demo: (_) => const DemoMEDialTimePicker()),
  CatalogEntry(
      name: 'showMEDatePicker',
      replaces: 'showDatePicker',
      category: 'Pickers',
      demo: (_) => const DemoShowMEDatePicker()),
  CatalogEntry(
      name: 'showMEDateRangePicker',
      replaces: 'showDateRangePicker',
      category: 'Pickers',
      demo: (_) => const DemoShowMEDateRangePicker()),
  CatalogEntry(
      name: 'showMETimePicker',
      replaces: 'showTimePicker',
      category: 'Pickers',
      demo: (_) => const DemoShowMETimePicker()),
  // Progress
  CatalogEntry(
      name: 'MECircularProgressIndicator',
      replaces: 'CircularProgressIndicator',
      category: 'Progress',
      demo: (_) => const DemoMEProgress()),
  CatalogEntry(
      name: 'MELinearProgressIndicator',
      replaces: 'LinearProgressIndicator',
      category: 'Progress',
      demo: (_) => const DemoMEProgress()),
  CatalogEntry(
      name: 'MELiquidProgress',
      replaces: '—',
      category: 'Progress',
      demo: (_) => const Center(
            child: MELiquidProgress(value: 0.62, label: Text('62%')),
          )),
  CatalogEntry(
      name: 'MELoadingIndicator',
      replaces: 'short waits',
      category: 'Progress',
      demo: (_) => const Row(
            children: [
              MELoadingIndicator(),
              SizedBox(width: 32),
              MELoadingIndicator(contained: true),
            ],
          )),
  CatalogEntry(
      name: 'MERefreshIndicator',
      replaces: 'RefreshIndicator',
      category: 'Progress',
      demo: (_) => const DemoMERefreshIndicator()),
  CatalogEntry(
      name: 'MESkeleton',
      replaces: '—',
      category: 'Progress',
      demo: (_) => const DemoMESkeleton()),
  CatalogEntry(
      name: 'MESkeletonizer',
      replaces: '—',
      category: 'Progress',
      demo: (_) => const DemoMESkeleton()),
  // Slivers
  CatalogEntry(
      name: 'MESliverList',
      replaces: 'SliverList',
      category: 'Slivers',
      demo: (_) => const DemoMESlivers()),
  CatalogEntry(
      name: 'MESliverGrid',
      replaces: 'SliverGrid',
      category: 'Slivers',
      demo: (_) => const DemoMESlivers()),
  CatalogEntry(
      name: 'MESliverPinnedHeader',
      replaces: 'SliverPersistentHeader',
      category: 'Slivers',
      demo: (_) => const DemoMESlivers()),
  CatalogEntry(
      name: 'MESliverSectionHeader',
      replaces: '—',
      category: 'Slivers',
      demo: (_) => const DemoMESlivers()),
  CatalogEntry(
      name: 'MESliverScaffold',
      replaces: 'Scaffold + CustomScrollView',
      category: 'Slivers',
      demo: (_) => const DemoMESlivers()),
  // Theme
  CatalogEntry(
      name: 'METheme',
      replaces: 'Theme / motion tokens',
      category: 'Theme',
      demo: (_) => const DemoMETheme()),
];
