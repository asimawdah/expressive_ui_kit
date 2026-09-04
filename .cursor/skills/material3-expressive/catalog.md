# material3_expressive catalog

Use this file when the picker table in `SKILL.md` does not name a widget.
Source paths are relative to the package root. Import remains:

```dart
import 'package:material3_expressive/material3_expressive.dart';
```

Prefix is **`ME`**, never `M3E`. Confirm constructors in the source file
before generating code.

## Theme

| Type | File | Use when |
|---|---|---|
| `METheme` / `METhemeData` | `lib/src/theme/me_theme.dart` | Wrapping the app; `.expressive` or `.standard` |
| `MEMotionScheme` / `MESpringSpec` | `lib/src/theme/me_motion.dart` | Custom springs; prefer `METheme.of(context).motion`. Driven by `motor` (same engine as `m3e_core`). Extra `popup` / `overflow` springs. |
| `MEShapeScheme` / `MEShapeMorph` | `lib/src/theme/me_shapes.dart` | Custom container shapes |
| `METypography` | `lib/src/theme/me_theme.dart` | Emphasized headlines |

## Buttons

| Type | File | Replaces | Use when |
|---|---|---|---|
| `MEButton` | `lib/src/buttons/me_button.dart` | `FilledButton` / `ElevatedButton` / `OutlinedButton` / `TextButton` | Labeled action. Variants: `.filled` `.tonal` `.elevated` `.outlined` `.text`. Sizes: `MEButtonSize`. |
| `METoggleButton` | `lib/src/buttons/me_toggle_button.dart` | — | Checked + **label** (favorite, bold). Not icon-only. |
| `METoggleButtonGroup` | `lib/src/buttons/me_toggle_button_group.dart` | format tool clusters | Neighbor-squish row of `METoggleButton`s. `style:` standard or connected. |
| `MEIconButton` | `lib/src/buttons/me_icon_button.dart` | `IconButton` | Icon-only; `selected:` for icon toggle. |
| `MEButtonGroup` | `lib/src/buttons/me_button_group.dart` | connected toggle rows | Neighbor-squish tool cluster. |
| `MESegmentedButton` | `lib/src/buttons/me_segmented_button.dart` | `SegmentedButton` | Exclusive or multi select in one pill. |
| `MESplitButton` | `lib/src/buttons/me_split_button.dart` | — | Primary action + overflow chevron. Menu is `List<MEMenuNode>`. |
| `MEFab` / `.extended` | `lib/src/buttons/me_fab.dart` | `FloatingActionButton` | Page primary action. |
| `MEFabMenu` | `lib/src/buttons/me_fab_menu.dart` | speed dial | FAB that fans out actions. |
| `MEProgressButton` | `lib/src/buttons/me_progress_button.dart` | — | Button that shows progress in-place. |
| `MEHoldButton` | `lib/src/buttons/me_hold_button.dart` | — | Confirm by holding. |
| `MELikeButton` | `lib/src/buttons/me_like_button.dart` | — | Heart / like with bounce. |
| `MEOrbitMenu` | `lib/src/buttons/me_orbit_menu.dart` | — | Radial actions around a hub. |
| `MEFloatingToolbar` | `lib/src/buttons/me_floating_toolbar.dart` | — | Selection toolbar near content. |
| `METoolbar` | `lib/src/navigation/me_toolbar.dart` | contextual `BottomAppBar` | Floating/docked action cluster. |
| `ExpressiveButton` | `lib/src/buttons/expressive_button.dart` | — | **Deprecated.** Use `MEButton`. |

## Navigation

| Type | File | Replaces | Use when |
|---|---|---|---|
| `MEAppBar` | `lib/src/navigation/me_app_bar.dart` | `AppBar` / `SliverAppBar` | **Sliver** top bar. Put in `CustomScrollView`. Sizes: small/medium/large. |
| `METopAppBar` | `lib/src/navigation/me_app_bar.dart` | `AppBar` | **Scaffold.appBar** 64dp bar. Not a sliver. |
| `MESearchAppBar` | `lib/src/navigation/me_app_bar.dart` | search `AppBar` | Top bar that expands into search. |
| `MEBottomAppBar` | `lib/src/navigation/me_bottom_app_bar.dart` | `BottomAppBar` | Docked actions + trailing FAB. |
| `MENavigationBar` | `lib/src/navigation/me_navigation_bar.dart` | `NavigationBar` | 2–5 root destinations at the bottom. |
| `MENavigationRail` | `lib/src/navigation/me_navigation_rail.dart` | `NavigationRail` | Wide/desktop destinations. Optional `fab:` and `sectionLabel` on destinations. |
| `MEDrawer` | `lib/src/navigation/me_drawer.dart` | `Drawer` / `NavigationDrawer` | Side destinations. `icon` is `IconData`. |
| `METabBar` | `lib/src/navigation/me_tab_bar.dart` | `TabBar` | In-page sections. `variant:` primary pill or secondary underline. |
| `MEBreadcrumbs` | `lib/src/navigation/me_breadcrumbs.dart` | — | Nested location path. |
| `MEDock` | `lib/src/navigation/me_dock.dart` | — | Magnifying icon dock. |
| `showMECommandPalette` | `lib/src/overlays/me_command_palette.dart` | — | Keyboard command search. |

