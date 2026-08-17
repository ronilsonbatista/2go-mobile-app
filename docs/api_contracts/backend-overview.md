# 2GO Backend & API Overview Assessment

## 1. Localização e Infraestrutura do Backend
* **Caminho do Projeto Backend**: `/Users/ronilsonbatista/Documents/2go-site`
* **Nome da Aplicação**: `2go-travel-next` (Next.js 16 + React 19)
* **Provedor de Banco de Dados e BaaS**: Supabase PostgreSQL (`@supabase/supabase-js` v2.108.2)
* **Arquitetura de Comunicação**: RESTful via Supabase PostgREST Client + Realtime WebSockets + Supabase Auth.

---

## 2. Visão Geral das Entidades e Tabelas

```text
2GO Backend (Supabase PostgreSQL)
├── auth.users                 # Usuários autenticados (email, pass, metadata)
├── public.profiles            # Perfis públicos de viajantes (avatar, bio, preferências)
├── public.destinations        # Destinos (Paris, Roma, Lisboa, Tóquio, Gramado, etc.)
├── public.itineraries         # Roteiros e planos de viagem por dias/atrações
├── public.attractions         # Pontos turísticos, horários, avaliações e custos
├── public.bookings            # Reservas de viagens, pacotes e roteiros
├── public.payments            # Transações financeiras (PIX, Cartão de Crédito)
├── public.coupons             # Cupons de desconto e promoções
├── public.vouchers            # Vouchers digitais e ingressos em PDF/QR Code
└── public.leads               # Captura de contatos e automação de e-mail
```

---

## 3. Matriz de Endpoints por Domínio

| Domínio | Rota / PostgREST Table | Método HTTP | Autenticado | Descrição |
|---|---|---|---|---|
| Identity | `/auth/v1/signup` | POST | NÃO | Cadastro com e-mail e senha |
| Identity | `/auth/v1/token?grant_type=password` | POST | NÃO | Login e emissão de JWT Bearer Token |
| Identity | `/auth/v1/otp` | POST | NÃO | Solicitação de código OTP de 6 dígitos |
| Identity | `/auth/v1/verify` | POST | NÃO | Validação do código OTP de confirmação |
| Identity | `/auth/v1/token?grant_type=refresh_token` | POST | SIM (Refresh) | Emissão de novo Access Token |
| Identity | `/rest/v1/profiles` | GET / PATCH | SIM | Leitura e atualização do perfil |
| Travel | `/rest/v1/destinations` | GET | NÃO | Consulta de destinos e detalhes |
| Travel | `/rest/v1/itineraries` | GET | NÃO / SIM | Leitura de roteiros públicos e salvos |
| Travel | `/rest/v1/vouchers` | GET | SIM | Download e leitura de vouchers do usuário |
| Commerce | `/rest/v1/bookings` | GET / POST | SIM | Criação de reserva de viagem |
| Commerce | `/rest/v1/payments` | POST | SIM | Processamento de pagamento (PIX / Cartão) |
| Commerce | `/rest/v1/coupons` | GET | SIM | Validação de cupom de desconto |
| Engagement | `/rest/v1/notifications` | GET | SIM | Notificações push e in-app |
| Engagement | `/rest/v1/support` | POST | SIM | Abertura de chamados de suporte |

---

## 4. Avaliação Arquitetural — Consumo Direto vs Mobile BFF

### Pergunta Arquitetural:
> *O Flutter pode consumir diretamente o backend 2GO de maneira saudável?*

### Veredito: **RECOMENDADO CONSUMO DIRETO COM SUPABASE SDK / DIO CLIENT**

#### Justificativa:
1. **Contratos Padronizados**: O Supabase fornece contratos PostgREST padrão REST com JSON estrito, tornando desnecessária a criação de um BFF intermediário adicional.
2. **Segurança via RLS**: O banco de dados PostgreSQL utiliza Row Level Security (RLS) para autorização a nível de linha por usuário (`auth.uid()`).
3. **Redução de Latência**: O consumo direto evita saltos extras de rede (Hop extra do App -> BFF -> Supabase).
4. **Mobile BFF**: Considerado **DESNECESSÁRIO** nesta fase. A camada de infraestrutura do Flutter (`packages/foundation/networking`) abrigará os repositórios com Dio e os mappers DTO -> Domain Entity de forma desacoplada.
