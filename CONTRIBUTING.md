# Contributing

Thank you for contributing to `material3_expressive`.

## Development setup

```sh
git clone https://github.com/asimawdah/material_expressive.git
cd material_expressive
flutter pub get
cd example && flutter pub get
```

Run the gallery:

```sh
cd example
flutter run
```

## Quality checks

Before opening a pull request, run:

```sh
flutter analyze --fatal-infos
dart format .
flutter test
```

CI runs the same checks on every push and pull request.

## Golden tests

Golden files live under `test/golden/goldens/`. After intentionally changing
widget appearance, regenerate them with:

```sh
flutter test --update-goldens
```

Commit the updated PNGs alongside your code changes.

## Code style

- Follow `analysis_options.yaml` (Flutter lints + `prefer_const_constructors`).
- Match existing naming: `ME` prefix for public widgets, spring motion via
  `METheme.of(context).motion`.
- Keep accessibility in mind: semantics labels, keyboard navigation, and
  respect for `MediaQuery.disableAnimations`.

## Pull requests

- Keep changes focused; one feature or fix per PR when possible.
- Update `CHANGELOG.md` under `[Unreleased]` for user-visible changes.
- Add or update tests for behavior changes.
