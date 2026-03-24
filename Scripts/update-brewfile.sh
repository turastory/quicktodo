#!/usr/bin/env bash
set -euo pipefail

BREWFILE="${1:-$HOME/dotfiles/Brewfile}"

if ! grep -Fq 'tap "turastory/tap"' "$BREWFILE"; then
  printf '\ntap "turastory/tap"\n' >> "$BREWFILE"
fi

if ! grep -Fq 'cask "quicktodo"' "$BREWFILE"; then
  printf 'cask "quicktodo"\n' >> "$BREWFILE"
fi

echo "Updated $BREWFILE"
