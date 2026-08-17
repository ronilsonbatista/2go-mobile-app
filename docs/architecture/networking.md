# Arquitetura de Networking e HTTP Client (`twogo_networking`)

## Visão Geral
O pacote `twogo_networking` encapsula o `Dio` HTTP Client e implementa resiliência de transporte para o aplicativo 2GO Mobile.

## Componentes Principais
1. **`DioClientFactory`**: Constrói instâncias configuradas com base na `ApiConfig` do ambiente (resolvendo `10.0.2.2` no Android e `localhost` no iOS/Web).
2. **`CorrelationInterceptor`**: Injeta `X-Correlation-ID`, `X-App-Platform` e `X-App-Version` em todas as requisições ativas.
3. **`AuthInterceptor`**: Anexa o `Authorization: Bearer <token>` apenas a rotas protegidas e intercepta respostas `401 Unauthorized` para acionar a recuperação via `RefreshCoordinator`.
4. **`RefreshCoordinator`**: Mutex single-flight que coordena renovações de sessão sob rotação de refresh token de uso único.
5. **`ErrorMapper`**: Mapeia respostas de erro da API backend contendo códigos de string estáveis (`AUTH_OTP_INVALID`, `AUTH_SESSION_EXPIRED`, etc.) para instâncias fortemente tipadas de `AppFailure`.
