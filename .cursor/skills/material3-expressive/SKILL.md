---
name: material3-expressive
description: Choose and author Flutter UI with the material3_expressive (ME*) widget library. Use whenever this package is a dependency, the user asks for Material 3 Expressive, spring/shape-morphing widgets, or a replacement for FilledButton, IconButton, FAB, AppBar, NavigationBar, Slider, Switch, Dialog, SearchBar, ListTile, PopupMenu, or other Material widgets. Also use when deciding which ME widget fits a screen, chart, chat, picker, or playful control.
---

# material3_expressive

Drop-in **Material 3 Expressive** widgets. Prefix is **`ME`**, never `M3E`.

Import:

```dart
import 'package:material3_expressive/material3_expressive.dart';
```

Before inventing constructors, **read the widget file** under `lib/src/` (or the matching demo in `example/lib/gallery/demos.dart`). Do not copy APIs from `material_3_expressive` on pub.dev — that package uses `M3E*` names and a different theme.

## Setup (always)

Wrap the app so motion/shape tokens resolve. Colors still come from `ThemeData.colorScheme`.

```dart
MaterialApp(
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3D6B35)),
    useMaterial3: true,
  ),
  builder: (context, child) => METheme(
    data: METhemeData.expressive, // or METhemeData.standard
    child: child!,
  ),
  home: const HomePage(),
);
```

Prefer `ME*` over the stock Material widget whenever this package is already a dependency.

## Hard rules

- Public types start with `ME`. Deprecated: `ExpressiveButton` → use `MEButton`.
- `MEAppBar` is a **sliver**. Put it first in a `CustomScrollView` (or `MESliverScaffold`). Do not pass it to `Scaffold.appBar`.
- Menus: `MEMenu` / `MEMenuAnchor`, not `PopupMenuButton`. Overlay spring, not a slow `PopupRoute`.
- Search-as-you-type: `MESearchAnchor` / `MESearchAppBar`, not a bare `MESearchBar` plus a custom overlay.
- Motion: `METheme.of(context).motion` + `springTo`. Do not hard-code `Duration`/`Curves` on ME surfaces.
- Honor `MediaQuery.disableAnimations` (already handled in `METheme.of`).
- For live examples of every widget, open `example/lib/gallery/catalog.dart` and the matching demo.

## Pick by job

Use this table to **choose** a widget. If two fit, take the more specific one.

### Replace Material

