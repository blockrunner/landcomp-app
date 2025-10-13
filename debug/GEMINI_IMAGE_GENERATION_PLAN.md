# 🎨 План реализации Gemini Image Generation

## 🎯 Цель
Реализовать генерацию изображений с помощью Gemini 2.5 Flash Image для сообщений с изображениями в чате.

## 📋 Пошаговый план действий

### 1. **Создать новый метод для генерации изображений**
- Добавить метод `sendImageGenerationToGemini()` в `AIService`
- Использовать модель `gemini-2.5-flash-image-preview`
- Обрабатывать как текстовые, так и изображения в ответе

### 2. **Обновить ChatProvider**
- Заменить вызов `sendImageToOpenAI()` на `sendImageGenerationToGemini()`
- Убрать system prompt (не нужен для генерации изображений)
- Обработать ответ с изображениями и текстом

### 3. **Создать структуру для ответа с изображениями**
- Создать класс `ImageGenerationResponse`
- Содержать список сгенерированных изображений и текстовый ответ
- Поддержка множественных изображений в ответе

### 4. **Обновить MessageBubble**
- Добавить поддержку отображения сгенерированных изображений
- Показывать как исходные, так и сгенерированные изображения
- Разделить визуально исходные и сгенерированные изображения

### 5. **Обновить Message entity**
- Добавить поле для сгенерированных изображений
- Поддержка отличия исходных и сгенерированных вложений

## 🛠️ Детальная реализация

### Шаг 1: Создать ImageGenerationResponse

```dart
class ImageGenerationResponse {
  final String textResponse;
  final List<Uint8List> generatedImages;
  final List<String> imageMimeTypes;
  
  const ImageGenerationResponse({
    required this.textResponse,
    required this.generatedImages,
    required this.imageMimeTypes,
  });
}
```

### Шаг 2: Добавить метод в AIService

```dart
Future<ImageGenerationResponse> sendImageGenerationToGemini({
  required String prompt,
  required List<Uint8List> images,
  String model = 'gemini-2.5-flash-image-preview',
}) async {
  // Реализация на основе test_gemini_simple.dart
  // 1. Подготовить parts с текстом и изображениями
  // 2. Отправить запрос в Gemini API
  // 3. Обработать ответ с изображениями и текстом
  // 4. Вернуть ImageGenerationResponse
}
```

### Шаг 3: Обновить ChatProvider

```dart
Future<void> sendMessageWithImages({
  required String content,
  required List<Uint8List> images,
}) async {
  // ... существующий код ...
  
  // ✅ ИЗМЕНЕНИЕ: Использовать Gemini для генерации изображений
  final response = await _aiService.sendImageGenerationToGemini(
    prompt: content.trim(),
    images: images,
  );
  
  // Создать AI сообщение с сгенерированными изображениями
  final aiMessage = Message.ai(
    id: _uuid.v4(),
    content: response.textResponse,
    agentId: 'gemini-image-generator',
    attachments: response.generatedImages.map((imageData) {
      return Attachment.image(
        id: _uuid.v4(),
        name: 'generated_${DateTime.now().millisecondsSinceEpoch}.jpg',
        data: imageData,
        mimeType: 'image/jpeg',
      );
    }).toList(),
  );
  
  _addMessageToCurrentSession(aiMessage);
}
```

### Шаг 4: Обновить MessageBubble

```dart
Widget _buildAttachments(BuildContext context) {
  // Разделить исходные и сгенерированные изображения
  final originalImages = message.attachments?.where((a) => a.name.startsWith('image_')).toList() ?? [];
  final generatedImages = message.attachments?.where((a) => a.name.startsWith('generated_')).toList() ?? [];
  
  return Column(
    children: [
      // Показать исходные изображения
      if (originalImages.isNotEmpty) ...[
        _buildImageSection(context, originalImages, 'Исходные изображения'),
      ],
      
      // Показать сгенерированные изображения
      if (generatedImages.isNotEmpty) ...[
        _buildImageSection(context, generatedImages, 'Сгенерированные варианты'),
      ],
    ],
  );
}
```

## 🔍 Анализ test_gemini_simple.dart

### Ключевые моменты из существующего кода:

1. **Модель**: `gemini-2.5-flash-image-preview`
2. **Формат запроса**: 
   ```dart
   'contents': [
     {
       'parts': [
         {'text': prompt},
         // ... изображения как inline_data
       ]
     }
   ]
   ```

3. **Обработка ответа**:
   ```dart
   // Проверяем parts в candidates
   for (final part in parts) {
     if (part['text'] != null) {
       // Текстовый ответ
     } else if (part['inline_data'] != null) {
       // Сгенерированное изображение
     }
   }
   ```

4. **Прокси поддержка**: Использует локальный прокси сервер

## 🎯 Ожидаемый результат

### Пользователь отправляет:
- Текст: "объедини эти фото в один участок с красивым садом в скандинавском стиле сделай 3 отдельных варианта и опиши каждый из них"
- 4 изображения участка

### AI отвечает:
- Текстовое описание 3 вариантов сада
- 3 сгенерированных изображения с вариантами дизайна

### В чате отображается:
- Исходные изображения пользователя
- Текстовый ответ AI
- 3 сгенерированных изображения с вариантами

## 📊 Приоритеты

1. **Высокий**: Создать ImageGenerationResponse
2. **Высокий**: Добавить метод sendImageGenerationToGemini
3. **Высокий**: Обновить ChatProvider для использования нового метода
4. **Средний**: Обновить MessageBubble для отображения сгенерированных изображений
5. **Низкий**: Добавить визуальное разделение исходных и сгенерированных изображений

## 🚀 Готовность к реализации

Все необходимые компоненты изучены:
- ✅ Gemini API документация
- ✅ Существующий код в проекте
- ✅ Пример реализации в test_gemini_simple.dart
- ✅ Структура проекта и архитектура

**Готов к реализации!** 🎉
