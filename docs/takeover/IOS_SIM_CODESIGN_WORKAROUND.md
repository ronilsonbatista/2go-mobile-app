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
| `Debug.xcconfig` `CODE_SIGNING_ALLOWED[sdk=iphonesimulator*]=NO` | Yes (Simulator Debug only) |
| Xcode Run Script when `PLATFORM_NAME=iphonesimulator` (PATH shim) | Yes |
| Plain `flutter build ios` / device SDK (`iphoneos`) | No |
| Physical device build | No |
| Archive / App Store / TestFlight | No |
| Global shell PATH | No |

## Why PATH shim alone is insufficient
Xcode's native CodeSign build phase often invokes **`/usr/bin/codesign` by absolute path**,
so a PATH-based shim never intercepts it. Simulator Debug therefore:

1. Sets `CODE_SIGNING_ALLOWED[sdk=iphonesimulator*]=NO` in `Flutter/Debug.xcconfig` and Podfile
2. Signs Flutter frameworks during assemble via PATH shim (`tools/bin/codesign` + ditto clean copy)
3. Deep-signs `Runner.app` with `ios_sim_resign.sh` after build

Device/Archive (iphoneos) keep normal Xcode signing and entitlements.

`SecureTokenStorageImpl` also tolerates missing keychain entitlements on Simulator
unsigned builds so bootstrap never dies on PlatformException -34018.

## Components
- `tools/bin/codesign` — local shim that strips xattrs then calls `/usr/bin/codesign`
- `tools/scripts/flutter_ios_sim.sh` — opt-in Simulator runner (requires env flag)
- `tools/scripts/ios_sim_resign.sh` — post-build ad-hoc deep-sign of `Runner.app` for Simulator install
- `project.pbxproj` Run Script phases — prepend `tools/bin` **only if** `PLATFORM_NAME=iphonesimulator`

## Forbidden
Never point device/archive CI or Release builds at these helpers.
Device/Archive/App Store builds must continue to use `/usr/bin/codesign` (PLATFORM_NAME gate).

## Preferred path
When the host environment allows standard Flutter codesign:

```bash
cd apps/mobile_app
flutter build ios --debug --simulator -t lib/main_development.dart
```

Use the workaround only if `IOS_STANDARD_SIM_BUILD = ENVIRONMENT_BLOCKED`.
