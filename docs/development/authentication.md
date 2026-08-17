# Procedimento de Autenticação e Obtenção de OTP em Desenvolvimento

## Visão Geral
Em ambiente local/desenvolvimento (`NODE_ENV=development`), o backend `app-roteiros-core` utiliza o serviço desacoplado `MockEmailService`. 
Não é necessário utilizar e-mails reais ou hardcodar senhas/códigos de teste.

## Como Obter o Código OTP em Desenvolvimento Local

1. **Solicitar OTP via aplicativo ou API**:
   O aplicativo envia uma requisição `POST /auth/otp/request` com o e-mail do usuário.

2. **Visualizar Log do Backend**:
   O `MockEmailService` intercepta a mensagem e registra o código de 6 dígitos no stdout/console do terminal do backend NestJS:
   ```text
   [MockEmailService] ✉️  Sending OTP to user@email.com: 123456
   ```

3. **Inserir o Código no Aplicativo**:
   Insira o código de 6 dígitos impresso nos logs do backend no componente `TwoGoOtpField` do aplicativo Flutter.

## Regras de Segurança
- Códigos OTP possuem validade de 10 minutos (`expiresAt`).
- O reenvio possui um tempo de recarga (cooldown) de 60 segundos (`AUTH_OTP_RATE_LIMITED`).
- O limite máximo de tentativas erradas é de 5 tentativas por código (`AUTH_OTP_TOO_MANY_ATTEMPTS`).
- Códigos OTP nunca são retornados no corpo da resposta HTTP da API para evitar vazamentos de produção.
