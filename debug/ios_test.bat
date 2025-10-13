@echo off
REM iOS Testing Script for LandComp (Windows version)
REM Этот скрипт помогает подготовить проект для тестирования на iOS

setlocal enabledelayedexpansion

echo 🧪 LandComp iOS Testing Preparation Script
echo ==========================================

echo.
echo ⚠️  ВАЖНО: Этот скрипт подготавливает проект для iOS тестирования
echo    Для реального тестирования на iPhone требуется macOS с Xcode
echo.

REM Проверка наличия Flutter
echo ℹ️  Проверка установки Flutter...
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter не установлен. Установите Flutter с https://flutter.dev
    pause
    exit /b 1
)
echo ✅ Flutter установлен

REM Проверка Flutter doctor
echo ℹ️  Проверка конфигурации Flutter...
flutter doctor

echo.
echo 📋 Подготовка проекта для iOS тестирования...

REM Очистка и установка зависимостей
echo ℹ️  Очистка и установка зависимостей...
flutter clean
flutter pub get

REM Проверка iOS папки
if exist "ios" (
    echo ✅ iOS папка найдена
    echo ℹ️  Проверка iOS конфигурации...
    
    REM Проверка Info.plist
    if exist "ios\Runner\Info.plist" (
        echo ✅ Info.plist найден
    ) else (
        echo ❌ Info.plist не найден
    )
    
    REM Проверка Bundle Identifier
    findstr /C:"com.landcomp.landscapeAiApp" "ios\Runner.xcodeproj\project.pbxproj" >nul 2>&1
    if %errorlevel% equ 0 (
        echo ✅ Bundle Identifier настроен: com.landcomp.landscapeAiApp
    ) else (
        echo ❌ Bundle Identifier не найден
    )
    
) else (
    echo ❌ iOS папка не найдена. Запустите 'flutter create --platforms=ios .'
)

REM Проверка зависимостей
echo ℹ️  Проверка зависимостей...
flutter pub deps

REM Анализ кода
echo ℹ️  Анализ кода...
flutter analyze

REM Запуск тестов
echo ℹ️  Запуск тестов...
flutter test

echo.
echo ✅ Подготовка завершена!
echo.
echo 📱 Следующие шаги для тестирования на iPhone:
echo.
echo 1. macOS с Xcode:
echo    - Установите macOS (виртуальная машина или реальный Mac)
echo    - Установите Xcode из App Store
echo    - Настройте iOS Simulator
echo.
echo 2. Apple Developer Account:
echo    - Бесплатный аккаунт для симулятора
echo    - Платный аккаунт ($99/год) для реального устройства
echo.
echo 3. Настройка подписи кода:
echo    - Откройте ios/Runner.xcworkspace в Xcode
echo    - Настройте Signing & Capabilities
echo    - Выберите вашу команду разработчика
echo.
echo 4. Запуск приложения:
echo    - На macOS: flutter run -d ios
echo    - Или используйте скрипт ios_test.sh
echo.
echo 📖 Подробные инструкции в файле: debug/iOS_TESTING_GUIDE.md
echo.

pause
