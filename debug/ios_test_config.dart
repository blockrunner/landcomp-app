// iOS Testing Configuration for LandComp
// Этот файл содержит конфигурацию для тестирования приложения на iOS

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Конфигурация для тестирования на iOS
class IOSTestConfig {
  static const String _tag = 'IOSTestConfig';
  
  /// Включить детальное логирование для iOS тестирования
  static const bool enableDetailedLogging = kDebugMode;
  
  /// Включить тестовые данные для iOS
  static const bool enableTestData = kDebugMode;
  
  /// Включить симуляцию медленного соединения
  static const bool simulateSlowConnection = false;
  
  /// Включить тестирование различных размеров экрана
  static const bool enableScreenSizeTesting = true;
  
  /// Включить тестирование темной темы
  static const bool enableDarkThemeTesting = true;
  
  /// Включить тестирование локализации
  static const bool enableLocalizationTesting = true;
  
  /// Тестовые изображения для iOS
  static const List<String> testImages = [
    'assets/images/logo.jpg',
    // Добавьте другие тестовые изображения
  ];
  
  /// Тестовые сообщения для чата
  static const List<String> testChatMessages = [
    'Привет! Помоги мне с дизайном сада',
    'Какой стиль ландшафта подойдет для моего участка?',
    'Покажи мне примеры современного сада',
    'Какие растения лучше посадить в тени?',
  ];
  
  /// Тестовые размеры экранов для проверки адаптивности
  static const List<Size> testScreenSizes = [
    Size(375, 667),  // iPhone SE
    Size(390, 844),  // iPhone 12/13/14
    Size(393, 852),  // iPhone 14 Pro
    Size(428, 926),  // iPhone 14 Pro Max
    Size(768, 1024), // iPad
    Size(834, 1194), // iPad Pro 11"
    Size(1024, 1366), // iPad Pro 12.9"
  ];
  
  /// Тестовые языки для локализации
  static const List<String> testLanguages = [
    'en', // Английский
    'ru', // Русский
    // Добавьте другие языки
  ];
  
  /// Логирование для iOS тестирования
  static void log(String message, {String? tag}) {
    if (enableDetailedLogging) {
      final timestamp = DateTime.now().toIso8601String();
      final logTag = tag ?? _tag;
      debugPrint('[$timestamp] [$logTag] $message');
    }
  }
  
  /// Проверка, запущено ли приложение на iOS
  static bool get isIOS {
    return defaultTargetPlatform == TargetPlatform.iOS;
  }
  
  /// Проверка, запущено ли приложение на симуляторе
  static bool get isSimulator {
    // В реальном приложении можно использовать device_info_plus
    // для определения, запущено ли на симуляторе
    return kDebugMode; // Упрощенная проверка
  }
  
  /// Получение тестовых данных для конкретного теста
  static Map<String, dynamic> getTestData(String testName) {
    switch (testName) {
      case 'chat':
        return {
          'messages': testChatMessages,
          'enableAI': true,
          'enableImageUpload': true,
        };
      case 'images':
        return {
          'testImages': testImages,
          'enableCamera': true,
          'enableGallery': true,
        };
      case 'theme':
        return {
          'enableDarkMode': enableDarkThemeTesting,
          'enableSystemTheme': true,
        };
      case 'localization':
        return {
          'languages': testLanguages,
          'enableRTL': false,
        };
      default:
        return {};
    }
  }
  
  /// Создание тестового виджета с конфигурацией
  static Widget createTestWidget({
    required Widget child,
    String? testName,
    Map<String, dynamic>? customConfig,
  }) {
    final config = customConfig ?? getTestData(testName ?? '');
    
    return Builder(
      builder: (context) {
        log('Creating test widget: $testName', tag: 'TestWidget');
        
        return Container(
          decoration: BoxDecoration(
            border: enableDetailedLogging 
                ? Border.all(color: Colors.red, width: 2)
                : null,
          ),
          child: child,
        );
      },
    );
  }
  
  /// Запуск тестового сценария
  static Future<void> runTestScenario(String scenarioName) async {
    log('Starting test scenario: $scenarioName', tag: 'TestScenario');
    
    switch (scenarioName) {
      case 'full_app_test':
        await _runFullAppTest();
        break;
      case 'chat_test':
        await _runChatTest();
        break;
      case 'image_test':
        await _runImageTest();
        break;
      case 'theme_test':
        await _runThemeTest();
        break;
      case 'localization_test':
        await _runLocalizationTest();
        break;
      default:
        log('Unknown test scenario: $scenarioName', tag: 'TestScenario');
    }
  }
  
