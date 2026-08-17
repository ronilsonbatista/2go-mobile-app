# ADR 002 — Single-Flight Refresh Token Coordination

## Status
Aprovado

## Contexto
O backend `app-roteiros-core` adota a política de **Single-Use Refresh Token Rotation**, na qual um refresh token é revogado imediatamente ao ser utilizado. Quando o token de acesso expira e múltiplas requisições assíncronas concorrentes (ex: buscar viagens, perfil, alertas) recebem `401 Unauthorized` simultaneamente, tentar disparar múltiplos refreshes consumiria o mesmo refresh token mais de uma vez, provocando falhas de invalidação de sessão.

## Decisão
Implementar o coordenador de renovação `RefreshCoordinator` no pacote `twogo_networking` utilizando o padrão **Single-Flight Concurrency Mutex**:
1. Apenas a **PRIMEIRA** requisição 401 dispara o HTTP `POST /auth/refresh`.
2. A requisição armazena seu `Future<AuthTokens>` compartilhado em `_refreshFuture`.
3. Todas as demais requisições concorrentes 401 detectam `_refreshFuture != null` e aguardam a conclusão do mesmo Future sem fazer nenhuma nova chamada HTTP.
4. Após o término da renovação, os novos tokens são salvos, a lista de requisições retoma a execução com o novo `accessToken` e o mutex é resetado.

## Consequências
- Garantia de que exatamente 1 requisição de refresh é realizada, respeitando rigorosamente a rotação de refresh token de uso único do backend.
- Eliminação de race conditions e loops de refresh.
