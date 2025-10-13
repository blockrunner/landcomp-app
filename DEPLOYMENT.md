# LandComp App - Deployment Guide

Этот документ описывает процесс развертывания Flutter приложения LandComp на облачном сервере с использованием Docker и автоматического CI/CD пайплайна.

## 🚀 Быстрый старт

### 1. Подготовка сервера

```bash
# Клонируйте репозиторий на сервер
git clone https://github.com/blockrunner/landcomp-app.git
cd landcomp-app

# Запустите скрипт автоматической настройки
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

### 2. Настройка переменных окружения

```bash
# Скопируйте пример конфигурации
cp env.example .env

# Отредактируйте файл с вашими API ключами
nano .env
```

### 3. Развертывание

```bash
# Запустите развертывание
./scripts/deploy.sh --deploy
```

## 📋 Требования к серверу

- **ОС**: Ubuntu 20.04+ или аналогичная Linux система
- **RAM**: Минимум 2GB, рекомендуется 4GB+
- **CPU**: 2+ ядра
- **Диск**: 20GB+ свободного места
- **Сеть**: Статический IP адрес и открытые порты 80, 443

## 🔧 Ручная настройка

### Установка Docker

```bash
# Установка Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Установка Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### Настройка приложения

```bash
# Создание директории приложения
sudo mkdir -p /opt/landcomp-app
sudo chown $USER:$USER /opt/landcomp-app

# Клонирование репозитория
cd /opt/landcomp-app
git clone https://github.com/blockrunner/landcomp-app.git .

# Настройка переменных окружения
cp env.example .env
nano .env
```

### Запуск приложения

```bash
# Сборка и запуск
docker-compose -f docker-compose.prod.yml up -d

# Проверка статуса
docker-compose -f docker-compose.prod.yml ps

# Просмотр логов
docker-compose -f docker-compose.prod.yml logs -f
```

## 🔐 Настройка SSL сертификатов

### Let's Encrypt (рекомендуется)

```bash
# Установка Certbot
sudo apt-get update
sudo apt-get install -y certbot python3-certbot-nginx

# Получение сертификата
sudo certbot certonly --standalone -d your-domain.com

# Копирование сертификатов
sudo cp /etc/letsencrypt/live/your-domain.com/fullchain.pem /opt/landcomp-app/ssl/
sudo cp /etc/letsencrypt/live/your-domain.com/privkey.pem /opt/landcomp-app/ssl/
sudo chown $USER:$USER /opt/landcomp-app/ssl/*
```

### Автоматическое обновление сертификатов

```bash
# Добавление в crontab
echo "0 12 * * * /usr/bin/certbot renew --quiet && docker-compose -f /opt/landcomp-app/docker-compose.prod.yml restart" | sudo crontab -
```

## 🔄 CI/CD настройка

### GitHub Secrets

Добавьте следующие секреты в настройках репозитория GitHub:

- `SERVER_HOST` - IP адрес вашего сервера
- `SERVER_USER` - имя пользователя для SSH
- `SERVER_SSH_KEY` - приватный SSH ключ
- `SERVER_PORT` - SSH порт (по умолчанию 22)
- `SLACK_WEBHOOK` - URL для уведомлений в Slack (опционально)

### Настройка SSH ключей

```bash
# На сервере
ssh-keygen -t rsa -b 4096 -C "deploy@landcomp-app"

# Добавление публичного ключа в authorized_keys
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

# Копирование приватного ключа в GitHub Secrets
cat ~/.ssh/id_rsa
```

## 📊 Мониторинг

### Проверка состояния приложения

```bash
# Статус контейнеров
docker-compose -f docker-compose.prod.yml ps

# Логи приложения
docker-compose -f docker-compose.prod.yml logs -f landcomp-app

# Использование ресурсов
docker stats

# Health check
curl -f http://localhost/health
```

### Настройка мониторинга

```bash
# Установка htop для мониторинга системы
sudo apt-get install -y htop

# Установка Docker stats
docker stats --no-stream
```

## 🔧 Обслуживание

### Обновление приложения

```bash
# Автоматическое обновление через GitHub Actions
git push origin main

# Ручное обновление
cd /opt/landcomp-app
git pull origin main
docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml up -d
```

### Резервное копирование

```bash
# Создание резервной копии
./backup.sh

# Восстановление из резервной копии
tar -xzf /opt/backups/landcomp-app/backup_YYYYMMDD_HHMMSS.tar.gz -C /opt/landcomp-app/
```

### Очистка системы

```bash
# Очистка неиспользуемых Docker образов
docker system prune -f

# Очистка старых логов
sudo journalctl --vacuum-time=7d
```

## 🚨 Устранение неполадок

### Проблемы с Docker

```bash
# Перезапуск Docker
sudo systemctl restart docker

# Проверка статуса Docker
sudo systemctl status docker

# Очистка Docker
docker system prune -a -f
```

### Проблемы с приложением

```bash
# Проверка логов
docker-compose -f docker-compose.prod.yml logs landcomp-app

# Перезапуск приложения
docker-compose -f docker-compose.prod.yml restart

# Полная пересборка
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml up -d --build
```

### Проблемы с сетью

```bash
# Проверка открытых портов
sudo netstat -tlnp | grep :80
sudo netstat -tlnp | grep :443

# Проверка файрвола
sudo ufw status
sudo ufw allow 80
sudo ufw allow 443
```

## 📞 Поддержка

При возникновении проблем:

1. Проверьте логи приложения
2. Убедитесь, что все переменные окружения настроены
3. Проверьте доступность API ключей
4. Создайте issue в GitHub репозитории

## 🔗 Полезные ссылки

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Flutter Web Deployment](https://flutter.dev/docs/deployment/web)
- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
