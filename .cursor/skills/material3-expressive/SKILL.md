---
name: material3-expressive
description: >-
  Choose the correct Flutter widget from the material3_expressive library
  (prefix ME, never M3E). Use whenever this package is a dependency; the user
  asks for Material 3 Expressive / M3E / expressive UI; they want a button,
  FAB, app bar, nav bar, slider, switch, dialog, search, list, menu, chip,
  card, chart, chat, picker, or playful control; or you must decide which
  widget from this library to use instead of stock Material. Also use for
  Arabic prompts about واجهة، زر، شريط، قائمة، حوار، بحث.
---

# Choose a widget from material3_expressive

This package is **`material3_expressive`**. Public types start with **`ME`**.
Do **not** use `M3E*` names and do **not** copy APIs from pub.dev
`material_3_expressive`.

## Procedure (always)

1. Confirm the app is wrapped in `METheme` (setup below).
2. Map the user's intent to **Pick by job**. If two rows match, take the
   **more specific** one.
3. If the intent is not in that table, open [`catalog.md`](catalog.md).
4. Before writing a constructor, copy it from [`constructors.md`](constructors.md)
   or read the matching file under `lib/src/`. Do not invent named parameters.
5. Prefer `ME*` over the stock Material widget whenever this package is already
   a dependency.

## Setup (always)

Colors still come from `ThemeData.colorScheme`. Motion/shape tokens come from
`METheme`.

