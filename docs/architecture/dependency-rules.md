# Regras de Dependência

A direção das dependências no projeto deve obrigatoriamente seguir:

```text
Presentation -> Application -> Domain <- Infrastructure
```

- `Domain`: Dart puro. Proibido importar Flutter, BLoC, Dio ou Firebase.
- `Design System`: Proibido importar módulos de negócio, networking ou analytics.
- `Core`: Proibido importar módulos de negócio.
