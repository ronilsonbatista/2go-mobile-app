# Segurança e Armazenamento de Tokens (`twogo_security`)

## Proteção e Persistência
- Os tokens `accessToken` e `refreshToken` são armazenados utilizando a abstração `TokenStorage` backed por `FlutterSecureStorage`.
- No Android, os dados são salvos via `EncryptedSharedPreferences` (Android Keystore).
- No iOS, os dados são salvos via Apple Keychain (`kSecAccessControlBiometryAny` / `first_unlock`).

## Higienização e Sanitização de Logs
- A classe `AuthTokens` sobrescreve `toString()` retornando `AuthTokens(accessToken: [REDACTED], refreshToken: [REDACTED])`.
- Tokens **NUNCA** são enviados para logs de produção, ferramentas de analytics ou crash reporting.
