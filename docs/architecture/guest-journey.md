# Architecture Specification — Guest Journey Backend & Lifecycle (2GO Mobile)

## 1. Context & Architectural Principles
The acquisition flow requires storing user responses, generating AI itineraries, and presenting previews **before** user authentication.

### Core Architectural Rules:
1. **No Nullable `Trip.userId`**: The core `Trip` entity in Prisma requires a non-null `userId`. We do **not** make `userId` optional or create fake users/anonymous JWTs.
2. **Dedicated Acquisition Entity**: We introduce `GuestJourney` (or `PlanningSession`) in Prisma to represent anonymous acquisition drafts.
3. **Secure Dual Credentials**: Every guest session is identified by `guestJourneyId` (UUID) + `guestToken` (random secret string).
   - In PostgreSQL, only `guestTokenHash` (SHA-256) is stored.
   - In Flutter, `guestToken` is stored securely in `FlutterSecureStorage`.
4. **State Machine & Expire Lifecycle**: Guest sessions expire automatically after 7 days if unclaimed (`expiresAt`).

---

## 2. Proposed Prisma Model (`schema.prisma`)

```prisma
enum GuestJourneyStatus {
  COLLECTING
  READY_TO_GENERATE
  GENERATING
  PREVIEW_READY
  AUTH_REQUIRED
  CLAIMED
  CHECKOUT_PENDING
  PAID
  EXPIRED
  FAILED
}

model GuestJourney {
  id               String             @id @default(uuid())
  guestTokenHash   String             @unique

  status           GuestJourneyStatus @default(COLLECTING)

  destinations     Json               // List of destinations with dates/times
  travelers        Json               // { adults: Int, children: Int, elders: Int }
  interests        String[]           // Array of interest keys
  activityHours    Json               // { startTime: String, endTime: String }
  travelStyle      TravelStyle
  budgetLevel      BudgetLevel

  generatedItinerary Json?            // Complete AI-generated itinerary data
  previewDayNumber Int                @default(1)

  claimedUserId    String?
  claimedUser      User?              @relation(fields: [claimedUserId], references: [id], onDelete: SetNull)

  createdTripId    String?
  createdTrip      Trip?              @relation(fields: [createdTripId], references: [id], onDelete: SetNull)

  expiresAt        DateTime
  createdAt        DateTime           @default(now())
  updatedAt        DateTime           @updatedAt

  @@index([status])
  @@index([expiresAt])
  @@map("guest_journeys")
}
```

---

## 3. Server-Side Security & Rate Limiting Strategy
Because AI itinerary generation (`POST /planning-sessions/:id/generate`) occurs before login:
- **Rate Limiting**: IP-based rate limiting + Fingerprint throttling (max 3 generation requests per IP/hour).
- **Single Active Generation**: Only 1 active generation per `GuestJourney`.
- **Idempotency**: Retrying generation returns existing `generatedItinerary` if already produced.
- **Server-Side Content Gating**: `GET /planning-sessions/:id/preview` filters out all days except `previewDayNumber` (Day 1). Locked days do not contain activity details, preventing client-side bypass.

---

## 4. Atomic Claim & User Profile Materialization (`POST /planning-sessions/:id/claim`)
When an authenticated user claims a guest journey:
1. Validate `guestToken` hash against `GuestJourney`.
2. Check `GuestJourney.status` is `PREVIEW_READY` or `AUTH_REQUIRED`.
3. Wrap inside a Prisma Transaction:
   - Create official `Trip` record with `userId = currentUser.id`.
   - Create corresponding `TripDay` and `ItineraryItem` records from `generatedItinerary`.
   - Copy permanent global preferences (interests, preferred travel styles) to `UserTravelProfile`.
   - Update `GuestJourney`: set `status = CLAIMED`, `claimedUserId = currentUser.id`, `createdTripId = newTrip.id`.
4. Return `createdTripId`.
