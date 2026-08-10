# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- GitHub Actions CI workflow (`analyze`, `format`, `test`).
- `MEMotionScheme.reduced` and automatic reduced-motion support via
  `MediaQuery.disableAnimations` in `METheme.of`.
- `MESpringSpec.instant` for zero-duration spring targets.
- `MEKeyboard` helper for arrow-key navigation and Enter/Space activation.
- Keyboard navigation for `MENavigationBar` and `METabBar` (arrows, Home, End).
- Keyboard activation (Enter/Space) for pressable widgets via `MEPressable`.
- Golden test scaffold and keyboard/widget tests.
- `CONTRIBUTING.md` with development and golden-test instructions.
- MIT `LICENSE` and `CHANGELOG.md`.
- Expanded widget tests for buttons, switches, and reduced motion.

### Fixed
- Example gallery: added `darkTheme` and theme/motion toggles in the drawer.

### Changed
- `pubspec.yaml`: added `repository` and `issue_tracker` metadata.

## [0.1.0] - 2026-08-06

### Added
- Initial release of Material 3 Expressive widgets for Flutter.
- Spring-physics motion system (`MEMotionScheme`, `METheme`).
- 150+ expressive widgets covering buttons, navigation, inputs, charts,
  chat, markdown, and more.
- Example gallery app in `example/`.
