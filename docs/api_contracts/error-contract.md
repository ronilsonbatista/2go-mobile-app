# Contrato de Erros e Exceções (NestJS GlobalExceptionFilter)

## 1. Envelope Padrão de Resposta de Erro
Todas as exceções capturadas pelo backend `app-roteiros-core` retornam um envelope JSON unificado através do `GlobalExceptionFilter`:

```json
{
  "success": false,
  "message": "Credenciais inválidas",
  "statusCode": 401,
  "timestamp": "2026-08-17T11:45:00.000Z",
  "path": "/auth/login"
}
```

### Validações de Formato (ClassValidator 400 Bad Request):
Quando ocorrem erros de validação de DTO, o campo `message` contém uma lista de strings explicativas:

```json
{
  "success": false,
  "message": [
    "email deve ser um e-mail válido",
    "password deve ser uma string"
  ],
  "statusCode": 400,
  "timestamp": "2026-08-17T11:45:00.000Z",
  "path": "/auth/signup"
}
```

---

## 2. Mapeamento de Status HTTP

| Código HTTP | Exceção NestJS | Cenário no App Mobile | Ação Recomendada no App |
|---|---|---|---|
| `400 Bad Request` | `BadRequestException` | E-mail duplicado ou campos malformados | Exibir validação em campos ou `TwoGoSnackbar` de alerta |
| `401 Unauthorized` | `UnauthorizedException` | Token ausente, expirado ou usuário bloqueado | Executar refresh token silencioso; se falhar, redirecionar para tela de Login |
| `403 Forbidden` | `ForbiddenException` | Usuário tentando acessar recurso administrativo | Exibir tela de permissão negada |
| `404 Not Found` | `NotFoundException` | Viagem ou item de roteiro inexistente | Exibir estado vazio ou voltar tela |
| `422 Unprocessable Entity` | `HttpStatus.UNPROCESSABLE_ENTITY` | Upload de mídia excedendo tamanho limite ou formato inválido | Informar erro de formato de arquivo no app |
| `429 Too Many Requests` | `ThrottlerException` | Limite de requisições por minuto excedido (ex: 5 logins/min) | Desabilitar botão temporariamente |
| `500 Internal Server Error` | `InternalServerErrorException` | Falha inesperada | Exibir `TwoGoStatusMessage` com opção de tentar novamente |
