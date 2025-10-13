# Руководство по тестированию LandComp на iPhone

## Предварительные требования

### 1. macOS с Xcode
- **macOS**: версия 12.0 или выше
- **Xcode**: версия 14.0 или выше
- **iOS Simulator**: входит в состав Xcode

### 2. Apple Developer Account
- **Бесплатный аккаунт**: для тестирования на симуляторе
- **Платный аккаунт ($99/год)**: для тестирования на реальном устройстве

### 3. Flutter на macOS
```bash
# Установка Flutter на macOS
brew install --cask flutter
# или скачать с https://flutter.dev/docs/get-started/install/macos

# Проверка установки
flutter doctor
```

## Настройка проекта для iOS

### 1. Проверка конфигурации
Проект уже настроен с:
- ✅ Bundle Identifier: `com.landcomp.landscapeAiApp`
- ✅ Разрешения для камеры и галереи
- ✅ Сетевые разрешения
- ✅ Все зависимости совместимы с iOS

### 2. Настройка подписи кода

#### Для симулятора (бесплатно):
1. Откройте `ios/Runner.xcworkspace` в Xcode
2. Выберите проект "Runner" в навигаторе
3. Перейдите в "Signing & Capabilities"
4. Выберите "Automatically manage signing"
5. Выберите вашу команду разработчика

#### Для реального устройства:
1. В Xcode выберите "Signing & Capabilities"
2. Выберите "Automatically manage signing"
3. Выберите ваш Apple Developer Team
4. Убедитесь, что Bundle Identifier уникален

## Способы тестирования

### 1. Тестирование на iOS Simulator

#### Запуск симулятора:
```bash
# Список доступных симуляторов
flutter emulators

# Запуск симулятора iPhone
open -a Simulator

# Или запуск конкретного симулятора
xcrun simctl boot "iPhone 15 Pro"
```

#### Сборка и запуск приложения:
```bash
# Переход в папку проекта
cd /path/to/landcomp-app

# Установка зависимостей
flutter pub get

# Запуск на симуляторе
flutter run -d ios
```

### 2. Тестирование на реальном iPhone

#### Подготовка устройства:
1. Подключите iPhone к Mac через USB
2. На iPhone: Настройки → Основные → Управление устройством → Доверять компьютеру
3. Включите "Режим разработчика" (если доступен)

#### Сборка и установка:
```bash
# Список подключенных устройств
flutter devices

# Запуск на реальном устройстве
flutter run -d [device-id]

# Или сборка для установки
flutter build ios --release
```

### 3. Создание IPA файла для TestFlight

```bash
# Сборка для архива
flutter build ios --release

# Откройте Xcode и создайте архив
open ios/Runner.xcworkspace
# В Xcode: Product → Archive
```

## Тестирование функций приложения

### 1. Основные функции для проверки:
- ✅ Запуск приложения
- ✅ Навигация между экранами
- ✅ Работа с чатом
- ✅ Загрузка изображений
- ✅ Генерация AI ответов
- ✅ Переключение тем
- ✅ Смена языка

### 2. Специфичные для iOS функции:
- ✅ Работа с камерой
- ✅ Доступ к галерее фотографий
- ✅ Сохранение изображений
- ✅ Работа с сетью
- ✅ Push-уведомления (если реализованы)

### 3. Тестирование на разных устройствах:
- iPhone SE (маленький экран)
- iPhone 15 (стандартный экран)
- iPhone 15 Pro Max (большой экран)
- iPad (если поддерживается)

## Отладка и логирование

### 1. Просмотр логов:
```bash
# Логи Flutter
flutter logs

# Логи iOS через Xcode
# Window → Devices and Simulators → View Device Logs
```

### 2. Отладка в Xcode:
1. Откройте `ios/Runner.xcworkspace`
2. Выберите устройство/симулятор
3. Нажмите "Run" или Cmd+R
4. Используйте отладчик Xcode для анализа

### 3. Проверка производительности:
- Используйте Instruments в Xcode
- Мониторинг памяти и CPU
- Проверка сетевых запросов

## Распространенные проблемы и решения

### 1. Ошибки подписи кода:
```
Error: No profiles for 'com.landcomp.landscapeAiApp' were found
```
**Решение**: Проверьте настройки подписи в Xcode

### 2. Ошибки зависимостей:
```
Error: CocoaPods not installed
```
**Решение**:
```bash
sudo gem install cocoapods
cd ios && pod install
```

### 3. Проблемы с сетью:
```
Error: Network request failed
```
**Решение**: Проверьте настройки App Transport Security в Info.plist

### 4. Ошибки разрешений:
```
Error: Camera permission denied
```
**Решение**: Проверьте настройки разрешений в Info.plist

## Команды для быстрого тестирования

### Создание скрипта для автоматизации:
```bash
#!/bin/bash
# ios_test.sh

echo "🧪 Запуск тестирования LandComp на iOS..."

# Очистка и установка зависимостей
flutter clean
flutter pub get

# Установка iOS зависимостей
cd ios && pod install && cd ..

# Запуск на симуляторе
flutter run -d ios --debug

echo "✅ Тестирование завершено!"
```

## Рекомендации по тестированию

### 1. Приоритеты тестирования:
1. **Критичные функции**: чат, AI генерация, загрузка изображений
2. **UI/UX**: навигация, темы, локализация
3. **Производительность**: скорость загрузки, использование памяти
4. **Совместимость**: разные версии iOS, размеры экранов

### 2. Чек-лист для тестирования:
- [ ] Приложение запускается без ошибок
- [ ] Все экраны отображаются корректно
- [ ] Навигация работает плавно
- [ ] AI чат отвечает на сообщения
- [ ] Загрузка изображений работает
- [ ] Переключение тем функционирует
- [ ] Смена языка работает
- [ ] Нет утечек памяти
- [ ] Приложение не крашится

### 3. Тестирование на разных версиях iOS:
- iOS 15.0+ (минимальная поддерживаемая)
- iOS 16.0 (популярная версия)
- iOS 17.0+ (последняя версия)

## Полезные ресурсы

- [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)
- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [Xcode Simulator Guide](https://developer.apple.com/documentation/xcode/running-your-app-in-the-simulator)
- [TestFlight Guide](https://developer.apple.com/testflight/)

---

**Примечание**: Для тестирования на реальном iPhone требуется macOS с Xcode. Если у вас нет доступа к Mac, рассмотрите использование облачных сервисов как Codemagic или GitHub Actions для сборки iOS приложений.
