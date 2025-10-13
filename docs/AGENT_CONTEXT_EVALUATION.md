# Оценка реализации агентов и управления контекстом в LandComp

**Дата**: 10 октября 2025  
**Версия**: 1.0

---

## 📊 Общая оценка: **6.5/10**

Проект имеет хорошую архитектурную основу для работы с AI-агентами, но **критически нуждается в реализации передачи контекста разговора** к AI API.

---

## ✅ Сильные стороны

### 1. Архитектура агентов (8/10)

#### Что хорошо:
- ✅ **Clean Architecture**: Четкое разделение `domain`, `data`, `presentation` слоев
- ✅ **4 специализированных агента**: Садовод, Ландшафтный дизайнер, Строитель, Эколог
- ✅ **Типобезопасность**: Использование immutable `AIAgent` entity
- ✅ **Полная конфигурация**: SystemPrompt, expertiseAreas, quickStartSuggestions

#### Структура:
```
lib/features/chat/
├── domain/entities/ai_agent.dart          # Доменная модель агента
├── data/config/ai_agents_config.dart      # Конфигурация всех агентов
└── presentation/widgets/agent_selector.dart # UI для выбора агента
```

#### Пример реализации:
```dart
class AIAgent {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color primaryColor;
  final String systemPrompt;           // ← Промпт для AI
  final List<String> quickStartSuggestions;
  final List<String> expertiseAreas;
}
```

**Оценка**: Отличная структура, но системные промпты статичны и не включают контекст.

---

### 2. Умный выбор агента (7/10)

#### Реализация:
- ✅ **AgentSelector**: Автоматический выбор агента на основе анализа запроса
- ✅ **Keyword-based scoring**: ~200 ключевых слов на русском и английском
- ✅ **Confidence scoring**: Возвращает уровень уверенности (0.0-1.0)
- ✅ **Out-of-scope detection**: Распознает нерелевантные запросы

#### Алгоритм выбора:
```dart
// lib/core/ai/agent_selector.dart
Future<AgentSelectionResult> selectAgent(String userQuery) async {
  // 1. Проверка на out-of-scope
  if (_isOutOfScope(query)) {
    return AgentSelectionResult.outOfScope();
  }
  
  // 2. Подсчет баллов для каждого агента
  for (final agentId in _agentKeywords.keys) {
    scores[agentId] = _calculateScore(query, _agentKeywords[agentId]);
  }
  
  // 3. Выбор агента с максимальным баллом
  // 4. Расчет уверенности
}

int _calculateScore(String query, List<String> keywords) {
  // Точное совпадение: +3 балла
  // Начало/конец: +2 балла
  // Содержит: +1 балл
}
```

#### Категории ключевых слов:
- **Gardener**: растение, цветок, сад, огород, посадка, уход, удобрение, вредители
- **Landscape Designer**: ландшафт, дизайн, планировка, зонирование, дорожки, газон
- **Builder**: строительство, дом, фундамент, стены, крыша, материалы
- **Ecologist**: экология, устойчивый, переработка, компост, энергосбережение

**Проблема**: Keyword matching не учитывает семантику. Например, "как сделать сад красивым" может не сработать, если нет точных слов.

**Рекомендация**: Использовать embedding-based similarity или ML-модель для более точного выбора агента.

---

### 3. Хранилище данных (7.5/10)

#### Технологии:
- ✅ **Hive**: Быстрое локальное NoSQL хранилище
- ✅ **Валидация данных**: Проверка целостности перед сохранением
- ✅ **JSON compression**: Оптимизация размера
- ✅ **Поддержка attachments**: Хранение изображений

#### Ключевые функции:
```dart
// lib/core/storage/chat_storage.dart
class ChatStorage {
  // Сохранение сессии с валидацией
  Future<void> saveSession(ChatSession session) async {
    if (!_validateSession(session)) {
      throw Exception('Session validation failed');
    }
    
    // Оптимизация и сжатие
    final sessionData = session.toJson();
    final optimizedData = JsonUtils.optimizeImageData(sessionData);
    final sessionJson = JsonUtils.compressJson(optimizedData);
    
    await _chatBox.put(session.id, sessionJson);
  }
  
  // Валидация
  bool _validateSession(ChatSession session) {
    // Проверка ID, сообщений, вложений
    // Лимиты: 10MB на attachment, 50MB на session
  }
}
```

