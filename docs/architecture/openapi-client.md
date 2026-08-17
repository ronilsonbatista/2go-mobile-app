# Cliente Gerado OpenAPI (`app_roteiros_api`)

## Regra de Isolamento de Camada
O código dentro de `packages/generated/app_roteiros_api` é um pacote de transporte gerado a partir do arquivo `openapi.json` do backend `app-roteiros-core`.

### Restrições Arquiteturais:
1. **Nunca editar manualmente**: Toda alteração de contrato deve ser feita no backend NestJS e sincronizada executando `melos run generate:api`.
2. **Sem acoplamento direto**: As camadas de Domain (Entities, Repositories), Presentation (BLoCs) e Application **NUNCA** devem importar `app_roteiros_api` ou `Dio`.
3. **Conversão obrigatória**: O `AuthMapper` e a infraestrutura convertem DTOs de transporte para entidades imutáveis do domínio.