```dart
import 'package:material3_expressive/material3_expressive.dart';

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

## Hard rules

| Do | Do not |
|---|---|
| Prefix `ME` (`MEButton`, `showMEDialog`) | Prefix `M3E` |
| `MEAppBar` first in a `CustomScrollView` / `MESliverScaffold` | `Scaffold(appBar: MEAppBar(...))` — it is a **sliver**. Use `METopAppBar` on a Scaffold |
| `MEMenu` / `MEMenuAnchor` | `PopupMenuButton` |
| `MESearchAnchor` / `MESearchAppBar` for live search | Bare `MESearchBar` plus a homemade overlay |
| `METheme.of(context).motion` + motor `MaterialSpringMotion` | Hard-coded `Duration`/`Curves` on ME surfaces |
| `MEDrawerDestination.icon` as `IconData` | Passing a `Widget` as the drawer icon |
| `MEButton` | Deprecated `ExpressiveButton` |
| Honor `MediaQuery.disableAnimations` | Extra animation wrappers that ignore it |

Springs are the same **motor** `MaterialSpringMotion` tokens `m3e_core` uses
(`expressiveSpatial*`, `standardSpatial*`, `*Effects`, plus `overflow` /
`popup`). Drive them with `springTo` / `MEMotionBuilder` /
`MEMotionReveal` / `MEMotionWidth` / `MEMotionOpacity` /
`MESpringSpec.toMotion()`. Button press morphs **corner radius** (not
`Transform.scale`). Button groups neighbor-squish by transferring width.
Never import `m3e_core` or `M3E*` types.

Live playgrounds for every public widget: `example/lib/gallery/catalog.dart`.

## Pick by job

### Replace Material

| Intent | Use | Not |
|---|---|---|
| Primary / secondary / tonal / outline / text button | `MEButton.filled` `.tonal` `.elevated` `.outlined` `.text` | `FilledButton`, `ExpressiveButton` |
| Icon-only action or icon toggle | `MEIconButton` (`selected:` for toggle) | `IconButton` |
| Checked action **with a label** (favorite, bold) | `METoggleButton` | `MEIconButton` unless icon-only |
| Exclusive or multi select in a pill | `MESegmentedButton` | `SegmentedButton` |
| Neighbor-squish tool cluster | `MEButtonGroup` | Several loose `MEButton`s |
| Primary action + overflow on one control | `MESplitButton` | `MEButton` + separate menu |
| FAB / extended FAB | `MEFab` / `MEFab.extended` | `FloatingActionButton` |
| Speed dial | `MEFabMenu` | Homemade overlay |
| Top bar on a **Scaffold** | `METopAppBar` | `MEAppBar` (that one is a sliver) |
| Collapsing / medium / large top bar | `MEAppBar` in `CustomScrollView` | `Scaffold(appBar: …)` |
| Checked tool cluster (bold/italic) | `METoggleButtonGroup` | Several loose `METoggleButton`s |
| Docked bar + trailing FAB | `MEBottomAppBar` | `METoolbar` (that one floats) |
| Selection / format toolbar that floats near content | `MEFloatingToolbar` | `METoolbar` unless it is a bottom cluster |
| Loading inside a button | `MEProgressButton` | `MEButton` + spinner |
| Confirm by holding | `MEHoldButton` | Long-press `MEButton` |
| Linear / circular / short wait | `MELinearProgressIndicator` / `MECircularProgressIndicator` / `MELoadingIndicator` | Material `*ProgressIndicator` |
| Pull to refresh | `MERefreshIndicator` | `RefreshIndicator` |
| Placeholder loading | `MESkeleton` / wrap with `MESkeletonizer` | Custom shimmer |
| Value / range / wavy / vertical slider | `MESlider` / `.wavy` / `.centered` / `.vertical` / `MERangeSlider` | `Slider` |
| Dial / analog value | `MEKnob` | `Slider` unless a linear track is wanted |
| Switch / checkbox / radio | `MESwitch` / `MECheckbox` / `MERadio` | Material counterparts |
| Filter / assist / input / suggestion chip | `MEChip` (`type:` / `selected:` / `onDeleted:`) | `FilterChip` |
| Card / carousel | `MECard` / `MECarousel` | `Card` / `CarouselView` |
| Avatar / stacked avatars | `MEAvatar` / `MEAvatarGroup` | `CircleAvatar` |
| Cookie / pill / burst shape well | `MEShapeContainer` (`MaterialShapes.*`) | Homemade `ClipPath` |
| Dialog | `MEDialog` + `showMEDialog` | `AlertDialog` |
| Full-screen editor dialog | `showMEFullScreenDialog` | `Dialog.fullscreen` |
| Pick one/many from a list in a dialog | `showMESelectionDialog` | Homemade `ListView` in a dialog |
| Sheet | `showMEBottomSheet` / `showMESideSheet` | `showModalBottomSheet` |
| Snackbar / toast | `showMESnackBar` (has action) / `showMEToast` (transient) | `ScaffoldMessenger` snackbar |
| Text / password / OTP / tags | `METextField` / `MEPasswordField` / `MEOtpInput` / `METagInput` | `TextField` |
| Search field only | `MESearchBar` | `SearchBar` |
| Search that opens suggestions | `MESearchAnchor.bar` or `MESearchAppBar` | `SearchAnchor` |
| Autocomplete | `MEAutocomplete` | `Autocomplete` |
| List row / grouped rows / stacked cards | `MEListTile` / `MEListGroup` / `MECardList` | `ListTile` |
| Expand one tile / accordion / expandable cards | `MEExpansionTile` / `MEAccordion` / `MEExpandableList` | `ExpansionTile` |
| Popup / overflow menu | `MEMenu` (`anchorBuilder`) | `PopupMenuButton` |
| Dropdown field | `MEDropdown` (`.future` / `searchEnabled` / `multiSelect`) | `DropdownButton` |
| Multi-select list with contextual bar | `MESelection` | Custom `AppBar` swap |
| Swipe to dismiss one / column / deck | `MEDismissible` / `MEDismissibleColumn` / `MEDismissibleList` | Spring swipe with archive/delete |
| Reorder | `MEReorderableList` | `ReorderableListView` |
| Table | `MEDataTable` / `MEPaginatedDataTable` | `DataTable` |
| Stepper / timeline / tree | `MEStepper` / `METimeline` / `METreeView` | `Stepper` |
| App bar (sliver) | `MEAppBar` | `AppBar` / `SliverAppBar` |
| Search in the top bar | `MESearchAppBar` | `AppBar` + `SearchBar` |
| Destinations | `MENavigationBar` / `MENavigationRail` / `MEDrawer` | Material nav widgets |
| Tabs | `METabBar` | `TabBar` |
| Breadcrumbs / dock / command palette | `MEBreadcrumbs` / `MEDock` / `showMECommandPalette` | Custom |
| Date / range / time | `showMEDatePicker` / `showMEDateRangePicker` / `showMETimePicker` | `showDatePicker` |
| Analog clock time | `MEDialTimePicker` | Digital `showMETimePicker` only |
| On-page calendar | `MECalendar` | `CalendarDatePicker` |
| Wheel / color | `MEWheelPicker` / `MEColorPicker` / `MEColorWheel` | `CupertinoPicker` |
| Badge / tooltip / divider | `MEBadge` / `METooltip` / `MEDivider` (`.vertical`) | Material counterparts |
| Banner | `MEBanner` | `MaterialBanner` |
| Network image | `MEImage` | `Image.network` |
| Empty screen | `MEEmptyState` | Centered `Column` |
| Slivers | `MESliverList` / `MESliverGrid` / `MESliverPinnedHeader` / `MESliverSectionHeader` / `MESliverScaffold` | Raw slivers |

### Product UI Material does not have

| Intent | Use |
|---|---|
| Chat thread | `MEChatBubble`, `MEChatInput`, `MEChatTypingIndicator` |
| Markdown view / editor / code | `MEMarkdown`, `MEMarkdownEditor`, `MECodeView` |
| Rating / quantity / slide-to-confirm | `MERating`, `MEQuantityStepper`, `MESlideToConfirm` |
| Like | `MELikeButton` |
| Stats KPI | `MEStatCard` |
| File row | `MEFileCard` |
| Compare before/after | `MECompareSlider` |
| Number that ticks | `MENumberTicker` |
| Page dots | `MEPageIndicator` |
| Onboarding coach | `showMECoachmark` |
| Success / error check | `MESuccessCheck` / `MESuccessCheck.error` |
| Launch screen | `MESplashScreen` |
| PIN pad | `MEPinPad` |
| Floating selection toolbar | `MEFloatingToolbar` |
| Radial action menu | `MEOrbitMenu` |

### Charts — pick by data shape

| Data | Use |
|---|---|
| Spark / KPI sparkline | `MESparkline` |
| Bars | `MEBarChart` / `MEStackedBarChart` |
| Line series | `MELineChart` |
| Parts of a whole | `MEDonutChart` / `MEFunnelChart` |
| Gauge / speedo / thermo | `MEGauge` / `MESpeedometer` / `METhermometer` |
| Radar / bubbles / candles / heatmap | `MERadarChart` / `MEBubbleChart` / `MECandlestickChart` / `MEHeatmap` |
| Activity rings | `MEActivityRings` |

### Decorative / playful — only if the product asks

`MEDice`, `MECoinFlip`, `MESlotMachine`, `MESpinWheel`, `MEScratchCard`,
`MEFireworks`, `MELavaLamp`, `MEVinyl`, `MEJoystick`, `MEPomodoro`,
`MEMetronome`, `MEFlipClock`, `MEHourglass`, `MEBreathingRing`, `MEEqualizer`,
`MEWaveform`, `MEVuMeter`, `MESonar`, `MECompass`, `METrafficLight`,
`MELockDial`, `MEBattery`, `MESignalStrength`, `MEStreakFlame`,
`MEDayNightToggle`, `MEMoodPicker`, `MEStickyNote`, `MEPolaroid`,
`MECreditCard`, `MEBoardingPass`, `MEReceipt`, `MEStampCard`, `MEStoryRing`,
`METiltCard`, `MEFlipCard`, `MESwipeDeck`, `MEMorphingShape`, `MEMarquee`,
`METypewriter`, `MECountdown`, `MEStopwatch`, `MELiquidProgress`.

Do **not** drop these into banking, settings, or dense data screens unless
the user asked for a playful or branded moment.

Full inventory with source files: [`catalog.md`](catalog.md).

## Default choices (vague prompts)

| Situation | Default |
|---|---|
| “Add a button” / «أضف زر» | `MEButton.filled` |
| “Add a FAB” | `MEFab` |
| “Top bar” / «شريط علوي» | `MEAppBar` inside `CustomScrollView` |
| “Bottom nav” | `MENavigationBar` |
| “Form field” | `METextField` |
| “Search” / «بحث» | `MESearchAnchor.bar` |
| “Menu on a button” / «قائمة» | `MEMenu` with `anchorBuilder` |
| “Show a dialog” / «حوار» | `showMEDialog` + `MEDialog` |
| “Toast” | `showMEToast` if transient; `showMESnackBar` if there is an action |
| “Loading” | `MELoadingIndicator` for short waits; linear/circular if determinate |
| “List of settings” | `MEListGroup` of `MEListTile`s |
| “Empty state” | `MEEmptyState` |

## Where to look

| Need | File |
|---|---|
| How to construct it | [`constructors.md`](constructors.md) then `lib/src/` |
| Every widget + source path | [`catalog.md`](catalog.md) |
| Public exports | `lib/material3_expressive.dart` |
| Theme / springs | `lib/src/theme/me_theme.dart`, `me_motion.dart` |
| Playgrounds | `example/lib/gallery/catalog.dart`, `demos.dart` |
