#!/bin/bash
# LOCAL SIMULATOR HELPER ONLY — never use for device, archive, or App Store.
#
# Post-build ad-hoc deep-sign of Runner.app for iOS Simulator when macOS
# provenance xattrs break Xcode's app signing after Flutter assemble.
#
# Requires TWIGO_ALLOW_IOS_SIM_CODESIGN_WORKAROUND=1 (same gate as flutter_ios_sim.sh).
set -euo pipefail

if [[ "${TWIGO_ALLOW_IOS_SIM_CODESIGN_WORKAROUND:-}" != "1" ]]; then
  echo "Refusing ios_sim_resign without TWIGO_ALLOW_IOS_SIM_CODESIGN_WORKAROUND=1" >&2
  exit 2
fi

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SHIM="$ROOT/tools/bin/codesign"
APP="${1:-$ROOT/apps/mobile_app/build/ios/Debug-iphonesimulator/Runner.app}"

if [[ ! -d "$APP" ]]; then
  echo "Runner.app not found at $APP" >&2
  exit 1
fi

# Refuse if this looks like a device/archive product.
case "$APP" in
  *iphoneos*|*Release-iphoneos*|*Archive*)
    echo "Refusing to resign device/archive product: $APP" >&2
    exit 2
    ;;
esac

if [[ -d "$APP/Frameworks" ]]; then
  find "$APP/Frameworks" -type f -perm +111 | while read -r f; do
    "$SHIM" --force --sign - --timestamp=none "$f" >/dev/null 2>&1 || true
  done
fi

"$SHIM" --force --deep --sign - "$APP"
echo "Signed $APP"
