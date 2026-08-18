# Architecture Specification — Guest Journey Backend Audit & Specifications (Phase A)

## 1. Executive Summary & Audit Findings

### Backend State (`approteiros-api`):
- **`Trip` Entity**: Requires non-null `userId`. We strictly preserve this contract and do **not** make `userId` nullable, create fake users, or issue anonymous JWTs.
- **`GuestJourney` Abstraction**: Recommended as a dedicated Prisma model for transient acquisition drafts before account creation.
- **`AiService` Audit**: Reuses existing `AiService` NestJS module and `OpenAIProvider`. OpenAI calls for multi-day itineraries take **6–15 seconds**.
- **Generation Strategy**: **Asynchronous (202 Accepted + Status Polling)** is mandatory for production mobile UX to avoid HTTP timeouts.

---

## 2. Mobile Persistence Rules (Separation of Concerns)

### Security Credentials (`packages/foundation/security`):
- Handled exclusively via `FlutterSecureStorage` (Keychain / EncryptedSharedPreferences).
- Holds: `guestToken` (random secret key for anonymous GuestJourney), `accessToken`, `refreshToken`.
- **Strict Rule**: `guestToken` is treated as a secret credential and MUST NEVER be saved to unencrypted local storage, common DB, logs, or analytics.

### Local Draft Storage (`packages/foundation/storage`):
- Handled via fast local storage (e.g. `SharedPreferences` / `hive` / `Isar`).
- Holds: Questionnaire draft answers (`destinations[]`, `travelers`, `interests[]`, `activityWindow`, `travelStyle`, `budgetLevel`, local step index).

---

## 3. Data Mapping & Schema Design

### Questionnaire -> Enum Mapping:
- Option `$ Econômica` -> `travelStyle = TravelStyle.ECONOMIC` & `budgetLevel = BudgetLevel.LOW`
- Option `$$ Confortável` -> `travelStyle = TravelStyle.COMFORT` & `budgetLevel = BudgetLevel.MEDIUM`
- Option `$$$ Premium` -> `travelStyle = TravelStyle.CULTURAL` & `budgetLevel = BudgetLevel.HIGH`
- Option `$$$$ Luxuosa` -> `travelStyle = TravelStyle.LUXURY` & `budgetLevel = BudgetLevel.PREMIUM`

### Typed Questionnaire Contract (`QuestionnaireAnswersDto`):
```typescript
export interface QuestionnaireAnswersDto {
  answersVersion: number; // e.g. 1 for schema evolution
  destinations: Array<{
    providerPlaceId?: string;
    name: string;
    city: string;
    country?: string;
    coverImage?: string;
    arrivalDate: string;   // ISO YYYY-MM-DD
    arrivalTime: string;   // HH:mm
    departureDate: string; // ISO YYYY-MM-DD
    departureTime: string; // HH:mm
  }>;
  travelers: {
    adults: number;   // >= 1
    children: number; // >= 0
    elders: number;   // >= 0
  };
  interests: string[];
  activityWindow: {
    startTime: string; // "09:00"
    endTime: string;   // "18:30"
  };
  travelStyle: 'ECONOMIC' | 'COMFORT' | 'LUXURY';
  budgetLevel: 'LOW' | 'MEDIUM' | 'HIGH' | 'PREMIUM';
}
```

---

## 4. AI Generation & Preview Security

### Asynchronous Generation Flow:
1. Mobile calls `POST /planning-sessions/:id/generate`.
2. Backend responds `202 Accepted` + `{ generationJobId: "...", status: "QUEUED" }`.
3. Backend executes AI generation in background.
4. Mobile polls `GET /planning-sessions/:id/status` every 2s (`QUEUED` -> `GENERATING` -> `PREVIEW_READY`).

### Server-Side Paywall Gating (`GET /planning-sessions/:id/preview`):
- The preview API filters out all days except Day 1 on the server before building the HTTP response payload.
- Days 2+ contain only metadata (`{ dayNumber: 2, isLocked: true }`). No premium activity content is sent over the wire prior to payment.

---

## 5. Atomic Claim & Security

### Atomic Claim Transaction (`POST /planning-sessions/:id/claim`):
- Wraps inside `prisma.$transaction`:
  1. Validates `SHA-256(guestToken)` match.
  2. Idempotency check: Returns existing `createdTripId` if already claimed by current user.
  3. Creates official `Trip` attached to `currentUser.id`.
  4. Materializes `TripDay` and `ItineraryItem` rows from `generatedItinerary`.
  5. Updates `UserTravelProfile` with permanent preferences.
  6. Marks `GuestJourney` as `CLAIMED`.

### Multi-Layer Rate Limit & Protection:
1. Max 1 active generation per `GuestJourney`.
2. 60-second generation cooldown.
3. Max 3 generations per IP address per hour.
4. Cryptographic 256-bit `guestToken` secret (SHA-256 backend hashing).
5. Automatic TTL expiration (7 days).
