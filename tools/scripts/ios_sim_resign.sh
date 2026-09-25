#!/bin/bash
# Post-build ad-hoc sign for iOS Simulator on macOS 15+/26.
# Flutter framework signing uses tools/bin/codesign during assemble; Xcode app
# signing often fails on provenance xattrs — re-sign the .app before install.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SHIM="$ROOT/tools/bin/codesign"
APP="${1:-$ROOT/apps/mobile_app/build/ios/Debug-iphonesimulator/Runner.app}"

if [[ ! -d "$APP" ]]; then
  echo "Runner.app not found at $APP" >&2
  exit 1
fi

if [[ -d "$APP/Frameworks" ]]; then
  find "$APP/Frameworks" -type f -perm +111 | while read -r f; do
    "$SHIM" --force --sign - --timestamp=none "$f" >/dev/null 2>&1 || true
  done
fi

"$SHIM" --force --deep --sign - "$APP"
echo "Signed $APP"
