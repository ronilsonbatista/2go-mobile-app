# 2GO MOBILE TAKEOVER — INITIAL STATE

**Date:** 2026-09-24  
**HEAD:** `3c9923f` — `fix(ios): link Mercado Pago CoreMethods via Swift Package Manager`  
**Branch:** `main` (up to date with `origin/main`)  
**Remote:** `git@github.com:ronilsonbatista/2go-mobile-app.git`

---

## Git

| Item | Value |
|------|-------|
| WIP preserved | `Podfile.lock` checksum drift; broken `build` → `/tmp/2go_mobile_build` symlink; untracked SPM `Package.resolved` |
| Destructive ops | None performed |
| Flutter | **3.32.6** stable / Dart **3.8.1** |
| Workspace | Melos + pub workspaces (`apps/*`, `packages/**`) |

---

## Classification legend

`READY` · `PARTIAL` · `BROKEN` · `MISSING`

---

## Workspace / Architecture

| Area | Status | Notes |
|------|--------|-------|
| Monorepo / Melos | READY | `melos.yaml` + root workspace pubspec |
| Modular Clean / DDD packages | READY | foundation / identity / travel / commerce / engagement / design_system / generated API |
| App composition (`apps/mobile_app`) | PARTIAL | Shell + auth + checkout routes; domain packages ahead of wiring |
| Networking / OpenAPI client | PARTIAL | `app_roteiros_api` + Dio packages exist; **bootstrap does not wire `ApiConfig` / clients** |
| Flavors | PARTIAL | `main_{development,staging,production}.dart`; Android productFlavors; iOS **no** Xcode flavors; env only affects app title today |

---

## Design System — `packages/design_system`

| Area | Status |
|------|--------|
| Tokens (colors, typography, spacing, radius, elevation, motion) | READY |
| Brand lime `#C4E000` | READY (matches Figma CTA family) |
| Components (Button, TextField, OTP, Pill, InlineFeedback, KeyboardAwareScaffold, CenteredContent, BottomNav, Card, Snackbar, BottomSheet, …) | READY |
| Random page-level styles | Avoid — reuse DS |

---

## Routes / Screens (app)

| Route | Widget | Status |
|-------|--------|--------|
| `/launch` | `LaunchPage` | PARTIAL — spinner, **not** Figma splash logo |
| `/auth` | `AuthenticationPage` | PARTIAL — UI READY in package; API wiring MISSING |
| `/checkout` | `CheckoutPage` | PARTIAL — package READY; app uses **MockPaymentsDataSource** |
| `/paid-handoff` | `PaidTripHandoffPage` | PARTIAL |
| `/app/home` | `HomePage` | MISSING vs Figma — **placeholder** |
| `/app/trips` | `TripsPage` | MISSING vs Figma — **placeholder** |
| `/app/notifications` | `NotificationsPage` | MISSING — placeholder |
| `/app/profile` | `ProfilePage` | PARTIAL — logout works; rest stubs |
| Planning wizard / generation / preview / claim | package pages | **MISSING from router** |

**Critical router fact:** unauthenticated users are forced to `/auth`. Documented guest journey (Home → questionnaire → …) is **not reachable**.

---

## FIGMA → CODE MAP

