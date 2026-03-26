#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/release-common.sh"
VERSION="${1:-0.1.0}"
BUILD_NUMBER="${2:-1}"
ARTIFACT_DIR="$ROOT_DIR/dist"
ZIP_PATH="$ARTIFACT_DIR/$QUICKTODO_APP_NAME.zip"
CHECKSUM_PATH="$ARTIFACT_DIR/$QUICKTODO_APP_NAME.sha256"

"$ROOT_DIR/Scripts/build-app.sh" release "$VERSION" "$BUILD_NUMBER"

rm -f "$ZIP_PATH" "$CHECKSUM_PATH"
ditto -c -k --sequesterRsrc --keepParent "$ARTIFACT_DIR/$QUICKTODO_APP_NAME.app" "$ZIP_PATH"
shasum -a 256 "$ZIP_PATH" | awk '{print $1}' > "$CHECKSUM_PATH"

echo "Zip: $ZIP_PATH"
echo "SHA256: $(cat "$CHECKSUM_PATH")"
