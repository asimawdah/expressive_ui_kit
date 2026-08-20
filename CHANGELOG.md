# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `MEShapeContainer` — clip a child to an official `MaterialShapes` polygon.
- Determinate `MELoadingIndicator` (`value:`) that morphs through the shape sequence as progress advances.
- Tristate `MECheckbox` (mixed / indeterminate).
- `MEButtonSizeTokens` — shared 32/40/56/96/136 heights and pressed corner radii (8/8/12/16/16).
- `MEMenu.onOpenChanged` so split buttons can morph the trailing chevron while open.
- `MEFabMenuPosition` and 80→56 trigger morph when the FAB menu opens.
- Re-export of `MaterialShapes` / `RoundedPolygon` / `Morph`.
- `MESplashScreen` — branded launch screen with staged reveal animation.
- `MEPinPad` — numeric PIN entry with spring feedback and shake-on-reject.
- `MEReceipt` — receipt-style container with print-out animation.
- `MEVinyl` — spinning vinyl record with tonearm and tap-to-toggle playback.
- `METoggleButton` — checked/unchecked action with round-to-square morphing.
- `MESearchAnchor` / `MESearchAppBar` — search view anchored to a bar or app bar.
- `MECardList` — stacked, tappable card rows.
- `MESelection` — multi-select host with contextual app bar and tiles.
- `MEDismissibleColumn` / `MEDismissibleList` — swipe-to-dismiss card lists.
- `MEExpandableList` — expandable cards with expressive open/close motion.
- `MEDialTimePicker` — analog hour/minute dial.
- `showMEFullScreenDialog`, `showMESelectionDialog`, `showMEDateRangePicker`.
- `MESlider.wavy` / `.centered` / `.vertical` and `MERangeSlider.wavy`.
- `MEDivider.vertical`, chip types, badge alignment, radio/checkbox labels.
- Searchable example gallery with a live playground for every public widget.
- `MEMotionReveal`, `MEMotionWidth`, and `MEMotionOpacity` — implicit
  motor springs that replace `AnimatedSize` / width `AnimatedContainer` /
  `AnimatedOpacity` on ME widgets.
- Overlay-based `MEMenu` popup (Y-axis spring expand) matching Material 3
  Expressive menus — no slow `PopupRoute` transition.
- Cursor skill (`.cursor/skills/material3-expressive/SKILL.md`) so agents
  can pick the right `ME*` widget for a job.
- Widget tests covering the M3E gap components, menu overlay, and every
  example-gallery playground.
- Android host for the example gallery (fat release APK: armeabi-v7a,
  arm64-v8a, x86_64).

### Changed
- `MEPressable` morphs against the **laid-out child size** instead of a
  100×40 fallback, so large/XL pills and wrap-content buttons keep the
  correct stadium radius.
- Shared `MEButtonSizeTokens` now also expose padding, icon size, icon
  gap and label style; split and toggle buttons follow the same scale.
- `METopAppBar` for `Scaffold.appBar`, `METoggleButtonGroup` (standard and
  connected), dropdown `.future` / multi-select / `searchEnabled`, tab
  `secondary` variant, carousel hero/contained/uncontained + `onChange`,
  rail FAB slot and destination `sectionLabel`s, drawer sections,
  list-tile `outlined`/`elevated` variants, slider `thumbLength` /
  `cornerRadius`.
- Extended FAB padding/gap uses the spec tokens (16/8, 26/12, 28/16)
  instead of height ratios.
- Chips use 8/16 start-end padding and 8dp icon gaps; cards press toward
  a squarer corner; list tiles are at least 56/72dp; snackbars are pills.
- Button press/selection morph uses **fast** spatial springs on release
  (press-in stays snappy effects). Corner changes no longer use the slower
  default spatial token.
- `MEDismissible` / `MEDismissibleColumn` swipe is motor-spring physics
  (finger follow, pill archive/delete, icon scale, snap-back, fly-off,
  neighbour pull) instead of stock `Dismissible`.
- Remaining ME surfaces (chips, dismissible, segmented, rail, dock, stepper,
  selection, command palette, slivers, OTP, password meter, wheel picker,
  timeline, image fade, skeletonizer, slide-to-confirm, mood, heatmap,
  charts, compare slider, stopwatch, hold abort, coachmark, lists) spring
  with `MEMotionBuilder` / `MEMotionReveal` / `MEMotionWidth` /
  `MEMotionOpacity` instead of hardcoded `Duration`/`Curves`.
