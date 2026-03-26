#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SVG_PATH="$ROOT_DIR/AppResources/QuickTodoIcon.svg"
ICNS_PATH="$ROOT_DIR/AppResources/QuickTodo.icns"
TMP_DIR="$(mktemp -d)"
PNG_DIR="$TMP_DIR/png"
ICONSET_DIR="$TMP_DIR/QuickTodo.iconset"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

mkdir -p "$PNG_DIR" "$ICONSET_DIR"

qlmanage -t -s 1024 -o "$PNG_DIR" "$SVG_PATH" >/dev/null

MASTER_PNG="$(find "$PNG_DIR" -name '*.png' -print -quit)"

if [[ -z "$MASTER_PNG" || ! -f "$MASTER_PNG" ]]; then
  echo "Failed to render PNG preview from $SVG_PATH" >&2
  exit 1
fi

create_icon() {
  local size="$1"
  local name="$2"
  sips -z "$size" "$size" "$MASTER_PNG" --out "$ICONSET_DIR/$name" >/dev/null
}

create_icon 16 icon_16x16.png
create_icon 32 icon_16x16@2x.png
create_icon 32 icon_32x32.png
create_icon 64 icon_32x32@2x.png
create_icon 128 icon_128x128.png
create_icon 256 icon_128x128@2x.png
create_icon 256 icon_256x256.png
create_icon 512 icon_256x256@2x.png
create_icon 512 icon_512x512.png
create_icon 1024 icon_512x512@2x.png

iconutil -c icns "$ICONSET_DIR" -o "$ICNS_PATH"

echo "Generated $ICNS_PATH"
