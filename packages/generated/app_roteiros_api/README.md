# AppRoteiros API — Generated Transport Client

> **IMPORTANT AUTOMATION NOTICE**
> Code inside `packages/generated/app_roteiros_api` represents low-level HTTP OpenAPI transport contracts generated from the `app-roteiros-core` backend `openapi.json`.
> **DO NOT EDIT THIS PACKAGE MANUALLY.**
> To update or regenerate this client, run `melos run generate:api`.

## Package Boundaries
- Domain entities, BLoCs, and UI components MUST NOT import `app_roteiros_api` or `Dio` directly.
- The `AuthenticationRepositoryImpl` and infrastructure mappers bridge these transport DTOs to domain entities.
