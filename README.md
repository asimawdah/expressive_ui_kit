# expressive_ui_kit

Material 3 Expressive widgets for Flutter — drop-in expressive replacements
for standard Material widgets, built around spring physics, shape morphing,
and the M3 Expressive motion scheme.

This package is maintained in its own repository and is licensed under the
[MIT License](LICENSE). Third-party dependencies retain their own licenses.

## Widget mapping

| Standard Material               | Material 3 Expressive           |
| ------------------------------- | ------------------------------- |
| `ElevatedButton`/`FilledButton` | `MEButton`                      |
| `IconButton`                    | `MEIconButton`                  |
| `SegmentedButton`               | `MESegmentedButton`             |
| toggle button rows              | `MEButtonGroup` (connected)     |
| `FloatingActionButton`          | `MEFab`                         |
| speed dial patterns             | `MEFabMenu` (new)               |
| —                               | `MESplitButton` (new)           |
| `LinearProgressIndicator`       | `MELinearProgressIndicator`     |
| `CircularProgressIndicator`     | `MECircularProgressIndicator`   |
| short indeterminate waits       | `MELoadingIndicator` (new)      |
| `Slider`                        | `MESlider`                      |
| `RangeSlider`                   | `MERangeSlider`                 |
| `Switch`                        | `MESwitch`                      |
| `Checkbox`                      | `MECheckbox`                    |
| `Radio`                         | `MERadio`                       |
| `AppBar`/`SliverAppBar`         | `MEAppBar` (sliver)             |
| `BottomAppBar`                  | `MEBottomAppBar`                |
| floating action clusters        | `METoolbar` (new)               |
| `NavigationBar`                 | `MENavigationBar`               |
| `NavigationRail` + drawer       | `MENavigationRail`              |
| `Drawer`/`NavigationDrawer`     | `MEDrawer`                      |
| `TabBar`                        | `METabBar`                      |
| `Card`                          | `MECard`                        |
| `Chip`/`FilterChip`/`InputChip` | `MEChip`                        |
| `CarouselView`                  | `MECarousel`                    |
| `AlertDialog` + `showDialog`    | `MEDialog` + `showMEDialog`     |
| `showModalBottomSheet`          | `showMEBottomSheet`             |
| `SnackBar`                      | `showMESnackBar`                |
| `TextField`/`TextFormField`     | `METextField`                   |
| `SearchBar`                     | `MESearchBar`                   |
| `ListTile`                      | `MEListTile` + `MEListGroup`    |
| `ExpansionTile`                 | `MEExpansionTile`               |
| `PopupMenuButton`/`MenuAnchor`  | `MEMenuAnchor`                  |
| `DropdownButton`/`DropdownMenu` | `MEDropdown`                    |
| `Badge`                         | `MEBadge`                       |
| `Tooltip`                       | `METooltip`                     |
| `Divider`                       | `MEDivider`                     |
| `showDatePicker`                | `showMEDatePicker`              |
| `showTimePicker`                | `showMETimePicker`              |
| `SliverList`                    | `MESliverList`                  |
| `SliverGrid`                    | `MESliverGrid`                  |
| `SliverPersistentHeader`        | `MESliverPinnedHeader`          |
| —                               | `MESliverSectionHeader` (new)   |
| `MaterialBanner`                | `MEBanner`                      |
| `RefreshIndicator`              | `MERefreshIndicator`            |
| `Stepper`                       | `MEStepper`                     |
| `DataTable`                     | `MEDataTable`                   |
| `CircleAvatar`                  | `MEAvatar` + `MEAvatarGroup`    |
| `Dismissible`                   | `MEDismissible`                 |
| `Autocomplete`                  | `MEAutocomplete`                |
| —                               | `MEPageIndicator` (new)         |
| —                               | `showMESideSheet` (new)         |
| —                               | `MEMarkdown` (new)              |
| —                               | `MEMarkdownEditor` (new)        |
| —                               | `MEChatBubble` (new)            |
| —                               | `MEChatInput` (new)             |
| —                               | `MEChatTypingIndicator` (new)   |
| —                               | `MERating` (new)                |
| —                               | `MEOtpInput` (new)              |
| —                               | `MESkeleton` + `MESkeletonizer` (new) |
| —                               | `MENumberTicker` (new)          |
| —                               | `METimeline` (new)              |
| —                               | `MEMorphingShape` (new)         |
| `CalendarDatePicker`            | `MECalendar`                    |
| —                               | `METagInput` (new)              |
| —                               | `METreeView` (new)              |
| —                               | `MEEmptyState` (new)            |
| —                               | `MEProgressButton` (new)        |
| —                               | `MECodeView` (new)              |
| —                               | `MEFileCard` (new)              |
| `Image.network`                 | `MEImage`                       |
| —                               | `MEColorPicker` (new)           |
| —                               | `MEPasswordField` (new)         |
| —                               | `MESparkline` (new)             |
| —                               | `MEBarChart` (new)              |
| —                               | `MEFlipCard` (new)              |
| —                               | `MECountdown` (new)             |
| —                               | `MEGauge` (new)                 |
| —                               | `MEDonutChart` (new)            |
| —                               | `showMEToast` (new)             |
| —                               | `MEBreadcrumbs` (new)           |
| —                               | `MESwipeDeck` (new)             |
| speed dial patterns             | `MEFabMenu`                     |
| —                               | `MEFloatingToolbar` (new)       |
| `ExpansionPanelList`            | `MEAccordion`                   |
| —                               | `MEStatCard` (new)              |
| —                               | `MESlideToConfirm` (new)        |
| —                               | `MEHeatmap` (new)               |
| —                               | `MEQuantityStepper` (new)       |
| —                               | `MECompareSlider` (new)         |
| `CupertinoPicker`               | `MEWheelPicker`                 |
| —                               | `MELineChart` (new)             |
| —                               | `showMECoachmark` (new)         |
| —                               | `MESuccessCheck` (new)          |
| —                               | `MEActivityRings` (new)         |
| —                               | `MERadarChart` (new)            |
| —                               | `MEWaveform` (new)              |
| —                               | `MEMarquee` (new)               |
| —                               | `showMECommandPalette` (new)    |
| —                               | `MEDock` (new)                  |
| —                               | `METiltCard` (new)              |
| —                               | `MEStoryRing` (new)             |
| —                               | `MEKnob` (new)                  |
| —                               | `MEEqualizer` (new)             |
| —                               | `MELiquidProgress` (new)        |
| —                               | `METypewriter` (new)            |
| —                               | `MEHoldButton` (new)            |
| —                               | `MEStopwatch` (new)             |
| —                               | `MEJoystick` (new)              |
| —                               | `MEFlipClock` (new)             |
| —                               | `MESpinWheel` (new)             |
| —                               | `MEScratchCard` (new)           |
| —                               | `MEFunnelChart` (new)           |
| —                               | `MECompass` (new)               |
| —                               | `MEDice` (new)                  |
| —                               | `MEBreathingRing` (new)         |
| —                               | `MEStackedBarChart` (new)       |
| —                               | `METhermometer` (new)           |
| —                               | `MEBattery` (new)               |
| —                               | `MECoinFlip` (new)              |
| —                               | `MESlotMachine` (new)           |
| —                               | `MEMetronome` (new)             |
| —                               | `MESignalStrength` (new)        |
| —                               | `MECreditCard` (new)            |
| —                               | `MEOrbitMenu` (new)             |
| —                               | `MEStickyNote` (new)            |
| —                               | `MEMoodPicker` (new)            |
| —                               | `MEStreakFlame` (new)           |
| —                               | `MEPolaroid` (new)              |
| —                               | `MELikeButton` (new)            |
| —                               | `MEVuMeter` (new)               |
| —                               | `MESonar` (new)                 |
| —                               | `MEDayNightToggle` (new)        |
| —                               | `MESpeedometer` (new)           |
| —                               | `MEHourglass` (new)             |
| —                               | `METrafficLight` (new)          |
| —                               | `MELockDial` (new)              |
| —                               | `MEBubbleChart` (new)           |
| —                               | `MECandlestickChart` (new)      |
| —                               | `MEFireworks` (new)             |
| —                               | `MEStampCard` (new)             |
| —                               | `MELavaLamp` (new)              |
| —                               | `MEPomodoro` (new)              |
| —                               | `MEBoardingPass` (new)          |
| —                               | `MEColorWheel` (new)            |

