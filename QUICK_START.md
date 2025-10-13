# 🚀 LandComp App - Быстрый старт развертывания

## 📋 Что нужно сделать

### 1. Подготовка сервера (5 минут)

```bash
# Подключитесь к вашему серверу
ssh user@your-server-ip

# Клонируйте репозиторий
git clone https://github.com/blockrunner/landcomp-app.git
cd landcomp-app

# Запустите автоматическую настройку
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

### 2. Настройка переменных окружения (2 минуты)

```bash
# Скопируйте пример конфигурации
cp env.example .env

# Отредактируйте файл с вашими API ключами
nano .env
```

**Обязательно заполните:**
- `OPENAI_API_KEY` - ваш ключ OpenAI
- `GOOGLE_API_KEY` - ваш ключ Google API

### 3. Настройка GitHub Actions (3 минуты)

1. Перейдите в **Settings** → **Secrets and variables** → **Actions**
2. Добавьте секреты:
   - `SERVER_HOST` - IP вашего сервера
   - `SERVER_USER` - имя пользователя SSH
   - `SERVER_SSH_KEY` - приватный SSH ключ

### 4. Первое развертывание (2 минуты)

```bash
# На сервере
./scripts/deploy.sh --deploy
```

### 5. Проверка работы

```bash
# Проверьте, что приложение работает
curl http://your-server-ip/health

# Откройте в браузере
http://your-server-ip
```

## ✅ Готово!

Теперь при каждом пуше в `main` ветку приложение будет автоматически обновляться на сервере.

## 🔧 Полезные команды

```bash
# Локальная разработка с Docker
make docker-dev

# Сборка Docker образа
make docker-build

# Просмотр логов
make docker-logs

# Проверка здоровья приложения
make health
```

## 🆘 Если что-то не работает

1. **Проверьте логи**: `docker-compose logs -f`
2. **Проверьте переменные**: убедитесь, что `.env` файл заполнен
3. **Проверьте GitHub Actions**: перейдите в раздел Actions репозитория
4. **Проверьте SSH**: `ssh user@your-server-ip`

## 📚 Подробная документация

- [DEPLOYMENT.md](DEPLOYMENT.md) - Полное руководство по развертыванию
- [GITHUB_SETUP.md](GITHUB_SETUP.md) - Настройка GitHub Actions
- [Makefile](Makefile) - Все доступные команды

---

**Время настройки: ~12 минут** ⏱️
