#!/bin/bash
# LOCAL SIMULATOR HELPER ONLY — never use for device, archive, or App Store.
#
# Purpose: work around macOS 15+/26 com.apple.provenance xattrs that break
# Flutter's ad-hoc codesign during `debug_unpack_ios` on the iOS Simulator.
#
# Safety:
# - Does NOT modify PATH globally.
# - Shim is only prepended for this process tree when THIS script is invoked.
# - CODE_SIGNING_ALLOWED/REQUIRED=NO applies only to this invoked flutter process
#   so Xcode skips native CodeSign of Runner.app (Simulator). frameworks are
#   signed via the shim during Flutter assemble; use ios_sim_resign.sh after.
# - project.pbxproj also gates tools/bin to PLATFORM_NAME=iphonesimulator only.
#
# Forbidden uses: physical device, Archive, Release→App Store, TestFlight.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

if [[ "${TWIGO_ALLOW_IOS_SIM_CODESIGN_WORKAROUND:-}" != "1" ]]; then
  echo "Refusing to run codesign workaround without TWIGO_ALLOW_IOS_SIM_CODESIGN_WORKAROUND=1" >&2
  echo "This helper is Simulator-only. Use plain flutter for device/archive." >&2
  exit 2
fi

export PATH="$ROOT/tools/bin:/opt/homebrew/bin:/opt/homebrew/lib/ruby/gems/3.4.0/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
cd "$ROOT/apps/mobile_app"

# Simulator-only: skip Xcode native app CodeSign (provenance xattrs); resign after.
export CODE_SIGNING_ALLOWED=NO
export CODE_SIGNING_REQUIRED=NO

exec /opt/homebrew/bin/flutter "$@"
