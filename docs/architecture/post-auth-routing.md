# Architecture Specification — Post-Auth Intent & Routing (2GO Mobile)

## 1. Context & Problem Statement
Currently, completing authentication (`SessionCubit` -> `authenticated`) automatically routes to `/app/home`.
However, during the **First Access Journey**, an unauthenticated prospect who logs in from the **Paywall** must **not** be sent to Home. They must claim their `GuestJourney` and immediately proceed to **Checkout**.

---

## 2. `PostAuthIntent` Concept & Definition

```dart
enum PostAuthIntentType {
  /// Default login flow -> Navigates to /app/home
  normalLogin,

  /// Login triggered from Guest Journey Paywall -> Claims journey and opens /checkout
  claimGuestJourney,

  /// Resuming a pending checkout for an existing trip -> Opens /checkout
  resumeCheckout,
}

class PostAuthIntent {
  final PostAuthIntentType type;
  final String? guestJourneyId;
  final String? guestToken;
  final String? targetTripId;

  const PostAuthIntent({
    required this.type,
    this.guestJourneyId,
    this.guestToken,
    this.targetTripId,
  });

  static const normal = PostAuthIntent(type: PostAuthIntentType.normalLogin);
}
```

---

## 3. Post-Auth Routing Logic Matrix

```
                      ┌─────────────────────────┐
                      │ Authentication Verified │
                      │      (OTP Success)      │
                      └────────────┬────────────┘
                                   │
                    Inspect PostAuthIntent.type
                                   │
       ┌───────────────────────────┼───────────────────────────┐
       ▼                           ▼                           ▼
 NORMAL_LOGIN              CLAIM_GUEST_JOURNEY          RESUME_CHECKOUT
       │                           │                           │
       │                   Execute Claim API                   │
       │              (POST /planning-sessions/claim)          │
       │                           │                           │
       ▼                           ▼                           ▼
Navigates to              Navigates to                 Navigates to
 /app/home                 /checkout                    /checkout
                          (with createdTripId)         (with targetTripId)
```

---

## 4. State Machine & Deep Linking Integration
- `SessionCubit` maintains an optional `PostAuthIntent? pendingIntent`.
- When navigating to `/auth` from Paywall:
  ```dart
  context.push('/auth', extra: PostAuthIntent(
    type: PostAuthIntentType.claimGuestJourney,
    guestJourneyId: journeyId,
    guestToken: token,
  ));
  ```
- When OTP authentication completes:
  1. `SessionCubit` checks if `pendingIntent` exists.
  2. If `type == claimGuestJourney`, invokes `claimGuestJourneyUseCase(intent.guestJourneyId, intent.guestToken)`.
  3. Upon successful claim, router navigates directly to `/checkout?tripId=${createdTrip.id}`.
  4. If `type == normalLogin`, router navigates to `/app/home`.
