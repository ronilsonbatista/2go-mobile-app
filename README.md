# 2GO Mobile

Aplicativo mobile oficial da 2GO para iOS e Android, desenvolvido em Flutter e Dart sobre uma arquitetura modular orientada a domínios.

## Status do Projeto

O projeto encontra-se atualmente na fase de fundação arquitetural.

Concluído:

- Estrutura do monorepo
- Modularização dos domínios
- Foundation packages
- Clean Architecture
- Regras de dependência
- Flavors Android
- Estrutura de flavors iOS
- Design System base
- Documentação arquitetural
- ADRs
- Testes estruturais
- Build Android Development

Em desenvolvimento:

- Design System completo
- Catálogo completo de componentes
- Implementações reais das features
- Integrações com APIs
- Mobile BFF
- Offline Sync completo
- Pagamentos reais
- Observabilidade real
- Analytics providers
- CI/CD

## Arquitetura

O 2GO Mobile utiliza uma arquitetura modular baseada em:

- Modular Clean Architecture
- DDD pragmático
- Bounded Contexts
- BLoC para fluxos complexos
- Cubit para estados simples
- Fluxo unidirecional de dados
- Repository Pattern
- Use Cases
- Dependency Inversion
- Mobile BFF
- Design System independente

Direção de dependência:

```text
Presentation
    ↓
Application
    ↓
Domain
    ↑
Infrastructure
```

Domain permanece independente de Flutter, BLoC, Dio, Firebase, banco local e SDKs externos.

## Estrutura do Projeto

O projeto é organizado como um monorepo composto por múltiplos apps e packages independentes:

```text
2go-mobile/
├── apps/
│   ├── mobile_app/
│   └── design_catalog/
│
├── packages/
│   ├── foundation/
│   │   ├── core/
│   │   ├── config/
│   │   ├── networking/
│   │   ├── analytics/
│   │   ├── observability/
│   │   ├── feature_flags/
│   │   ├── storage/
│   │   ├── security/
│   │   ├── localization/
│   │   ├── sync/
│   │   └── test_support/
│   │
│   ├── design_system/
│   │
│   ├── identity/
│   │   ├── authentication/
│   │   ├── session/
│   │   └── profile/
│   │
│   ├── travel/
│   │   ├── trips/
│   │   ├── itinerary/
│   │   ├── places/
│   │   ├── maps/
│   │   ├── documents/
│   │   └── vouchers/
│   │
│   ├── commerce/
│   │   ├── quotations/
│   │   ├── bookings/
│   │   ├── checkout/
│   │   ├── payments/
│   │   ├── refunds/
│   │   └── invoices/
│   │
│   └── engagement/
│       ├── notifications/
│       ├── support/
│       ├── chat/
│       ├── reviews/
│       └── settings/
│
├── docs/
│   ├── architecture/
│   ├── adr/
│   ├── analytics/
│   └── api_contracts/
│
├── tools/
├── .github/
├── melos.yaml
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

## Módulos Foundation

### Core
Abstrações fundamentais e estruturas independentes de framework.

### Config
Ambientes e configurações tipadas.

### Networking
Infraestrutura HTTP e contratos de comunicação.

### Analytics
Contratos de analytics desacoplados de fornecedores.

### Observability
Logging, tracing, crashes e performance.

### Feature Flags
Feature flags e kill switches.

### Storage
Abstrações para banco, cache e preferências.

### Security
Secure Storage, criptografia e proteção de dados.

### Localization
Estrutura de internacionalização.

### Sync
Contratos de sincronização e offline-first.

### Test Support
Fakes, mocks, fixtures e helpers compartilhados.

## Domínios

Os pacotes de domínio estão estruturados e preparados para implementação incremental das funcionalidades:

### Identity
- `authentication`
- `session`
- `profile`

### Travel
- `trips`
- `itinerary`
- `places`
- `maps`
- `documents`
- `vouchers`

### Commerce
- `quotations`
- `bookings`
- `checkout`
- `payments`
- `refunds`
- `invoices`

### Engagement
- `notifications`
- `support`
- `chat`
- `reviews`
- `settings`

## Design System

Pacote: `packages/design_system`

Estado atual:
- Tokens base (`TwoGoColors`, `TwoGoTypography`, `TwoGoSpacing`)
- Estrutura para radius, elevation, motion e breakpoints
- Componente base `TwoGoButton`

*O Design System ainda está em desenvolvimento e será expandido na próxima fase.*

## Design Catalog

Aplicativo: `apps/design_catalog`

Estado atual:
- Skeleton funcional preparado para consumir o Design System
- Widgetbook configurado no `pubspec.yaml`

## Tecnologias

- Flutter 3.32.6
- Dart 3.8.1
- Melos 6.3.3
- BLoC / Cubit (Planejado)
- Dio (Instalado em `networking`)
- Widgetbook (Configurado em `design_catalog`)

## Ambientes & Flavors

Ambientes suportados:
- `development`
- `staging`
- `production`

Entrypoints do aplicativo principal (`apps/mobile_app`):
- `main_development.dart`
- `main_staging.dart`
- `main_production.dart`

Android Application IDs:
- Development: `com.twogo.app.dev`
- Staging: `com.twogo.app.staging`
- Production: `com.twogo.app`

### Estado dos Builds

#### Android
- Android Development build foi validado com sucesso.
- Recomenda-se concluir a instalação do Android SDK command-line tools e aceitar as licenças Android (`flutter doctor --android-licenses`).

#### iOS
- A estrutura do projeto e os flavors iOS estão preparados.
- Para realizar builds nativos e executar o iOS Simulator é necessária uma instalação completa do Xcode (`Xcode.app`).

## Pré-requisitos

- Flutter SDK (3.32.6 ou superior)
- Dart SDK (3.8.1 ou superior)
- Android Studio
- Android SDK
- JDK 17
- Melos CLI (`dart pub global activate melos`)
- Xcode (para desenvolvimento iOS)
- CocoaPods

## Instalação & Setup

```bash
git clone https://github.com/ronilsonbatista/2go-mobile-app.git
cd 2go-mobile-app