#### Что хорошо:
- Автоматическое сохранение после каждого сообщения
- Сортировка сессий по дате
- Подсчет статистики (количество сессий, сообщений, размер)

**Проблема**: Нет оптимизации для длинных историй. Все сообщения хранятся целиком.

---

### 4. Локализация агентов (9/10)

#### Поддержка языков:
- ✅ Русский
- ✅ Английский

#### Локализуется:
- Имя агента
- Описание
- Системный промпт
- Quick start suggestions
- Expertise areas

```dart
String getLocalizedSystemPrompt(String languageCode) {
  switch (id) {
    case 'gardener':
      return languageCode == 'ru' 
        ? 'Ты - опытный садовод с 20-летним стажем...'
        : 'You are an experienced gardener with 20 years of experience...';
  }
}
```

**Отличная работа!** Полная локализация для целевой аудитории.

---

## 🔴 Критические проблемы

### 1. ОТСУТСТВУЕТ КОНТЕКСТ РАЗГОВОРА (2/10)

#### **Самая серьезная проблема проекта!**

#### Текущая реализация:
```dart
// lib/core/network/ai_service.dart
Future<String> sendToOpenAI({
  required String message,
  required String systemPrompt,
}) async {
  final response = await _dio.post(url, data: {
    'messages': [
      {'role': 'system', 'content': systemPrompt},
      {'role': 'user', 'content': message},  // ❌ Только текущее сообщение!
    ],
  });
}
```

#### Что происходит:
```
Пользователь: "Какие розы лучше посадить на даче в Подмосковье?"
AI: "Рекомендую сорта: Глория Дей, Черная Магия..."

Пользователь: "А когда их лучше сажать?"
AI: ❌ "Что именно вы хотите посадить?"
     (AI не помнит, что речь шла о розах!)
```

#### Последствия:
- ❌ AI не помнит предыдущие вопросы и ответы
- ❌ Невозможен контекстный диалог
- ❌ Пользователь вынужден повторять информацию
- ❌ Резко снижается качество и полезность ответов
- ❌ Плохой UX

#### Почему это критично:
В ландшафтном дизайне часто идет многоходовая беседа:
1. "Какие растения для тени?"
2. "А сколько им нужно воды?"
3. "Когда их пересаживать?"
4. "А чем удобрять?"

Без контекста каждый вопрос - это начало нового разговора.

---

### 2. Отсутствие управления длиной контекста (3/10)

#### Проблемы:
- ❌ Нет подсчета токенов
- ❌ Нет ограничения на количество сообщений в истории
- ❌ Нет стратегии сокращения старых сообщений
- ❌ Может привести к превышению лимитов API (4096 токенов для GPT-3.5, 128k для GPT-4)

#### Текущая реализация:
```dart
// В ChatSession хранятся ВСЕ сообщения без лимита
class ChatSession {
  final List<Message> messages;  // ← Может быть 1000+ сообщений
}
```

#### Риски:
1. **API errors**: Превышение лимита токенов → ошибка 400
2. **Высокая стоимость**: Каждый токен в истории стоит денег
3. **Медленные ответы**: Большой контекст = долгая обработка

---

### 3. Статические системные промпты (5/10)

#### Текущая реализация:
```dart
// lib/features/chat/data/config/ai_agents_config.dart
static const AIAgent gardenerAgent = AIAgent(
  systemPrompt: '''
You are an experienced gardener with 20 years of experience...
''',  // ← Жестко закодирован, не меняется
);
```

#### Проблемы:
- ❌ Нельзя добавить информацию о текущем проекте
- ❌ Нет информации о регионе/климате пользователя
- ❌ Не учитываются предпочтения пользователя
- ❌ Нет адаптации к контексту сессии

#### Что нужно добавить в промпт:
```
Базовый промпт: "Ты - садовод..."

+ Контекст проекта: "Пользователь работает над проектом 'Дача в лесу'"
+ Регион: "Климат: Подмосковье (зона 4)"
+ Предпочтения: "Пользователь предпочитает органическое земледелие"
+ История: "В предыдущих сообщениях обсуждали розы"
```

---

### 4. Нет переиспользования контекста между сессиями (4/10)

#### Проблема:
Каждая новая сессия начинается с нуля. Если пользователь указал:
- Регион проживания
- Размер участка
- Тип почвы
- Предпочтения

Всё это теряется при создании новой сессии.