## Install

After the package is published, add it from pub.dev:

```yaml
dependencies:
  expressive_ui_kit: ^0.3.0
```

Or use a local checkout while developing the package:

```yaml
dependencies:
  expressive_ui_kit:
    path: ../
```

The package requires Flutter 3.27.0 or later.

## Setup

Wrap your app with `METheme` (optional — widgets fall back to the
expressive defaults when no theme is present):

```dart
MaterialApp(
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3D6B35)),
    useMaterial3: true,
  ),
  builder: (context, child) => METheme(
    data: METhemeData.expressive,
    child: child!,
  ),
  home: const HomePage(),
)
```

Colors always come from your `ThemeData.colorScheme`, so existing dynamic
color / seed-color setups keep working.

## Usage highlights

```dart
// Buttons: five sizes, five variants, press-morph shape.
MEButton.filled(
  size: MEButtonSize.large,
  onPressed: () {},
  child: const Text('Get started'),
);

// Toggle icon button: morphs round -> square when selected.
MEIconButton(
  icon: const Icon(Icons.favorite_border),
  selectedIcon: const Icon(Icons.favorite),
  selected: liked,
  onPressed: toggleLike,
);

// Segmented button (typed, single or multi select). The selected
// segment morphs into a fully-round pill with a check-mark reveal.
MESegmentedButton<String>(
  segments: const [
    MESegment(value: 'day', label: Text('Day')),
    MESegment(value: 'week', label: Text('Week')),
  ],
  selected: selection,
  onSelectionChanged: (s) => setState(() => selection = s),
);

// Avatars: circle at rest, morph to rounded square on press/selection.
MEAvatar(child: const Text('JD'), onPressed: () {}, selected: isSelected);
MEAvatarGroup(avatars: [for (final u in users) MEAvatar(child: Text(u))]);

// Swipe to dismiss with themed action reveal.
MEDismissible(
  dismissKey: ValueKey(item.id),
  onDismissed: (_) => remove(item),
  child: MEListTile(title: Text(item.title)),
);

// Autocomplete with an expressive options overlay.
MEAutocomplete<String>(
  label: 'Fruit',
  optionsBuilder: (v) => fruits.where((f) => f.contains(v.text)),
);

// Page indicator with a liquid active pill; side sheet from the edge.
MEPageIndicator(count: 4, index: page, onDotPressed: goToPage);
showMESideSheet(context: context, title: const Text('Filters'),
    builder: (context) => const FilterList());

// Markdown: zero-dependency viewer and editor with toolbar + preview.
// Fenced code blocks get theme-aware syntax highlighting and a copy
// button; `![alt](url)` renders images; `[file:name.ext](url)` renders
// a tappable attachment card.
MEMarkdown(
  data: source,
  onLinkTap: openUrl,
  onFileTap: downloadFile,
);
MEMarkdownEditor(
  controller: mdController,
  // Wire your file picker/uploader; the editor inserts the markdown.
  onAttachFile: () async {
    final file = await pickAndUpload();
    return file == null
        ? null
        : MEMarkdownAttachment(name: file.name, url: file.url);
  },
);

// Standalone syntax-highlighted code view (same one markdown uses).
MECodeView(code: source, language: 'dart');

// File attachment card with extension-derived icon.
MEFileCard(name: 'report.pdf', size: '2.4 MB', onPressed: open);

// Network image with shimmer loading and broken-image fallback.
MEImage(url: imageUrl, aspectRatio: 16 / 9);

// Chat: grouped bubbles (markdown-capable), typing dots, and a composer
// whose send button springs in when there is text.
MEChatBubble(
  text: 'Supports **markdown** too',
  markdown: true,
  outgoing: false,
  position: MEChatGroupPosition.first,
  avatar: const MEAvatar(child: Text('A')),
);
const MEChatTypingIndicator();
MEChatInput(onSend: (text) => sendMessage(text));

// Star rating with staggered pop; OTP input with per-cell bounce.
MERating(value: rating, onChanged: (v) => setState(() => rating = v));
MEOtpInput(length: 6, onCompleted: verify);

// Color swatch picker: selected swatch morphs circle -> rounded square.
MEColorPicker(
  colors: palette,
  selected: color,
  onChanged: (c) => setState(() => color = c),
);

// Password field with visibility toggle and animated strength meter.
MEPasswordField(showStrengthMeter: true);

// Charts: a sparkline that draws itself in, and a bar chart whose bars
// grow with a staggered spring. Tap a bar to select it.
MESparkline(values: weeklyData);
MEBarChart(entries: const [
  MEBarChartEntry(value: 12, label: 'Mon'),
  MEBarChartEntry(value: 18, label: 'Tue'),
]);

// 3D flip card with a spring settle-wobble.
MEFlipCard(
  front: MEFlipCardFace(child: const Text('Front')),
  back: MEFlipCardFace(child: const Text('Back')),
);

// Countdown with rolling digits (uses MENumberTicker cells).
MECountdown(target: launchDate, onFinished: celebrate);

// Radial gauge whose arc sweeps in with a spring.
MEGauge(value: 0.72, label: const Text('Storage'));

// Donut chart: segments sweep in sequentially with angular gaps.
// Tap a slice to select it — it thickens and the center shows its share.
MEDonutChart(segments: const [
  MEDonutSegment(value: 42, label: 'Documents'),
  MEDonutSegment(value: 28, label: 'Photos'),
]);

// Toast: a floating pill that springs down from the top. Works from
// dialogs and sheets (root overlay), unlike a snack bar.
showMEToast(context, message: 'Saved', kind: METoastKind.success);

// Breadcrumb trail with press-morphing pills.
MEBreadcrumbs(
  crumbs: const [
    MEBreadcrumb(label: 'Home', icon: Icons.home_outlined),
    MEBreadcrumb(label: 'Projects'),
  ],
  onCrumbPressed: navigateTo,
);

// Swipeable card deck: drag past the threshold to dismiss, or the card
// springs back with a bounce. Cards behind rise into place.
MESwipeDeck(
itemCount: profiles.length,
itemBuilder: (context, i) => ProfileCard(profile: profiles[i]),
onSwiped: (i, dir) => like(profiles[i], dir == MESwipeDirection.right),
);

// FAB menu (new M3E component): the FAB expands into labeled action
// pills with a staggered spring entrance. Use as floatingActionButton.
MEFabMenu(items: [
  MEFabMenuItem(
    icon: const Icon(Icons.edit_outlined),
    label: const Text('Compose'),
    onPressed: compose,
  ),
]);

// Floating toolbar (new M3E component): a floating pill of actions with
// a liquid selection highlight that springs between slots.
MEFloatingToolbar(
  selectedIndex: tool,
  onSelected: (i) => setState(() => tool = i),
  actions: const [
    METoolbarAction(icon: Icon(Icons.format_bold), tooltip: 'Bold'),
    METoolbarAction(icon: Icon(Icons.format_italic), tooltip: 'Italic'),
  ],
);

// Accordion: panels unfold with a spring; the open panel morphs to a
// larger radius and tonal color.
MEAccordion(items: const [
  MEAccordionItem(header: Text('Question'), body: Text('Answer.')),
]);

// Stat card: rolling value, trend chip, and an optional sparkline.
MEStatCard(
  label: const Text('Revenue'),
  value: revenue,
  prefix: '\$',
  delta: 12.4,
  sparkline: history,
);

// Slide-to-confirm for destructive/irreversible actions. Release early
// and the thumb springs back; confirming morphs it squarer + checked.
MESlideToConfirm(
  label: 'Slide to send payment',
  onConfirmed: sendPayment,
);

// Heatmap calendar (contribution graph): cells pop in with a diagonal
// stagger; tapping a cell morphs it rounder and shows its tooltip.
MEHeatmap(
  columns: 12,
  cells: [for (final d in days) MEHeatmapCell(value: d.count)],
);

// Quantity stepper: pill segments press-morph, value rolls on a spring.
MEQuantityStepper(
  value: qty,
  min: 1,
  onChanged: (v) => setState(() => qty = v),
);

// Before/after compare slider with a press-morphing drag handle.
MECompareSlider(
before: Image.asset('original.png', fit: BoxFit.cover),
after: Image.asset('edited.png', fit: BoxFit.cover),
beforeLabel: 'Before',
afterLabel: 'After',
);

// Wheel picker: tonal selection window morphs squarer while dragging,
// detents tick with haptics.
MEWheelPicker(
  items: const ['Small', 'Medium', 'Large'],
  onSelected: (i) => setState(() => size = i),
);

// Multi-series line chart: lines draw themselves in; touch to scrub
// with a snapping value bubble.
MELineChart(series: [
  MELineSeries(values: revenue, label: 'Revenue'),
  MELineSeries(values: costs, label: 'Costs'),
]);

// Coachmark: scrim with a rounded cutout over the target widget and a
// spring-in card. Attach a GlobalKey to the widget to highlight.
showMECoachmark(
  context,
  targetKey: fabKey,
  title: 'Create a note',
  message: 'Tap here to start writing.',
);

// Animated success/error indicator: circle pops in, stroke draws itself.
const MESuccessCheck(size: 96);
MESuccessCheck.error(size: 96);

// Concentric activity rings that sweep in staggered outside-in.
MEActivityRings(
  rings: const [
    MEActivityRing(value: 0.85, label: 'Move'),
    MEActivityRing(value: 0.6, label: 'Exercise'),
  ],
  showLegend: true,
);

// Radar chart: the polygon inflates from the center with a spring and
// springs between shapes when values change.
MERadarChart(axes: const [
  MERadarAxis(label: 'Speed', value: 0.9),
  MERadarAxis(label: 'Power', value: 0.6),
  MERadarAxis(label: 'Range', value: 0.75),
]);

// Audio waveform seek bar: drag to scrub — bars near your finger
// stretch, detents tick with haptics, the playhead follows a spring.
MEWaveform(
  samples: amplitudes,
  progress: position,
  onChangeEnd: seekTo,
);

// Marquee for overflowing titles: constant-velocity loop with edge
// fades and a pause between passes. Static if the content fits.
MEMarquee(child: Text('A very long song title — Extended Remix'));

// Command palette: searchable command list with keyboard navigation.
// The highlight pill springs between rows; Enter executes.
showMECommandPalette(context, commands: [
  MECommand(
    label: 'New document',
    icon: Icons.note_add_outlined,
    shortcut: 'Ctrl N',
    onSelected: createDocument,
  ),
]);

// Dock: icons magnify under the pointer with cosine falloff; drag along
// it on touch to scrub with haptic ticks, release to activate.
MEDock(items: [
  MEDockItem(icon: Icons.home_outlined, tooltip: 'Home', onPressed: goHome),
  MEDockItem(icon: Icons.search, tooltip: 'Search', onPressed: openSearch),
]);

// 3D tilt card: tilts toward the pointer in perspective with a tracking
// sheen, then springs back flat with a wobble on release.
METiltCard(
  height: 200,
  child: ArtworkPreview(),
);

// Story ring: segmented arc around an avatar signalling unseen content.
// Sweeps in with a spring; collapses to a thin outline once seen.
MEStoryRing(
  segments: 3,
  seen: story.seen,
  child: MEAvatar(image: NetworkImage(url), size: 56),
);

// Rotary knob: drag vertically or in a circle. The face morphs squarer
// while grabbed and detents tick with haptics.
MEKnob(
  value: volume,
  onChanged: (v) => setState(() => volume = v),
  label: const Icon(Icons.volume_up),
);

// Now-playing equalizer glyph: bars bob organically while playing.
MEEqualizer(playing: isPlaying, size: 24);

// Liquid progress: the fill springs to its level and the surface
// sloshes with velocity, calming down at rest.
MELiquidProgress(value: 0.62, label: const Text('62%'));

// Typewriter text: types phrases out with a blinking block cursor,
// erasing between them. Layout is reserved so nothing reflows.
METypewriter(
  phrases: const ['Build expressively.', 'Ship with springs.'],
  style: textTheme.headlineSmall,
);

// Hold-to-confirm: an error fill sweeps across while held; release
// early and it springs back. Compact alternative to MESlideToConfirm.
MEHoldButton(
  label: 'Hold to delete',
  icon: const Icon(Icons.delete_outline),
  onConfirmed: deleteAccount,
);

// Stopwatch: rolling MENumberTicker digits; the start/stop control
// morphs circle <-> rounded square with the state change.
MEStopwatch(onLap: (elapsed) => laps.add(elapsed));

// Virtual joystick: spring-loaded thumb that bounces back to center on
// release. Reports normalized -1..1 offsets.
MEJoystick(onChanged: (v) => move(v.dx, v.dy));

// Split-flap clock: digits fold over in 3D with a spring landing.
// Shows the current time by default, or pass a value for countdowns.
const MEFlipClock();
MEFlipClock(value: score.toString());

// Prize wheel: fling it (or spin programmatically) and it decelerates
// with friction physics, ticking haptics at each segment boundary.
MESpinWheel(
  segments: const [
    MESpinSegment(label: 'Coffee'),
    MESpinSegment(label: 'Tea'),
  ],
  onSettled: (i) => award(i),
);

// Scratch card: drag to scratch off the tonal cover; once past the
// threshold the rest auto-reveals with a success haptic.
MEScratchCard(
  onRevealed: claimPrize,
  child: const Center(child: Text('You won!')),
);

// Funnel chart: stages grow in staggered, with conversion percentages.
MEFunnelChart(stages: const [
  MEFunnelStage(value: 12400, label: 'Visitors'),
  MEFunnelStage(value: 6800, label: 'Sign-ups'),
  MEFunnelStage(value: 1150, label: 'Customers'),
]);

// Compass dial: springs to a heading via the shortest rotational path,
// overshooting and settling like a physical needle.
MECompass(heading: bearingDegrees);

// Tappable die: tumbles with a spin, cycles faces, lands with a bounce
// and a haptic. Faces above 9 render as numerals.
MEDice(onRolled: (value) => score += value);

// Guided breathing ring: inflates on the inhale, holds, deflates on the
// exhale, with a blooming halo and cross-fading phase label.
MEBreathingRing(
  inhale: Duration(seconds: 4),
  exhale: Duration(seconds: 6),
);

// Stacked bar chart: segments grow from the baseline with staggered
// springs; colors derive from the scheme (primary, tertiary, ...).
MEStackedBarChart(
  seriesLabels: const ['Direct', 'Referral'],
  bars: const [
    MEStackedBar(values: [40, 24], label: 'Mon'),
MEStackedBar(values: [55, 30], label: 'Tue'),
  ],
  );

// Thermometer: the mercury springs to its level and colors itself
// primary (cold) -> tertiary (warm) -> error (hot).
METhermometer(value: 22, min: -10, max: 40, unit: '°C');

// Battery indicator: spring-animated fill with semantic colors and a
// pulsing bolt while charging.
MEBattery(value: 0.68, charging: isPluggedIn);

// Coin flip: tumbles in 3D perspective with lift, lands with a haptic.
MECoinFlip(onFlipped: (heads) => call(heads));

// Slot machine: reels stop left to right with spring overshoot and
// haptic ticks; jackpots fire a heavy haptic.
MESlotMachine(onJackpot: celebrate);

// Metronome: pendulum swings at the set BPM with haptic beats; the
// downbeat gets a heavier tick and a stronger dot pulse.
MEMetronome(bpm: 96, onBeat: (i) => flash(i));

// Signal strength: bars fill with staggered springs; colors follow
// strength (error -> tertiary -> primary). Searching runs a wave.
MESignalStrength(level: 3, searching: isScanning);

// Payment card: glass theme, tap/swipe to flip and reveal CVC.
MECreditCard(
  number: '4242424242424242',
  holder: 'Alex Rivera',
  expiry: '09/28',
);

// Orbit menu: actions bloom out radially on staggered springs; the
// central toggle cross-rotates and morphs round -> square while open.
MEOrbitMenu(
  startAngle: 30,
  sweepAngle: 120,
  actions: [
    MEOrbitAction(icon: Icons.edit, onPressed: edit),
MEOrbitAction(icon: Icons.share, onPressed: share),
  ],
  );

// Sticky note: tinted paper with a folded corner. Drops in with a
// spring and settles into its tilt; pressing squashes and levels it.
MEStickyNote(
  color: MEStickyNoteColor.tertiary,
  angle: -2,
  child: const Text('Buy oat milk'),
);

// Mood picker: face glyphs from frown to smile. The selected face
// fills with a mood color (error -> tertiary -> primary) and pops.
MEMoodPicker(value: mood, onChanged: (i) => setState(() => mood = i));

// Habit streak flame: flickers organically while active, grays out
// when broken. The day count pops on increment.
MEStreakFlame(count: 12, active: true);

// Polaroid: the photo "develops" from dark on mount; pressing
// straightens the tilt, releasing wobbles back.
MEPolaroid(
caption: 'Golden hour',
  child: Image.network(url, fit: BoxFit.cover),
  );

// Like button: the heart squashes then springs up while a ring of
// confetti dots bursts outward; the count pops on change.
MELikeButton(
  liked: isLiked,
  count: likes,
  onChanged: (v) => setState(() => isLiked = v),
);

// Analog VU meter: the needle chases the level with galvanometer
// physics, overshooting on spikes. Hot zone drawn in the error color.
MEVuMeter(value: audioLevel, label: 'VU');
MEVuMeter(active: true); // self-animating demo mode

// Sonar display: a rotating beam lights up blips, which decay with the
// classic radar afterglow until the next pass.
MESonar(blips: const [
  MESonarBlip(angle: 40, distance: 0.55),
  MESonarBlip(angle: 210, distance: 0.8),
]);

// Day-night toggle: the sun morphs into a crescent moon, stars fade
// in, and the sky track cross-fades. Great as a theme-mode switch.
MEDayNightToggle(
  night: isDark,
onChanged: (v) => setThemeMode(v ? ThemeMode.dark : ThemeMode.light),
  );

// Speedometer: the needle chases the value with a slow spring,
// overshooting on spikes. Zones color primary/tertiary/error.
MESpeedometer(value: speed, max: 160, unit: 'km/h');

// Hourglass: sand drains over the duration with a falling stream;
// tap to flip it 180 degrees (with overshoot) and restart.
MEHourglass(
  duration: const Duration(minutes: 1),
  onEmpty: timeUp,
);

// Traffic light: the active lamp blooms with a glow halo; great for
// build/health status. Colors: stop=error, caution=tertiary, go=primary.
METrafficLight(state: METrafficState.go);

// Combination lock dial: drag to rotate with haptic detents; releasing
// snaps to the nearest number and reports it.
MELockDial(onEntry: (n) => combination.add(n));

// Bubble chart: bubbles inflate with staggered springs and gently
// drift while idle. Positions and sizes are normalized 0..1.
MEBubbleChart(bubbles: const [
  MEBubble(x: 0.2, y: 0.6, size: 0.9, label: 'Web'),
  MEBubble(x: 0.7, y: 0.3, size: 0.5, label: 'iOS'),
]);

// Candlestick chart: candles grow from their midpoints left to right;
// bullish candles use primary, bearish use error.
MECandlestickChart(candles: const [
  MECandle(open: 42, close: 48, high: 50, low: 40, label: 'Mon'),
  MECandle(open: 48, close: 45, high: 52, low: 44, label: 'Tue'),
]);

// Fireworks: tap the canvas to launch at that spot, or drive it
// programmatically. Rockets arc up and burst into twinkling sparks.
final fireworks = MEFireworksController();
MEFireworks(controller: fireworks);
fireworks.celebrate(); // volley of 5

// Loyalty stamp card: new stamps punch in with a spring drop and a
// haptic thump; the reward slot pulses when it is next.
MEStampCard(
  total: 10,
  earned: stamps,
  onCompleted: giveReward,
);

// Lava lamp: ambient metaball blobs rise, wobble and sink using the
// scheme's primary and tertiary colors. Decorative backdrop surface.
const MELavaLamp(width: 200, height: 280);

// Pomodoro: the ring drains over the focus session, then flips to a
// tertiary-colored break. The play control morphs circle <-> square.
MEPomodoro(
  focusDuration: const Duration(minutes: 25),
  breakDuration: const Duration(minutes: 5),
  onSessionEnd: (wasFocus) => log(wasFocus),
);

// Boarding pass: swipe the stub past the perforation to tear it off
// with a spring, rotation and fade. Under-threshold drags snap back.
MEBoardingPass(
  header: const Text('SFO -> NRT'),
  body: const Text('Alex Rivera, Seat 12A'),
  stub: const Text('12A'),
  onTornOff: checkIn,
);

// Hue color wheel: the thumb rides the ring, growing while grabbed,
// with haptic ticks every 30 degrees; the center puck pops on change.
MEColorWheel(hue: hue, onChanged: (h) => setState(() => hue = h));

  // Skeleton loading with a traveling shimmer, plus a cross-fade wrapper.
MESkeletonizer(
  loading: isLoading,
  skeleton: const Row(children: [
    MESkeleton.circle(size: 48),
    SizedBox(width: 12),
    Expanded(child: MESkeleton.line()),
  ]),
  child: ProfileRow(user: user),
);

// Animated number whose digits roll with a spatial spring.
MENumberTicker(value: count, style: textTheme.displaySmall);

// Vertical activity timeline with animated node states.
METimeline(
  activeIndex: 2,
  entries: const [
    METimelineEntry(title: Text('Order placed')),
    METimelineEntry(title: Text('Shipped')),
    METimelineEntry(title: Text('Out for delivery')),
    METimelineEntry(title: Text('Delivered')),
  ],
);

// Decorative M3E shape (cookie/clover/flower/sunny) that spring-morphs
// and slowly rotates. Great for hero moments and empty states.
MEMorphingShape(size: 160, child: const Icon(Icons.music_note));

// Inline month calendar: selected day is a full pill, today is
// outlined, month changes slide with a spring.
MECalendar(
  selectedDate: date,
  onDateSelected: (d) => setState(() => date = d),
);

// Tag input: enter/comma commits, backspace removes, chips pop in.
METagInput(
  tags: tags,
  onChanged: (next) => setState(() => tags = next),
);

// Tree view with spring-unfolding children and rotating chevrons.
METreeView(
  nodes: const [
    METreeNode(label: Text('lib'), icon: Icons.folder_outlined, children: [
      METreeNode(label: Text('main.dart'), icon: Icons.description_outlined),
    ]),
  ],
);

// Empty state composing the morphing shape hero.
MEEmptyState(
  icon: Icons.inbox_outlined,
  title: const Text('No messages yet'),
  action: MEButton.tonal(onPressed: () {}, child: const Text('Start')),
);

// Async button: label morphs into a loading indicator until the
// future completes.
MEProgressButton(
  onPressed: () => uploadFile(),
  child: const Text('Upload'),
);

// Connected button group for toggle-button rows.
MEButtonGroup(
  style: MEButtonGroupStyle.connected,
  selectedIndices: selection,
  onSelectionChanged: (s) => setState(() => selection = s),
  items: const [
    MEButtonGroupItem(child: Text('Day')),
    MEButtonGroupItem(child: Text('Week')),
    MEButtonGroupItem(child: Text('Month')),
  ],
);

// FAB menu (replaces speed dials).
MEFabMenu(
  items: [
    MEFabMenuItem(
      icon: const Icon(Icons.photo_camera_outlined),
      label: const Text('Camera'),
      onPressed: () {},
    ),
  ],
);

// Wavy progress.
MELinearProgressIndicator(value: 0.6);
const MECircularProgressIndicator(); // indeterminate

// Shape-morphing loading indicator for short waits.
const MELoadingIndicator(contained: true);

// Navigation bar: liquid pill indicator that stretches between
// destinations, icon bounce, badges, and label behavior control.
MENavigationBar(
  selectedIndex: index,
  onDestinationSelected: (i) => setState(() => index = i),
  labelBehavior: MENavigationLabelBehavior.onlyShowSelected,
  destinations: [
    const MENavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
    MENavigationDestination(
      icon: const Icon(Icons.inbox_outlined),
      label: 'Inbox',
      badge: const MEBadge(count: 3),
    ),
  ],
);

// Expressive app bar is a sliver with a collapsing emphasized headline,
// optional subtitle, and scrolled-under surface change:
CustomScrollView(
  slivers: [
    MEAppBar(
      title: const Text('Headline'),
      subtitle: const Text('Supporting text'),
      size: MEAppBarSize.large,
    ),
    const MESliverSectionHeader(title: 'RECENT'),
    MESliverList(
      itemCount: items.length,
      itemBuilder: (context, i) => ListTile(title: Text(items[i])),
    ),
    const MESliverPinnedHeader(title: Text('GALLERY')),
    MESliverGrid(
      itemCount: photos.length,
      itemBuilder: (context, i) => Image.network(photos[i]),
    ),
  ],
);

// Text field with spring focus morph.
METextField(label: 'Name', hintText: 'Jane Doe');

// Segmented list group.
MEListGroup(
  children: [
    MEListTile(title: const Text('First'), onPressed: () {}),
    MEListTile(title: const Text('Last'), onPressed: () {}),
  ],
);

// Menus, sheets, snackbars and pickers.
MEMenuAnchor<String>(
  items: const [MEMenuItem(value: 'a', label: 'Option A')],
  onSelected: (v) {},
  child: const Icon(Icons.more_vert),
);
showMEBottomSheet(context: context, builder: (context) => const SheetBody());
showMESnackBar(context, message: 'Saved', actionLabel: 'Undo');
final date = await showMEDatePicker(
  context: context,
  initialDate: DateTime.now(),
  firstDate: DateTime(2020),
  lastDate: DateTime(2030),
);

// Dialog with spring entrance.
showMEDialog<void>(
  context: context,
  builder: (context) => MEDialog(
    title: const Text('Title'),
    content: const Text('Body'),
    actions: [
      MEButton.text(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      MEButton.filled(onPressed: () => Navigator.pop(context), child: const Text('OK')),
    ],
  ),
);
```

