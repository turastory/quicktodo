#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${1:?version is required}"
SHA256="${2:?sha256 is required}"
OUTPUT_PATH="${3:-$ROOT_DIR/Homebrew/quicktodo.rb}"

cat > "$OUTPUT_PATH" <<EOF
cask "quicktodo" do
  version "$VERSION"
  sha256 "$SHA256"

  url "https://github.com/turastory/quicktodo/releases/download/v#{version}/QuickTodo.zip"
  name "QuickTodo"
  desc "Single-file Markdown todo panel for macOS"
  homepage "https://github.com/turastory/quicktodo"

  app "QuickTodo.app"
end
EOF

echo "Rendered $OUTPUT_PATH"
