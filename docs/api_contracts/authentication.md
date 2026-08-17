# Contratos de API — Autenticação e Sessão

## 1. Cadastro com E-mail e Senha
* **Endpoint**: `POST /auth/v1/signup`
* **Headers**:
  ```http
  Content-Type: application/json
  apikey: <SUPABASE_ANON_KEY>
  ```
* **Request Body**:
  ```json
  {
    "email": "passageiro@2go.com",
    "password": "SenhaSegura123!",
    "data": {
      "full_name": "João da Silva",
      "phone": "+5511999999999"
    }
  }
  ```
* **Response Body (200 OK)**:
  ```json
  {
    "id": "u49a21b3-5e18-4931-8544-a68394848a68",
    "email": "passageiro@2go.com",
    "email_confirmed_at": null,
    "role": "authenticated"
  }
  ```

---

## 2. Login com E-mail e Senha
* **Endpoint**: `POST /auth/v1/token?grant_type=password`
* **Request Body**:
  ```json
  {
    "email": "passageiro@2go.com",
    "password": "SenhaSegura123!"
  }
  ```
* **Response Body (200 OK)**:
  ```json
  {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "token_type": "bearer",
    "expires_in": 3600,
    "refresh_token": "r_38a91c2b5e1849318544",
    "user": {
      "id": "u49a21b3-5e18-4931-8544-a68394848a68",
      "email": "passageiro@2go.com"
    }
  }
  ```

---

## 3. Envio de Código OTP por E-mail
* **Endpoint**: `POST /auth/v1/otp`
* **Request Body**:
  ```json
  {
    "email": "passageiro@2go.com",
    "create_user": true
  }
  ```
* **Response Body (200 OK)**:
  ```json
  {
    "message": "OTP enviado para o e-mail informado"
  }
  ```

---

## 4. Confirmação de Código OTP (6 dígitos)
* **Endpoint**: `POST /auth/v1/verify`
* **Request Body**:
  ```json
  {
    "type": "signup",
    "email": "passageiro@2go.com",
    "token": "123456"
  }
  ```
* **Response Body (200 OK)**:
  ```json
  {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "token_type": "bearer",
    "expires_in": 3600,
    "refresh_token": "r_99b71c2b5e1849318544",
    "user": {
      "id": "u49a21b3-5e18-4931-8544-a68394848a68",
      "email": "passageiro@2go.com",
      "email_confirmed_at": "2026-08-17T11:00:00Z"
    }
  }
  ```

---

## 5. Refresh Token
* **Endpoint**: `POST /auth/v1/token?grant_type=refresh_token`
* **Request Body**:
  ```json
  {
    "refresh_token": "r_99b71c2b5e1849318544"
  }
  ```
* **Response Body (200 OK)**:
  ```json
  {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "token_type": "bearer",
    "expires_in": 3600,
    "refresh_token": "r_11c91c2b5e1849318544"
  }
  ```

---

## 6. Logout
* **Endpoint**: `POST /auth/v1/logout`
* **Headers**: `Authorization: Bearer <access_token>`
* **Response Body (204 No Content)**.