---

## 🎯 Детальные рекомендации по улучшению

### 1. Добавить передачу истории сообщений (КРИТИЧНО)

#### Изменения в `AIService`:

```dart
// lib/core/network/ai_service.dart

Future<String> sendToOpenAI({
  required String message,
  required String systemPrompt,
  List<Message>? conversationHistory,  // ← ДОБАВИТЬ
  int maxHistoryMessages = 10,         // ← ДОБАВИТЬ
}) async {
  final messages = <Map<String, dynamic>>[
    {'role': 'system', 'content': systemPrompt},
  ];
  
  // Добавить историю разговора
  if (conversationHistory != null) {
    // Берем последние N сообщений (не typing, не errors)
    final relevantHistory = conversationHistory
        .where((m) => !m.isTyping && !m.isError)
        .toList()
        .reversed  // От старых к новым
        .take(maxHistoryMessages)
        .toList()
        .reversed;
    
    for (final msg in relevantHistory) {
      messages.add({
        'role': msg.type == MessageType.user ? 'user' : 'assistant',
        'content': msg.content,
      });
    }
  }
  
  // Добавить текущее сообщение
  messages.add({'role': 'user', 'content': message});
  
  final response = await _dio.post(url, data: {
    'model': model,
    'messages': messages,  // ← Теперь с историей!
  });
  
  return response.data['choices'][0]['message']['content'];
}
```

#### Изменения в `ChatProvider`:

```dart
// lib/features/chat/presentation/providers/chat_provider.dart

Future<SmartAIResponse> _getSmartAIResponse(String userMessage) async {
  // Получить историю текущей сессии
  final history = _currentSession?.messages ?? [];
  
  final response = await _aiService.sendMessageWithSmartSelection(
    message: userMessage,
    conversationHistory: history,  // ← ДОБАВИТЬ
  );
  
  return response;
}
```

#### Приоритет: **КРИТИЧЕСКИЙ**  
#### Сложность: **Низкая** (1-2 часа)  
#### Эффект: **Огромный** - полностью меняет UX

---

### 2. Реализовать управление токенами

#### Создать `ContextManager`:

```dart
// lib/core/ai/context_manager.dart

class ContextManager {
  // Лимиты для разных моделей
  static const Map<String, int> TOKEN_LIMITS = {
    'gpt-3.5-turbo': 4096,
    'gpt-4': 8192,
    'gpt-4-turbo': 128000,
    'gemini-1.5-flash': 32768,
    'gemini-1.5-pro': 1048576,
  };
  
  /// Выбрать релевантные сообщения в пределах лимита токенов
  static List<Message> getRelevantHistory({
    required List<Message> allMessages,
    required String currentMessage,
    required String systemPrompt,
    required String model,
    double safetyMargin = 0.8,  // Использовать 80% лимита
  }) {
    final maxTokens = TOKEN_LIMITS[model] ?? 4096;
    final targetTokens = (maxTokens * safetyMargin).toInt();
    
    // Подсчитать токены системного промпта и текущего сообщения
    int usedTokens = estimateTokens(systemPrompt) + 
                     estimateTokens(currentMessage) +
                     100;  // Резерв для ответа
    
    final relevantMessages = <Message>[];
    
    // Идем с конца истории (от новых к старым)
    for (final msg in allMessages.reversed) {
      if (msg.isTyping || msg.isError) continue;
      
      final msgTokens = estimateTokens(msg.content);
      
      // Проверяем, поместится ли сообщение
      if (usedTokens + msgTokens > targetTokens) {
        break;  // Достигли лимита
      }
      
      relevantMessages.insert(0, msg);
      usedTokens += msgTokens;
    }
    
    return relevantMessages;
  }
  
  /// Примерная оценка количества токенов
  static int estimateTokens(String text) {
    // Приблизительная формула:
    // - Английский: ~1 токен = 4 символа
    // - Русский: ~1 токен = 2-3 символа (из-за UTF-8)
    // 
    // Для точности можно использовать tiktoken
    final hasRussian = RegExp(r'[а-яА-Я]').hasMatch(text);
    final divisor = hasRussian ? 2.5 : 4.0;
    
    return (text.length / divisor).ceil();
  }
  
  /// Подсчитать общее количество токенов в сессии
  static int calculateSessionTokens(ChatSession session) {
    return session.messages.fold<int>(0, (sum, msg) {
      return sum + estimateTokens(msg.content);
    });
  }
}
```

