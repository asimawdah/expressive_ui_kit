# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `MESplashScreen` — branded launch screen with staged reveal animation.
- `MEPinPad` — numeric PIN entry with spring feedback and shake-on-reject.
- `MEReceipt` — receipt-style container with print-out animation.
- `MEVinyl` — spinning vinyl record with tonearm and tap-to-toggle playback.

### Changed
- Example gallery widget catalog now indexes all 150+ exported widgets.
- Analyzer excludes generated `build/` and platform directories.
- `ExpressiveButton` is deprecated in favor of `MEButton`.
- Keyboard navigation added to `MENavigationRail` and `MESegmentedButton`.
- Root `pubspec.lock` is tracked for reproducible CI.

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
