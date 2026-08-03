# 2GO Mobile Monorepo

O **2GO Mobile** é um aplicativo mobile em Flutter estruturado como um monorepo corporativo utilizando **Pub Workspaces**, **Melos** e **Modular Clean Architecture + DDD Pragmático**.

---

## 🚀 Estrutura do Monorepo

```text
2go-mobile/
├── apps/
│   ├── mobile_app/         # Composition Root do aplicativo principal
│   └── design_catalog/     # Catálogo visual interativo do Design System
│
├── packages/
│   ├── foundation/         # Módulos transversais da fundação
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
│   ├── design_system/     # Design System independente
│   │
│   ├── identity/           # Bounded Context de Identidade
│   ├── travel/             # Bounded Context de Viagens & Roteiros
│   ├── commerce/           # Bounded Context de Comércio & Pagamentos
│   └── engagement/         # Bounded Context de Engajamento
│
├── tools/                  # Regras de lint e geradores
├── docs/                   # Documentação arquitetural e ADRs
├── melos.yaml              # Configuração do Melos
└── pubspec.yaml            # Configuração do Pub Workspaces
```

---

## 🛠️ Requisitos e Instalação

### Pré-requisitos
- **Flutter**: >= 3.32.0 (Dart SDK >= 3.8.0)
- **Melos CLI**: `dart pub global activate melos`

### Inicialização
```bash
cd ~/Documents/2go-mobile
~/.pub-cache/bin/melos bootstrap
```

---

## 🧪 Comandos Principais

### Análise Estática
```bash
~/.pub-cache/bin/melos run analyze
```

### Formatação
```bash
~/.pub-cache/bin/melos run format
```

### Regras de Dependência (Lint Arquitetural)
```bash
~/.pub-cache/bin/melos run lint:arch
```

### Executar Testes Automatizados
```bash
~/.pub-cache/bin/melos run test
```

### Executar Aplicativo (Development)
```bash
cd apps/mobile_app
flutter run -t lib/main_development.dart --flavor development
```

---

## 📖 Documentação Arquitetural
Toda a documentação técnica, diretrizes e ADRs (Architecture Decision Records) encontram-se no diretório `docs/`:
- `docs/architecture/`: Diretrizes de arquitetura, fluxo MVI, BLoC, segurança, offline-first.
- `docs/adr/`: Registros de decisões de arquitetura (ADR-001 a ADR-014).
