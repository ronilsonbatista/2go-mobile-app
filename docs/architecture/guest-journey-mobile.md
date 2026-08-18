# 2GO Mobile — Anonymous Guest Journey Mobile Architecture

## 1. Overview
The Anonymous Guest Journey in `2go-mobile` allows non-authenticated users to create and customize travel itineraries without prior sign-in or account creation.

## 2. Token Security & Storage Architecture
- **`guestToken` Handling**:
  - The raw secret `guestToken` is returned ONCE by `POST /planning-sessions`.
  - It is stored **exclusively** in `packages/foundation/security` (`GuestJourneyCredentialStorage`) backed by `FlutterSecureStorage` (`AndroidOptions` encrypted SharedPreferences & `IOSOptions` Keychain).
  - It is **NEVER** stored in `packages/foundation/storage` (`PlanningDraft`), unencrypted files, database JSON, logs, or analytics payloads.

## 3. Local Questionnaire & Draft Persistence
- **`PlanningDraft` Structure**:
  - Stored in `packages/foundation/storage` (`PlanningDraftStorage`).
  - Contains transient user answers (`destinations`, `travelers`, `interests`, `activityWindow`, `budgetLevel`, `travelStyle`), `currentStep`, `activeJourneyId`, `lastSyncedAt`, and `isDirty`.
  - Allows full offline resilience and UI recovery.

## 4. JWT Refresh Isolation Rule
- Anonymous `401` HTTP responses on `/planning-sessions` endpoints MUST NOT trigger JWT `RefreshCoordinator` or `/auth/refresh` calls.
- Requests carry `isGuestRequest: true` extra flag and `X-Guest-Token` header.
- `AuthInterceptor` checks `_isGuestPath(options)` and completely skips `RefreshCoordinator.handleRefresh()`.
