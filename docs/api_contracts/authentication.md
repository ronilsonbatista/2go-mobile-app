# Contratos de API — Autenticação e Sessão (app-roteiros-core)

O backend oficial `app-roteiros-core` (NestJS 11 + Prisma ORM) fornece suporte completo para autenticação por senha e autenticação sem senha (Passwordless via código OTP de 6 dígitos enviado por e-mail).

---

## 1. Solicitar Código OTP (Passwordless / Login / Registro)
* **Endpoint**: `POST /auth/otp/request`
* **Guarda**: Público (Rate limit: 5 requisições/min; Cooldown: 60s entre envios)
* **Request Body**:
  ```json
  {
    "email": "passageiro@2go.com",
    "purpose": "LOGIN"
  }
  ```
  *Nota*: `purpose` é opcional e aceita: `SIGNUP`, `LOGIN`, `EMAIL_VERIFICATION`, `PASSWORD_RESET` (default: `LOGIN`).
* **Response Body (200 OK)**:
  ```json
  {
    "success": true,
    "data": {
      "success": true,
      "message": "Código de verificação enviado com sucesso para o e-mail."
    },
    "timestamp": "2026-08-17T12:00:00.000Z"
  }
  ```

---

## 2. Validar OTP e Criar Sessão (Verify OTP)
* **Endpoint**: `POST /auth/otp/verify`
* **Guarda**: Público (Rate limit: 10 requisições/min)
* **Request Body**:
  ```json
  {
    "email": "passageiro@2go.com",
    "code": "123456",
    "purpose": "LOGIN"
  }
  ```
* **Response Body (200 OK)**:
  ```json
  {
    "success": true,
    "data": {
      "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "user": {
        "id": "u49a21b3-5e18-4931-8544-a68394848a68",
        "email": "passageiro@2go.com",
        "fullName": "Passageiro",
        "role": "USER",
        "emailConfirmed": true
      }
    },
    "timestamp": "2026-08-17T12:00:00.000Z"
  }
  ```

---

## 3. Registrar Novo Usuário (Com Senha)
* **Endpoint**: `POST /auth/signup`
* **Guarda**: Público (Rate limit: 5 requisições/min)
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

## 4. Autenticação e Login (Com Senha)
* **Endpoint**: `POST /auth/login`
* **Guarda**: Público (Rate limit: 5 requisições/min)
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

---

## 5. Renovação de Tokens (Refresh Token)
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

## 6. Encerrar Sessão Atual (Server-Side Logout)
* **Endpoint**: `POST /auth/logout`
* **Header**: `Authorization: Bearer <accessToken>`
* **Request Body** (opcional):
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
      "message": "Sessão encerrada com sucesso."
    },
    "timestamp": "2026-08-17T12:00:00.000Z"
  }
  ```

---

## 7. Encerrar Todas as Sessões do Usuário (Logout All)
* **Endpoint**: `POST /auth/logout-all`
* **Header**: `Authorization: Bearer <accessToken>`
* **Response Body (200 OK)**:
  ```json
  {
    "success": true,
    "data": {
      "message": "Todas as sessões ativas foram encerradas."
    },
    "timestamp": "2026-08-17T12:00:00.000Z"
  }
  ```

---

## 8. Esqueci Minha Senha (Forgot Password)
* **Endpoint**: `POST /auth/password/forgot`
* **Guarda**: Público (Rate limit: 5 requisições/min)
* **Request Body**:
  ```json
  {
    "email": "passageiro@2go.com"
  }
  ```
* **Response Body (200 OK)**:
  ```json
  {
    "success": true,
    "data": {
      "success": true,
      "message": "Se o e-mail estiver cadastrado, um código de verificação será enviado."
    },
    "timestamp": "2026-08-17T12:00:00.000Z"
  }
  ```

---

## 9. Redefinir Senha com OTP (Reset Password)
* **Endpoint**: `POST /auth/password/reset`
* **Guarda**: Público (Rate limit: 5 requisições/min)
* **Request Body**:
  ```json
  {
    "email": "passageiro@2go.com",
    "code": "123456",
    "newPassword": "NovaSenhaSegura123!"
  }
  ```
* **Response Body (200 OK)**:
  ```json
  {
    "success": true,
    "data": {
      "success": true,
      "message": "Senha redefinida com sucesso. Por favor, faça login com sua nova senha."
    },
    "timestamp": "2026-08-17T12:00:00.000Z"
  }
  ```

---

## 10. Mapeamento Atualizado de Recursos Autenticados

| Recurso | Status no Backend | Endpoint |
|---|---|---|
| Request OTP (Passwordless / Auth) | IMPLEMENTADO | `POST /auth/otp/request` |
| Verify OTP (Login / Passwordless) | IMPLEMENTADO | `POST /auth/otp/verify` |
| Signup (Com Senha) | IMPLEMENTADO | `POST /auth/signup` |
| Login (Com Senha) | IMPLEMENTADO | `POST /auth/login` |
| Refresh Token (Single-Use) | IMPLEMENTADO | `POST /auth/refresh` |
| Logout (Server-Side) | IMPLEMENTADO | `POST /auth/logout` |
| Logout All (Todas as sessões) | IMPLEMENTADO | `POST /auth/logout-all` |
| Forgot Password | IMPLEMENTADO | `POST /auth/password/forgot` |
| Reset Password | IMPLEMENTADO | `POST /auth/password/reset` |
| Obter Perfil (`/users/me`) | IMPLEMENTADO | `GET /users/me` |
| Social Login (Google/Apple) | ARQUITETURA PRONTA | A ser habilitado em fase futura |
