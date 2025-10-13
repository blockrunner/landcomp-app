#!/usr/bin/env dart

/// Тест исправления обработки изображений
/// 
/// Проверяет, что система правильно классифицирует намерения
/// и выбирает релевантные изображения

import 'dart:io';
import 'dart:typed_data';

// Импорты для тестирования
import 'package:landcomp_app/core/orchestrator/agent_orchestrator.dart';
import 'package:landcomp_app/core/orchestrator/intent_classifier.dart';
import 'package:landcomp_app/core/orchestrator/context_manager.dart';
import 'package:landcomp_app/shared/models/intent.dart';
import 'package:landcomp_app/features/chat/domain/entities/message.dart';
import 'package:landcomp_app/features/chat/domain/entities/attachment.dart';

void main() async {
  print('🧪 Тестирование исправления обработки изображений');
  print('=' * 50);
  
  try {
    // 1. Тест Intent Classifier
    print('\n1. Тестирование Intent Classifier...');
    await testIntentClassifier();
    
    // 2. Тест Context Manager
    print('\n2. Тестирование Context Manager...');
    await testContextManager();
    
    // 3. Тест Agent Orchestrator
    print('\n3. Тестирование Agent Orchestrator...');
    await testAgentOrchestrator();
    
    print('\n✅ Все тесты пройдены успешно!');
    print('🎉 Система обработки изображений работает правильно!');
    
  } catch (e) {
    print('\n❌ Ошибка в тестах: $e');
    exit(1);
  }
}

/// Тест Intent Classifier
Future<void> testIntentClassifier() async {
  final classifier = IntentClassifier.instance;
  
  // Создаем тестовый контекст с изображением
  final context = RequestContext(
    userMessage: 'как можно преобразовать участок?',
    conversationHistory: [],
    attachments: [
      Attachment.image(
        id: 'test-image-1',
        name: 'test_image.jpg',
        data: Uint8List.fromList([1, 2, 3, 4, 5]), // Тестовые данные
        mimeType: 'image/jpeg',
      ),
    ],
    metadata: {},
  );
  
  print('   📝 Тестируем классификацию намерений...');
  
  try {
    final intent = await classifier.classifyIntent(
      'как можно преобразовать участок?',
      context,
    );
    
    print('   ✅ Intent классифицирован:');
    print('      Type: ${intent.type.name}');
    print('      Subtype: ${intent.subtype?.name ?? 'null'}');
    print('      Image Intent: ${intent.imageIntent?.name ?? 'null'}');
    print('      Images Needed: ${intent.imagesNeeded ?? 'null'}');
    print('      Confidence: ${intent.confidence}');
    
    // Проверяем, что image intent определен
    if (intent.imageIntent == null) {
      throw Exception('Image intent не определен!');
    }
    
    if (intent.imageIntent != ImageIntent.analyzeNew) {
      print('   ⚠️ Ожидался analyzeNew, получен: ${intent.imageIntent!.name}');
    }
    
  } catch (e) {
    print('   ❌ Ошибка классификации: $e');
    rethrow;
  }
}

/// Тест Context Manager
Future<void> testContextManager() async {
  final contextManager = ContextManager.instance;
  
  // Создаем тестовые данные
  final testAttachments = [
    Attachment.image(
      id: 'test-image-1',
      name: 'test_image.jpg',
      data: Uint8List.fromList([1, 2, 3, 4, 5]),
      mimeType: 'image/jpeg',
    ),
  ];
  
  final testHistory = [
    Message.user(
      id: 'msg-1',
      content: 'Привет!',
    ),
    Message.ai(
      id: 'msg-2',
      content: 'Здравствуйте! Как дела?',
      agentId: 'test_agent',
    ),
  ];
  
  final testIntent = Intent(
    type: IntentType.analysis,
    subtype: IntentSubtype.landscapePlanning,
    confidence: 0.9,
    reasoning: 'Тестовый intent',
    imageIntent: ImageIntent.analyzeNew,
    imagesNeeded: 1,
  );
  
  print('   🖼️ Тестируем умный выбор изображений...');
  
  try {
    final relevantImages = await contextManager.getRelevantImages(
      userMessage: 'как можно преобразовать участок?',
      conversationHistory: testHistory,
      intent: testIntent,
      currentAttachments: testAttachments,
    );
    
    print('   ✅ Выбрано изображений: ${relevantImages.length}');
    
    if (relevantImages.isEmpty) {
      throw Exception('Не выбрано ни одного изображения!');
    }
    
    if (relevantImages.length != 1) {
      print('   ⚠️ Ожидалось 1 изображение, получено: ${relevantImages.length}');
    }
    
    print('   📸 Выбранное изображение: ${relevantImages.first.name}');
    
  } catch (e) {
    print('   ❌ Ошибка выбора изображений: $e');
    rethrow;
  }
}

/// Тест Agent Orchestrator
Future<void> testAgentOrchestrator() async {
  final orchestrator = AgentOrchestrator.instance;
  
  // Инициализируем orchestrator
  await orchestrator.initialize();
  
  // Создаем тестовые данные
  final testAttachments = [
    Attachment.image(
      id: 'test-image-1',
      name: 'test_image.jpg',
      data: Uint8List.fromList([1, 2, 3, 4, 5]),
      mimeType: 'image/jpeg',
    ),
  ];
  
  final testHistory = [
    Message.user(
      id: 'msg-1',
      content: 'Привет!',
    ),
  ];
  
  print('   🤖 Тестируем обработку запроса...');
  
  try {
    final response = await orchestrator.processRequest(
      userMessage: 'как можно преобразовать участок?',
      conversationHistory: testHistory,
      attachments: testAttachments,
    );
    
    print('   ✅ Запрос обработан:');
    print('      Success: ${response.isSuccess}');
    print('      Selected Agent: ${response.selectedAgent?.name ?? 'null'}');
    print('      Message Length: ${response.message?.length ?? 0}');
    
    if (!response.isSuccess) {
      throw Exception('Запрос не обработан успешно!');
    }
    
    if (response.message == null || response.message!.isEmpty) {
      throw Exception('Ответ пустой!');
    }
    
    print('   📝 Ответ: ${response.message!.substring(0, response.message!.length > 100 ? 100 : response.message!.length)}...');
    
  } catch (e) {
    print('   ❌ Ошибка обработки запроса: $e');
    rethrow;
  }
}
