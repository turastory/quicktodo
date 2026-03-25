#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/release-common.sh"
VERSION="${1:?version is required, e.g. 0.1.0}"
BUILD_NUMBER="${2:-1}"
REPO="${3:-$QUICKTODO_APP_REPO}"
SHA256_PATH="$ROOT_DIR/dist/$QUICKTODO_APP_NAME.sha256"
ZIP_PATH="$ROOT_DIR/dist/$QUICKTODO_APP_NAME.zip"
TAG="v$VERSION"

"$ROOT_DIR/Scripts/create-release-zip.sh" "$VERSION" "$BUILD_NUMBER"

gh release create "$TAG" \
  "$ZIP_PATH" \
  "$SHA256_PATH" \
  --repo "$REPO" \
  --title "$TAG" \
  --notes "QuickTodo $VERSION"

if [[ -n "${GH_TOKEN:-}" || -n "${HOMEBREW_TAP_GITHUB_TOKEN:-}" ]]; then
  "$ROOT_DIR/Scripts/dispatch-tap-update.sh" "$VERSION" "$(cat "$SHA256_PATH")" "$TAG"
elif gh auth status >/dev/null 2>&1; then
  "$ROOT_DIR/Scripts/dispatch-tap-update.sh" "$VERSION" "$(cat "$SHA256_PATH")" "$TAG"
else
  echo "Skipped tap dispatch: set GH_TOKEN or HOMEBREW_TAP_GITHUB_TOKEN, or log in with gh."
fi
