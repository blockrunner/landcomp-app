# 🚀 Быстрый старт - Тест Gemini Image Generation

## Что нужно сделать

1. **Получить API ключ Google Gemini**
   - Перейдите на https://aistudio.google.com/app/apikey
   - Создайте новый API ключ
   - Скопируйте ключ

2. **Установить API ключ и прокси**

   **Windows:**
   ```cmd
   set GOOGLE_API_KEY=your_api_key_here
   set ALL_PROXY=socks5h://username:password@proxy-server:port
   set BACKUP_PROXIES=socks5h://username:password@backup-proxy-1:port,socks5h://username:password@backup-proxy-2:port
   ```

   **Linux/Mac:**
   ```bash
   export GOOGLE_API_KEY=your_api_key_here
   export ALL_PROXY=socks5h://username:password@proxy-server:port
   export BACKUP_PROXIES=socks5h://username:password@backup-proxy-1:port,socks5h://username:password@backup-proxy-2:port
   ```

3. **Запустить тест**

   **Windows:**
   ```cmd
   debug\run_gemini_test.bat
   ```

   **Linux/Mac:**
   ```bash
   dart run debug/test_gemini_image_generation.dart
   ```

   **Или через Dart:**
   ```bash
   dart run debug/run_gemini_test.dart
   ```

## Что произойдет

1. 📸 Скрипт найдет все изображения в папке `test-images`
2. 🤖 Отправит их в модель `gemini-2.5-flash-image-preview` с промптом
3. 💾 Сохранит 3 варианта сада в скандинавском стиле в папку `test-images/test-gemini`
4. 📄 Сохранит описание каждого варианта в текстовый файл

## Результат

В папке `test-images/test-gemini` появятся:
- `gemini_result_1.jpg` - первый вариант сада
- `gemini_result_2.jpg` - второй вариант сада  
- `gemini_result_3.jpg` - третий вариант сада
- `gemini_response.txt` - описание каждого варианта

## Промпт

```
объедини эти фото в один участок с красивым садом в скандинавском стиле сделай 3 отдельных вараинта и опиши каждый из них
```

## Требования

- ✅ API ключ Google Gemini
- ✅ Изображения в папке `test-images`
- ✅ Подключение к интернету
- ✅ Прокси сервер (рекомендуется)
- ✅ Dart SDK

## Поддержка

Если что-то не работает:
1. Проверьте, что API ключ установлен правильно
2. Убедитесь, что в папке `test-images` есть изображения
3. Проверьте подключение к интернету
4. Посмотрите подробную документацию в `GEMINI_TEST_README.md`
