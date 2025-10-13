# Подготовка сервера для деплоя LandComp

## Подключение к серверу

```bash
# Подключение по SSH
ssh tonybreza@89.111.171.89
```

## 1. Загрузка и запуск скрипта настройки

```bash
# Скачать скрипт настройки
curl -O https://raw.githubusercontent.com/blockrunner/landcomp-app/main/scripts/server-setup.sh

# Сделать скрипт исполняемым
chmod +x server-setup.sh

# Запустить настройку
./server-setup.sh
```

## 2. Ручная настройка (если скрипт недоступен)

### Установка Docker

```bash
# Обновить систему
sudo apt update && sudo apt upgrade -y

# Установить Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker tonybreza

# Установить Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Перезайти в систему для применения группы docker
exit
ssh tonybreza@89.111.171.89
```

### Создание директории проекта

```bash
# Создать директорию
mkdir -p /home/landcomp-app
cd /home/landcomp-app
```

### Клонирование репозитория

```bash
# Клонировать репозиторий
git clone git@github.com:blockrunner/landcomp-app.git .

# Проверить клонирование
ls -la
```

### Настройка .env файла

```bash
# Скопировать пример конфигурации
cp env.example .env

# Отредактировать .env файл
nano .env
```

**Важно:** Заполните реальные значения в .env файле:

```bash
# AI API ключи (замените на реальные)
OPENAI_API_KEY="ваш-реальный-openai-ключ"
GOOGLE_API_KEY="ваш-реальный-google-ключ"

# Прокси (уже настроены в env.example)
ALL_PROXY=socks5h://11111:22222@111111111111114:3333333333
BACKUP_PROXIES=socks5h://11111:22222@2222222222222222222:333333333,socks5h://11111:22222@46.232.26.176:62081

# Сервер (уже настроены)
SERVER_HOST=89.111.171.89
SERVER_USER=tonybreza
SERVER_SSH_KEY_PATH=C:\Users\Admin\.ssh\tonybreza_deploy
```

### Создание директорий

```bash
# Создать директорию для логов
mkdir -p logs
chmod 755 logs

# Создать директорию для бэкапов
mkdir -p /home/tonybreza/backups
```

## 3. Проверка настройки

### Проверка Docker

```bash
# Проверить версии
docker --version
docker-compose --version

# Проверить права
docker ps
```

### Проверка SSH подключения к GitHub

```bash
# Тест подключения к GitHub
ssh -T git@github.com

# Ожидаемый ответ: "Hi blockrunner! You've successfully authenticated..."
```

### Проверка Git

```bash
# Проверить настройки Git
git config --global --list

# Проверить статус репозитория
git status
```

## 4. Первый запуск приложения

```bash
# Перейти в директорию проекта
cd /home/landcomp-app

# Запустить приложение
docker-compose -f docker-compose.prod.yml up -d

# Проверить статус
docker-compose -f docker-compose.prod.yml ps

# Проверить логи
docker-compose -f docker-compose.prod.yml logs -f
```

## 5. Проверка работоспособности

```bash
# Проверить health check
curl http://localhost/health

# Проверить доступность приложения
curl http://localhost/

# Проверить извне (с другого компьютера)
curl http://89.111.171.89/health
```

## 6. Настройка автозапуска

```bash
# Создать systemd сервис
sudo tee /etc/systemd/system/landcomp-app.service > /dev/null << 'EOF'
[Unit]
Description=LandComp App
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/landcomp-app
ExecStart=/usr/local/bin/docker-compose -f docker-compose.prod.yml up -d
ExecStop=/usr/local/bin/docker-compose -f docker-compose.prod.yml down
TimeoutStartSec=0
User=tonybreza

[Install]
WantedBy=multi-user.target
EOF

# Включить автозапуск
sudo systemctl daemon-reload
sudo systemctl enable landcomp-app.service

# Проверить статус
sudo systemctl status landcomp-app.service
```

## 7. Настройка бэкапов

```bash
# Создать скрипт бэкапа
cat > /home/landcomp-app/backup.sh << 'EOF'
#!/bin/bash
BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/home/tonybreza/backups"
BACKUP_FILE="$BACKUP_DIR/landcomp_backup_$BACKUP_DATE.tar.gz"

mkdir -p "$BACKUP_DIR"
tar -czf "$BACKUP_FILE" -C /home/landcomp-app .
find "$BACKUP_DIR" -name "landcomp_backup_*.tar.gz" -mtime +7 -delete

echo "Backup created: $BACKUP_FILE"
EOF

# Сделать исполняемым
chmod +x /home/landcomp-app/backup.sh

# Добавить в crontab
(crontab -l 2>/dev/null; echo "0 2 * * * /home/landcomp-app/backup.sh") | crontab -
```

## 8. Финальная проверка

```bash
# Проверить все сервисы
sudo systemctl status landcomp-app.service
docker ps
curl http://localhost/health

# Проверить логи
docker-compose -f docker-compose.prod.yml logs --tail=50
```

## Готово!

После выполнения всех шагов:

1. ✅ Сервер настроен для деплоя
2. ✅ Docker и Docker Compose установлены
3. ✅ Репозиторий клонирован
4. ✅ .env файл настроен
5. ✅ Приложение запущено
6. ✅ Автозапуск настроен
7. ✅ Бэкапы настроены

**Приложение доступно по адресу:** `http://89.111.171.89`

Теперь можно настроить GitHub Secrets и протестировать автоматический деплой!
