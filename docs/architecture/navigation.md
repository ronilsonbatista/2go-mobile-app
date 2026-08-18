# Architecture & Navigation — 2GO Mobile

## 1. Overview
The **2GO Mobile Application Architecture** organizes navigation around a persistent, authenticated **App Shell** leveraging `GoRouter`'s `StatefulShellRoute.indexedStack`.

---

## 2. Navigation Architecture Diagram

```
App Launch
    │
    ▼
SessionRestore (SessionCubit)
    │
    ├── SessionStatus.restoring / unknown ──► /launch (LaunchPage)
    │
    ├── SessionStatus.unauthenticated / expired ──► /auth (AuthenticationPage)
    │
    └── SessionStatus.authenticated ──► /app/home (AppShell)
                                             │
                                             ├── Branch 0: /app/home (HomePage)
                                             ├── Branch 1: /app/trips (TripsPage)
                                             ├── Branch 2: /app/notifications (NotificationsPage)
                                             └── Branch 3: /app/profile (ProfilePage)
```

---

## 3. Key Components & Responsibilities

### Session Guard (`SessionCubit`)
- Serves as the single source of truth for global session status.
- `_getInitialLocation` and `redirect` in `AppRouter` dynamically route the app based on session lifecycle state (`restoring`, `unauthenticated`, `authenticated`, `expired`).

### App Shell (`AppShell` & `TwoGoBottomNavigation`)
- Located in `apps/mobile_app/lib/src/shell/app_shell.dart`.
- Uses `TwoGoBottomNavigation` from `packages/design_system` v0.3.
- Completely free of business logic (application composition only).
- Manages 4 primary destinations:
  1. **Início** (`/app/home`)
  2. **Viagens** (`/app/trips`)
  3. **Notificações** (`/app/notifications`)
  4. **Perfil** (`/app/profile`)

### Stateful Tab State Preservation
- Built using `StatefulShellRoute.indexedStack` with separate `StatefulShellBranch` per tab.
- Preserves tab scroll state, local state, and navigation stack when switching between bottom navigation tabs without unnecessary widget rebuilds.

### Deep Linking Readiness
- The route structure (`/app/home`, `/app/trips`, etc.) is structured for future deep-linking handling (e.g. `2go://trip/:id`, `2go://voucher/:id`).

---

## 4. Architectural Decisions & Rules
- **No Business Logic in Shell**: `AppShell` only handles tab indexing via `StatefulNavigationShell.goBranch`.
- **Design System Separation**: `TwoGoBottomNavigation` and `TwoGoBadge` are generic primitives in `packages/design_system` v0.3 with 0 feature dependencies.
- **Security Privacy**: No access tokens, refresh tokens, or JWT strings are rendered in the UI or printed to console logs.