dart pub get
melos bootstrap
```

Se o Melos CLI não estiver instalado globalmente:

```bash
dart pub global activate melos
```

### Comandos de Verificação & Validação

#### Verificar ambiente
```bash
flutter doctor -v
```

#### Análise estática
```bash
melos run analyze
```

#### Regras arquiteturais
```bash
melos run lint:arch
```
*Valida os limites de dependência e isolamento entre os módulos.*

#### Testes unitários
```bash
melos run test
```

#### Formatação de código
```bash
melos run format
```

### Executar & Compilar Apps

#### Executar Android (Development)
```bash
cd apps/mobile_app
flutter run --flavor development --target lib/main_development.dart
```

#### Build APK Android (Development)
```bash
cd apps/mobile_app
flutter build apk --debug --flavor development --target lib/main_development.dart
```

#### Executar iOS (Development)
*Exige instalação completa do Xcode (`Xcode.app`).*
```bash
cd apps/mobile_app
flutter run --flavor development --target lib/main_development.dart
```

## Segurança

Nunca versionar:
- `.env`
- Tokens
- Secrets
- Chaves privadas
- Keystores
- Certificados
- Provisioning Profiles
- Senhas
- Credenciais administrativas
- Credenciais de provedores de pagamento

## Documentação

Documentação detalhada disponível nos seguintes diretórios:
- `docs/architecture/` (Diretrizes arquiteturais, estratégias de estado, offline-sync, navegação, segurança)
- `docs/adr/` (Architectural Decision Records)
- `docs/api_contracts/` (Contratos de comunicação Mobile BFF)
- `docs/analytics/` (Catálogo de eventos)

*Novas decisões arquiteturais relevantes devem ser registradas como ADR.*

## CI/CD

CI/CD será configurado em uma etapa posterior.

