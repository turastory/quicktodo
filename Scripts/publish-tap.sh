#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${1:?version is required, e.g. 0.1.0}"
SHA256="${2:?sha256 is required}"
TAP_REPO="${3:-${QUICKTODO_TAP_REPO:-turastory/homebrew-tap}}"
TAP_BRANCH="${QUICKTODO_TAP_BRANCH:-main}"
CASK_TOKEN="${QUICKTODO_CASK_TOKEN:-quicktodo}"
GIT_AUTHOR_NAME="${GIT_AUTHOR_NAME:-QuickTodo Release Bot}"
GIT_AUTHOR_EMAIL="${GIT_AUTHOR_EMAIL:-quicktodo-release-bot@users.noreply.github.com}"
WORK_DIR="$(mktemp -d)"
TAP_DIR="$WORK_DIR/homebrew-tap"

cleanup() {
  rm -rf "$WORK_DIR"
}
trap cleanup EXIT

"$ROOT_DIR/Scripts/render-cask.sh" "$VERSION" "$SHA256"

gh auth status >/dev/null
gh auth setup-git >/dev/null 2>&1 || true

if gh repo view "$TAP_REPO" >/dev/null 2>&1; then
  gh repo clone "$TAP_REPO" "$TAP_DIR"
else
  gh repo create "$TAP_REPO" --public --description "Homebrew tap for QuickTodo and personal tools"
  gh repo clone "$TAP_REPO" "$TAP_DIR"
fi

git -C "$TAP_DIR" config user.name "$GIT_AUTHOR_NAME"
git -C "$TAP_DIR" config user.email "$GIT_AUTHOR_EMAIL"

if git -C "$TAP_DIR" show-ref --verify --quiet "refs/remotes/origin/$TAP_BRANCH"; then
  git -C "$TAP_DIR" checkout "$TAP_BRANCH"
else
  git -C "$TAP_DIR" checkout --orphan "$TAP_BRANCH"
fi

mkdir -p "$TAP_DIR/Casks"
cp "$ROOT_DIR/Homebrew/$CASK_TOKEN.rb" "$TAP_DIR/Casks/$CASK_TOKEN.rb"

git -C "$TAP_DIR" add "Casks/$CASK_TOKEN.rb"
if git -C "$TAP_DIR" diff --cached --quiet; then
  echo "Tap already up to date."
  exit 0
fi

git -C "$TAP_DIR" commit -m "Update $CASK_TOKEN to $VERSION"
git -C "$TAP_DIR" push origin "HEAD:$TAP_BRANCH"
