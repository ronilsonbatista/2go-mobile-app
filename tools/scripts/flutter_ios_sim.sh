#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# Put repo codesign shim FIRST so Flutter's debug_unpack_ios succeeds on macOS 26.
# Include Homebrew Ruby gems for CocoaPods.
export PATH="$ROOT/tools/bin:/opt/homebrew/bin:/opt/homebrew/lib/ruby/gems/3.4.0/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
cd "$ROOT/apps/mobile_app"

# Simulator builds: disable Xcode app codesign (Flutter framework still signed via shim).
# Avoids com.apple.provenance failures on macOS 26 when signing Runner.app.
export CODE_SIGNING_ALLOWED=NO
export CODE_SIGNING_REQUIRED=NO

exec /opt/homebrew/bin/flutter "$@"
