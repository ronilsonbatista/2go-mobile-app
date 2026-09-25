#!/bin/bash
# LOCAL SIMULATOR HELPER ONLY — never use for device, archive, or App Store.
#
# Purpose: work around macOS 15+/26 com.apple.provenance xattrs that break
# Flutter's ad-hoc codesign during `debug_unpack_ios` on the iOS Simulator.
#
# Safety:
# - Does NOT modify PATH globally.
# - Does NOT alter Xcode project build phases for device/archive.
# - Shim is only prepended for this process tree when THIS script is invoked.
# - CODE_SIGNING_ALLOWED/REQUIRED=NO applies only to this invoked flutter process.
#
# Forbidden uses: physical device, Archive, Release→App Store, TestFlight.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

if [[ "${TWIGO_ALLOW_IOS_SIM_CODESIGN_WORKAROUND:-}" != "1" ]]; then
  echo "Refusing to run codesign workaround without TWIGO_ALLOW_IOS_SIM_CODESIGN_WORKAROUND=1" >&2
  echo "This helper is Simulator-only. Use plain flutter for device/archive." >&2
  exit 2
fi

# Explicit opt-in: shim only for this invocation.
export PATH="$ROOT/tools/bin:/opt/homebrew/bin:/opt/homebrew/lib/ruby/gems/3.4.0/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
cd "$ROOT/apps/mobile_app"

# Simulator-only: skip Xcode app re-sign; frameworks still signed via shim during assemble.
export CODE_SIGNING_ALLOWED=NO
export CODE_SIGNING_REQUIRED=NO

exec /opt/homebrew/bin/flutter "$@"
