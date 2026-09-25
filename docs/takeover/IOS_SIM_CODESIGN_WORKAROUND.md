# iOS Simulator codesign workaround (macOS 15+/26)

## Problem
On macOS 15+/26, copied Flutter frameworks receive `com.apple.provenance`
extended attributes. Flutter's ad-hoc `codesign` during `debug_unpack_ios`
then fails with "resource fork, Finder information, or similar detritus not
allowed".

## Scope (SAFE)
| Surface | Affected? |
|---------|-----------|
| Explicit `TWIGO_ALLOW_IOS_SIM_CODESIGN_WORKAROUND=1 tools/scripts/flutter_ios_sim.sh …` | Yes (intentional) |
| Plain `flutter build ios` / `flutter run` (no script) | No |
| Physical device build | No |
| Archive / App Store / TestFlight | No |
| Global shell PATH | No |

## Components
- `tools/bin/codesign` — local shim that strips xattrs then calls `/usr/bin/codesign`
- `tools/scripts/flutter_ios_sim.sh` — opt-in Simulator runner (requires env flag)
- `tools/scripts/ios_sim_resign.sh` — post-build ad-hoc deep-sign of `Runner.app` for Simulator install

## Forbidden
Never point device/archive CI or Release builds at these helpers.
`project.pbxproj` must NOT prepend `tools/bin` to PATH (verified removed).

## Preferred path
When the host environment allows standard Flutter codesign:

```bash
cd apps/mobile_app
flutter build ios --debug --simulator -t lib/main_development.dart
```

Use the workaround only if `IOS_STANDARD_SIM_BUILD = ENVIRONMENT_BLOCKED`.
