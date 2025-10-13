/// Главный скрипт для запуска всех тестов
/// 
/// Этот скрипт запускает все тесты последовательно для полной диагностики
/// проблем с AI сервисом.
library;

import 'test_ai_service.dart';
import 'test_env_config.dart';
import 'test_network_connection.dart';

/// Главный класс для запуска всех тестов
class AllTestsRunner {
  static Future<void> runAllTests() async {
    print('🚀 Запуск полной диагностики AI сервиса...\n');
    print('=' * 60);
    
    try {
      // Тест 1: Конфигурация окружения
      print('\n📋 ЭТАП 1: Тестирование конфигурации окружения');
      print('=' * 60);
      await EnvConfigTester.runAllTests();
      
      // Тест 2: Сетевое соединение
      print('\n🌐 ЭТАП 2: Тестирование сетевого соединения');
      print('=' * 60);
      await NetworkConnectionTester.runAllTests();
      
      // Тест 3: AI Service
      print('\n🤖 ЭТАП 3: Тестирование AI Service');
      print('=' * 60);
      await AIServiceTester.runAllTests();
      
      print('\n🎉 ВСЕ ТЕСТЫ ЗАВЕРШЕНЫ УСПЕШНО!');
      print('=' * 60);
      print('Если все тесты прошли успешно, проблема может быть в:');
      print('1. Инициализации AIService в приложении');
      print('2. Обработке ошибок в UI');
      print('3. Асинхронности вызовов');
      
    } catch (e) {
      print('\n💥 КРИТИЧЕСКАЯ ОШИБКА: $e');
      print('=' * 60);
      print('Рекомендации:');
      print('1. Проверьте .env файл');
      print('2. Проверьте интернет соединение');
      print('3. Проверьте доступность прокси');
      print('4. Проверьте валидность API ключей');
    }
  }
}

/// Запуск всех тестов
void main() async {
  await AllTestsRunner.runAllTests();
}
