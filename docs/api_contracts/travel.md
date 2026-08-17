# Contratos de API — Viagens, Roteiros e Vouchers

## 1. Consulta de Destinos

* **Endpoint**: `GET /rest/v1/destinations?slug=eq.paris&select=*`
* **Response Body (200 OK)**:
  ```json
  [
    {
      "id": "dest_paris_01",
      "name": "Paris",
      "slug": "paris",
      "country": "França",
      "emoji": "🇫🇷",
      "description": "A capital da luz, arte, bistrôs tradicionais e passeios românticos.",
      "best_time": "Primavera (Abril a Junho) e Outono (Setembro a Novembro)",
      "visa_required": false,
      "currency": "EUR",
      "language": "Francês",
      "costs": {
        "economy": { "daily": 70, "meal": 20, "hotel": 30 },
        "comfort": { "daily": 160, "meal": 45, "hotel": 75 },
        "luxury": { "daily": 450, "meal": 120, "hotel": 220 }
      }
    }
  ]
  ```

---

## 2. Consulta de Roteiro de Viagem por Dias

* **Endpoint**: `GET /rest/v1/itineraries?slug=eq.paris-3-dias&select=*,days(*)`
* **Response Body (200 OK)**:
  ```json
  [
    {
      "id": "itin_paris_3d",
      "slug": "paris-3-dias",
      "destination_slug": "paris",
      "title": "Roteiro Paris 3 dias: O Clássico Essencial",
      "duration": 3,
      "days": [
        {
          "day_number": 1,
          "title": "Do Louvre à Torre Eiffel",
          "events": [
            { "time": "09:00", "title": "Visita matinal guiada no Museu do Louvre" },
            { "time": "13:00", "title": "Almoço no Jardin des Tuileries" },
            { "time": "18:30", "title": "Pôr do sol nos Jardins do Trocadéro" }
          ]
        }
      ]
    }
  ]
  ```

---

## 3. Emissão e Consulta de Vouchers Virtuais

* **Endpoint**: `GET /rest/v1/vouchers?user_id=eq.u49a21b3`
* **Headers**: `Authorization: Bearer <access_token>`
* **Response Body (200 OK)**:
  ```json
  [
    {
      "id": "vch_8819203",
      "booking_id": "b78a9c11-4e92-4110-8b01-f51948381180",
      "title": "Ingresso Museu do Louvre - Acesso Fura-Fila",
      "qr_code_data": "2GO-VOUCHER-LOUVRE-8819203",
      "pdf_url": "https://api.2go.com/vouchers/vch_8819203.pdf",
      "valid_until": "2026-12-31T23:59:59Z"
    }
  ]
  ```
