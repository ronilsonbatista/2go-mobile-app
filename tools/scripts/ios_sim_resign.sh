#!/bin/bash
# LOCAL SIMULATOR HELPER ONLY — never use for device, archive, or App Store.
#
# Post-build ad-hoc deep-sign of Runner.app for iOS Simulator when macOS
# provenance xattrs break Xcode's app signing after Flutter assemble.
#
# Do NOT embed custom entitlements on Simulator ad-hoc signatures. On
# Xcode 26 / iOS 18.5+ Simulator, any non-empty entitlements blob
# (including get-task-allow or keychain-access-groups) makes launchd
# reject the spawn with NSPOSIXErrorDomain 153 — SpringBoard shows a
# brief splash then closes. Device/Archive keep CODE_SIGN_ENTITLEMENTS.
# Guest Keychain -34018 on Simulator is covered by in-memory session
# fallbacks in SecureTokenStorageImpl / GuestJourneyCredentialStorageImpl.
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

/usr/bin/xattr -cr "$APP" 2>/dev/null || true

# Root-level debug dylibs (Flutter 3.32+ stub) must be executable + ad-hoc signed.
for root_bin in "$APP/Runner" "$APP/Runner.debug.dylib" "$APP/__preview.dylib"; do
  if [[ -f "$root_bin" ]]; then
    chmod +x "$root_bin" 2>/dev/null || true
    "$SHIM" --force --sign - --timestamp=none "$root_bin" >/dev/null 2>&1 || true
  fi
done

if [[ -d "$APP/Frameworks" ]]; then
  find "$APP/Frameworks" -type f \( -perm +111 -o -name '*.dylib' \) | while read -r f; do
    chmod +x "$f" 2>/dev/null || true
    "$SHIM" --force --sign - --timestamp=none "$f" >/dev/null 2>&1 || true
  done
fi

# Empty entitlements only — non-empty blobs → launchd errno 153 on Simulator.
"$SHIM" --force --deep --sign - "$APP"

echo "Signed $APP (Simulator ad-hoc, no custom entitlements)"