| FIGMA SCREEN | CURRENT ROUTE | CURRENT WIDGET/PAGE | STATUS | VISUAL_MATCH | FUNCTIONAL_MATCH |
|--------------|---------------|---------------------|--------|--------------|------------------|
| Splash | `/launch` | `LaunchPage` | PARTIAL | MAJOR_DIFF | PARTIAL |
| Home (all states) | `/app/home` | `HomePage` | PARTIAL | NOT_IMPLEMENTED | MISSING |
| Criação de roteiro (6 steps) | — | `PlanningWizardPage` | IMPLEMENTED (pkg) | UNKNOWN* | READY (pkg) |
| Gerando roteiro | — | `PlanningGenerationPage` | IMPLEMENTED (pkg) | UNKNOWN* | READY (pkg) |
| Preview + locks | — | `PlanningPreviewPage` | IMPLEMENTED (pkg) | UNKNOWN* | READY (pkg) |
| Paywall / unlock sheet | — | `PlanningUnlockSheet` | IMPLEMENTED (pkg) | UNKNOWN* | READY (pkg) |
| Login email | `/auth` | `EmailStepView` | IMPLEMENTED | MINOR_DIFF / ASSET_REQUIRED | PARTIAL (mock OTP) |
| OTP states | `/auth` | `OtpStepView` | IMPLEMENTED | UNKNOWN* | PARTIAL |
| Checkout / cupom / PIX / card | `/checkout` | `CheckoutPage` + views | IMPLEMENTED (pkg) | UNKNOWN* | PARTIAL (mocks) |
| Pagamento confirmado / falha | checkout states | package views | IMPLEMENTED (pkg) | UNKNOWN* | PARTIAL |
| Roteiro pago / timeline | — | trips/itinerary | MISSING UI | NOT_IMPLEMENTED | PARTIAL domain |
| Detalhe / substituir / swipe delete | — | — | MISSING | NOT_IMPLEMENTED | MISSING (+ backend dep) |
| Múltiplos destinos | planning + home variants | draft supports multi dest | PARTIAL | NOT_IMPLEMENTED (home) | PARTIAL |
| Error patterns | DS + auth/checkout | InlineFeedback / Snackbar | PARTIAL | MINOR_DIFF | PARTIAL |

\*UNKNOWN until package screens are opened on simulator (not routed today). Goldens exist for auth/planning/checkout/DS.

---

## Domain modules

| Module | Status | Notes |
|--------|--------|-------|
| Auth (package) | READY | OTP 60s cooldown, invalid/expired/rate-limit steps |
| Auth (app integration) | PARTIAL | No `AuthApiClient`; request no-op / verify mock tokens |
| Guest journey | MISSING (app) / READY (pkg) | Docs vs router mismatch |
| AI generation | READY (pkg) | Not routed |
| Preview / paywall | READY (pkg) | Core-driven preview; not routed |
| Claim + PostAuthIntent | PARTIAL | `resumeCheckout` routed; `claimGuestJourney` enum only |
| Checkout PIX/CARD | PARTIAL | Package ready; mocks in app; Apple Pay post-V1 |
| Card tokenization iOS | BROKEN | SPM linked; `AppDelegate` returns `IOS_RUNTIME_NOT_VALIDATED` |
| Trips | PARTIAL | Domain + mock repo; shell placeholder |
| Itinerary UI | MISSING | Module shell only |
| Notifications | MISSING | Placeholder tab |
| Profile | PARTIAL | Email + logout |
| App Shell | READY | `StatefulShellRoute.indexedStack` + DS bottom nav |
| Security / secure storage | PARTIAL | Token storage present; guest token docs exist; Dio sanitization needs live API audit |
| Android | PARTIAL | Flavors present; not run this session |
| iOS simulator build | READY | Built & launched on **iPhone 16 Pro** (iOS 18.5) |
| Physical iPhone card tokenization | MISSING | Still pending (do not break SPM/Pods) |

---

## Runtime inspection (real)

| Item | Result |
|------|--------|
| Device | iPhone 16 Pro simulator `A5EC7975-…` **Booted** |
| Command | `flutter run -d … -t lib/main_development.dart` |
| First screen | **Login** (`/auth`) — not Splash/Home |
| Screenshot | `docs/takeover/screenshots/01_auth_current.png` |
| Build blocker fixed | Recreated target of broken symlink `apps/mobile_app/build` → `/tmp/2go_mobile_build` |

### CURRENT vs FIGMA (Login) — Checkpoint 0

