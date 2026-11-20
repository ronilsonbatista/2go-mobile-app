# Tratamento de Erros

Padrão `Result<S, F>` com `Success` / `Failure` tipados em `twogo_core`.

## Camada de serviço / API

`ErrorMapper.mapDioError` (`twogo_networking`) converte `DioException` + envelope Nest (`code` / `message`) em `AppFailure`:

| Origem | Tipo | UI compartilhada |
| --- | --- | --- |
| Timeout / `connectionError` | `NetworkFailure` (“Sem conexão com a internet!”) | Toast coral `TwoGoSnackbar.showNoConnection` |
| 400 / `BAD_REQUEST` / lista ValidationPipe | `ValidationFailure` (+ `fieldErrors`) | Campo rosa + ícone `!` + helper (`TwoGoTextField`) |
| `AUTH_OTP_*` e demais códigos estáveis | Failures tipadas | Inline / toast escuro conforme tela |

Repositórios devem preferir `ErrorMapper.throwMapped` / `mapDioError` em vez de deixar `DioException` chegar na UI.

## Apresentação

`TwoGoErrorFeedback.present(context, failure)` escolhe toast vs. erros de campo. Copys canônicas de campo: `TwoGoCoreFieldMessages` / `TwoGoErrorFeedback.invalidField|requiredField`.