## Inputs

| Type | File | Replaces | Use when |
|---|---|---|---|
| `METextField` | `lib/src/inputs/me_text_field.dart` | `TextField` | Single/multi-line text. `METextFieldVariant.filled` / `.outlined`. |
| `MEPasswordField` | `lib/src/inputs/me_password_field.dart` | — | Password + optional strength meter. |
| `MESearchBar` | `lib/src/inputs/me_search_bar.dart` | `SearchBar` | Search field **without** a suggestion overlay. |
| `MESearchAnchor` | `lib/src/inputs/me_search_anchor.dart` | `SearchAnchor` | Search that opens suggestions. Prefer `.bar`. |
| `MEAutocomplete` | `lib/src/inputs/me_autocomplete.dart` | `Autocomplete` | Typed suggestions in a field. |
| `METagInput` | `lib/src/inputs/me_tag_input.dart` | — | Chips entered as tags. |
| `MEOtpInput` | `lib/src/inputs/me_otp_input.dart` | — | One-time code boxes. |
| `MEPinPad` | `lib/src/inputs/me_pin_pad.dart` | — | Numeric PIN pad. |
| `MEColorPicker` | `lib/src/inputs/me_color_picker.dart` | — | Swatch color picker. |
| `MEColorWheel` | `lib/src/pickers/me_color_wheel.dart` | — | Hue wheel. |

## Lists / menus

| Type | File | Replaces | Use when |
|---|---|---|---|
| `MEListTile` / `MEListGroup` | `lib/src/lists/me_list_tile.dart` | `ListTile` | Settings rows; group sets corner radii. `variant:` filled / elevated / outlined. |
| `MECardList` | `lib/src/lists/me_card_list.dart` | stacked cards | Overlapping card stack. |
| `MEMenu` / `MEMenuEntry` / `MEMenuGroup` | `lib/src/lists/me_menu.dart` | `PopupMenuButton` | Overflow / dropdown menu. Overlay spring, not `PopupRoute`. |
| `MEMenuAnchor` | `lib/src/lists/me_menu.dart` | `MenuAnchor` | Menu from a list of `MEMenuItem`. |
| `showMEMenu` | `lib/src/lists/me_menu.dart` | — | Imperative menu at a rect. |
| `MEDropdown` / `MEDropdownMenu` | `lib/src/lists/me_dropdown.dart` | `DropdownButton` | Form field that picks one value. `.future` / `multiSelect` / `searchEnabled`. |
| `MEExpansionTile` | `lib/src/lists/me_expansion_tile.dart` | `ExpansionTile` | One expandable row. |
| `MEAccordion` | `lib/src/lists/me_accordion.dart` | `ExpansionPanelList` | Several expandable sections. |
| `MEExpandableList` | `lib/src/lists/me_expandable_list.dart` | — | Expandable **cards** (also `.scrollable` / `.sliver`). |
| `MESelection` + `MESelectionAppBar` | `lib/src/lists/me_selection.dart` | custom CAB | Multi-select list with contextual bar. |
| `MEDismissible` | `lib/src/lists/me_dismissible.dart` | `Dismissible` | Spring swipe; archive start / delete end. |
| `MEDismissibleColumn` / `MEDismissibleList` | `lib/src/lists/me_dismissible_list.dart` | — | Neighbour-pull card stack. |
| `MEReorderableList` | `lib/src/lists/me_reorderable_list.dart` | `ReorderableListView` | Drag to reorder. |
| `MEDataTable` / `MEPaginatedDataTable` | `lib/src/lists/me_data_table.dart` | `DataTable` | Tabular data. |
| `MEStepper` | `lib/src/lists/me_stepper.dart` | `Stepper` | Linear steps. |
| `METimeline` | `lib/src/lists/me_timeline.dart` | — | Event timeline. |
| `METreeView` | `lib/src/lists/me_tree_view.dart` | — | Nested nodes. |

