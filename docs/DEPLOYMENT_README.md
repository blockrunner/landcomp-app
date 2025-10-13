# LandComp CI/CD Deployment Guide

Полное руководство по настройке автоматического деплоя Flutter приложения LandComp на Ubuntu сервер через GitHub Actions с Docker.

## 🚀 Быстрый старт

1. **Подготовьте сервер** → [SERVER_PREPARATION.md](SERVER_PREPARATION.md)
2. **Настройте GitHub Secrets** → [GITHUB_SECRETS_SETUP.md](GITHUB_SECRETS_SETUP.md)
3. **Протестируйте деплой** → [DEPLOYMENT_TESTING.md](DEPLOYMENT_TESTING.md)

## 📋 Обзор архитектуры

```
GitHub Repository (main branch)
    ↓ (push trigger)
GitHub Actions CI/CD
    ↓ (build & test)
Docker Image (ghcr.io/blockrunner/landcomp-app)
    ↓ (deploy)
Ubuntu Server (89.111.171.89)
    ↓ (docker-compose)
LandComp App (http://89.111.171.89)
```

## 🛠 Компоненты системы

### GitHub Actions Workflow
- **Тестирование**: Flutter analyze, tests, build
- **Сборка**: Docker image с поддержкой прокси
- **Деплой**: Автоматический деплой на сервер

### Docker Configuration
- **Multi-stage build**: Flutter → Nginx
- **Proxy support**: Для AI API запросов
- **Health checks**: Автоматическая проверка работоспособности

### Server Setup
- **Ubuntu 20.04+**: Операционная система
- **Docker & Docker Compose**: Контейнеризация
- **Systemd service**: Автозапуск приложения
- **Backup system**: Автоматические бэкапы

## 🔧 Технические детали

### Переменные окружения
```bash
# AI API
OPENAI_API_KEY=sk-...
GOOGLE_API_KEY=AIza...

# Прокси
ALL_PROXY=socks5h://...
BACKUP_PROXIES=...
NO_PROXY=localhost,127.0.0.1,...

# Сервер
SERVER_HOST=89.111.171.89
SERVER_USER=tonybreza
```

### Docker Compose
```yaml
services:
  landcomp-app:
    image: ghcr.io/blockrunner/landcomp-app:latest
    ports:
      - "80:80"
    environment:
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - GOOGLE_API_KEY=${GOOGLE_API_KEY}
      - ALL_PROXY=${ALL_PROXY}
    restart: unless-stopped
```

## 📁 Структура файлов

```
├── .github/workflows/deploy.yml     # GitHub Actions workflow
├── Dockerfile                       # Docker конфигурация
├── docker-compose.prod.yml         # Production compose
├── nginx.conf                      # Nginx конфигурация
├── scripts/
│   ├── server-setup.sh            # Скрипт настройки сервера
│   └── deploy.sh                  # Скрипт деплоя
├── docs/
│   ├── GITHUB_SECRETS_SETUP.md    # Настройка GitHub Secrets
│   ├── SERVER_PREPARATION.md      # Подготовка сервера
│   ├── DEPLOYMENT_TESTING.md      # Тестирование деплоя
│   └── DEPLOYMENT_README.md       # Это руководство
└── env.example                    # Пример переменных окружения
```

## 🔐 Безопасность

### GitHub Secrets
- Все чувствительные данные хранятся в GitHub Secrets
- SSH ключи для безопасного подключения к серверу
- API ключи для AI сервисов

### Server Security
- SSH доступ только по ключам
- Docker контейнеры изолированы
- Nginx с security headers
- Автоматические обновления системы

## 📊 Мониторинг

### Health Checks
- **Endpoint**: `http://89.111.171.89/health`
- **Frequency**: Каждые 30 секунд
- **Timeout**: 10 секунд
- **Retries**: 3 попытки

### Logging
- **Nginx logs**: `/home/landcomp-app/logs/`
- **Docker logs**: `docker-compose logs -f`
- **System logs**: `journalctl -u landcomp-app.service`

### Backup
- **Frequency**: Ежедневно в 2:00
- **Retention**: 7 дней
- **Location**: `/home/tonybreza/backups/`

## 🚨 Troubleshooting

### Проблемы с деплоем
```bash
# Проверить статус GitHub Actions
# Проверить логи на сервере
docker-compose -f docker-compose.prod.yml logs

# Проверить health check
curl http://localhost/health
```

### Проблемы с прокси
```bash
# Проверить переменные окружения
docker exec landcomp-app env | grep -i proxy

# Проверить сетевые соединения
docker exec landcomp-app netstat -tulpn
```

### Проблемы с SSH
```bash
# Проверить SSH ключ
ssh -T git@github.com

# Проверить подключение к серверу
ssh tonybreza@89.111.171.89
```

## 📈 Производительность

### Оптимизации
- **Docker layers**: Кэширование слоев сборки
- **Nginx**: Gzip сжатие, кэширование статики
- **Flutter**: Release build с HTML renderer
- **Health checks**: Быстрая проверка работоспособности

### Масштабирование
- Горизонтальное масштабирование через Docker Swarm
- Load balancer для распределения нагрузки
- CDN для статических ресурсов

## 🔄 Обновления

### Автоматические обновления
- Push в main ветку → автоматический деплой
- Zero-downtime deployment
- Rollback через предыдущие Docker images

### Ручные обновления
```bash
# На сервере
cd /home/landcomp-app
git pull origin main
docker-compose -f docker-compose.prod.yml up -d
```

## 📞 Поддержка

### Полезные команды
```bash
# Статус сервиса
sudo systemctl status landcomp-app.service

# Перезапуск
sudo systemctl restart landcomp-app.service

# Логи
journalctl -u landcomp-app.service -f

# Docker статус
docker ps
docker-compose -f docker-compose.prod.yml ps
```

### Контакты
- **GitHub**: [blockrunner/landcomp-app](https://github.com/blockrunner/landcomp-app)
- **Server**: 89.111.171.89
- **Application**: http://89.111.171.89

---

**Готово к продакшену!** 🎉

Все компоненты настроены и протестированы. Приложение автоматически деплоится при каждом push в main ветку.
