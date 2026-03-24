#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${1:?version is required, e.g. 0.1.0}"
BUILD_NUMBER="${2:-1}"
REPO="${3:-turastory/quicktodo}"
TAG="v$VERSION"

"$ROOT_DIR/Scripts/create-release-zip.sh" "$VERSION" "$BUILD_NUMBER"
"$ROOT_DIR/Scripts/render-cask.sh" "$VERSION" "$(cat "$ROOT_DIR/dist/QuickTodo.sha256")"

gh release create "$TAG" \
  "$ROOT_DIR/dist/QuickTodo.zip" \
  "$ROOT_DIR/dist/QuickTodo.sha256" \
  --repo "$REPO" \
  --title "$TAG" \
  --notes "QuickTodo $VERSION"
