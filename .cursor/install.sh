#!/usr/bin/env bash
# Idempotent Cloud Agent bootstrap for the material3_expressive Flutter package.
# Installs the Flutter Linux toolchain + fonts, the pinned Flutter SDK, and
# resolves dependencies for both the package and its example gallery.
# Safe to run repeatedly; produces durable state captured by the environment build.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"   # material_expressive
FLUTTER_VERSION="3.44.9"
FLUTTER_HOME="$HOME/flutter"

log() { printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }

# ---------------------------------------------------------------------------
log "System packages (Flutter Linux toolchain + golden-test fonts)"
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -qq
sudo apt-get install -y -qq \
  clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev \
  libstdc++-12-dev unzip xz-utils curl git ca-certificates \
  fonts-dejavu-core fonts-liberation fontconfig
fc-cache -f >/dev/null 2>&1 || true

# ---------------------------------------------------------------------------
log "Flutter SDK $FLUTTER_VERSION"
if [ ! -x "$FLUTTER_HOME/bin/flutter" ] \
   || ! "$FLUTTER_HOME/bin/flutter" --version 2>/dev/null | grep -q "Flutter $FLUTTER_VERSION"; then
  curl -fSL "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" -o /tmp/flutter.tar.xz
  rm -rf "$FLUTTER_HOME"
  tar -xf /tmp/flutter.tar.xz -C "$HOME"
  rm -f /tmp/flutter.tar.xz
fi
git config --global --add safe.directory "$FLUTTER_HOME" || true
sudo ln -sf "$FLUTTER_HOME/bin/flutter" /usr/local/bin/flutter
sudo ln -sf "$FLUTTER_HOME/bin/dart" /usr/local/bin/dart
export PATH="$FLUTTER_HOME/bin:$PATH"
flutter config --no-analytics >/dev/null 2>&1 || true
flutter precache --linux --web >/dev/null 2>&1 || true
flutter --version

# ---------------------------------------------------------------------------
log "Resolve package dependencies"
cd "$REPO_DIR"
flutter pub get

log "Resolve example gallery dependencies"
cd "$REPO_DIR/example"
flutter pub get

# Generate the web platform scaffold so the gallery can be served by the
# "gallery" terminal. Only adds the untracked web/ folder; never touches lib/.
if [ ! -d "$REPO_DIR/example/web" ]; then
  flutter create --platforms=web --project-name material3_expressive_example . >/dev/null
fi

log "Install complete. Run 'flutter test' or open the gallery on http://localhost:8080."
