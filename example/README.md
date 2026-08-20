# Material 3 Expressive Gallery

Example app showcasing the `material3_expressive` widget library.

## Run

From this directory:

```bash
flutter pub get
flutter run
```

## Android release APKs

Fat APK (all ABIs in one file):

```bash
flutter build apk --release --target-platform android-arm,android-arm64,android-x64
```

`build/app/outputs/flutter-apk/app-release.apk`

One APK per ABI (smaller downloads):

```bash
flutter build apk --release --split-per-abi --target-platform android-arm,android-arm64,android-x64
```

| ABI | File | Typical devices |
| --- | --- | --- |
| `armeabi-v7a` | `app-armeabi-v7a-release.apk` | 32-bit ARM phones |
| `arm64-v8a` | `app-arm64-v8a-release.apk` | Most current phones |
| `x86_64` | `app-x86_64-release.apk` | Emulators, ChromeOS, some tablets |

Flutter 3.47 does not ship 32-bit `x86`.


## How to try every widget

The home screen is a **searchable gallery of every public widget**. Tap a row
to open that component's live playground.

Use the drawer for:

- **Tours** — the original grouped pages (buttons, progress, controls, …)
- **Appearance** — system / light / dark
- **Motion** — expressive (bouncy) vs standard (subtle)
