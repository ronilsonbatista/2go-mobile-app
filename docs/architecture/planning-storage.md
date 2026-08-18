# 2GO Mobile — Planning Local Storage & Persistence Specification

## 1. Responsibilities & Layering
- **`packages/foundation/security` (`GuestJourneyCredentialStorage`)**:
  - Responsible ONLY for secret tokens (`guestToken`).
  - Backed by `FlutterSecureStorage`.

- **`packages/foundation/storage` (`PlanningDraftStorage`)**:
  - Responsible for user questionnaire inputs, step progress, destination list, travelers counts, interest tags, activity windows, budget level, and travel style.
  - Does NOT store secret tokens or credentials.

## 2. Syncing Strategy
- When user modifies wizard step:
  1. Save local draft state in `PlanningDraftStorage`.
  2. Perform optimistic or batch update to `PlanningRepository.updateJourney()`.
  3. Clear `isDirty` flag upon successful response.
