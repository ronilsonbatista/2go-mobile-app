# Contrato Unificado de Erros (PostgREST & REST API)

## 1. Schema do Erro Padrão Supabase / PostgREST
Todos os erros retornados pela API seguem o formato padronizado abaixo:

```json
{
  "code": "PGRST116",
  "message": "The result contains 0 rows",
  "details": "Results contain 0 rows, application expected 1 row",
  "hint": "Check query parameters or permissions."
}
```

Para chamadas HTTP genéricas e validações de input:
```json
{
  "code": "invalid_credentials",
  "message": "E-mail ou senha incorretos.",
  "status": 400
}
```

---

## 2. Tabela de Mapeamento de Status HTTP

| Código HTTP | Significado | Exemplo de Causa no App Mobile | Ação Recomendada no App |
|---|---|---|---|
| `400 Bad Request` | Parâmetros ou payload inválidos | Código OTP com menos de 6 dígitos, e-mail malformado | Exibir mensagem no `TwoGoTextField` ou `TwoGoSnackbar` |
| `401 Unauthorized` | Access Token ausente, expirado ou inválido | Sessão expirada | Trigar interseptor de Refresh Token; se falhar, redirecionar para Login |
| `403 Forbidden` | Sem permissão de acesso ao recurso | Tentativa de acessar voucher de outro usuário | Exibir `TwoGoStatusMessage` de erro de permissão |
| `404 Not Found` | Recurso não localizado | Roteiro ou destino inexistente | Exibir tela de estado vazio/404 |
| `409 Conflict` | Conflito de dados | E-mail já cadastrado | Exibir alerta de e-mail em uso no formulário de cadastro |
| `422 Unprocessable Entity` | Erro de regra de negócio | Cupom expirado ou inválido | Exibir erro no BottomSheet de Cupom |
| `429 Too Many Requests` | Limite de requisições excedido | Múltiplas solicitações consecutivas de OTP | Bloquear temporariamente o botão e exibir cronômetro de espera |
| `500 / 503 Server Error` | Instabilidade no servidor ou banco de dados | Erro de banco de dados no Supabase | Exibir `TwoGoStatusMessage` de erro com botão "Tentar novamente" |
