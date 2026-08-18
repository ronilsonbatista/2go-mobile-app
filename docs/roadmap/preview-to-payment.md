# Technical Roadmap — First Access Journey (Preview to Payment)

## 1. Overview & Master Phases (Phase A to Phase M)

| Phase | Title | Main Focus | Repository Target |
| :--- | :--- | :--- | :--- |
| **PHASE A** | Backend Guest Journey Audit | Schema audit, Prisma models, OpenAPI contract design | Backend (`approteiros-api`) |
| **PHASE B** | Guest Journey Backend API | Implement `GuestJourney` module, controller, Prisma migration | Backend (`approteiros-api`) |
| **PHASE C** | OpenAPI Sync Mobile | Regenerate mobile API client, OpenAPI sync | Mobile (`2go-mobile`) |
| **PHASE D** | Design System & Wizard Primitives | Stepper, date/time pickers, counter/stepper, selection tiles | DS (`packages/design_system`) |
| **PHASE E** | Questionnaire Steps 1–2 | Onde + Datas + Horários voo + Passageiros | Mobile (`packages/travel/planning`) |
| **PHASE F** | Questionnaire Steps 3–6 | Interesses + Horário atividades + Estilo + Revisão | Mobile (`packages/travel/planning`) |
| **PHASE G** | AI Generation & State Screen | Tela "Gerando seu roteiro...", job/status state machine | Mobile + Backend |
| **PHASE H** | One-Day Preview & Paywall | Day 1 timeline, locked days, countdown, paywall modal | Mobile (`packages/travel/planning`) |
| **PHASE I** | Auth Handoff & Claim | `PostAuthIntent`, OTP flow preservation, atomic claim | Mobile + Backend |
| **PHASE J** | Billing & Payment Audit | Audit existing `Purchase` & `Product` models, gaps analysis | Backend (`approteiros-api`) |
| **PHASE K** | Real Payment Backend | Payment abstraction, Gateway provider, Webhooks, PIX | Backend (`approteiros-api`) |
| **PHASE L** | Checkout & Payment UI | Cart, Coupon code sheet, Credit Card, PIX, Apple Pay UI | Mobile (`packages/commerce`) |
| **PHASE M** | Payment Confirmation & Unlock | Payment approval handler, `premiumUnlockedAt`, Home handoff | Mobile + Backend |

---

## 2. Phase Execution Rules
1. **Isolated Execution**: Each phase is planned, implemented, tested, and audited independently.
2. **Mandatory Verification**: Every phase must pass unit/widget/golden tests, `melos run analyze`, architecture lints, and build checks before proceeding.
3. **Dedicated Git Commit**: A clear commit message per phase (e.g. `feat(planning): add anonymous itinerary planning sessions`).
4. **Approval Gate**: Stop and present delivery report after each phase. Do not auto-advance to subsequent phases.
