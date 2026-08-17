# Gerenciamento de Sessão e Ciclo de Vida (`twogo_session`)

## Estados da Sessão (`SessionState`)
O ciclo de vida da autenticação é gerenciado através de estados explícitos:
- **`unknown`**: Estado inicial pré-restauração.
- **`restoring`**: Restauração ativa em andamento a partir de secure storage.
- **`authenticated`**: Usuário possui sessão válida e tokens ativos.
- **`unauthenticated`**: Usuário não autenticado ou pós-logout.
- **`expired`**: Sessão expirada no servidor e revogada.

## Restauração da Sessão
Na inicialização do aplicativo, o `SessionCubit` lê silenciosamente o `TokenStorage`. Se tokens válidos forem encontrados, a sessão é restaurada sem bloquear o splash ou exigir novo login.