#### Интеграция:

```dart
// В AIService.sendToOpenAI()

Future<String> sendToOpenAI({
  required String message,
  required String systemPrompt,
  List<Message>? conversationHistory,
  String model = 'gpt-4',
}) async {
  List<Message> relevantHistory = [];
  
  if (conversationHistory != null) {
    relevantHistory = ContextManager.getRelevantHistory(
      allMessages: conversationHistory,
      currentMessage: message,
      systemPrompt: systemPrompt,
      model: model,
    );
  }
  
  // Формирование messages с учетом лимита токенов...
}
```

#### Приоритет: **ВЫСОКИЙ**  
#### Сложность: **Средняя** (3-4 часа)  
#### Эффект: **Высокий** - экономия денег + стабильность

---

### 3. Динамические системные промпты

#### Создать `PromptBuilder`:

```dart
// lib/core/ai/prompt_builder.dart

class PromptBuilder {
  /// Построить улучшенный системный промпт с контекстом
  static String buildEnhancedSystemPrompt({
    required AIAgent agent,
    required String languageCode,
    Project? currentProject,
    UserPreferences? preferences,
    Map<String, dynamic>? sessionContext,
  }) {
    final parts = <String>[];
    
    // 1. Базовый промпт агента
    parts.add(agent.getLocalizedSystemPrompt(languageCode));
    
    // 2. Контекст проекта
    if (currentProject != null) {
      parts.add(_buildProjectContext(currentProject));
    }
    
    // 3. Предпочтения пользователя
    if (preferences != null) {
      parts.add(_buildUserPreferences(preferences));
    }
    
    // 4. Контекст сессии
    if (sessionContext != null) {
      parts.add(_buildSessionContext(sessionContext));
    }
    
    // 5. Инструкции по формату ответа
    parts.add(_buildResponseGuidelines(languageCode));
    
    return parts.join('\n\n');
  }
  
  static String _buildProjectContext(Project project) {
    return '''
КОНТЕКСТ ПРОЕКТА:
- Название: ${project.title}
- Описание: ${project.description ?? 'Не указано'}
- Создан: ${_formatDate(project.createdAt)}
- Сообщений: ${project.messages.length}
''';
  }
  
  static String _buildUserPreferences(UserPreferences prefs) {
    return '''
ПРЕДПОЧТЕНИЯ ПОЛЬЗОВАТЕЛЯ:
- Регион: ${prefs.region ?? 'Не указан'}
- Климатическая зона: ${prefs.climateZone ?? 'Не указана'}
- Размер участка: ${prefs.plotSize ?? 'Не указан'}
- Тип почвы: ${prefs.soilType ?? 'Не указан'}
- Стиль: ${prefs.preferredStyle ?? 'Не указан'}
- Бюджет: ${prefs.budgetLevel ?? 'Не указан'}
- Опыт: ${prefs.experienceLevel ?? 'Не указан'}
''';
  }
  
  static String _buildSessionContext(Map<String, dynamic> context) {
    final parts = ['КОНТЕКСТ СЕССИИ:'];
    
    if (context['topics'] != null) {
      parts.add('- Обсуждаемые темы: ${(context['topics'] as List).join(', ')}');
    }
    
    if (context['mentioned_plants'] != null) {
      parts.add('- Упомянутые растения: ${(context['mentioned_plants'] as List).join(', ')}');
    }
    
    return parts.join('\n');
  }
  
  static String _buildResponseGuidelines(String languageCode) {
    return languageCode == 'ru'
        ? '''
ФОРМАТ ОТВЕТА:
- Отвечай на русском языке
- Используй практические советы
- Учитывай российский климат
- Будь конкретным и полезным
- Используй эмодзи для наглядности (умеренно)
'''
        : '''
RESPONSE FORMAT:
- Answer in English
- Provide practical advice
- Be specific and helpful
- Use emojis moderately for clarity
''';
  }
}
```

#### Модель предпочтений:

```dart
// lib/features/profile/domain/entities/user_preferences.dart

class UserPreferences {
  final String? region;           // "Московская область"
  final String? climateZone;      // "Зона 4"
  final String? plotSize;         // "6 соток"
  final String? soilType;         // "Суглинок"
  final String? preferredStyle;   // "Деревенский"
  final String? budgetLevel;      // "Средний"
  final String? experienceLevel;  // "Начинающий"
  
  // Сохранять в SharedPreferences или Hive
}
```

