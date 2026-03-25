#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/release-common.sh"

VERSION="${1:?version is required, e.g. 0.1.2}"
SHA256="${2:?sha256 is required}"
RELEASE_TAG="${3:-v$VERSION}"
TAP_REPO="${4:-$QUICKTODO_TAP_REPO}"
PAYLOAD_FILE="$(mktemp)"

cleanup() {
  rm -f "$PAYLOAD_FILE"
}
trap cleanup EXIT

if [[ -n "${HOMEBREW_TAP_GITHUB_TOKEN:-}" && -z "${GH_TOKEN:-}" ]]; then
  export GH_TOKEN="$HOMEBREW_TAP_GITHUB_TOKEN"
fi

gh auth status >/dev/null 2>&1 || true

cat > "$PAYLOAD_FILE" <<EOF
{
  "event_type": "quicktodo_release_published",
  "client_payload": {
    "version": "$VERSION",
    "sha256": "$SHA256",
    "release_tag": "$RELEASE_TAG",
    "app_repo": "$QUICKTODO_APP_REPO",
    "app_name": "$QUICKTODO_APP_NAME",
    "cask_token": "$QUICKTODO_CASK_TOKEN",
    "min_macos": "$QUICKTODO_MIN_MACOS"
  }
}
EOF

gh api "repos/$TAP_REPO/dispatches" --method POST --input "$PAYLOAD_FILE" >/dev/null

echo "Dispatched $RELEASE_TAG to $TAP_REPO"