| User / screen intent | Use | Not |
|---|---|---|
| Primary / secondary / tonal / outline / text button | `MEButton.filled` `.tonal` `.elevated` `.outlined` `.text` | `FilledButton`, `ElevatedButton`, `ExpressiveButton` |
| Icon-only toggle or action | `MEIconButton` | `IconButton` |
| Checked / unchecked action with label (favorite, bold) | `METoggleButton` | `MEIconButton` unless icon-only |
| Exclusive or multi select in a pill | `MESegmentedButton` | `SegmentedButton` |
| Neighbor-squish tool cluster | `MEButtonGroup` | several separate `MEButton`s |
| Primary + overflow menu on one control | `MESplitButton` | `MEButton` + separate `MEMenu` |
| FAB / extended FAB | `MEFab` / `MEFab.extended` | `FloatingActionButton` |
| Speed dial | `MEFabMenu` | homemade `Overlay` |
| Loading inside a button | `MEProgressButton` | `MEButton` + spinner |
| Confirm by holding | `MEHoldButton` | long-press `MEButton` |
| Linear / circular / short wait | `MELinearProgressIndicator` / `MECircularProgressIndicator` / `MELoadingIndicator` | `*ProgressIndicator` |
| Pull to refresh | `MERefreshIndicator` | `RefreshIndicator` |
| Placeholder loading | `MESkeleton` / `MESkeletonizer` | custom shimmer |
| Value slider / range / wavy / vertical | `MESlider` / `.wavy` / `.centered` / `.vertical` / `MERangeSlider` | `Slider` |
| Switch / checkbox / radio | `MESwitch` / `MECheckbox` / `MERadio` | Material counterparts |
| Filter / assist / input / suggestion chip | `MEChip` (`type:` / `selected:` / `onDeleted:`) | `FilterChip` |
| Card / carousel | `MECard` / `MECarousel` | `Card` / `CarouselView` |
| Avatar / stacked avatars | `MEAvatar` / `MEAvatarGroup` | `CircleAvatar` |
| Dialog | `MEDialog` + `showMEDialog` | `AlertDialog` |
| Full-screen editor dialog | `showMEFullScreenDialog` | `Dialog.fullscreen` |
| Pick one/many from a list in a dialog | `showMESelectionDialog` | homemade `ListView` in a dialog |
| Sheet | `showMEBottomSheet` / `showMESideSheet` | `showModalBottomSheet` |
| Snackbar / toast | `showMESnackBar` / `showMEToast` | `ScaffoldMessenger` snackbar |
| Text / password / OTP / tags | `METextField` / `MEPasswordField` / `MEOtpInput` / `METagInput` | `TextField` |
| Search bar only | `MESearchBar` | `SearchBar` |
| Search bar that opens suggestions | `MESearchAnchor` or `MESearchAppBar` | `SearchAnchor` |
| Autocomplete | `MEAutocomplete` | `Autocomplete` |
| List row / grouped rows / stacked cards | `MEListTile` / `MEListGroup` / `MECardList` | `ListTile` |
| Expand one tile / accordion / expandable cards | `MEExpansionTile` / `MEAccordion` / `MEExpandableList` | `ExpansionTile` |
| Popup / overflow menu | `MEMenu` (`anchorBuilder`) or `MEMenuAnchor` | `PopupMenuButton` |
| Dropdown field | `MEDropdown` | `DropdownButton` |
| Multi-select list with contextual bar | `MESelection` | custom `AppBar` swap |
| Swipe to dismiss one / column / deck | `MEDismissible` / `MEDismissibleColumn` / `MEDismissibleList` | `Dismissible` only |
| Reorder | `MEReorderableList` | `ReorderableListView` |
| Table | `MEDataTable` / `MEPaginatedDataTable` | `DataTable` |
| Stepper / timeline / tree | `MEStepper` / `METimeline` / `METreeView` | `Stepper` |
| App bar (sliver) | `MEAppBar` | `AppBar` / `SliverAppBar` |
| Search in the top bar | `MESearchAppBar` | `AppBar` + `SearchBar` |
| Bottom app bar + FAB | `MEBottomAppBar` | `BottomAppBar` |
| Destinations | `MENavigationBar` / `MENavigationRail` / `MEDrawer` | `NavigationBar` / `Rail` / `Drawer` |
| Tabs | `METabBar` | `TabBar` |
| Breadcrumbs / dock / command palette | `MEBreadcrumbs` / `MEDock` / `showMECommandPalette` | custom |
| Date / range / time | `showMEDatePicker` / `showMEDateRangePicker` / `showMETimePicker` | `showDatePicker` |
| Analog clock time | `MEDialTimePicker` | `showTimePicker` only |
| On-page calendar | `MECalendar` | `CalendarDatePicker` |
| Wheel / color | `MEWheelPicker` / `MEColorPicker` / `MEColorWheel` | `CupertinoPicker` |
| Badge / tooltip / divider | `MEBadge` / `METooltip` / `MEDivider` (`.vertical`) | Material counterparts |
| Banner | `MEBanner` | `MaterialBanner` |
| Network image | `MEImage` | `Image.network` |
| Empty screen | `MEEmptyState` | centered `Column` |
| Slivers | `MESliverList` / `MESliverGrid` / `MESliverPinnedHeader` / `MESliverSectionHeader` / `MESliverScaffold` | raw slivers |

### Product UI that Material does not have

| Intent | Use |
|---|---|
| Chat thread | `MEChatBubble`, `MEChatInput`, `MEChatTypingIndicator` |
| Markdown view / editor / code | `MEMarkdown`, `MEMarkdownEditor`, `MECodeView` |
| Rating / quantity / slide-to-confirm | `MERating`, `MEQuantityStepper`, `MESlideToConfirm` |
| Like | `MELikeButton` |
| Stats KPI | `MEStatCard` |
| File row | `MEFileCard` |
| Compare before/after | `MECompareSlider` |
| Skeleton of existing layout | wrap with `MESkeletonizer` |
| Number that ticks | `MENumberTicker` |
| Page dots | `MEPageIndicator` |
| Onboarding coach | `showMECoachmark` |
| Success / error check | `MESuccessCheck` / `MESuccessCheck.error` |
| Launch screen | `MESplashScreen` |
| PIN pad | `MEPinPad` |
| Password with strength | `MEPasswordField` |
| Floating selection toolbar | `MEFloatingToolbar` |
| Radial action menu | `MEOrbitMenu` |