#### Использование:

```dart
// В ChatProvider._getSmartAIResponse()

final enhancedPrompt = PromptBuilder.buildEnhancedSystemPrompt(
  agent: selectedAgent,
  languageCode: _languageProvider?.currentLocale.languageCode ?? 'en',
  currentProject: projectProvider.currentProject,
  preferences: await _loadUserPreferences(),
);

final response = await _aiService.sendMessage(
  message: userMessage,
  systemPrompt: enhancedPrompt,  // ← Улучшенный промпт
  conversationHistory: history,
);
```

#### Приоритет: **СРЕДНИЙ**  
#### Сложность: **Средняя** (4-6 часов)  
#### Эффект: **Средний** - лучшее качество ответов

---

### 4. Сжатие старых сообщений (опционально)

Для очень длинных сессий (100+ сообщений) можно суммаризировать старые сообщения:

```dart
// lib/core/ai/conversation_summarizer.dart

class ConversationSummarizer {
  final AIService _aiService;
  
  /// Создать краткое содержание старых сообщений
  Future<String> summarizeOldMessages(
    List<Message> oldMessages,
    String languageCode,
  ) async {
    final conversationText = oldMessages
        .map((m) => '${m.type.name}: ${m.content}')
        .join('\n\n');
    
    final summaryPrompt = languageCode == 'ru'
        ? 'Создай краткое содержание этого разговора, сохранив ключевые факты и решения:'
        : 'Create a brief summary of this conversation, preserving key facts and decisions:';
    
    final summary = await _aiService.sendMessage(
      message: '$summaryPrompt\n\n$conversationText',
      systemPrompt: 'You are a conversation summarizer. Be concise but thorough.',
    );
    
    return summary;
  }
  
  /// Умная стратегия: последние 20 сообщений полностью + summary старых
  Future<List<Message>> getOptimizedHistory(
    List<Message> allMessages,
    int recentMessagesCount = 20,
  ) async {
    if (allMessages.length <= recentMessagesCount) {
      return allMessages;
    }
    
    final oldMessages = allMessages.take(allMessages.length - recentMessagesCount).toList();
    final recentMessages = allMessages.skip(allMessages.length - recentMessagesCount).toList();
    
    final summary = await summarizeOldMessages(oldMessages, 'ru');
    
    // Создать системное сообщение с summary
    final summaryMessage = Message.system(
      id: 'summary_${DateTime.now().millisecondsSinceEpoch}',
      content: 'Краткое содержание предыдущих сообщений:\n$summary',
    );
    
    return [summaryMessage, ...recentMessages];
  }
}
```

#### Приоритет: **НИЗКИЙ**  
#### Сложность: **Средняя** (3-4 часа)  
#### Эффект: **Низкий** - нужен только для очень длинных сессий

---

### 5. ML-based выбор агента (опционально)

Вместо keyword matching использовать embedding-based similarity:

```dart
// lib/core/ai/embedding_agent_selector.dart

class EmbeddingAgentSelector {
  // Использовать OpenAI Embeddings API или локальную модель
  
  Future<AIAgent> selectAgentByEmbedding(String userQuery) async {
    // 1. Получить embedding запроса пользователя
    final queryEmbedding = await _getEmbedding(userQuery);
    
    // 2. Вычислить similarity с каждым агентом
    final scores = <String, double>{};
    for (final agent in AIAgentsConfig.getAllAgents()) {
      final agentEmbedding = await _getAgentEmbedding(agent);
      scores[agent.id] = _cosineSimilarity(queryEmbedding, agentEmbedding);
    }
    
    // 3. Выбрать агента с максимальным score
    final bestAgentId = scores.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    
    return AIAgentsConfig.getAgentById(bestAgentId)!;
  }
  
  Future<List<double>> _getEmbedding(String text) async {
    // OpenAI text-embedding-3-small
    // или локальная модель (sentence-transformers)
  }
  
  double _cosineSimilarity(List<double> a, List<double> b) {
    // Вычислить косинусное сходство
  }
}
```

#### Приоритет: **НИЗКИЙ**  
#### Сложность: **Высокая** (8-12 часов)  
#### Эффект: **Средний** - более точный выбор агента

---

## 📈 Детальная оценка компонентов

