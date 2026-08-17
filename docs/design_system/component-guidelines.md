# Diretrizes de Componentes — 2GO Design System

## Diretrizes Gerais
1. **Sem Regras de Negócio**: Componentes do Design System devem ser pura apresentação.
2. **Uso Exclusivo da API Pública**: Importar apenas via `package:twogo_design_system/design_system.dart`.
3. **Internacionalização Neutra**: Componentes não contêm textos de negócio hardcoded; os textos devem ser recebidos via parâmetros (`label`, `title`, `description`).
4. **Respeito às Cores Semânticas**: Preferir sempre tokens semânticos (`TwoGoColors.actionPrimary`, `TwoGoColors.contentPrimary`) em vez de cores brutas.

## Tabela de Responsabilidades
| Tipo | Pertence ao DS | Exemplo |
|---|---|---|
| Botões Genéricos | SIM | `TwoGoButton` |
| Inputs de Texto | SIM | `TwoGoTextField` |
| Form de Cartão de Crédito | NÃO (Feature Commerce) | `CreditCardForm` |
| OTP Box Input | SIM | `TwoGoOtpField` |
| Validação de E-mail / Auth BLoC | NÃO (Feature Identity) | `LoginBloc` |
