# Contrato de Erros e Exceções (NestJS GlobalExceptionFilter)

## 1. Envelope Padrão de Resposta de Erro
Todas as exceções capturadas pelo backend `app-roteiros-core` retornam um envelope JSON unificado através do `GlobalExceptionFilter` contendo o campo de código de erro estável `code`:

```json
{
  "success": false,
  "code": "AUTH_OTP_INVALID",
  "message": "Código de verificação incorreto.",
  "statusCode": 400,
  "timestamp": "2026-08-17T12:00:00.000Z",
  "path": "/auth/otp/verify"
}
```

### Validações de Formato (ClassValidator 400 Bad Request):
Quando ocorrem erros de validação de DTO, o campo `message` contém uma lista de strings explicativas:

```json
{
  "success": false,
  "code": "BAD_REQUEST",
  "message": [
    "Formato de e-mail inválido",
    "O código OTP deve ter exatamente 6 dígitos"
  ],
  "statusCode": 400,
  "timestamp": "2026-08-17T12:00:00.000Z",
  "path": "/auth/otp/verify"
}
```

---

## 2. Tabela de Códigos de Erro Estáveis (`AuthErrorCode`)

| Error Code | HTTP Status | Descrição no Backend | Tratamento Recomendado no App Mobile |
|---|---|---|---|
| `AUTH_OTP_INVALID` | 400 | Código de 6 dígitos incorreto | Exibir erro no campo OTP (`TwoGoOtpField`) |
| `AUTH_OTP_EXPIRED` | 400 | Código OTP expirado (>10 min) | Solicitar reenvio do OTP (`requestOtp`) |
| `AUTH_OTP_TOO_MANY_ATTEMPTS` | 429 | Excedido limite de 5 tentativas incorretas | Bloquear envio do código e sugerir novo OTP |
| `AUTH_OTP_RATE_LIMITED` | 429 | Tentativa de solicitar novo OTP em < 60s | Exibir timer de regressão de 60 segundos |
| `AUTH_SESSION_EXPIRED` | 401 | Access token ou session expirada | Tentar `refreshTokens`; se falhar, exibir tela de Login |
| `AUTH_REFRESH_TOKEN_INVALID` | 401 | Refresh token revogado ou inválido | Limpar tokens locais e navegar para Login |
| `AUTH_CREDENTIALS_INVALID` | 401 | E-mail ou senha incorretos | Exibir alerta de credenciais inválidas |
| `AUTH_USER_BLOCKED` | 401 / 403 | Conta de usuário bloqueada por admin | Exibir modal de suporte/bloqueio |
| `AUTH_USER_ARCHIVED` | 401 | Conta arquivada | Exibir mensagem de conta desativada |
| `AUTH_USER_EXISTS` | 400 | Tentativa de cadastro com e-mail em uso | Sugerir login via OTP ou senha |
| `AUTH_USER_NOT_FOUND` | 404 | E-mail não encontrado | Exibir alerta de usuário não cadastrado |

---

## 3. Mapeamento de Status HTTP Gerais

| Código HTTP | Exceção NestJS | Cenário no App Mobile | Ação Recomendada no App |
|---|---|---|---|
| `400 Bad Request` | `BadRequestException` | E-mail duplicado ou campos malformados | Exibir validação em campos ou `TwoGoSnackbar` |
| `401 Unauthorized` | `UnauthorizedException` | Token ausente ou revogado | Executar refresh token silencioso ou ir para Login |
| `403 Forbidden` | `ForbiddenException` | Recurso não permitido | Exibir permissão negada |
| `404 Not Found` | `NotFoundException` | Recurso inexistente | Exibir estado vazio |
| `429 Too Many Requests` | `ThrottlerException` | Limite de requisições por minuto excedido | Desabilitar botão e iniciar contador de cooldown |
| `500 Internal Server Error` | `InternalServerErrorException` | Falha inesperada | Exibir `TwoGoStatusMessage` com botão tentar novamente |
