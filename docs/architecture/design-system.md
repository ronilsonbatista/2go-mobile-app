# Design System 2GO Mobile v0.1

## Filosofia & Princípios
O **2GO Design System** é uma biblioteca incremental e independente de componentes visuais, tokens e temas.
Ele garante consistência visual, acessibilidade e desacoplamento total das regras de negócio dos domínios.

### Diretriz Fundamental: Design System ≠ Feature
- **Componentes do Design System**: Primitivos e genéricos (`TwoGoButton`, `TwoGoTextField`, `TwoGoOtpField`, `TwoGoCard`, `TwoGoListTile`).
- **Componentes de Feature**: Ricos em contexto de domínio (`PaymentMethodCard`, `TripCard`, `CheckoutSummary`).

### Regra de Promoção de Componentes (Component Ownership)
```text
GENÉRICO + REUTILIZÁVEL
→ Design System

ESPECÍFICO DO DOMÍNIO
→ Feature (identity, travel, commerce, engagement)

COMPROVADAMENTE REUTILIZÁVEL ENTRE MÚLTIPLOS DOMÍNIOS
→ Candidato a promoção para o Design System
```

---

## Estrutura do Package (`packages/design_system`)

```text
packages/design_system/
├── lib/
│   ├── design_system.dart       # Export público exclusivo da API
│   └── src/
│       ├── tokens/             # Colors, Typography, Spacing, Radius, Elevation, Motion, Opacity, Sizing, Breakpoints
│       ├── themes/             # TwoGoTheme (Light / Dark structure)
│       ├── components/         # Buttons, Inputs, Selection, Cards, Navigation, Feedback, Overlays, Layout, Indicators
│       ├── icons/              # TwoGoIcons
│       └── accessibility/      # TwoGoTouchTarget
└── test/                       # Unit, Widget e Golden Tests
```

---

## Tokens

### Colors (`TwoGoColors`)
- **Primitives**:
  - `brandLime`: `0xFFC4E000` (Cor de ação principal baseada nos prints de produto)
  - `neutral0` a `neutral900`: Escala neutra de cinzas
  - `success`, `error`, `warning`, `info`: Cores funcionais de feedback
- **Semantics**:
  - `backgroundPrimary`: `neutral0`
  - `contentPrimary`: `neutral900`
  - `actionPrimary`: `brandLime`
  - `borderFocused`: `brandLime`
  - `toastBackground`: `neutral900`

### Typography (`TwoGoTypography`)
Escala semântica alinhada ao Dynamic Type (`display`, `headlineLarge`, `headlineMedium`, `headlineSmall`, `titleLarge`, `bodyLarge`, `bodyMedium`, `labelSmall`).

### Spacing (`TwoGoSpacing`)
Escala em grid 8pt/4pt: `xxs` (4), `xs` (8), `sm` (12), `md` (16), `lg` (24), `xl` (32), `xxl` (48).

### Radius (`TwoGoRadius`)
`small` (4), `medium` (8), `large` (16), `full` (999).

---

## Componentes v0.1

1. **`TwoGoButton`**: Botão primário/secundário/terciário/destrutivo com estados default, pressed, disabled e loading.
2. **`TwoGoIconButton`**: Botão circular para ações com ícones.
3. **`TwoGoTextField`**: Input de texto com tratamento de borda focada em lime green e estado de erro em vermelho.
4. **`TwoGoOtpField`**: Entrada de código com 6 boxes individuais, suporte a digitação sequencial, colar código e estado de erro.
5. **`TwoGoCheckbox`**: Checkbox quadrado com fundo verde-lima quando ativo.
6. **`TwoGoCard`**: Superfície primitivo reutilizável.
7. **`TwoGoListTile`**: Tile para listas genéricas.
8. **`TwoGoAppBar`**: Header minimalista.
9. **`TwoGoSnackbar`**: Toast flutuante escuro para feedbacks.
10. **`TwoGoStatusMessage`**: Layout para telas/mensagens de status (ex: confirmação ou erro).
11. **`TwoGoBottomSheet`**: Sheet com controle de teclado (`viewInsets`), safe area e handle bar.
12. **`TwoGoDivider`**: Divisor minimalista.
13. **`TwoGoLoadingIndicator`**: Spinner de carregamento.
14. **`TwoGoSkeleton`**: Placeholder de carregamento.

---

## Acessibilidade & Testes

- **Touch Target**: Mínimo de 48x48px via `TwoGoTouchTarget`.
- **Golden Tests**: Cobertura visual para componentes essenciais em `packages/design_system/test/`.
- **Widgetbook**: App `apps/design_catalog` para exploração interativa.