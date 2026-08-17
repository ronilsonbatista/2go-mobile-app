# Contratos de API — Autenticação e Sessão (app-roteiros-core)

## 1. Registrar Novo Usuário
* **Endpoint**: `POST /auth/signup`
* **Guarda**: Público (Rate limit: 5 requisições por minuto)
* **Request Body**:
  ```json
  {
    "email": "passageiro@2go.com",
    "fullName": "João da Silva",
    "password": "SenhaSegura123!"
  }
  ```
* **Response Body (201 Created)**:
  ```json
  {
    "success": true,
    "data": {
      "message": "Usuário registrado com sucesso",
      "userId": "u49a21b3-5e18-4931-8544-a68394848a68"
    },
    "timestamp": "2026-08-17T11:45:00.000Z"
  }
  ```

---

## 2. Autenticação e Login
* **Endpoint**: `POST /auth/login`
* **Guarda**: Público (Rate limit: 5 requisições por minuto)
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
    "success": true,
    "data": {
      "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    },
    "timestamp": "2026-08-17T11:45:00.000Z"
  }
  ```

### Especificação dos Tokens:
* **Access Token**: JWT com expiração de **15 minutos**. Transmitido em todas as requisições protegidas no header `Authorization: Bearer <accessToken>`.
* **Refresh Token**: JWT com expiração de **7 dias**. Salvo com hash seguro em tabela `refresh_tokens` no PostgreSQL com mecanismo de **Single-Use Rotation** (revogação imediata após uso).

---

## 3. Renovação de Tokens (Refresh Token)
* **Endpoint**: `POST /auth/refresh`
* **Guarda**: Público
* **Request Body**:
  ```json
  {
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
  ```
* **Response Body (200 OK)**:
  ```json
  {
    "success": true,
    "data": {
      "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    },
    "timestamp": "2026-08-17T11:45:00.000Z"
  }
  ```

---

## 4. Perfil do Usuário Logado
* **Endpoint**: `GET /users/me`
* **Header**: `Authorization: Bearer <accessToken>`
* **Response Body (200 OK)**:
  ```json
  {
    "success": true,
    "data": {
      "message": "Acesso liberado!",
      "user": {
        "userId": "u49a21b3-5e18-4931-8544-a68394848a68",
        "email": "passageiro@2go.com",
        "role": "USER"
      }
    },
    "timestamp": "2026-08-17T11:45:00.000Z"
  }
  ```

---

## 5. Mapeamento de Recursos Autenticados

| Recurso | Status no Backend | Observação do Contrato |
|---|---|---|
| Signup (Registro) | IMPLEMENTADO | `POST /auth/signup` |
| Login (JWT) | IMPLEMENTADO | `POST /auth/login` |
| Refresh Token | IMPLEMENTADO | `POST /auth/refresh` com rotação |
| Obter Perfil (`/users/me`) | IMPLEMENTADO | `GET /users/me` |
| Perfil de Viagem (`travel-profile`) | IMPLEMENTADO | `GET / POST / PATCH / DELETE /users/me/travel-profile` |
| Email OTP / Confirmação | NÃO IMPLEMENTADO | Mantido campo no DB `emailConfirmed`, mas sem rota pública |
| Password Reset / Esqueci Senha | NÃO IMPLEMENTADO | Suportado via Admin `PATCH /admin/users/:id/change-password` |
| Social Login (Google/Apple) | NÃO IMPLEMENTADO | Não existente no backend atual |
| Logout | CLIENT-SIDE | Limpeza de tokens no cliente Flutter (`TokenStorage`) |
