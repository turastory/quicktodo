#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${1:?version is required, e.g. 0.1.0}"
SHA256="${2:?sha256 is required}"
TAP_REPO="${3:-turastory/homebrew-tap}"
WORK_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "$WORK_DIR"
}
trap cleanup EXIT

"$ROOT_DIR/Scripts/render-cask.sh" "$VERSION" "$SHA256"

if gh repo view "$TAP_REPO" >/dev/null 2>&1; then
  gh repo clone "$TAP_REPO" "$WORK_DIR/homebrew-tap"
else
  gh repo create "$TAP_REPO" --public --description "Homebrew tap for QuickTodo and personal tools"
  gh repo clone "$TAP_REPO" "$WORK_DIR/homebrew-tap"
fi

mkdir -p "$WORK_DIR/homebrew-tap/Casks"
cp "$ROOT_DIR/Homebrew/quicktodo.rb" "$WORK_DIR/homebrew-tap/Casks/quicktodo.rb"

git -C "$WORK_DIR/homebrew-tap" add Casks/quicktodo.rb
if git -C "$WORK_DIR/homebrew-tap" diff --cached --quiet; then
  echo "Tap already up to date."
  exit 0
fi

git -C "$WORK_DIR/homebrew-tap" commit -m "Add QuickTodo $VERSION"
git -C "$WORK_DIR/homebrew-tap" push origin HEAD
