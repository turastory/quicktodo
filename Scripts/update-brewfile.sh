#!/usr/bin/env bash
set -euo pipefail

BREWFILE="${1:-$HOME/dotfiles/Brewfile}"
TAP_NAME="${QUICKTODO_TAP_NAME:-turastory/tap}"
CASK_TOKEN="${QUICKTODO_CASK_TOKEN:-quicktodo}"
mkdir -p "$(dirname "$BREWFILE")"
touch "$BREWFILE"

if ! grep -Fq "tap \"$TAP_NAME\"" "$BREWFILE"; then
  printf '\ntap "%s"\n' "$TAP_NAME" >> "$BREWFILE"
fi

if ! grep -Fq "cask \"$CASK_TOKEN\"" "$BREWFILE"; then
  printf 'cask "%s"\n' "$CASK_TOKEN" >> "$BREWFILE"
fi

echo "Updated $BREWFILE"