## Containers / overlays

| Type | File | Replaces | Use when |
|---|---|---|---|
| `MECard` | `lib/src/containers/me_card.dart` | `Card` | Elevated/filled/outlined surface. |
| `MEChip` | `lib/src/containers/me_chip.dart` | `Chip` / `FilterChip` / `InputChip` | `MEChipType` assist/filter/input/suggestion. |
| `MECarousel` | `lib/src/containers/me_carousel.dart` | `CarouselView` | `type:` hero / contained / uncontained. Optional `axis:` and `onChange`. |
| `MEAvatar` / `MEAvatarGroup` | `lib/src/containers/me_avatar.dart` | `CircleAvatar` | Face or initials. |
| `ExpressiveIconContainer` | `lib/src/containers/expressive_icon_container.dart` | — | Cookie-shaped icon well. |
| `MEShapeContainer` | `lib/src/containers/me_shape_container.dart` | — | Clip a child to a `MaterialShapes` polygon. |
| `MEDialog` / `showMEDialog` | `lib/src/containers/me_dialog.dart` | `AlertDialog` / `showDialog` | Modal confirm/info. |
| `showMEFullScreenDialog` | `lib/src/containers/me_dialog.dart` | fullscreen dialog | Editor covering the screen. |
| `showMESelectionDialog` | `lib/src/containers/me_dialog.dart` | — | Pick one/many from a list. |
| `showMEBottomSheet` | `lib/src/containers/me_bottom_sheet.dart` | `showModalBottomSheet` | Sheet from the bottom. |
| `showMESideSheet` | `lib/src/containers/me_side_sheet.dart` | — | Sheet from the side (wide screens). |
| `MEEmptyState` | `lib/src/containers/me_empty_state.dart` | — | Zero-data screen. |
| `MEImage` | `lib/src/containers/me_image.dart` | `Image.network` | Network image with loading/error. |
| `MEFileCard` / `MEStatCard` | `lib/src/containers/me_file_card.dart`, `me_stat_card.dart` | — | File row / KPI card. |
| `MECompareSlider` | `lib/src/containers/me_compare_slider.dart` | — | Before/after. |
| `MESplashScreen` | `lib/src/containers/me_splash_screen.dart` | — | Launch screen. |

## Controls

| Type | File | Replaces | Use when |
|---|---|---|---|
| `MESwitch` | `lib/src/controls/me_switch.dart` | `Switch` | On/off. |
| `MECheckbox` | `lib/src/controls/me_checkbox.dart` | `Checkbox` | Optional `label`. |
| `MERadio` | `lib/src/controls/me_radio.dart` | `Radio` | Optional `label`. |
| `MESlider` | `lib/src/controls/me_slider.dart` | `Slider` | `.wavy` `.centered` `.vertical`. Optional `thumbLength` / `cornerRadius`. |
| `MERangeSlider` | `lib/src/controls/me_range_slider.dart` | `RangeSlider` | Two thumbs; `.wavy`. |
| `MERating` | `lib/src/controls/me_rating.dart` | — | Stars. |
| `MEQuantityStepper` | `lib/src/controls/me_quantity_stepper.dart` | — | − / count / +. |
| `MESlideToConfirm` | `lib/src/controls/me_slide_to_confirm.dart` | — | Slide to confirm. |
| `MEKnob` | `lib/src/controls/me_knob.dart` | — | Rotary value. |
| `MEWheelPicker` | `lib/src/pickers/me_wheel_picker.dart` | `CupertinoPicker` | Scroll wheel. |
| `MEDayNightToggle` / `MEMoodPicker` | `lib/src/controls/me_day_night_toggle.dart`, `me_mood_picker.dart` | — | Theme / mood. |

## Pickers

| Type | File | Replaces | Use when |
|---|---|---|---|
| `showMEDatePicker` | `lib/src/pickers/me_pickers.dart` | `showDatePicker` | Pick a day. |
| `showMEDateRangePicker` | `lib/src/pickers/me_pickers.dart` | `showDateRangePicker` | Pick a range. |
| `showMETimePicker` | `lib/src/pickers/me_pickers.dart` | `showTimePicker` | Digital time. |
| `MEDialTimePicker` | `lib/src/pickers/me_dial_time_picker.dart` | analog time | Clock-face time. |
| `MECalendar` | `lib/src/pickers/me_calendar.dart` | `CalendarDatePicker` | In-page month grid. |

## Progress / slivers / communication

