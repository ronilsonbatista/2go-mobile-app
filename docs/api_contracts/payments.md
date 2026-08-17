# Contratos de API — Pagamentos e Checkout

## 1. Métodos de Pagamento Suportados
* **PIX**: QR Code estático/dinâmico + chave Copia e Cola.
* **Cartão de Crédito**: À vista e parcelado (em até 12x).

---

## 2. Processar Pagamento via PIX

* **Endpoint**: `POST /rest/v1/payments`
* **Headers**:
  ```http
  Content-Type: application/json
  Authorization: Bearer <access_token>
  Idempotency-Key: <UUID-v4>
  ```
* **Request Body**:
  ```json
  {
    "booking_id": "b78a9c11-4e92-4110-8b01-f51948381180",
    "method": "pix",
    "amount": 299.90,
    "coupon_code": "PROMO2GO10"
  }
  ```
* **Response Body (201 Created)**:
  ```json
  {
    "payment_id": "p_91823192031",
    "status": "pending",
    "method": "pix",
    "amount": 269.91,
    "pix_copy_paste": "00020126580014BR.GOV.BCB.PIX0136123e4567-e89b-12d3-a456-4266141740005204000053039865405269.915802BR59102GO TRAVEL6009SAO PAULO62070503***6304E2CA",
    "qr_code_url": "https://api.2go.com/qr/p_91823192031.png",
    "expires_at": "2026-08-17T12:00:00Z"
  }
  ```

---

## 3. Processar Pagamento via Cartão de Crédito

* **Endpoint**: `POST /rest/v1/payments`
* **Request Body**:
  ```json
  {
    "booking_id": "b78a9c11-4e92-4110-8b01-f51948381180",
    "method": "credit_card",
    "amount": 299.90,
    "installments": 3,
    "card_token": "tok_1N82h02eZvKYlo2C",
    "billing_address": {
      "street": "Av. Paulista",
      "number": "1000",
      "zip_code": "01310-100",
      "city": "São Paulo",
      "state": "SP"
    }
  }
  ```
* **Response Body (201 Created)**:
  ```json
  {
    "payment_id": "p_91823192032",
    "status": "approved",
    "method": "credit_card",
    "amount": 299.90,
    "installments": 3,
    "transaction_code": "TX991203819"
  }
  ```

---

## 4. Idempotência e Segurança Garantida
* O header `Idempotency-Key` (UUID v4) é obrigatório em requisições de pagamento e reservas para evitar cobranças duplicadas em caso de instabilidade de rede ou retry no cliente mobile.
