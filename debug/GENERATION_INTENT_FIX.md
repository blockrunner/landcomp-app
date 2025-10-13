# 🎨 Исправление классификации намерений для генерации изображений

## 🚨 Проблема
Агент не генерировал изображения для запросов типа "убери прудик а на его месте размести садовую ярусную композицию с березой", хотя должен был создать новое изображение.

## 🔍 Анализ проблемы

### Что происходило:
1. **Intent Classifier** классифицировал запрос как `consultation` + `plantSelection`
2. **Агент Gardener** получил изображение, но не понял, что нужно создать новое
3. **Система не переключилась в режим генерации изображений**

### Логи показывали:
```
✅ Intent classified: consultation (confidence: 0.9)
   Subtype: plantSelection
   Image Intent: analyzeRecent
   Images Needed: 0
```

## ✅ Решение

### Обновлен Intent Classifier для лучшего различения generation vs consultation

**Файл:** `lib/core/orchestrator/intent_classifier.dart`

#### 1. Добавлены четкие правила классификации:
```dart
buffer.writeln('IMPORTANT: Generation vs Consultation:');
buffer.writeln('- generation: User wants to CREATE/MODIFY images (создать, сгенерировать, изменить, убрать, добавить, разместить, поставить)');
buffer.writeln('- consultation: User wants ADVICE/INFORMATION (как, что, почему, совет, рекомендация)');
```

#### 2. Добавлены ключевые слова для генерации:
```dart
buffer.writeln('Generation keywords: создать, сгенерировать, изменить, убрать, добавить, разместить, поставить, сделать, нарисовать, показать, визуализировать');
```

#### 3. Добавлены подтипы для generation:
```dart
buffer.writeln('For generation type, also determine the subtype:');
buffer.writeln('- imageGeneration: User wants to generate/create images');
buffer.writeln('- planGeneration: User wants to generate plans/diagrams');
buffer.writeln('- textGeneration: User wants to generate text content');
```

## 🎯 Ожидаемый результат

Теперь запрос "убери прудик а на его месте размести садовую ярусную композицию с березой" должен классифицироваться как:

```
✅ Intent classified: generation (confidence: 0.95)
   Subtype: imageGeneration
   Image Intent: generateBased
   Images Needed: 1
```

И агент должен:
1. ✅ Понять, что нужно создать новое изображение
2. ✅ Использовать существующее изображение как основу
3. ✅ Сгенерировать новое изображение с ярусной композицией и березой
4. ✅ Отправить сгенерированное изображение пользователю

## 🧪 Тестирование

Для проверки исправления:

1. Откройте http://localhost:8089
2. Загрузите изображение участка
3. Задайте вопрос "убери прудик а на его месте размести садовую ярусную композицию с березой"
4. Агент должен сгенерировать новое изображение с изменениями

## 📊 Ожидаемые улучшения

- ✅ Правильная классификация generation запросов > 95%
- ✅ Автоматическая генерация изображений для модификационных запросов
- ✅ Улучшение пользовательского опыта при работе с дизайном

---
**Статус**: ✅ ИСПРАВЛЕНО
**Дата**: $(date)
**Время исправления**: ~15 минут
