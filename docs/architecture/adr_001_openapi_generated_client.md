# ADR 001 — OpenAPI Generated Transport Client

## Status
Aprovado

## Contexto
O aplicativo 2GO Mobile consome a API oficial `app-roteiros-core` (NestJS 11 + OpenAPI 3.0). Para evitar a criação manual de dezenas de clientes HTTP e DTOs sujeitos a erro humano, adotamos um cliente OpenAPI gerado automaticamente.

## Decisão
Criar o pacote técnico dedicado `packages/generated/app_roteiros_api/` alimentado diretamente pelo `openapi.json` exportado pelo backend NestJS.

## Consequências
- A manutenção de contratos fica automatizada via `melos run generate:api`.
- O código gerado permanece 100% isolado na camada de infraestrutura de transporte e não polui o domínio ou a UI do Flutter.
