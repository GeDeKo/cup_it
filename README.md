# Adaptive Banking Storefront (Flutter Hackathon Demo)

Demo-версия мобильного банка для iOS/Android: сильный UI/UX-прототип с широкой банковской функциональностью, локальным fake backend и гиперперсонализацией по возрастным сегментам.

## Какую проблему решает
- Снижает перегруз витрины и показывает только релевантные сценарии.
- Перестраивает Home под жизненный этап клиента: `child`, `teen`, `adult`, `business`.
- Показывает feature-gating и ограничения в объяснимом виде (`feature locked`, `available with guardian`, `18+`).

## Что демонстрирует MVP
- Splash + onboarding + demo login.
- Adaptive Home с разными приоритетами, карточками и CTA для каждого сегмента.
- Полноценные demo-flow: счета, карты, платежи, переводы, аналитика, цели, кредиты, инвестиции, профиль.
- Бизнес-модуль: dashboard, payments, analytics.
- Уведомления, безопасность/лимиты, поддержка, заявки.
- Segment comparison screen и быстрый live-switch пользователя.
- Demo Presentation Mode.

## Технологический стек
- Flutter (Material 3)
- Riverpod (state management + DI)
- go_router (routing + shell)
- Node.js in-memory backend (без внешних API)
- Clean-ish feature-first архитектура

## Архитектура
```text
lib/
  app/
  core/ (config, constants, segment, utils)
  domain/
  data/ (mock, backend)
  shared/ (design, widgets)
  features/
    auth, onboarding, dashboard, accounts, cards, payments, transfers,
    analytics, savings, loans, investments, notifications, support,
    security, applications, business, demo_mode, products, profile, settings
backend/
  server.js
```

## Запуск
1. Backend:
```bash
node backend/server.js
```
2. Flutter:
```bash
flutter pub get
flutter run -d ios
# или
flutter run -d android
```

## Demo login
- Телефон: `+79990000000`
- Пароль: `123456`

## Примечания
- Это demo-продукт для хакатона: реалистичные сценарии и stateful UX, но без production security/compliance.
- Все данные внутри проекта (моки + in-memory backend), без интеграций с внешними банковскими API.
