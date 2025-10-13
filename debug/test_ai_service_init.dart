/// Тест инициализации AIService
/// 
/// Этот скрипт проверяет, правильно ли инициализируется AIService
library;

import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Импортируем необходимые классы
import 'package:landcomp_app/core/config/env_config.dart';
import 'package:landcomp_app/core/network/ai_service.dart';

void main() async {
  print('🧪 Тестирование инициализации AIService...\n');

  // Загружаем переменные окружения
  try {
    await dotenv.load();
    print('✅ Переменные окружения загружены');
  } catch (e) {
    print('❌ Ошибка загрузки .env: $e');
    return;
  }

  // Проверяем конфигурацию
  print('\n📋 Проверка конфигурации:');
  print('   OpenAI настроен: ${EnvConfig.isOpenAIConfigured ? '✅' : '❌'}');
  print('   Google настроен: ${EnvConfig.isGoogleConfigured ? '✅' : '❌'}');
  print('   Прокси настроен: ${EnvConfig.isProxyConfigured ? '✅' : '❌'}');

  if (!EnvConfig.isOpenAIConfigured && !EnvConfig.isGoogleConfigured) {
    print('❌ Ни один AI сервис не настроен');
    return;
  }

  // Инициализируем AIService
  print('\n🔧 Инициализация AIService...');
  try {
    await AIService.instance.initialize();
    print('✅ AIService инициализирован успешно');
    
    // Получаем статус
    final status = AIService.instance.getStatus();
    print('\n📊 Статус AIService:');
    print('   OpenAI: ${status['openai_configured'] ? '✅' : '❌'}');
    print('   Google: ${status['google_configured'] ? '✅' : '❌'}');
    print('   Прокси: ${status['proxy_configured'] ? '✅' : '❌'}');
    print('   Текущий прокси: ${status['current_proxy']}');
    print('   Google ключ: ${status['current_google_key']}');
    
  } catch (e) {
    print('❌ Ошибка инициализации AIService: $e');
    print('📋 Детали ошибки:');
    print('   Тип: ${e.runtimeType}');
    print('   Сообщение: ${e}');
    
    // Проверяем стек вызовов
    if (e is Error) {
      print('   Стек: ${e.stackTrace}');
    }
  }

  print('\n🎉 Тестирование завершено!');
}
