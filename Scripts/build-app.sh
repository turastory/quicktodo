#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIGURATION="${1:-release}"
VERSION="${2:-0.1.0}"
BUILD_NUMBER="${3:-1}"
BIN_DIR="$(swift build -c "$CONFIGURATION" --package-path "$ROOT_DIR" --show-bin-path)"
APP_DIR="$ROOT_DIR/dist/QuickTodo.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
PLIST_TEMPLATE="$ROOT_DIR/AppResources/Info.plist"
PLIST_OUTPUT="$CONTENTS_DIR/Info.plist"
RESOURCE_BUNDLE="$BIN_DIR/KeyboardShortcuts_KeyboardShortcuts.bundle"

swift build -c "$CONFIGURATION" --package-path "$ROOT_DIR"

rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

cp "$BIN_DIR/QuickTodo" "$MACOS_DIR/QuickTodo"
chmod +x "$MACOS_DIR/QuickTodo"

sed \
  -e "s/__VERSION__/$VERSION/g" \
  -e "s/__BUILD__/$BUILD_NUMBER/g" \
  "$PLIST_TEMPLATE" > "$PLIST_OUTPUT"

if [[ -d "$RESOURCE_BUNDLE" ]]; then
  cp -R "$RESOURCE_BUNDLE" "$RESOURCES_DIR/"
fi

echo "Created $APP_DIR"
