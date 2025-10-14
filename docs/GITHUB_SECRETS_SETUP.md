# GitHub Secrets Setup Guide

Этот документ описывает, какие секреты нужно настроить в GitHub для полной функциональности CI/CD pipeline.

## Обязательные секреты

### Для деплоя на сервер
- `SERVER_HOST` - IP адрес или домен сервера
- `SERVER_USER` - имя пользователя для SSH подключения
- `SERVER_SSH_KEY` - приватный SSH ключ для подключения к серверу

### Опциональные секреты
- `SERVER_PORT` - порт SSH (по умолчанию 22)

## Опциональные секреты

### Firebase Hosting
- `FIREBASE_SERVICE_ACCOUNT` - JSON ключ сервисного аккаунта Firebase

### Slack уведомления
- `SLACK_WEBHOOK` - URL webhook для Slack уведомлений

## Как добавить секреты

1. Перейдите в настройки репозитория: `Settings` → `Secrets and variables` → `Actions`
2. Нажмите `New repository secret`
3. Введите имя секрета и его значение
4. Нажмите `Add secret`

## Поведение без секретов

- **Без серверных секретов**: деплой на сервер будет пропущен
- **Без Firebase секрета**: деплой на Firebase Hosting будет пропущен
- **Без Slack секрета**: уведомления в Slack будут пропущены

Все остальные этапы CI/CD (тесты, сборка, анализ кода) будут выполняться независимо от наличия секретов.

## Проверка конфигурации

В логах GitHub Actions вы увидите сообщения о том, какие секреты настроены, а какие отсутствуют:

```
✅ Server configuration complete - proceeding with deployment
⚠️ Firebase Service Account not configured - skipping Firebase deployment
⚠️ Slack webhook not configured - skipping notifications
```