| Type | File | Replaces | Use when |
|---|---|---|---|
| `MELinearProgressIndicator` | `lib/src/progress/me_linear_progress.dart` | `LinearProgressIndicator` | Determinate/indeterminate bar. |
| `MECustomProgressIndicator` | `lib/src/progress/me_custom_progress.dart` | — | Split-track bar; `waved:` for stroke waves. |
| `MEWavedProgressIndicator` | `lib/src/progress/me_waved_progress.dart` | — | `.linear` / `.circular` animated wave stroke. |
| `MECircularProgressIndicator` | `lib/src/progress/me_circular_progress.dart` | `CircularProgressIndicator` | Spinner. |
| `MELoadingIndicator` | `lib/src/progress/me_loading_indicator.dart` | short wait | Compact morphing wait. |
| `MERefreshIndicator` | `lib/src/progress/me_refresh_indicator.dart` | `RefreshIndicator` | Pull to refresh. |
| `MESkeleton` / `MESkeletonizer` | `lib/src/progress/me_skeleton.dart` | shimmer | Placeholder layout. |
| `MESliverList` / `MESliverGrid` / `MESliverPinnedHeader` / `MESliverSectionHeader` | `lib/src/slivers/me_slivers.dart` | matching slivers | Scroll content under `MEAppBar`. |
| `MESliverScaffold` | `lib/src/slivers/me_sliver_scaffold.dart` | `Scaffold` + `CustomScrollView` | App bar + slivers + optional nav. |
| `MEBadge` | `lib/src/communication/me_badge.dart` | `Badge` | Count on an icon. |
| `METooltip` | `lib/src/communication/me_tooltip.dart` | `Tooltip` | Hover/long-press hint. |
| `MEDivider` | `lib/src/communication/me_divider.dart` | `Divider` | `.vertical` available. |
| `MEBanner` | `lib/src/communication/me_banner.dart` | `MaterialBanner` | Persistent page message. |
| `showMESnackBar` | `lib/src/communication/me_snack_bar.dart` | `SnackBar` | Message **with** action. |
| `showMEToast` | `lib/src/communication/me_toast.dart` | — | Transient message, no action. |
| `MEPageIndicator` | `lib/src/communication/me_page_indicator.dart` | — | Page dots. |
| `MENumberTicker` | `lib/src/communication/me_number_ticker.dart` | — | Number that ticks. |
| `showMECoachmark` | `lib/src/communication/me_coachmark.dart` | — | Onboarding spotlight. |
| `MESuccessCheck` | `lib/src/communication/me_success_check.dart` | — | Success / `.error`. |

## Content / charts

| Type | File | Use when |
|---|---|---|
| `MEChatBubble` / `MEChatInput` / `MEChatTypingIndicator` | `lib/src/chat/` | Messaging UI. |
| `MEMarkdown` / `MEMarkdownEditor` / `MECodeView` | `lib/src/markdown/` | Docs, notes, code. |
| `MESparkline` / `MEBarChart` / `MEStackedBarChart` / `MELineChart` | `lib/src/charts/` | Spark, bars, lines. |
| `MEDonutChart` / `MEFunnelChart` / `MEGauge` / `MESpeedometer` / `METhermometer` | `lib/src/charts/` | Parts of a whole / meters. |
| `MERadarChart` / `MEBubbleChart` / `MECandlestickChart` / `MEHeatmap` / `MEActivityRings` | `lib/src/charts/` | Specialized charts. |

## Playful / decorative

Only if the product asks: `MEDice`, `MECoinFlip`, `MESlotMachine`, `MESpinWheel`,
`MEScratchCard`, `MEFireworks`, `MELavaLamp`, `MEVinyl`, `MEJoystick`,
`MEPomodoro`, `MEMetronome`, `MEFlipClock`, `MEHourglass`, `MEBreathingRing`,
`MEEqualizer`, `MEWaveform`, `MEVuMeter`, `MESonar`, `MECompass`,
`METrafficLight`, `MELockDial`, `MEBattery`, `MESignalStrength`, `MEStreakFlame`,
`MEStickyNote`, `MEPolaroid`, `MECreditCard`, `MEBoardingPass`, `MEReceipt`,
`MEStampCard`, `MEStoryRing`, `METiltCard`, `MEFlipCard`, `MESwipeDeck`,
`MEMorphingShape`, `MEMarquee`, `METypewriter`, `MECountdown`, `MEStopwatch`,
`MELiquidProgress`.

See `example/lib/gallery/catalog.dart` for a runnable demo of each public widget.
