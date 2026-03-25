#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${1:?version is required, e.g. 0.1.0}"
BUILD_NUMBER="${2:-1}"
REPO="${3:-${QUICKTODO_APP_REPO:-turastory/quicktodo}}"
APP_NAME="${QUICKTODO_APP_NAME:-QuickTodo}"
SHA256_PATH="$ROOT_DIR/dist/$APP_NAME.sha256"
ZIP_PATH="$ROOT_DIR/dist/$APP_NAME.zip"
LOCAL_CASK_PATH="$ROOT_DIR/Homebrew/${QUICKTODO_CASK_TOKEN:-quicktodo}.rb"
TAG="v$VERSION"

"$ROOT_DIR/Scripts/create-release-zip.sh" "$VERSION" "$BUILD_NUMBER"
"$ROOT_DIR/Scripts/render-cask.sh" "$VERSION" "$(cat "$SHA256_PATH")"

gh release create "$TAG" \
  "$ZIP_PATH" \
  "$SHA256_PATH" \
  "$LOCAL_CASK_PATH" \
  --repo "$REPO" \
  --title "$TAG" \
  --notes "QuickTodo $VERSION"
