# Тестирование автоматического деплоя

## Предварительные требования

Перед тестированием убедитесь, что выполнены все шаги:

1. ✅ Сервер подготовлен (см. `SERVER_PREPARATION.md`)
2. ✅ GitHub Secrets настроены (см. `GITHUB_SECRETS_SETUP.md`)
3. ✅ Все файлы обновлены в репозитории

## 1. Проверка GitHub Secrets

Убедитесь, что в GitHub репозитории настроены все необходимые secrets:

- `SERVER_HOST`: 89.111.171.89
- `SERVER_USER`: tonybreza
- `SERVER_SSH_KEY`: содержимое приватного ключа
- `OPENAI_API_KEY`: ваш OpenAI ключ
- `GOOGLE_API_KEY`: ваш Google API ключ
- `ALL_PROXY`: socks5h://11111:22222@111111111111114:3333333333
- `BACKUP_PROXIES`: резервные прокси
- `NO_PROXY`: исключения для прокси

## 2. Тестовый коммит

Создайте тестовый коммит для запуска автоматического деплоя:

```bash
# Сделать небольшое изменение в коде
echo "# Test deployment $(date)" >> README.md

# Добавить изменения
git add README.md

# Сделать коммит
git commit -m "test: trigger automatic deployment"

# Отправить в main ветку
git push origin main
```

## 3. Мониторинг деплоя

### В GitHub Actions

1. Перейдите в репозиторий на GitHub
2. Нажмите на вкладку **Actions**
3. Найдите запуск workflow "Deploy to Production"
4. Нажмите на него для просмотра деталей
5. Следите за выполнением каждого шага:
   - ✅ test
   - ✅ build-and-push
   - ✅ deploy

### На сервере

```bash
# Подключиться к серверу
ssh tonybreza@89.111.171.89

# Перейти в директорию проекта
cd /home/landcomp-app

# Проверить статус контейнеров
docker ps

# Проверить логи
docker-compose -f docker-compose.prod.yml logs -f
```

## 4. Проверка работоспособности

### Health Check

```bash
# Локальная проверка
curl http://localhost/health

# Внешняя проверка
curl http://89.111.171.89/health

# Ожидаемый ответ: "healthy"
```

### Доступность приложения

```bash
# Проверить главную страницу
curl -I http://89.111.171.89/

# Ожидаемый ответ: HTTP/1.1 200 OK
```

### Проверка в браузере

Откройте в браузере: `http://89.111.171.89`

Должна загрузиться главная страница приложения LandComp.

## 5. Проверка работы прокси

### Тест AI API запросов

1. Откройте приложение в браузере
2. Попробуйте отправить сообщение в чат
3. Проверьте, что AI отвечает (это означает, что прокси работает)

### Проверка логов прокси

```bash
# Проверить логи контейнера
docker-compose -f docker-compose.prod.yml logs landcomp-app

# Искать сообщения о прокси соединениях
```

## 6. Проверка автоматического перезапуска

```bash
# Остановить контейнер
docker-compose -f docker-compose.prod.yml down

# Проверить, что systemd перезапустил его
sleep 30
docker ps

# Контейнер должен быть запущен автоматически
```

## 7. Проверка бэкапов

```bash
# Запустить бэкап вручную
/home/landcomp-app/backup.sh

# Проверить создание бэкапа
ls -la /home/tonybreza/backups/

# Должен быть создан файл landcomp_backup_YYYYMMDD_HHMMSS.tar.gz
```

## 8. Мониторинг производительности

```bash
# Проверить использование ресурсов
docker stats

# Проверить логи nginx
tail -f /home/landcomp-app/logs/access.log
tail -f /home/landcomp-app/logs/error.log
```

## 9. Тестирование отката

В случае проблем с новой версией:

```bash
# Остановить текущий контейнер
docker-compose -f docker-compose.prod.yml down

# Запустить предыдущую версию (если есть)
docker-compose -f docker-compose.prod.yml up -d

# Или восстановить из бэкапа
cd /home/tonybreza/backups
tar -xzf landcomp_backup_YYYYMMDD_HHMMSS.tar.gz -C /home/landcomp-app
```

## 10. Уведомления

Если настроен Slack webhook, проверьте получение уведомлений о статусе деплоя.

## Возможные проблемы и решения

### Проблема: Health check не проходит

```bash
# Проверить логи контейнера
docker-compose -f docker-compose.prod.yml logs landcomp-app

# Проверить, что nginx запущен
docker exec landcomp-app ps aux | grep nginx

# Проверить конфигурацию nginx
docker exec landcomp-app nginx -t
```

### Проблема: Прокси не работает

```bash
# Проверить переменные окружения в контейнере
docker exec landcomp-app env | grep -i proxy

# Проверить сетевые соединения
docker exec landcomp-app netstat -tulpn
```

### Проблема: SSH подключение не работает

```bash
# Проверить SSH ключ на сервере
ls -la ~/.ssh/

# Проверить подключение к GitHub
ssh -T git@github.com
```

## Успешное завершение

После успешного тестирования:

1. ✅ Автоматический деплой работает
2. ✅ Приложение доступно по http://89.111.171.89
3. ✅ AI API работает через прокси
4. ✅ Health check проходит
5. ✅ Автозапуск настроен
6. ✅ Бэкапы работают
7. ✅ Мониторинг настроен

**Деплой готов к продакшену!** 🚀
