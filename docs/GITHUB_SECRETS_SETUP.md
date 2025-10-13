# GitHub Secrets Setup для CI/CD деплоя

## Необходимые Secrets для GitHub Actions

Для автоматического деплоя через GitHub Actions необходимо настроить следующие secrets в репозитории:

### 1. Сервер подключение

| Secret Name | Value | Описание |
|-------------|-------|----------|
| `SERVER_HOST` | `89.111.171.89` | IP адрес удаленного сервера |
| `SERVER_USER` | `tonybreza` | Имя пользователя на сервере |
| `SERVER_SSH_KEY` | Содержимое приватного ключа | Приватный ключ для SSH подключения |
| `SERVER_PORT` | `22` | SSH порт (опционально, по умолчанию 22) |

### 2. AI API ключи

| Secret Name | Value | Описание |
|-------------|-------|----------|
| `OPENAI_API_KEY` | Ваш OpenAI ключ | API ключ для OpenAI |
| `GOOGLE_API_KEY` | Ваш Google API ключ | API ключ для Google Gemini |
| `GOOGLE_API_KEYS_FALLBACK` | Резервные ключи | Дополнительные Google API ключи через запятую |

### 3. Прокси конфигурация

| Secret Name | Value | Описание |
|-------------|-------|----------|
| `ALL_PROXY` | `socks5h://11111:22222@111111111111114:3333333333` | Основной прокси сервер |
| `BACKUP_PROXIES` | Резервные прокси | Дополнительные прокси серверы через запятую |
| `NO_PROXY` | Исключения | Список исключений для прокси |

### 4. Дополнительные API ключи (опционально)

| Secret Name | Value | Описание |
|-------------|-------|----------|
| `STABILITY_API_KEY` | Ваш Stability AI ключ | Для генерации изображений |
| `HUGGINGFACE_API_KEY` | Ваш Hugging Face ключ | Для ML моделей |

### 5. Yandex Cloud (опционально)

| Secret Name | Value | Описание |
|-------------|-------|----------|
| `YC_API_KEY_ID` | ID ключа | Yandex Cloud API Key ID |
| `YC_API_KEY` | API ключ | Yandex Cloud API Key |
| `YC_FOLDER_ID` | ID папки | Yandex Cloud Folder ID |

### 6. Уведомления (опционально)

| Secret Name | Value | Описание |
|-------------|-------|----------|
| `SLACK_WEBHOOK` | Webhook URL | Для уведомлений в Slack |

## Как добавить Secrets в GitHub

1. Перейдите в ваш репозиторий на GitHub
2. Нажмите на вкладку **Settings**
3. В левом меню выберите **Secrets and variables** → **Actions**
4. Нажмите **New repository secret**
5. Введите **Name** и **Secret** значение
6. Нажмите **Add secret**

## Получение приватного SSH ключа

Для `SERVER_SSH_KEY` нужно скопировать содержимое приватного ключа:

```bash
# На Windows (PowerShell)
Get-Content C:\Users\Admin\.ssh\tonybreza_deploy

# На Linux/Mac
cat ~/.ssh/tonybreza_deploy
```

**Важно:** Копируйте весь ключ включая строки:
```
-----BEGIN OPENSSH PRIVATE KEY-----
[содержимое ключа]
-----END OPENSSH PRIVATE KEY-----
```

## Проверка настройки

После добавления всех secrets:

1. Сделайте коммит в ветку `main`
2. GitHub Actions автоматически запустит деплой
3. Проверьте логи в разделе **Actions** репозитория
4. После успешного деплоя приложение будет доступно по адресу: `http://89.111.171.89`

## Безопасность

- Никогда не коммитьте secrets в код
- Регулярно обновляйте API ключи
- Используйте минимально необходимые права доступа
- Мониторьте использование API ключей