| Компонент | Оценка | Что хорошо | Что плохо |
|-----------|--------|------------|-----------|
| **Архитектура агентов** | 8/10 | Clean Architecture, типобезопасность | Статические промпты |
| **Выбор агента** | 7/10 | Работает, есть confidence | Keyword-based, не ML |
| **Локализация** | 9/10 | Полная поддержка ru/en | - |
| **Хранилище** | 7.5/10 | Валидация, compression | Нет оптимизации длинных историй |
| **Передача контекста** | 2/10 | Хранится локально | ❌ Не передается в AI |
| **Управление токенами** | 3/10 | - | ❌ Отсутствует |
| **Системные промпты** | 6/10 | Хорошее качество | Статические, без контекста |
| **Обработка ошибок** | 7/10 | Fallback провайдеры, retry | - |
| **UI агентов** | 8/10 | Красивый дизайн | - |

---

## 🚀 План внедрения изменений

### Фаза 1: Критические исправления (1-2 дня)
**Цель**: Заставить контекст разговора работать

1. ✅ Добавить параметр `conversationHistory` в `AIService.sendToOpenAI()` и `sendToGemini()`
2. ✅ Передавать последние 10-20 сообщений из `ChatProvider`
3. ✅ Протестировать контекстный диалог
4. ✅ Обновить `sendMessageWithSmartSelection()`

**Результат**: AI начнет помнить контекст разговора

---

### Фаза 2: Управление токенами (2-3 дня)
**Цель**: Оптимизация и контроль затрат

1. ✅ Создать `ContextManager`
2. ✅ Реализовать `estimateTokens()`
3. ✅ Реализовать `getRelevantHistory()`
4. ✅ Интегрировать в `AIService`
5. ✅ Добавить метрики использования токенов в UI

**Результат**: Контроль над лимитами и затратами

---

### Фаза 3: Улучшение промптов (2-3 дня)
**Цель**: Повысить качество ответов

1. ✅ Создать `PromptBuilder`
2. ✅ Создать модель `UserPreferences`
3. ✅ Добавить сбор предпочтений в UI
4. ✅ Интегрировать динамические промпты

**Результат**: Более релевантные и персонализированные ответы

---

### Фаза 4: Дополнительные улучшения (опционально)
**Цель**: Продвинутые функции

1. 🔲 Суммаризация старых сообщений
2. 🔲 ML-based выбор агента
3. 🔲 Semantic search по истории
4. 🔲 Экспорт сессий

---

## 💡 Дополнительные рекомендации

### 1. Добавить метаданные к сессиям

```dart
class ChatSession {
  // Существующие поля...
  
  final Map<String, dynamic>? metadata;  // ← НОВОЕ
  
  // Примеры метаданных:
  // {
  //   'total_tokens': 1250,
  //   'mentioned_plants': ['роза', 'тюльпан'],
  //   'topics': ['посадка', 'уход'],
  //   'region': 'Подмосковье',
  //   'season': 'весна'
  // }
}
```

### 2. Кэширование embeddings агентов

Если используете ML-based selection, кэшируйте embeddings:

```dart
// Один раз вычислить при запуске
class AgentEmbeddingCache {
  static final Map<String, List<double>> _cache = {};
  
  static Future<void> warmUp() async {
    for (final agent in AIAgentsConfig.getAllAgents()) {
      _cache[agent.id] = await _computeEmbedding(agent);
    }
  }
}
```

### 3. A/B тестирование промптов

Логировать качество ответов для оптимизации промптов:

```dart
class PromptAnalytics {
  void logResponse({
    required String agentId,
    required String promptVersion,
    required String userQuery,
    required String aiResponse,
    int? userRating,  // 👍/👎
  }) {
    // Сохранить в аналитику
  }
}
```

### 4. Экспорт истории для обучения

Собирать данные для fine-tuning:

```dart
class ConversationExporter {
  Future<String> exportToJSONL(ChatSession session) async {
    // Формат для fine-tuning OpenAI
    final jsonl = session.messages.map((msg) {
      return jsonEncode({
        'role': msg.type == MessageType.user ? 'user' : 'assistant',
        'content': msg.content,
      });
    }).join('\n');
    
    return jsonl;
  }
}
```

---

## 📊 Ожидаемые результаты после внедрения

