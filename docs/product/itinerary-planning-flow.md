# Product Specification — Itinerary Planning Flow (2GO Mobile)

## 1. Overview & Data Model
The **Itinerary Planning Questionnaire** captures structured travel preferences across 6 sequential steps. Responses are stored progressively in local storage and mirrored to the backend server-side guest session (`GuestJourney`).

---

## 2. Step-by-Step Specifications

### Step 1 — Onde (Destino & Período)
- **Multi-destination Support**: Allows adding one or more destinations.
- **Fields per Destination**:
  - `destinationId` / `providerPlaceId` (Place ID if selected from Google Places autocomplete)
  - `name` (e.g. "Roma")
  - `city` (e.g. "Roma")
  - `country` (e.g. "Itália")
  - `coverImage` (Place photo URL when available)
  - `arrivalDate` (e.g. `2026-07-25`)
  - `arrivalTime` (e.g. `11:00`)
  - `departureDate` (e.g. `2026-07-28`)
  - `departureTime` (e.g. `19:00`)

### Step 2 — Quem vai (Viajantes)
- **Independent Counter Controls**:
  - `adults` (18+ anos): Minimum 1, default 2.
  - `children` (Menores de 12 anos): Minimum 0.
  - `elders` (Mais de 65 anos): Minimum 0.
- **Rationale**: AI generation tailors activity pacing, venue accessibility, and child-friendly flags based on exact demographic counts rather than a generic "family" label.

### Step 3 — Interesses (Preferências)
- **Typed Interest Options (Multi-select)**:
  - `ARTE` ("Arte")
  - `GASTRONOMIA` ("Gastronomia")
  - `ESPORTE` ("Esporte")
  - `ARQUITETURA` ("Arquitetura")
  - `ATIVIDADES_AO_AR_LIVRE` ("Atividades ao ar livre")
  - `MUSICA` ("Música")
  - `CULTURA_GEEK` ("Cultura Geek")
  - `HISTORIA_LOCAL` ("História local")
  - `NATUREZA` ("Natureza")

### Step 4 — Horários das Atividades
- **Daily Operating Window**:
  - `activityStartTime` (Time pills: `08:00`, `08:30`, `09:00`, `09:30`, `10:00`)
  - `activityEndTime` (Time pills: `18:00`, `18:30`, `19:00`, `19:30`, `20:00`)

### Step 5 — Estilo da Viagem
- **Travel Style Options (Single-select)**:
  - `$ Econômica` -> Maps to `TravelStyle.ECONOMIC` / `BudgetLevel.LOW`
  - `$$ Confortável` -> Maps to `TravelStyle.COMFORT` / `BudgetLevel.MEDIUM`
  - `$$$ Premium` -> Maps to `TravelStyle.PREMIUM` / `BudgetLevel.HIGH`
  - `$$$$ Luxuosa` -> Maps to `TravelStyle.LUXURY` / `BudgetLevel.PREMIUM`

### Step 6 — Revisão & Lock Confirmation
- Renders comprehensive review cards for all previous steps.
- Each section includes a direct edit action ("Taque para editar").
- **Submit Action**: Displays modal overlay:
  - **Title**: "Deseja continuar?"
  - **Message**: "Após essa etapa, não será possível alterar as informações."
  - **Buttons**: "Continuar" (triggers AI generation & locks guest session draft) and "Cancelar".