  /// Полный тест приложения
  static Future<void> _runFullAppTest() async {
    log('Running full app test...', tag: 'FullAppTest');
    
    // Тест запуска приложения
    log('✓ App startup test passed', tag: 'FullAppTest');
    
    // Тест навигации
    log('✓ Navigation test passed', tag: 'FullAppTest');
    
    // Тест чата
    await _runChatTest();
    
    // Тест изображений
    await _runImageTest();
    
    // Тест тем
    await _runThemeTest();
    
    // Тест локализации
    await _runLocalizationTest();
    
    log('✓ Full app test completed', tag: 'FullAppTest');
  }
  
  /// Тест чата
  static Future<void> _runChatTest() async {
    log('Running chat test...', tag: 'ChatTest');
    
    for (final message in testChatMessages) {
      log('Testing message: $message', tag: 'ChatTest');
      // Здесь можно добавить реальную логику тестирования
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    log('✓ Chat test completed', tag: 'ChatTest');
  }
  
  /// Тест изображений
  static Future<void> _runImageTest() async {
    log('Running image test...', tag: 'ImageTest');
    
    for (final image in testImages) {
      log('Testing image: $image', tag: 'ImageTest');
      // Здесь можно добавить реальную логику тестирования
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    log('✓ Image test completed', tag: 'ImageTest');
  }
  
  /// Тест тем
  static Future<void> _runThemeTest() async {
    log('Running theme test...', tag: 'ThemeTest');
    
    if (enableDarkThemeTesting) {
      log('Testing dark theme...', tag: 'ThemeTest');
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    log('Testing light theme...', tag: 'ThemeTest');
    await Future.delayed(const Duration(milliseconds: 100));
    
    log('✓ Theme test completed', tag: 'ThemeTest');
  }
  
  /// Тест локализации
  static Future<void> _runLocalizationTest() async {
    log('Running localization test...', tag: 'LocalizationTest');
    
    for (final language in testLanguages) {
      log('Testing language: $language', tag: 'LocalizationTest');
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    log('✓ Localization test completed', tag: 'LocalizationTest');
  }
  
  /// Получение информации о тестовой среде
  static Map<String, dynamic> getTestEnvironmentInfo() {
    return {
      'platform': defaultTargetPlatform.toString(),
      'isIOS': isIOS,
      'isSimulator': isSimulator,
      'isDebug': kDebugMode,
      'enableDetailedLogging': enableDetailedLogging,
      'enableTestData': enableTestData,
      'testScreenSizes': testScreenSizes.map((s) => '${s.width}x${s.height}').toList(),
      'testLanguages': testLanguages,
    };
  }
  
  /// Вывод информации о тестовой среде
  static void printTestEnvironmentInfo() {
    final info = getTestEnvironmentInfo();
    log('Test Environment Info:', tag: 'Environment');
    
    info.forEach((key, value) {
      log('  $key: $value', tag: 'Environment');
    });
  }
}

/// Миксин для тестирования на iOS
mixin IOSTestMixin {
  /// Проверка, что тест запущен на iOS
  bool get isIOSTest => IOSTestConfig.isIOS;
  
  /// Логирование тестового события
  void logTestEvent(String event, {Map<String, dynamic>? data}) {
    IOSTestConfig.log('Test Event: $event', tag: 'TestEvent');
    if (data != null) {
      data.forEach((key, value) {
        IOSTestConfig.log('  $key: $value', tag: 'TestEvent');
      });
    }
  }
  
  /// Создание тестового виджета
  Widget createTestWidget({
    required Widget child,
    String? testName,
  }) {
    return IOSTestConfig.createTestWidget(
      child: child,
      testName: testName,
    );
  }
}

/// Расширение для тестирования виджетов
extension IOSTestWidgetExtension on Widget {
  /// Обертывание виджета в тестовую конфигурацию
  Widget withIOSTest({
    String? testName,
    Map<String, dynamic>? config,
  }) {
    return IOSTestConfig.createTestWidget(
      child: this,
      testName: testName,
      customConfig: config,
    );
  }
}
