# 2GO Mobile — Planning API Contracts & Mapping

## 1. Endpoints
- `POST /planning-sessions` -> Creates anonymous guest planning session.
- `GET /planning-sessions/:id` -> Retrieves current guest planning session state. Requires `X-Guest-Token`.
- `PATCH /planning-sessions/:id` -> Updates questionnaire answers & step progress. Requires `X-Guest-Token`.
- `POST /planning-sessions/:id/finalize` -> Finalizes questionnaire (`COLLECTING` -> `READY_TO_GENERATE`). Requires `X-Guest-Token`.

## 2. DTO <-> Domain Mapping
- `PlanningApiClient` communicates via `app_roteiros_api` generated client DTOs.
- `PlanningMapper` maps DTOs to pure domain entities (`GuestJourney`, `PlanningDestination`, `PlanningTravelers`, `PlanningInterest`, `PlanningActivityWindow`).
- Enums are safely converted (`GuestJourneyStatus.fromRaw`, `PlanningInterest.fromRaw`).
- BudgetLevel and TravelStyle mapping rules:
  - `$ Econômica`, `$$ Confortável`, `$$$ Premium`, `$$$$ Luxuosa` map to `BudgetLevel` (`LOW`, `MEDIUM`, `HIGH`, `PREMIUM`) and `TravelStyle` (`ECONOMIC`, `COMFORT`, `LUXURY`). `$$$ Premium` represents economic comfort/budget tier and is NEVER artificially converted to `TravelStyle.CULTURAL`.
