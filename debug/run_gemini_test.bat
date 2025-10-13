@echo off
echo 🎨 Запуск теста Gemini Image Generation
echo =======================================
echo.

REM Проверяем наличие API ключа
if "%GOOGLE_API_KEY%"=="" (
    echo ❌ Ошибка: Не найден GOOGLE_API_KEY
    echo.
    echo 💡 Установите переменную окружения:
    echo    set GOOGLE_API_KEY=your_api_key_here
    echo.
    echo 🔑 Получить API ключ можно здесь: https://aistudio.google.com/app/apikey
    pause
    exit /b 1
)

echo ✅ API ключ найден
echo 🤖 Модель: gemini-2.5-flash-image-preview
echo 📝 Промпт: объедини эти фото в один участок с красивым садом в скандинавском стиле сделай 3 отдельных вараинта и опиши каждый из них
echo.

REM Запускаем тест
echo 🚀 Запуск теста...
dart run debug/test_gemini_image_generation.dart

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo 💥 Тест завершился с ошибкой
    pause
    exit /b 1
)

echo.
echo ✅ Тест завершен успешно!
echo 📁 Результаты сохранены в папку: test-images\test-gemini
echo.
pause
