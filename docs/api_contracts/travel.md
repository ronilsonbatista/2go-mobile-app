# Contratos de API — Viagens, Roteiros e Colaboradores (app-roteiros-core)

## 1. Listagem de Viagens do Usuário
* **Endpoint**: `GET /trips`
* **Header**: `Authorization: Bearer <accessToken>`
* **Response Body (200 OK)**:
  ```json
  {
    "success": true,
    "data": [
      {
        "id": "t78a9c11-4e92-4110-8b01-f51948381180",
        "title": "Minha Viagem para Paris",
        "destination": "Paris, França",
        "coverImage": "https://api.2go.com/uploads/trips/cover_paris.jpg",
        "startDate": "2026-09-01T00:00:00.000Z",
        "endDate": "2026-09-07T00:00:00.000Z",
        "status": "ACTIVE",
        "premiumUnlockedAt": "2026-08-17T11:45:00.000Z"
      }
    ],
    "timestamp": "2026-08-17T11:45:00.000Z"
  }
  ```

---

## 2. Criar Nova Viagem
* **Endpoint**: `POST /trips`
* **Request Body**:
  ```json
  {
    "title": "Férias em Tóquio",
    "destination": "Tóquio, Japão",
    "startDate": "2026-10-10T00:00:00.000Z",
    "endDate": "2026-10-20T00:00:00.000Z"
  }
  ```

---

## 3. Gerar Roteiro via IA (OpenAI GPT)
* **Endpoint**: `POST /trips/:tripId/generate-itinerary`
* **Rate Limit**: 3 requisições por minuto
* **Request Body**:
  ```json
  {
    "style": "CULTURAL",
    "budget": "COMFORT",
    "interests": ["museus", "gastronomia", "parques"]
  }
  ```
* **Response Body (200 OK)**: Retorna a estrutura da `Trip` atualizada com todos os `TripDay` e `ItineraryItem` gerados.

---

## 4. Gerenciamento do Roteiro (Dias e Atividades)
* **Adicionar Dia**: `POST /trips/:id/days` (`{ dayNumber: 1, title: "Chegada em Paris" }`)
* **Adicionar Item/Atividade**: `POST /trip-days/:id/items`
  ```json
  {
    "title": "Visita à Torre Eiffel",
    "description": "Subida ao topo e almoço no Trocadéro",
    "category": "TOURIST_ATTRACTION",
    "period": "MANHA",
    "duration": 180,
    "cost": 30.00,
    "currency": "EUR",
    "order": 1
  }
  ```
* **Reordenar Item**: `PATCH /itinerary-items/:id/reorder` (`{ newOrder: 2 }`)
* **Enriquecer com Google Places**: `PATCH /itinerary-items/:id/place` (`{ providerPlaceId: "ChIJLU7jZClu5kcR4PcD-5xMwVV" }`)

---

## 5. Colaboradores e Viagens Compartilhadas
* **Convidar Participante**: `POST /trips/:tripId/participants` (`{ email: "amigo@2go.com", role: "VIEWER" }`)
* **Aceitar Convite**: `POST /trip-invites/accept` (`{ inviteToken: "tok_invite_991203" }`)
* **Listar Viagens Compartilhadas Comigo**: `GET /users/me/shared-trips`
