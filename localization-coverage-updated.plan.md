# Localization Coverage Fix Plan - UPDATED

## Analysis Summary

Проведен анализ актуальной версии кода. Выявлены **значительные пробелы в локализации**, где захардкоженные строки не меняются при смене языка.

### Критические нелокализованные области

#### 1. **Home Page** (`lib/features/home/presentation/pages/home_page.dart`) ✅ ИСПРАВЛЕНО

**ВСЕ тексты захардкожены на русском:**

- Line 94: "Создавайте ландшафтные композиции легко и быстро"
- Line 104: "Ваш персональный AI-дизайнер сада поможет создать профессиональные композиции"
- Line 124: "Быстрый старт"
- Line 137: "Новый проект"
- Line 138: "Создайте новый ландшафтный проект"
- Line 150: "Мои проекты"
- Line 151: "Просмотрите сохраненные проекты"
- Line 193: "Версия 1.0.0"
- Line 204: "Ваш AI-помощник для создания ландшафтных композиций"

**Итого: 9 строк**

#### 2. **Router Error Page** (`lib/app/router.dart`) ✅ ИСПРАВЛЕНО

**Тексты на английском:**

- Line 62: "Page not found"
- Line 67: "The page '...' could not be found."
- Line 73: "Go to Home"

**Итого: 3 строки**

#### 3. **Profile Page** (`lib/features/profile/presentation/pages/profile_page.dart`) ✅ ИСПРАВЛЕНО

**ВСЕ тексты захардкожены на английском:**

- Line 18: "Profile" (AppBar title)
- Line 40: "LandComp User"
- Line 45: "user@example.com"
- Line 65: "Usage Statistics"
- Line 74: "Messages"
- Line 81: "Sessions"
- Line 87: "Days Active"
- Line 105: "Edit Profile"
- Line 114: "Privacy & Security"
- Line 123: "Export Data"
- Line 141: "Help & Support"
- Line 150: "Send Feedback"
- Line 159: "Rate App"
- Line 182: "Sign Out"
- Line 198: "Delete Account"
- Line 249: "Sign Out" (dialog title)
- Line 250: "Are you sure you want to sign out?"
- Line 254: "Cancel"
- Line 261: "Sign Out" (button)
- Line 273: "Delete Account" (dialog title)
- Line 274-275: "Are you sure you want to delete your account? This action cannot be undone."
- Line 279: "Cancel"
- Line 290: "Delete"

**Итого: 23 строки**

#### 4. **Settings Page** (`lib/features/settings/presentation/pages/settings_page.dart`) ✅ ИСПРАВЛЕНО

**Частично захардкожено:**

- Line 116: 'Русский' (inline в коде)
- Line 126: 'Английский' (inline в коде)

**Итого: 2 строки**

#### 5. **Message Bubble** (`lib/features/chat/presentation/widgets/message_bubble.dart`) ✅ ИСПРАВЛЕНО

- Line 174: "Retry"
- Line 339: "Исходные изображения"
- Line 345: "Сгенерированные варианты"
- Line 490: "h ago"
- Line 492: "m ago"
- Line 494: "Just now"
- Line 504: "Изображения" / "Изображение"
- Line 617: "Ошибка загрузки"

**Итого: 8 строк**

#### 6. **Image Picker Widget** (`lib/features/chat/presentation/widgets/image_picker_widget.dart`) ✅ ИСПРАВЛЕНО

- Line 87: "Ошибка при выборе изображений: $e"
- Line 210: "Выбрать фото"
- Line 211: "Добавить фото ({count}/{max})"
- Line 222: "Очистить"
- Line 231: "Можно выбрать до X изображений"

**Итого: 5 строк**

#### 7. **Image Viewer** (`lib/shared/widgets/image_viewer.dart`) ✅ ИСПРАВЛЕНО

- Line 59: "Изображение {n} из {total}"
- Line 298: "Не удалось загрузить изображение"

**Итого: 2 строки**

#### 8. **Error Messages** (`lib/core/constants/app_constants.dart`) ✅ ИСПРАВЛЕНО

Lines 56-64: Все сообщения об ошибках захардкожены на английском:

- networkErrorMessage
- serverErrorMessage
- unknownErrorMessage
- aiServiceErrorMessage
- messageSentMessage
- settingsSavedMessage

**Итого: 6 строк**

#### 9. **Chat Input Placeholders** (`lib/features/chat/presentation/pages/chat_page.dart`) ✅ ИСПРАВЛЕНО

**Плейсхолдеры захардкожены на русском:**

- Line 151: "Опишите изображения..."
- Line 152: "Спросите о ландшафтном дизайне, садоводстве или строительстве..."

**Итого: 2 строки**

## Реализация

### ✅ Выполнено

1. **Расширен словарь локализации** - Добавлено ~62 новых ключа в `lib/core/localization/app_localizations.dart`
2. **Добавлены вспомогательные методы** в `LanguageProvider` для форматирования
3. **Обновлены все файлы** с заменой захардкоженных строк
4. **Добавлены Consumer обертки** где необходимо
5. **Исправлены все синтаксические ошибки**

### Файлы изменены

1. ✅ `lib/core/localization/app_localizations.dart` - Добавлено ~62 ключа перевода
2. ✅ `lib/core/localization/language_provider.dart` - Добавлены вспомогательные методы
3. ✅ `lib/features/home/presentation/pages/home_page.dart` - Заменено 9 строк
4. ✅ `lib/app/router.dart` - Заменено 3 строки + добавлен доступ к локализации
5. ✅ `lib/features/profile/presentation/pages/profile_page.dart` - Заменено 23 строки + добавлен Consumer
6. ✅ `lib/features/settings/presentation/pages/settings_page.dart` - Заменено 2 inline строки
7. ✅ `lib/features/chat/presentation/widgets/message_bubble.dart` - Заменено 8 строк
8. ✅ `lib/features/chat/presentation/widgets/image_picker_widget.dart` - Заменено 5 строк + добавлен Consumer
9. ✅ `lib/shared/widgets/image_viewer.dart` - Заменено 2 строки + добавлен доступ к локализации
10. ✅ `lib/features/chat/presentation/pages/chat_page.dart` - Заменено 2 плейсхолдера

## Результат

- ✅ **100% покрытие локализацией** всех страниц
- ✅ **Консистентный билингвальный опыт** (EN/RU)
- ✅ **Корректный перевод динамического контента** (даты, счетчики)
- ✅ **Устранение смешения языков в UI**
- ✅ **Плейсхолдеры в поле ввода сообщения** теперь переводятся

### Ключевые особенности

1. **Динамическое форматирование времени**: "2h ago" → "2ч назад", "Just now" → "Только что"
2. **Локализация счетчиков изображений**: "Image 1 of 3" → "Изображение 1 из 3"
3. **Поддержка плюрализации**: "image" vs "images" / "изображение" vs "изображения"
4. **Локализация сообщений об ошибках**: Все сообщения об ошибках поддерживают оба языка
5. **Контекстно-зависимая локализация**: Все виджеты правильно получают доступ к провайдеру языка
6. **Плейсхолдеры ввода**: Динамические плейсхолдеры в зависимости от контекста (с изображениями/без)

Приложение теперь обеспечивает **полностью локализованный опыт**, где **все элементы UI меняют язык** при переключении пользователя между английским и русским, устраняя предыдущую проблему смешанных языковых интерфейсов.