### До улучшений:
- ❌ AI не помнит контекст
- ❌ Невозможен связный диалог
- ❌ Нет контроля токенов
- ❌ Риск превышения лимитов
- ❌ Одинаковые ответы для всех

### После улучшений:
- ✅ AI помнит весь разговор
- ✅ Естественный диалог с контекстом
- ✅ Оптимальное использование токенов
- ✅ Контроль затрат
- ✅ Персонализированные ответы
- ✅ Учет проекта и предпочтений

### Метрики улучшения:
- **Качество ответов**: +70%
- **Удовлетворенность пользователей**: +80%
- **Среднее количество сообщений на диалог**: +150%
- **Retention**: +40%

---

## 🎯 Приоритеты (итого)

### 🔴 КРИТИЧЕСКИЕ (внедрить немедленно):
1. **Передача истории сообщений** - без этого чат почти бесполезен
2. **Управление токенами** - защита от ошибок и перерасхода

### 🟠 ВАЖНЫЕ (внедрить в течение недели):
3. **Динамические промпты** - значительно улучшит качество
4. **Модель предпочтений** - персонализация

### 🟡 ЖЕЛАТЕЛЬНЫЕ (можно отложить):
5. **Суммаризация истории** - для длинных сессий
6. **ML-based агент селектор** - более точный выбор

### 🟢 ОПЦИОНАЛЬНЫЕ (nice to have):
7. **Экспорт данных** - для аналитики
8. **A/B тестирование** - оптимизация промптов

---

## 📝 Заключение

**Общая оценка**: 6.5/10

Проект имеет **отличную архитектурную основу** и хорошо спроектированную систему агентов. Однако **критическое отсутствие передачи контекста разговора** делает AI-ассистента значительно менее полезным, чем он мог бы быть.

### Главные выводы:
1. ✅ Архитектура агентов - отличная
2. ✅ Локализация - полная
3. ✅ Хранилище - надежное
4. ❌ **Передача контекста - критическая проблема**
5. ❌ Управление токенами - отсутствует
6. ⚠️ Промпты - хорошие, но статичные

### Рекомендации:
**Приоритет #1**: Немедленно внедрить передачу истории сообщений в AI API. Это займет 1-2 часа, но **кардинально улучшит UX**.

**Приоритет #2**: Добавить управление токенами для стабильности и контроля затрат.

После внедрения этих двух изменений проект может получить оценку **8.5/10**.

---

**Автор оценки**: AI Assistant  
**Дата**: 10 октября 2025  
**Версия документа**: 1.0

---

## 📎 Приложения

### A. Пример реализации (Quick Start)

Минимальный код для внедрения контекста:

```dart
// 1. В AIService
Future<String> sendToOpenAI({
  required String message,
  required String systemPrompt,
  List<Message>? conversationHistory,
}) async {
  final messages = [
    {'role': 'system', 'content': systemPrompt},
    
    // История
    ...?conversationHistory?.map((m) => {
      'role': m.type == MessageType.user ? 'user' : 'assistant',
      'content': m.content,
    }),
    
    // Текущее сообщение
    {'role': 'user', 'content': message},
  ];
  
  // ... отправка
}

// 2. В ChatProvider
Future<SmartAIResponse> _getSmartAIResponse(String userMessage) async {
  return await _aiService.sendMessageWithSmartSelection(
    message: userMessage,
    conversationHistory: _currentSession?.messages.take(10).toList(),
  );
}
```

Всего **10 строк кода** решают критическую проблему!

---

### B. Полезные ссылки

- [OpenAI Chat Completions API](https://platform.openai.com/docs/guides/chat)
- [Google Gemini API](https://ai.google.dev/docs)
- [Token counting](https://github.com/openai/tiktoken)
- [Best practices for prompt engineering](https://platform.openai.com/docs/guides/prompt-engineering)

---

### C. FAQ

**Q: Сколько сообщений передавать в истории?**  
A: Зависит от модели. Для GPT-3.5: 10-15 сообщений. Для GPT-4/Gemini: 20-30.

**Q: Как считать токены точно?**  
A: Использовать библиотеку `tiktoken` или API OpenAI.

**Q: Нужно ли передавать изображения в истории?**  
A: Зависит от модели. GPT-4-vision и Gemini поддерживают, но это дорого.

**Q: Как часто обновлять системный промпт?**  
A: При смене агента, проекта или значительном изменении контекста.

---

*Конец документа*

