# Visão Geral da Arquitetura 2GO

O aplicativo 2GO utiliza uma **Modular Clean Architecture** combinada com **DDD Pragmático**, **BLoC/Cubit (MVI)** e **Mobile BFF**.

## Princípios
1. **Desacoplamento**: Módulos divididos por bounded contexts.
2. **Inversão de Dependência**: O domínio não possui dependências de UI, Flutter ou SDKs de terceiros.
3. **Flavors**: Development, Staging e Production strict-isolated.
