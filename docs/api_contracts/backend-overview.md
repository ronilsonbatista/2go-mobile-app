# Visão Geral do Backend e Arquitetura da API (app-roteiros-core)

## 1. Identificação do Backend Oficial
* **Repositório Oficial**: `git@github.com:ronilsonbatista/app-roteiros-core.git`
* **Tecnologia**: NestJS 11 (Framework Node.js/Express) + TypeScript 5.7
* **ORM e Banco de Dados**: Prisma ORM 7.8 com PostgreSQL (`@prisma/adapter-pg`)
* **Documentação Viva**: Swagger UI / OpenAPI 3.0 disponível na rota `/api`
* **Containerização**: Docker (Node 20 Alpine + PostgreSQL 16 Alpine containerizado)

---

## 2. Modelos de Dados Principais (Prisma Schema)

```text
app-roteiros-core (PostgreSQL Database)
├── users                     # Conta do usuário (email, fullName, passwordHash, role: USER/ADMIN)
├── refresh_tokens            # Rotação de Refresh Tokens (tokenHash, expiresAt, revokedAt)
├── trips                     # Viagens do usuário (title, destination, dates, status: DRAFT/ACTIVE/COMPLETED)
├── trip_days                 # Dias da viagem (dayNumber, date, title, description)
├── itinerary_items           # Atividades/Pontos do roteiro (category, location, lat/lng, providerPlaceId)
├── base_trips                # Roteiros Base / Templates criados por Administradores
├── base_trip_days            # Dias dos roteiros base
├── base_attractions          # Atrações cadastradas nos roteiros base
├── base_restaurants          # Restaurantes cadastrados nos roteiros base
├── trip_participants         # Convites e colaboradores de viagens (role: VIEWER)
├── user_travel_profiles      # Perfil de preferências do viajante (travelStyles, budgetLevel, etc.)
├── ai_requests               # Histórico de solicitações de IA via OpenAI (GPT)
├── products                  # Produtos digitais (ITINERARY_FULL_ACCESS, AI_CREDITS, PREMIUM_TEMPLATE)
└── purchases                 # Compras e transações de produtos (status: PENDING, PAID, CANCELLED, REFUNDED)
```

---

## 3. Matriz de Endpoints da Aplicação Mobile

| Domínio | Rota API | Método HTTP | Auth (JwtAuthGuard) | Descrição |
|---|---|---|---|---|
| Auth | `/auth/signup` | POST | NÃO | Registrar novo usuário |
| Auth | `/auth/login` | POST | NÃO | Login e geração de Access (15m) + Refresh (7d) |
| Auth | `/auth/refresh` | POST | NÃO | Renovação de tokens com rotação de refresh token |
| Users | `/users/me` | GET | SIM | Perfil do usuário autenticado |
| Users | `/users/me/travel-profile` | GET / POST / PATCH | SIM | Perfil de preferências do viajante |
| Trips | `/trips` | GET / POST | SIM | Listar e criar viagens próprias |
| Trips | `/trips/:id` | GET / PATCH / DELETE | SIM | Detalhar, editar e remover viagem |
| Trips | `/trips/:id/days` | POST | SIM | Adicionar dia ao roteiro |
| Trips | `/trips/:tripId/generate-itinerary` | POST | SIM | Gerar roteiro via OpenAI GPT |
| Trip Days | `/trip-days/:id` | PATCH / DELETE | SIM | Editar ou remover dia da viagem |
| Trip Days | `/trip-days/:id/items` | POST | SIM | Adicionar atividade/item ao dia |
| Itinerary | `/itinerary-items/:id` | PATCH / DELETE | SIM | Editar ou remover item do roteiro |
| Itinerary | `/itinerary-items/:id/reorder` | PATCH | SIM | Reordenar posição do item |
| Places | `/places/search?query=...` | GET | SIM | Buscar locais via Google Places API |
| Places | `/places/:providerPlaceId` | GET | SIM | Obter detalhes do local Google Places |
| Places | `/itinerary-items/:id/place` | PATCH | SIM | Enriquecer item do roteiro com dados reais |
| Participants | `/trips/:tripId/participants` | GET / POST | SIM | Listar e convidar colaboradores |
| Participants | `/trip-invites/accept` | POST | SIM | Aceitar convite de viagem compartilhada |
| Participants | `/users/me/shared-trips` | GET | SIM | Listar viagens compartilhadas comigo |
| Media | `/media/upload/avatar` | POST | SIM | Upload de imagem de avatar do usuário |
| Media | `/media/upload/trips/:id/cover` | POST | SIM | Upload de foto de capa da viagem |
| Billing | `/products` | GET | SIM | Listar produtos ativos disponíveis |
| Billing | `/users/me/purchases` | GET | SIM | Listar compras efetuadas pelo usuário |
| Billing | `/purchases/mock` | POST | SIM | Criar pedido de compra |
| Billing | `/purchases/:id/confirm-mock-payment` | POST | SIM | Confirmar pagamento do pedido |
| System | `/health` | GET | NÃO | Health check do sistema (DB, OpenAI, Google Maps) |

---

## 4. Avaliação Arquitetural — Mobile BFF vs Consumo Direto

### Pergunta Arquitetural:
> *O aplicativo Flutter deve consumir diretamente o backend `app-roteiros-core` ou necessita de um Mobile BFF intermediário?*

### Veredito: **CONSUMO DIRETO RECOMENDADO (MOBILE BFF DESNECESSÁRIO)**

#### Justificativa Técnica:
1. **APIs Especializadas**: O backend NestJS já fornece endpoints granulares e DTOs especificamente formatados para consumo mobile.
2. **Geração de SDK**: A presença do Swagger 3.0 em `/api` permite a geração automatizada de clientes OpenAPI fortemente tipados para o Flutter.
3. **Desempenho**: O consumo direto via `Dio` com interceptor de autenticação garante a menor latência possível sem adicionar custos de manutenção de infraestrutura extra.