### Charts (pick by data shape)

| Data | Use |
|---|---|
| Spark / KPI sparkline | `MESparkline` |
| Bars | `MEBarChart` / `MEStackedBarChart` |
| Line series | `MELineChart` |
| Parts of a whole | `MEDonutChart` / `MEFunnelChart` |
| Gauge / speedo / thermo | `MEGauge` / `MESpeedometer` / `METhermometer` |
| Radar / bubbles / candles / heatmap | `MERadarChart` / `MEBubbleChart` / `MECandlestickChart` / `MEHeatmap` |
| Activity rings | `MEActivityRings` |

### Decorative / playful (only if the product asks)

`MEDice`, `MECoinFlip`, `MESlotMachine`, `MESpinWheel`, `MEScratchCard`, `MEFireworks`, `MELavaLamp`, `MEVinyl`, `MEJoystick`, `MEPomodoro`, `MEMetronome`, `MEFlipClock`, `MEHourglass`, `MEBreathingRing`, `MEEqualizer`, `MEWaveform`, `MEVuMeter`, `MESonar`, `MECompass`, `METrafficLight`, `MELockDial`, `MEBattery`, `MESignalStrength`, `MEStreakFlame`, `MEDayNightToggle`, `MEMoodPicker`, `MEStickyNote`, `MEPolaroid`, `MECreditCard`, `MEBoardingPass`, `MEReceipt`, `MEStampCard`, `MEStoryRing`, `METiltCard`, `MEFlipCard`, `MESwipeDeck`, `MEMorphingShape`, `MEMarquee`, `METypewriter`, `MECountdown`, `MEStopwatch`, `MELiquidProgress`.

Do **not** drop these into banking, settings, or dense data screens unless the user asked for a playful / branded moment.

## Default choices (when the prompt is vague)

| Situation | Default |
|---|---|
| “Add a button” | `MEButton.filled` |
| “Add a FAB” | `MEFab` |
| “Top bar” | `MEAppBar` inside `CustomScrollView` |
| “Bottom nav” | `MENavigationBar` |
| “Form field” | `METextField` |
| “Search” | `MESearchAnchor.bar` |
| “Menu on a button” | `MEMenu` with `anchorBuilder` |
| “Show a dialog” | `showMEDialog` + `MEDialog` |
| “Toast” | `showMEToast` for transient, `showMESnackBar` if there is an action |
| “Loading” | `MELoadingIndicator` for short waits; linear/circular for determinate |
| “List of settings” | `MEListGroup` of `MEListTile`s |
| “Empty state” | `MEEmptyState` |

## Snippets

```dart
MEButton.filled(
  icon: const Icon(Icons.send),
  onPressed: () {},
  child: const Text('Send'),
);

METoggleButton.filled(
  checked: favorite,
  icon: const Icon(Icons.favorite_border),
  checkedIcon: const Icon(Icons.favorite),
  label: const Text('Favorite'),
  onCheckedChange: (v) => setState(() => favorite = v),
);

CustomScrollView(
  slivers: [
    const MEAppBar(title: Text('Inbox'), size: MEAppBarSize.medium),
    MESliverList(
      itemCount: items.length,
      itemBuilder: (context, i) => MEListTile(title: Text(items[i])),
    ),
  ],
);

MEMenu(
  anchorBuilder: (context, open) => MEButton.outlined(
    icon: const Icon(Icons.arrow_drop_down),
    onPressed: open,
    child: const Text('Open menu'),
  ),
  children: const [
    MEMenuEntry(label: 'Edit', value: 'edit'),
    MEMenuEntry(label: 'Delete', value: 'delete', isDestructive: true),
  ],
  onSelected: (value) {},
);
```

## Where to look

| Need | File |
|---|---|
| Public exports | `lib/material3_expressive.dart` |
| Widget source | `lib/src/<area>/me_*.dart` |
| Theme / springs | `lib/src/theme/me_theme.dart`, `me_motion.dart` |
| Every playground | `example/lib/gallery/catalog.dart`, `demos.dart` |
| Human docs | `README.md` |