```
SCREEN = Login / Email
FIGMA_REFERENCE = attached payment/auth boards + product login frames
CURRENT_IMPLEMENTATION = docs/takeover/screenshots/01_auth_current.png

TYPOGRAPHY = close (bold title, PT-BR copy)
SPACING = generous, aligned with DS
COLORS = white bg; disabled CTA gray (lime when enabled — DS)
COMPONENTS = TwoGoTextField, TwoGoButton, social row, illustration slot
INTERACTION = email validation gates Continuar
DATA = mock auth (no Core client)

VISUAL_MATCH = MINOR_DIFF (+ ASSET_REQUIRED)
FUNCTIONAL_MATCH = PARTIAL

DIFFS:
- Placeholder ? icons for help / social / email prefix
- "AUTH ILLUSTRATION PENDING" instead of travel illustration
- Social buttons visible while feature flags off / non-functional
- Entry gate is Auth-first; Figma product path starts Guest → Home
```

---

## Tests / Build

| Item | Status |
|------|--------|
| `dart run melos run test` | BROKEN tooling — script calls `melos` not on PATH (`dart run melos` works for scripts entry) |
| Package tests (auth/planning/checkout/DS) | Running in parallel this session; goldens slow under concurrent `flutter run` |
| `flutter analyze` | Pending full workspace pass |
| iOS simulator | **PASS** (debug launch) |
| Android emulator | Available (`Medium_Phone_API_36.0`) — not launched yet |

---

## BLOCKERS / Priorities

### BLOCKER
1. **Guest journey not wired** — packages exist; router forces `/auth`; product flow cannot be certified.
2. **Core API not bootstrapped** — no `ApiConfig` / clients in `bootstrap.dart` → OTP/planning/checkout hit mocks or no-ops.
3. **Home / Trips / Itinerary UI missing** vs Figma (placeholders).
4. **iOS rebuild blocked (environment)** — after first successful simulator launch, subsequent `flutter run` / `flutter build ios` fail on `debug_unpack_ios` codesign (`resource fork` / `com.apple.provenance` on `Flutter.framework`) under macOS 26.5. Disk was at ~100% earlier (now ~7GB free). Installed app from first build still launches via `simctl`.

### HIGH
4. iOS Mercado Pago `CoreMethods` still stubbed (`IOS_RUNTIME_NOT_VALIDATED`).
5. `claimGuestJourney` PostAuthIntent not persisted/routed.
6. Official Figma assets (logo splash, suitcase hero, auth illustration, icons) — **ASSET_REQUIRED**.
7. Broken `build` symlink dependency on `/tmp` (fragile across reboots).

### MEDIUM
8. Melos test script PATH issue.
9. Notifications placeholder (OK if backend undefined — document only).
10. Social login UI without backend support.

### LOW
11. Package dependency upgrade noise (`flutter pub outdated`).
12. iOS product flavors not mirrored from Android.

---

## Status board (continuous)

```
CURRENT_SCREEN = Login (EmailStepView)
CURRENT_STATUS = App running on iOS Simulator; audit complete; visual checkpoint 0 captured
VISUAL_MATCH = MINOR_DIFF (login) / NOT_IMPLEMENTED (home+)
FUNCTIONAL_STATUS = Auth mock path works; guest journey unreachable
TEST_STATUS = In progress (package suites)
NEXT = (1) Persist build dir fix (2) Wire guest/planning routes per docs (3) Checkpoint 1 Home empty state vs Figma once assets/route exist
```

---

## Definition gates (this phase)

| Gate | Status |
|------|--------|
| MOBILE_IMPLEMENTATION_REVIEWED | IN PROGRESS |
| MOBILE_UI_FIGMA_ALIGNED | NO |
| MOBILE_CORE_INTEGRATION_VALIDATED | NO |
| MOBILE_READY_FOR_FINAL_DEVICE_CERTIFICATION | NO |

**Stopped short of:** Production, real payment, Store release.
