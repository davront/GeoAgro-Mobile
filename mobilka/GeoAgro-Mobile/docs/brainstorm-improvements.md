# GeoAgro Mobile — брейншторм улучшений

Дата: 2026-09-22. Приоритет: аналитика → архитектура → UX → инфра.

## 1. Аналитика/метрики (топ-приоритет)

Сейчас (`analytics_service.dart`): только `logLogin`, `logSearch`, `plantation_created/deleted`, `farmer_created`, `page_view`. Нет воронки, нет ошибок, нет perf.

- **Воронка регистрации плантации**: старт рисования полигона → точка добавлена → GPS-проверка pass/fail → фото загружены → отправлено на модерацию → approved/rejected. Сейчас виден только факт создания — непонятно, на каком шаге юзеры бросают.
- **Error/retry метрики бизнес-флоу**: `/api/device-tokens/` нестабилен (500, см. комментарий в `login_vm.dart:75`), upload queue retry rate, GPS-timeout rate. Сейчас только в Crashlytics non-fatal, не агрегируется как продуктовая метрика.
- **Retention/engagement**: DAU/WAU полевых исполнителей, время между открытием приложения и первым действием, % плантаций с `is_rejected` по конкретному исполнителю/district_id.
- **Performance monitoring** (Firebase Performance, не подключено): время загрузки списка плантаций, время аплоада фото (критично при плохой связи в полях), cold start time.
- **BigQuery export**: если уже смотрят через Firebase Analytics export — воронка выше даёт материал для reject-rate анализа по districtId/исполнителю.

## 2. Архитектура/качество кода

- **Два Dio-клиента** (`ApiService` + `ApiServiceV2`) — дублирование уже ловили при security-фиксах (оба имели bad-cert bypass, разный логгер). `ApiServiceV2` содержит retry-логику (`_makeRequest` с `maxRetries`), которой нет в основном клиенте — стоит понять, используется ли активно, и либо смержить retry в основной, либо убить дубликат.
- **Global mutable state в `setup.dart`** (`accessToken`, `userId`, `districtId` — top-level переменные) — работает, но не тестируемо, хрупко при hot-reload/multi-instance.
- **`upload_queue_service.dart`** (346 строк) — стоит проверить retry-backoff, персистентность очереди при убийстве процесса (важно — полевые работники часто теряют связь), дедупликацию.
- **Тестовое покрытие** — проверить `flutter test` coverage на критичных путях (login, upload queue, token refresh).

## 3. UX/продукт (полевые условия — Узбекистан, сельская местность)

- **Оффлайн-режим** — upload queue должна кэшировать локально и retry при восстановлении сети (`ConnectivityInterceptor` уже есть — вопрос глубины использования для UX, не только retry запросов).
- **Индикация состояния очереди аплоада** пользователю — видит ли исполнитель "3 фото ждут отправки".
- **GPS-точность** — есть gate ("GPS + is_rejected gate on task submit"), можно расширить UX: показывать точность GPS перед сабмитом, не только бинарный pass/fail.
- **Локализация** — Uzbekistan-first, но встречается кириллица в error-messages (`token_interceptor.dart` — "Пароль был изменён"). Проверить консистентность локализации ошибок, не только UI-текстов.

## 4. Инфраструктура/DevOps

- **CI/CD** — есть ли автосборка/автотесты gate перед мержем (сейчас пуш напрямую в main).
- **Crash-free rate дашборд** — сверить в Crashlytics эффект security/logging фиксов на noise от benign errors.
- **Remote Config feature flags** — уже используется (`setting/remote_controller.dart`), можно расширить на постепенный rollout вместо бинарного вкл/выкл всем.
- **Версионирование** — `version_check_service.dart` форсит апдейт (`UpdateRequiredDialog`) — убедиться, что это не банит юзеров при плохой связи с сервером в моменте проверки.

## Следующий шаг

Рекомендация: начать с **воронки регистрации плантации** (bounded — flow уже существует в `google_map`/`edit` фичах, добавить `logEvent` на ключевых шагах рисования/загрузки/сабмита).
