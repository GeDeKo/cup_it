# Bank Mock Backend

In-memory backend для расширенного mock-банка.

## Запуск
```bash
node backend/server.js
```

## Auth
- `POST /auth/register`
- `POST /auth/login`
- `POST /auth/logout`

## Banking
- `GET /bank/overview`
- `GET /bank/notifications`
- `POST /bank/notifications/read-all`
- `GET /bank/support/thread`
- `POST /bank/support/message`
- `GET /bank/security`
- `POST /bank/security/update`
- `GET /bank/applications`
- `POST /bank/applications/create`
- `POST /bank/transfer`
- `POST /bank/topup`
- `POST /bank/payments/pay`
- `POST /bank/payments/custom`
- `POST /bank/templates/create`
- `POST /bank/subscriptions/toggle`
- `POST /bank/loans/pay`
- `POST /bank/deposits/open`
- `POST /bank/goals/create`
- `POST /bank/goals/topup`
- `POST /bank/cards/freeze`
- `POST /bank/cards/reissue`
- `POST /bank/offers/cashback/activate`
- `POST /bank/stocks/buy`
- `POST /bank/stocks/sell`
