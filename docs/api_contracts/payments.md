# Contratos de API — Billing, Compras e Pagamentos (app-roteiros-core)

## 1. Módulo de Billing Existente
O backend `app-roteiros-core` possui um módulo funcional de **Billing & Purchases** (`src/billing`) com provedor mock de pagamentos (`MockPaymentProvider`), gerenciando a venda e liberação de produtos digitais.

### Produtos Suportados (`ProductType`):
* `ITINERARY_FULL_ACCESS`: Acesso completo ao roteiro premium
* `AI_CREDITS`: Créditos adicionais para geração via IA
* `PREMIUM_TEMPLATE`: Template base premium

---

## 2. Listagem de Produtos Ativos
* **Endpoint**: `GET /products`
* **Header**: `Authorization: Bearer <accessToken>`
* **Response Body (200 OK)**:
  ```json
  {
    "success": true,
    "data": [
      {
        "id": "prod_full_access_01",
        "name": "Roteiro Completo Paris Premium",
        "description": "Desbloqueio de todas as atrações e mapas",
        "type": "ITINERARY_FULL_ACCESS",
        "price": 29.90,
        "currency": "BRL",
        "active": true
      }
    ],
    "timestamp": "2026-08-17T11:45:00.000Z"
  }
  ```

---

## 3. Criar Pedido de Compra (Mock)
* **Endpoint**: `POST /purchases/mock`
* **Header**: `Authorization: Bearer <accessToken>`
* **Request Body**:
  ```json
  {
    "productId": "prod_full_access_01",
    "tripId": "t78a9c11-4e92-4110-8b01-f51948381180"
  }
  ```
* **Response Body (201 Created)**:
  ```json
  {
    "success": true,
    "data": {
      "id": "pur_9910283",
      "userId": "u49a21b3-5e18-4931-8544-a68394848a68",
      "productId": "prod_full_access_01",
      "tripId": "t78a9c11-4e92-4110-8b01-f51948381180",
      "status": "PENDING",
      "amount": 29.90,
      "currency": "BRL",
      "createdAt": "2026-08-17T11:45:00.000Z"
    },
    "timestamp": "2026-08-17T11:45:00.000Z"
  }
  ```

---

## 4. Confirmar Pagamento do Pedido (Mock Payment)
* **Endpoint**: `POST /purchases/:id/confirm-mock-payment`
* **Header**: `Authorization: Bearer <accessToken>`
* **Response Body (200 OK)**:
  ```json
  {
    "success": true,
    "data": {
      "id": "pur_9910283",
      "status": "PAID",
      "paidAt": "2026-08-17T11:45:05.000Z",
      "mockPaymentId": "mock_pay_881923"
    },
    "timestamp": "2026-08-17T11:45:05.000Z"
  }
  ```

---

## 5. Auditoria de Gateways Reais e Recomendações
* **Gateways Reais (Stripe / MercadoPago / PIX / Webhooks / Idempotency-Key)**: **NÃO IMPLEMENTADOS** na versão atual do backend `app-roteiros-core`.
* **Recomendação Futura P1**: Quando a integração real com gateways for solicitada no backend, os segredos de API e webhooks deverão permanecer estritamente no servidor NestJS, nunca expostos no cliente mobile.