- `MEMotionBuilder.from` matches motor `SingleMotionBuilder.from` for
  enter springs (charts, gauges, like counts).
- Deprecated `ExpressiveButton` press uses `MEPressable` corner morph
  (no squash, no `Curves.easeOutCubic`).
- PIN reject shake, refresh-indicator snap/scale, heatmap/funnel/
  candlestick/bubble enter, and remaining switchers spring with motor.
- Remaining one-shot ME widgets (`MEReceipt` print, `MESplashScreen` exit,
  `MEDice` tumble, `MECoinFlip`, `MEVinyl` tonearm, `MELikeButton` burst,
  breathing-ring labels, chat typing bounce) use `springTo` /
  `MEMotionBuilder` instead of `Duration`/`Curves`. `springTo` now returns
  a `TickerFuture` so callers can await settlement.
- Core surfaces animate with `motor` springs (`MaterialSpringMotion` tokens,
  the same engine as `m3e_core`) via `METheme` — menus use the popup spring.
- Buttons, icon buttons, FABs, chips and cards morph **corner radius** on
  press (snappy effects spring in, spatial spring out) like `m3e_core` —
  they no longer squash with `Transform.scale`.
- `MEButtonGroup` / `METoggleButtonGroup` neighbor-squish is a layout
  width transfer (15% growth, neighbors give the space back) driven by
  `MEMotionBuilder`, including the spring-back after release.
- Buttons, icon buttons and toggles morph on press to the M3E **pressed
  corner radii** (not all the way to square/stadium).
- Toggle unselected/selected colors follow M3E tokens (filled unselected
  uses `surfaceContainerHighest`, not primary).
- `MESwitch` track is 52×32 with 16/24dp thumbs, press stretch, and drag.
- `MESplitButton` uses `MEMenu` instead of Flutter `MenuAnchor`.
- `MEFab.extended` defaults to small (56dp) per the extended FAB spec.
- Loading and progress indicators honor reduced motion; loading morph
  springs come from `METheme`.
- `MEButtonGroup` height follows `MEButtonSize` (default small / 40dp).
- Example gallery widget catalog now indexes all 150+ exported widgets.
- Analyzer excludes generated `build/` and platform directories.
- `ExpressiveButton` is deprecated in favor of `MEButton`.
- Keyboard navigation added to `MENavigationRail` and `MESegmentedButton`.
- Root `pubspec.lock` is tracked for reproducible CI.
- Collapsed `MEExpandableList` bodies are offstaged so they are not hittable.

### Added
- Vertical keyboard helpers on `MEKeyboard`.
- Widget tests for `METextField`, `MEDialog`, and `showMEDialog`.
- Golden tests for text field, dialog, and dark-theme button variants.

## [0.2.0] - 2026-08-10

### Added
- GitHub Actions CI workflow (`analyze`, `format`, `test`).
- `MEMotionScheme.reduced` and automatic reduced-motion via
  `MediaQuery.disableAnimations` in `METheme.of`.
- `MEKeyboard` helper and keyboard navigation for `MENavigationBar`,
  `METabBar`, and pressable widgets (`Enter`/`Space`).
- `MEPaginatedDataTable` — expressive replacement for `PaginatedDataTable`.
- `MEReorderableList` — expressive replacement for `ReorderableListView`.
- Searchable **Widget catalog** page in the example gallery.
- Golden tests for buttons, switches, tab bar, and navigation bar.
- `CONTRIBUTING.md`, MIT `LICENSE`, and expanded widget tests (26+).
- `pubspec.yaml` topics and documentation link for pub.dev.

### Fixed
- Example gallery: added `darkTheme` and theme/motion toggles in the drawer.

### Changed
- Bumped package version to `0.2.0`.
- Applied `dart format` across the codebase for CI compliance.

## [0.1.0] - 2026-08-06

### Added
- Initial release of Material 3 Expressive widgets for Flutter.
- Spring-physics motion system (`MEMotionScheme`, `METheme`).
- 150+ expressive widgets covering buttons, navigation, inputs, charts,
  chat, markdown, and more.
- Example gallery app in `example/`.
