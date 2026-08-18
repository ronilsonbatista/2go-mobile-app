# Product Specification — AI Preview, Paywall & Checkout Flow (2GO Mobile)

## 1. Executive Summary
This document specifies the UX and product rules for the **One-Day Free Preview**, **Paywall Modal**, **Authentication Handoff**, and **Checkout / Payment** screens.

---

## 2. One-Day Free Preview Specs

### Layout Structure
- **Header Banner**: Destination title (e.g. "Roma"), cover photo, share & options buttons.
- **Countdown Badge**: Displays time remaining until trip departure (`Faltam apenas X dias Y horas Z minutos`).
- **Sale Banner**: Highlighted CTA banner (`Tenha acesso a todos os dias de roteiro por apenas R$ 19,99`).
- **Day Tabs**:
  - `Sáb 25/07`: Unlocked (Day 1). Shows full activity timeline (Morning, Afternoon, Evening, price tags, category, duration, map location).
  - `Dom 24/07`: Locked icon 🔒.
  - `Seg 25/07`: Locked icon 🔒.
- **Map Floating Button**: Displays map overlay with Day 1 activity pins.

---

## 3. Paywall Trigger Rules
The Paywall Modal can be triggered via 3 distinct events:
1. **Banner Tap**: Clicking the sale banner on top of the preview screen.
2. **Locked Day Tap**: Tapping any locked day tab in the day bar.
3. **10-Second Auto-Trigger**: Appearing automatically after 10 seconds of user activity on the preview screen if neither banner nor locked days were clicked.
   - **Session Suppression Rule**: If dismissed via the 'X' button, the auto-timer will not re-open the modal automatically during the same session to preserve UX.

### Paywall Modal Content
- **Ribbon Icon & Title**: "Tenha acesso a todos os dias de roteiro por apenas"
- **Price Display**: `R$ 19,99` (Fetched dynamically from backend `Product` API).
- **Bullet Benefits**:
  - `Dicas exclusivas`
  - `Roteiro personalizado`
  - `Acesso offline ao seu roteiro`
- **CTA Button**: **"Aproveitar"** (Triggers Auth / Checkout handoff).

---

## 4. Checkout & Payment Specs

### Cart View
- Renders trip summary card (Destination, travelers count, dates, product price).
- **Coupon Code Action**: Opens bottom sheet modal to apply promo codes. Server-side validation calculates final price (`POST /coupons/validate`).
- **Personal Information Fields**: Full Name, CPF, Phone number.

### Payment Methods
1. **Cartão de Crédito**:
   - Card form: Number, Cardholder Name, Expiration (MM/YY), CVV, Save card checkbox.
   - Saved card selection for returning customers.
2. **PIX**:
   - Renders QR Code + "Copia e Cola" string button. Instructions for bank app payment.
3. **Apple Pay**:
   - Native Apple Pay sheet trigger (when supported by payment gateway backend).

### Outcome Screens
- **Pagamento Confirmado**: Green checkmark icon, "Já pode fazer as malas! O roteiro completo da sua viagem já está liberado!" + CTA button "Acessar roteiro" (navigates to App Shell / Full Trip View).
- **Pagamento com Falha**: Error state banner, "Ops! Tivemos um problema para processar seu pagamento." + CTA button "Tentar novamente".
