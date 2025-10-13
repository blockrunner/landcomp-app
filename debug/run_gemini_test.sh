#!/bin/bash

echo "🎨 Запуск теста Gemini Image Generation"
echo "======================================="
echo

# Проверяем наличие API ключа
if [ -z "$GOOGLE_API_KEY" ]; then
    echo "❌ Ошибка: Не найден GOOGLE_API_KEY"
    echo
    echo "💡 Установите переменную окружения:"
    echo "   export GOOGLE_API_KEY=your_api_key_here"
    echo
    echo "🔑 Получить API ключ можно здесь: https://aistudio.google.com/app/apikey"
    exit 1
fi

echo "✅ API ключ найден"
echo "🤖 Модель: gemini-2.5-flash-image-preview"
echo "📝 Промпт: объедини эти фото в один участок с красивым садом в скандинавском стиле сделай 3 отдельных вараинта и опиши каждый из них"
echo

# Запускаем тест
echo "🚀 Запуск теста..."
dart run debug/test_gemini_image_generation.dart

if [ $? -ne 0 ]; then
    echo
    echo "💥 Тест завершился с ошибкой"
    exit 1
fi

echo
echo "✅ Тест завершен успешно!"
echo "📁 Результаты сохранены в папку: test-images/test-gemini"
echo