## Motion system

Every pressable surface (buttons, FABs, cards, chips, avatars, list
tiles...) shares the same expressive press choreography:

- **Shape morph** — the surface springs toward a squarer (or rounder)
  shape while pressed and back on release.
- **Squash & overshoot** — the surface scales down slightly on press;
  the underdamped release spring pushes it just past 1.0 for a natural
  bounce.
- **Haptics** — buttons and FABs emit a light haptic tick on press-down.

All animations run on physics springs, exposed through `MEMotionScheme`:

- `fastSpatial` / `defaultSpatial` / `slowSpatial` — bouncy springs for
  movement, scaling and shape morphs.
- `fastEffects` / `defaultEffects` / `slowEffects` — critically damped
  springs for color, opacity and other non-spatial effects.

Use them in your own widgets:

```dart
final motion = METheme.of(context).motion;
springTo(controller, 1.0, motion.defaultSpatial);
// or as a Curve for implicit animations:
AnimatedContainer(curve: motion.defaultSpatial.curve, ...);
```

Pass `METhemeData.standard` to tone the bounce down (reduced-motion
friendly).

## Example

A full gallery app lives in `example/` — run it with:

```sh
cd example
flutter run
```

It has eight sections covering every widget: buttons & FABs, progress &
loading, sliders & controls, navigation, cards/chips/dialogs,
inputs/lists/menus/pickers, markdown/chat/content widgets, and the sliver
suite. The first five are on the bottom navigation bar; open the drawer
(an `MEDrawer`) to reach the remaining pages.
