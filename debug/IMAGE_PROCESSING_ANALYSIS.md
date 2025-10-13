# 📸 Анализ обработки сообщений с изображениями

## 🎯 Текущая ситуация

### ✅ Что работает:
- **Превью изображений**: Теперь отображаются и сохраняются в истории сообщений
- **Загрузка изображений**: Пользователь может прикрепить до 5 изображений
- **Сжатие изображений**: Автоматическое сжатие для оптимизации размера
- **Сохранение в хранилище**: Изображения корректно сериализуются в Hive

### ❌ Проблемы:
- **Неправильная модель**: Используется `gpt-4o` вместо специализированной модели для ландшафтного дизайна
- **Отсутствие контекста агента**: Не передается system prompt выбранного AI агента
- **Жестко заданная модель**: Всегда используется OpenAI, игнорируя предпочтения пользователя

## 🔍 Анализ текущей реализации

### 1. **Поток обработки сообщения с изображениями:**

```
Пользователь прикрепляет изображения
    ↓
ChatProvider.sendMessageWithImages()
    ↓
Создание Attachment объектов
    ↓
Сохранение в Message.attachments
    ↓
Вызов AIService.sendImageToOpenAI()
    ↓
Использование модели 'gpt-4o' (без system prompt)
    ↓
Получение ответа и сохранение
```

### 2. **Проблемы в коде:**

#### В `ChatProvider.sendMessageWithImages()`:
```dart
// ❌ ПРОБЛЕМА: Жестко заданная модель и отсутствие system prompt
final aiResponse = await _aiService.sendImageToOpenAI(
  prompt: content.trim(),
  images: images,
  model: 'gpt-4o',  // ← Жестко задано
);
```

#### В `AIService.sendImageToOpenAI()`:
```dart
// ❌ ПРОБЛЕМА: Отсутствует system prompt
'messages': [
  {
    'role': 'user',  // ← Только user, нет system
    'content': content,
  }
],
```

## 🎯 План улучшения

### 1. **Интеграция с AI агентами**
- Передавать system prompt выбранного агента
- Использовать специализированные промпты для ландшафтного дизайна
- Поддерживать контекст выбранного агента

### 2. **Умный выбор модели**
- Для ландшафтного дизайна: `gpt-4o` с system prompt
- Для строительства: `gpt-4o` с соответствующим промптом
- Для экологии: `gpt-4o` с экологическим контекстом

### 3. **Улучшенная обработка изображений**
- Анализ содержимого изображений
- Специализированные промпты для разных типов изображений
- Контекстная обработка множественных изображений

## 🛠️ Предлагаемые изменения

### 1. **Обновить ChatProvider:**
```dart
Future<void> sendMessageWithImages({
  required String content,
  required List<Uint8List> images,
}) async {
  // ... существующий код ...
  
  // ✅ ИСПРАВЛЕНИЕ: Использовать system prompt текущего агента
  final currentAgent = _currentAgent ?? AIAgentsConfig.getDefaultAgent();
  final systemPrompt = currentAgent.systemPrompt;
  
  final aiResponse = await _aiService.sendImageToOpenAI(
    prompt: content.trim(),
    images: images,
    model: 'gpt-4o',
    systemPrompt: systemPrompt,  // ← Добавить system prompt
  );
}
```

### 2. **Обновить AIService:**
```dart
Future<String> sendImageToOpenAI({
  required String prompt,
  required List<Uint8List> images,
  String model = 'gpt-4o',
  String? systemPrompt,  // ← Добавить параметр
}) async {
  // ... существующий код ...
  
  final messages = <Map<String, dynamic>>[];
  
  // ✅ ИСПРАВЛЕНИЕ: Добавить system prompt если есть
  if (systemPrompt != null && systemPrompt.isNotEmpty) {
    messages.add({
      'role': 'system',
      'content': systemPrompt,
    });
  }
  
  messages.add({
    'role': 'user',
    'content': content,
  });
  
  // ... остальной код ...
}
```

### 3. **Специализированные промпты для изображений:**
```dart
// Добавить в AIAgentsConfig
static String getImageAnalysisPrompt(String agentId) {
  switch (agentId) {
    case 'landscape_designer':
      return '''
You are analyzing landscape images for design purposes. Focus on:
- Terrain analysis and slope assessment
- Existing vegetation and plant identification
- Soil conditions and drainage
- Sun exposure and microclimates
- Potential design opportunities
- Integration with surrounding landscape
''';
    case 'gardener':
      return '''
You are analyzing garden images for plant care. Focus on:
- Plant health and disease identification
- Soil conditions and fertility
- Watering needs and irrigation
- Seasonal care requirements
- Companion planting opportunities
''';
    // ... другие агенты
  }
}
```

## 🎯 Ожидаемые результаты

### После внедрения:
1. **Контекстные ответы**: AI будет отвечать как специалист по ландшафтному дизайну
2. **Анализ изображений**: Правильная интерпретация содержимого фотографий
3. **Специализированные советы**: Рекомендации в соответствии с выбранным агентом
4. **Улучшенное качество**: Более точные и полезные ответы

### Пример улучшенного ответа:
```
Вместо: "Я вижу несколько изображений участка..."

Будет: "Как ландшафтный дизайнер, я анализирую ваши фотографии участка. 
Вижу хороший потенциал для создания скандинавского сада с учетом 
существующей растительности и рельефа. Предлагаю 3 варианта..."
```

## 📊 Приоритеты реализации

1. **Высокий**: Добавить system prompt в обработку изображений
2. **Высокий**: Интегрировать с выбранным AI агентом
3. **Средний**: Специализированные промпты для анализа изображений
4. **Низкий**: Поддержка разных моделей для разных агентов
