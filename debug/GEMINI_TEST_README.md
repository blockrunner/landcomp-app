# Тест Gemini Image Generation

Этот скрипт отправляет все изображения из папки `test-images` в модель Gemini 2.5 Flash Image с промптом для создания сада в скандинавском стиле.

## Что делает скрипт

1. 📸 Загружает все изображения из папки `test-images`
2. 🤖 Отправляет их в модель `gemini-2.5-flash-image-preview` с промптом
3. 💾 Сохраняет полученные изображения и текст в папку `test-images/test-gemini`

## Промпт

```
объедини эти фото в один участок с красивым садом в скандинавском стиле сделай 3 отдельных вараинта и опиши каждый из них
```

## Требования

- ✅ API ключ Google Gemini
- ✅ Изображения в папке `test-images`
- ✅ Подключение к интернету
- ✅ Прокси сервер (рекомендуется для стабильной работы)

## Установка API ключа

### Windows
```cmd
set GOOGLE_API_KEY=your_api_key_here
```

### Linux/Mac
```bash
export GOOGLE_API_KEY=your_api_key_here
```

### Получение API ключа
1. Перейдите на https://aistudio.google.com/app/apikey
2. Создайте новый API ключ
3. Скопируйте ключ и установите как переменную окружения

### Настройка прокси (рекомендуется)
```bash
# Основной прокси
ALL_PROXY="socks5h://username:password@proxy-server:port"

# Резервные прокси
BACKUP_PROXIES="socks5h://username:password@backup-proxy-1:port,socks5h://username:password@backup-proxy-2:port"
```

## Запуск

### Вариант 1: Прямой запуск
```bash
dart run debug/test_gemini_image_generation.dart
```

### Вариант 2: Через скрипт запуска
```bash
dart run debug/run_gemini_test.dart
```

## Структура файлов

```
test-images/
├── test_image.jpg
├── test_image2.jpg
├── test_image4_original_copy.jpg
├── final.png
└── test-gemini/          # Папка с результатами
    ├── gemini_result_1.jpg
    ├── gemini_result_2.jpg
    ├── gemini_result_3.jpg
    └── gemini_response.txt
```

## Результаты

После выполнения скрипта в папке `test-images/test-gemini` будут сохранены:

- 🖼️ **Изображения**: `gemini_result_1.jpg`, `gemini_result_2.jpg`, `gemini_result_3.jpg`
- 📄 **Текст**: `gemini_response.txt` с описанием каждого варианта

## Поддерживаемые форматы изображений

- `.jpg` / `.jpeg`
- `.png`
- `.gif`
- `.bmp`
- `.webp`

## Обработка ошибок

Скрипт обрабатывает следующие ошибки:
- ❌ Отсутствие API ключа
- ❌ Отсутствие папки с изображениями
- ❌ Ошибки API Gemini
- ❌ Проблемы с сохранением файлов

## Логирование

Скрипт выводит подробную информацию о процессе:
- 📁 Пути к папкам
- 📸 Количество найденных изображений
- 📤 Статус отправки запроса
- 📥 Информация о полученном ответе
- 💾 Статистика сохраненных файлов

## Пример вывода

```
🎨 Тест Gemini Image Generation
================================

🚀 Запуск теста Gemini Image Generation...
📁 Папка с изображениями: D:\LandComp\landcomp-app\test-images
📁 Папка для результатов: D:\LandComp\landcomp-app\test-images\test-gemini
🤖 Модель: gemini-2.5-flash-image-preview

📸 Найдено изображений: 4
📤 Отправка запроса в Gemini API...
📋 Отправляем 4 изображений с промптом...
📝 Промпт: объедини эти фото в один участок с красивым садом в скандинавском стиле сделай 3 отдельных вараинта и опиши каждый из них
📥 Получен ответ от Gemini API
📝 Получен текст: 1234 символов
🖼️ Сохранено изображение: gemini_result_1.jpg (45678 байт)
🖼️ Сохранено изображение: gemini_result_2.jpg (43210 байт)
🖼️ Сохранено изображение: gemini_result_3.jpg (44567 байт)
📄 Сохранен текст: gemini_response.txt

📊 Статистика:
   - Изображений получено: 3
   - Текстовых частей: 1
   - Общий размер текста: 1234 символов

✅ Тест завершен успешно!
```
