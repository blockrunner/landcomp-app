# GitHub Actions Setup Guide

Этот документ описывает настройку GitHub Actions для автоматического развертывания LandComp приложения.

## 🔐 Настройка GitHub Secrets

Для работы CI/CD пайплайна необходимо настроить следующие секреты в GitHub репозитории:

### 1. Перейдите в настройки репозитория

1. Откройте ваш репозиторий на GitHub: https://github.com/blockrunner/landcomp-app
2. Перейдите в **Settings** → **Secrets and variables** → **Actions**
3. Нажмите **New repository secret**

### 2. Добавьте следующие секреты:

#### `SERVER_HOST`
- **Описание**: IP адрес или домен вашего сервера
- **Пример**: `192.168.1.100` или `your-domain.com`
- **Обязательно**: ✅

#### `SERVER_USER`
- **Описание**: Имя пользователя для SSH подключения
- **Пример**: `ubuntu`, `root`, `deploy`
- **Обязательно**: ✅

#### `SERVER_SSH_KEY`
- **Описание**: Приватный SSH ключ для подключения к серверу
- **Пример**: Содержимое файла `~/.ssh/id_rsa`
- **Обязательно**: ✅

#### `SERVER_PORT` (опционально)
- **Описание**: SSH порт сервера
- **Пример**: `22` (по умолчанию)
- **Обязательно**: ❌

#### `SLACK_WEBHOOK` (опционально)
- **Описание**: URL для уведомлений в Slack
- **Пример**: `https://hooks.slack.com/services/...`
- **Обязательно**: ❌

## 🔑 Генерация SSH ключей

### На вашем локальном компьютере:

```bash
# Генерация SSH ключей
ssh-keygen -t rsa -b 4096 -C "deploy@landcomp-app"

# Просмотр публичного ключа (добавить на сервер)
cat ~/.ssh/id_rsa.pub

# Просмотр приватного ключа (добавить в GitHub Secrets)
cat ~/.ssh/id_rsa
```

### На сервере:

```bash
# Создание директории для SSH ключей
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Добавление публичного ключа в authorized_keys
echo "your_public_key_here" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Настройка SSH (опционально)
sudo nano /etc/ssh/sshd_config
# Убедитесь, что включены:
# PubkeyAuthentication yes
# AuthorizedKeysFile .ssh/authorized_keys

# Перезапуск SSH сервиса
sudo systemctl restart sshd
```

## 🚀 Тестирование подключения

### Проверка SSH подключения:

```bash
# Тест подключения к серверу
ssh -i ~/.ssh/id_rsa user@your-server-ip

# Если подключение успешно, вы должны попасть на сервер
```

### Проверка GitHub Actions:

1. Сделайте коммит и пуш в main ветку:
```bash
git add .
git commit -m "Setup CI/CD pipeline"
git push origin main
```

2. Перейдите в **Actions** вкладку вашего репозитория
3. Проверьте, что workflow запустился и выполнился успешно

## 🔧 Настройка сервера

### Автоматическая настройка:

```bash
# На сервере
git clone https://github.com/blockrunner/landcomp-app.git
cd landcomp-app
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

### Ручная настройка:

```bash
# Установка Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Установка Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Создание директории приложения
sudo mkdir -p /opt/landcomp-app
sudo chown $USER:$USER /opt/landcomp-app
```

## 📋 Проверочный список

- [ ] SSH ключи сгенерированы и настроены
- [ ] GitHub Secrets добавлены в репозиторий
- [ ] Сервер настроен и доступен по SSH
- [ ] Docker и Docker Compose установлены на сервере
- [ ] Репозиторий клонирован на сервер
- [ ] Файл `.env` создан с правильными API ключами
- [ ] Тестовый push в main ветку выполнен успешно
- [ ] GitHub Actions workflow выполнился без ошибок

## 🚨 Устранение неполадок

### Проблема: SSH подключение не работает

```bash
# Проверка SSH ключей
ssh-add -l

# Проверка подключения с подробным выводом
ssh -v -i ~/.ssh/id_rsa user@your-server-ip

# Проверка прав доступа
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
```

### Проблема: GitHub Actions не может подключиться к серверу

1. Проверьте правильность `SERVER_HOST` и `SERVER_USER`
2. Убедитесь, что SSH ключ добавлен в `authorized_keys` на сервере
3. Проверьте, что сервер доступен из интернета
4. Убедитесь, что SSH порт открыт в файрволе

### Проблема: Docker команды не выполняются

```bash
# Проверка установки Docker
docker --version
docker-compose --version

# Проверка прав пользователя
groups $USER

# Добавление пользователя в группу docker
sudo usermod -aG docker $USER
# Перелогиньтесь после этого
```

## 📞 Поддержка

При возникновении проблем:

1. Проверьте логи GitHub Actions в разделе **Actions**
2. Проверьте SSH подключение к серверу
3. Убедитесь, что все секреты настроены правильно
4. Создайте issue в GitHub репозитории с подробным описанием проблемы

## 🔗 Полезные ссылки

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [SSH Key Generation](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)
- [Docker Installation](https://docs.docker.com/engine/install/)
- [Docker Compose Installation](https://docs.docker.com/compose/install/)
