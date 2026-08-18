# Product Specification — First Access & Acquisition Journey (2GO Mobile)

## 1. Executive Summary
The **First Access Journey** transforms anonymous visitors into paying customers by offering an interactive AI-powered itinerary creation wizard **before** requiring account registration or authentication.

```
APP FIRST ACCESS
      │
      ▼
ITINERARY CREATION WIZARD (Steps 1–6)
      │
      ▼
CONFIRMATION MODAL & AI GENERATION ("Gerando seu roteiro...")
      │
      ▼
ONE-DAY FREE PREVIEW + TIMELINE & MAP
      │
      ▼
PAYWALL (Banner, Locked Days, or 10s Timer)
      │
      ▼
AUTHENTICATION / OTP (Preserves PostAuthIntent + GuestJourney)
      │
      ▼
CLAIM GUEST JOURNEY (Atomically attaches draft & creates Trip)
      │
      ▼
CHECKOUT & PAYMENT (Cart, Personal Info, Payment Methods)
      │
      ▼
PAYMENT CONFIRMED ──► UNLOCK PREMIUM ──► APP SHELL / FULL TRIP
```

---

## 2. Key Product Principles

### Frictionless Acquisition
- **No Early Login Wall**: Prospective travelers experience value immediately by building their trip profile and generating a custom AI itinerary preview without sign-up barriers.

### Server-Side Paywall & Security
- **Strict Content Gate**: Only 1 day of the generated itinerary is returned to the mobile app during the preview phase (`GET /planning-sessions/:id/preview`). The full itinerary remains locked server-side until payment confirmation (`Purchase.status == PAID`).

### Seamless Auth Handoff (`PostAuthIntent`)
- When a user logs in from the Paywall, authentication preserves the `guestJourneyId`, `guestToken`, and intent (`CLAIM_GUEST_JOURNEY`).
- After OTP verification, the user is redirected straight to **Checkout**—not to the generic Home page.

### Returning Customer Shortcut
- Unauthenticated returning users can select **"Já sou cliente? Entrar"** on the initial wizard screen to navigate directly to Login/OTP and restore their existing account.

---

## 3. Journey Flow Breakdown

### A. Itinerary Creation Wizard (Steps 1 to 6)
1. **Step 1 — Onde (Destino & Datas)**: Multi-destination support, city, arrival/departure dates, arrival/departure times.
2. **Step 2 — Quem vai (Passageiros)**: Independent counts for Adults (18+), Children (<12), and Elders (>65).
3. **Step 3 — Interesses (Preferências)**: Multi-select interests (Arte, Gastronomia, Esporte, Arquitetura, Atividades ao ar livre, Música, Cultura Geek, História local, Natureza).
4. **Step 4 — Horários (Atividades)**: Preferred daily window (Início e Fim das atividades, e.g., 09:00 – 19:00).
5. **Step 5 — Estilo / Faixa**: Budget level selection (`$ Econômica`, `$$ Confortável`, `$$$ Premium`, `$$$$ Luxuosa`).
6. **Step 6 — Revisão & Confirmação**: Full summary cards with edit buttons per step.
   - **Confirmation Modal**: "Deseja continuar? Após essa etapa, não será possível alterar as informações."

### B. AI Generation & Storage
- Screen: **"Gerando seu roteiro..."** with animated progress.
- Backend calls OpenAI to generate the complete multi-day itinerary and persists it in `GuestJourney`.

### C. One-Day Free Preview & Paywall
- Interactive timeline showing Day 1 activities (morning, afternoon, evening, free/paid badges, map coordinates).
- Locked Day tabs (e.g. Day 2, Day 3 locked).
- Countdown badge showing time until trip departure.
- **Paywall Triggers**:
  1. Top sale banner ("Tenha acesso a todos os dias por R$ 19,99").
  2. Tapping any locked day tab.
  3. Automatic 10-second timer on preview screen (with session suppression on dismiss).

### D. Auth -> Claim -> Checkout -> Payment
- User logs in via OTP.
- `POST /planning-sessions/:id/claim` converts `GuestJourney` into an official `Trip` attached to `User.id`.
- Redirects to **Checkout** with product details, optional coupon discount, and payment options (Credit Card, PIX, Apple Pay).
- On payment approval (`Purchase.status == PAID`), server sets `Trip.premiumUnlockedAt`, unlocking all itinerary days.
