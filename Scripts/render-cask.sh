#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${1:?version is required}"
SHA256="${2:?sha256 is required}"
APP_REPO="${QUICKTODO_APP_REPO:-turastory/quicktodo}"
CASK_TOKEN="${QUICKTODO_CASK_TOKEN:-quicktodo}"
APP_NAME="${QUICKTODO_APP_NAME:-QuickTodo}"
APP_DESC="${QUICKTODO_APP_DESC:-Single-file Markdown todo panel for macOS}"
OUTPUT_PATH="${3:-$ROOT_DIR/Homebrew/$CASK_TOKEN.rb}"

cat > "$OUTPUT_PATH" <<EOF
cask "$CASK_TOKEN" do
  version "$VERSION"
  sha256 "$SHA256"

  url "https://github.com/$APP_REPO/releases/download/v#{version}/$APP_NAME.zip"
  name "$APP_NAME"
  desc "$APP_DESC"
  homepage "https://github.com/$APP_REPO"

  app "$APP_NAME.app"
end
EOF

echo "Rendered $OUTPUT_PATH"
