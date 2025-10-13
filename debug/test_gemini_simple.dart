/// Упрощенный тестовый скрипт для Gemini Image Generation без Flutter зависимостей
/// 
/// Этот скрипт:
/// 1. Загружает все изображения из папки test-images
/// 2. Отправляет их в модель gemini-2.5-flash-image с промптом
/// 3. Сохраняет полученные изображения и текст в папку test-images/test-gemini
library;

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

/// Основной класс для тестирования Gemini Image Generation
class GeminiImageTest {
  
  GeminiImageTest({
    required this.apiKey,
    required this.testImagesDir,
    required this.outputDir,
    this.proxyUrl,
    this.backupProxies = const [],
  });
  static const String _modelName = 'gemini-2.5-flash-image-preview';
  static const String _apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/$_modelName:generateContent';
  static const String _prompt = 'объедини эти фото в один участок с красивым садом в скандинавском стиле сделай 3 отдельных варианта и опиши каждый из них';
  
  final String apiKey;
  final String testImagesDir;
  final String outputDir;
  final String? proxyUrl;
  final List<String> backupProxies;

  /// Запуск теста
  Future<void> runTest() async {
    print('🚀 Запуск теста Gemini Image Generation...');
    print('📁 Папка с изображениями: $testImagesDir');
    print('📁 Папка для результатов: $outputDir');
    print('🤖 Модель: $_modelName');
    if (proxyUrl != null) {
      print('🌐 Прокси: $proxyUrl');
    }
    if (backupProxies.isNotEmpty) {
      print('🔄 Резервные прокси: ${backupProxies.length}');
    }
    print('');

    try {
      // Создаем папку для результатов
      await _createOutputDirectory();
      
      // Получаем список изображений
      final imageFiles = await _getImageFiles();
      print('📸 Найдено изображений: ${imageFiles.length}');
      
      if (imageFiles.isEmpty) {
        print('❌ Изображения не найдены в папке $testImagesDir');
        return;
      }
      
      // Отправляем запрос в Gemini с fallback механизмом
      print('📤 Отправка запроса в Gemini API...');
      final response = await _sendWithFallback(imageFiles);
      
      // Обрабатываем ответ
      await _processResponse(response);
      
      print('✅ Тест завершен успешно!');
      
    } catch (e) {
      print('❌ Ошибка во время теста: $e');
      rethrow;
    }
  }

  /// Создание папки для результатов
  Future<void> _createOutputDirectory() async {
    final outputDirPath = Directory(outputDir);
    if (!await outputDirPath.exists()) {
      await outputDirPath.create(recursive: true);
      print('📁 Создана папка: $outputDir');
    }
  }

  /// Получение списка изображений
  Future<List<File>> _getImageFiles() async {
    final testDir = Directory(testImagesDir);
    if (!await testDir.exists()) {
      throw Exception('Папка $testImagesDir не существует');
    }

    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    final files = <File>[];
    
    await for (final entity in testDir.list()) {
      if (entity is File) {
        final extension = path.extension(entity.path).toLowerCase();
        if (imageExtensions.contains(extension)) {
          files.add(entity);
        }
      }
    }
    
    return files;
  }

  /// Отправка запроса с fallback механизмом для прокси
  Future<Map<String, dynamic>> _sendWithFallback(List<File> imageFiles) async {
    final proxies = <String>[];
    // Добавляем прямое соединение как первый вариант
    proxies.add('');
    if (proxyUrl != null) proxies.add(proxyUrl!);
    proxies.addAll(backupProxies);
    
    Exception? lastException;
    
    for (var i = 0; i < proxies.length; i++) {
      final currentProxy = proxies[i];
      try {
        print('🌐 Попытка ${i + 1}/${proxies.length}: ${currentProxy.isNotEmpty ? "Прокси $currentProxy" : "Прямое соединение"}');
        
        final test = GeminiImageTest(
          apiKey: apiKey,
          testImagesDir: testImagesDir,
          outputDir: outputDir,
          proxyUrl: currentProxy.isNotEmpty ? currentProxy : null,
          backupProxies: backupProxies,
        );
        
        return await test._sendToGemini(imageFiles);
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        print('❌ Ошибка с ${currentProxy.isNotEmpty ? "прокси $currentProxy" : "прямым соединением"}: $e');
        
        if (i < proxies.length - 1) {
          print('🔄 Переключение на следующий вариант...');
          await Future.delayed(const Duration(seconds: 2)); // Пауза между попытками
        }
      }
    }
    
    throw lastException ?? Exception('Все варианты соединения недоступны');
  }

  /// Создание HTTP клиента с поддержкой прокси
  http.Client _createHttpClient() {
    if (proxyUrl == null || proxyUrl!.isEmpty) {
      return http.Client();
    }

    try {
      // Парсим прокси URL
      final proxyUri = Uri.parse(proxyUrl!);
      
      // Создаем HTTP клиент с прокси
      final client = http.Client();
      
      // Для простоты используем системный прокси
      // В реальном проекте здесь была бы более сложная логика
      return client;
    } catch (e) {
      print('⚠️ Ошибка конфигурации прокси: $e');
      return http.Client();
    }
  }

  /// Отправка запроса в Gemini API
  Future<Map<String, dynamic>> _sendToGemini(List<File> imageFiles) async {
    // Подготавливаем части запроса
    final parts = <Map<String, dynamic>>[
      {'text': _prompt}
    ];

    // Добавляем изображения
    for (final imageFile in imageFiles) {
      final imageData = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageData);
      final mimeType = _getMimeType(imageFile.path);
      
      parts.add({
        'inline_data': {
          'mime_type': mimeType,
          'data': base64Image,
        }
      });
    }

    // Формируем запрос
    final requestBody = {
      'contents': [
        {
          'parts': parts,
        }
      ]
    };

    print('📋 Отправляем ${imageFiles.length} изображений с промптом...');
    print('📝 Промпт: $_prompt');

    // Определяем URL для запроса
    String requestUrl;
    if (proxyUrl != null && proxyUrl!.isNotEmpty) {
      // Используем локальный прокси сервер
      requestUrl = 'http://localhost:3001/proxy/gemini/v1beta/models/$_modelName:generateContent?key=$apiKey';
      print('🌐 Используем локальный прокси сервер: localhost:3001');
    } else {
      // Прямое соединение
      requestUrl = '$_apiUrl?key=$apiKey';
      print('🌐 Используем прямое соединение');
    }

    // Создаем HTTP клиент
    final client = http.Client();
    
    try {
      // Отправляем запрос
      final response = await client.post(
        Uri.parse(requestUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != 200) {
        throw Exception('Ошибка API: ${response.statusCode} - ${response.body}');
      }

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      print('📋 Полный ответ: ${json.encode(responseData)}');
      
      // Проверяем, есть ли parts в candidates
      if (responseData['candidates'] != null && responseData['candidates'] is List) {
        final candidates = responseData['candidates'] as List;
        if (candidates.isNotEmpty) {
          final candidate = candidates[0] as Map<String, dynamic>;
          print('🔍 Candidate keys: ${candidate.keys.join(', ')}');
          if (candidate['content'] != null) {
            print('✅ Найден content в candidate');
            final content = candidate['content'] as Map<String, dynamic>;
            print('🔍 Content keys: ${content.keys.join(', ')}');
          }
        }
      }
      
      return responseData;
    } finally {
      client.close();
    }
  }

  /// Обработка ответа от Gemini
  Future<void> _processResponse(Map<String, dynamic> response) async {
    print('📥 Получен ответ от Gemini API');
    
    final candidates = response['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('Нет кандидатов в ответе');
    }

    final candidate = candidates.first;
    final content = candidate['content'] as Map<String, dynamic>?;
    if (content == null) {
      throw Exception('Нет контента в ответе');
    }

    final parts = content['parts'] as List<dynamic>?;
    if (parts == null || parts.isEmpty) {
      throw Exception('Нет частей в контенте');
    }

    var imageCount = 0;
    final textParts = <String>[];

    // Обрабатываем каждую часть ответа
    print('🔍 Найдено частей в ответе: ${parts.length}');
    for (var i = 0; i < parts.length; i++) {
      final part = parts[i] as Map<String, dynamic>;
      print('🔍 Часть $i содержит ключи: ${part.keys.join(', ')}');
      
      if (part['text'] != null) {
        // Текстовая часть
        final text = part['text'] as String;
        textParts.add(text);
        print('📝 Получен текст: ${text.length} символов');
      } else if (part['inline_data'] != null || part['inlineData'] != null) {
        // Изображение - проверяем оба варианта
        final inlineData = (part['inline_data'] ?? part['inlineData']) as Map<String, dynamic>;
        final imageData = inlineData['data'] as String;
        final mimeType = (inlineData['mime_type'] ?? inlineData['mimeType']) as String;
        
        // Декодируем base64
        final imageBytes = base64Decode(imageData);
        
        // Определяем расширение файла
        final extension = _getExtensionFromMimeType(mimeType);
        final fileName = 'gemini_result_${++imageCount}$extension';
        final filePath = path.join(outputDir, fileName);
        
        // Сохраняем изображение
        final file = File(filePath);
        await file.writeAsBytes(imageBytes);
        
        print('🖼️ Сохранено изображение: $fileName (${imageBytes.length} байт)');
      }
    }

    // Сохраняем текст
    if (textParts.isNotEmpty) {
      final fullText = textParts.join('\n\n');
      final textFile = File(path.join(outputDir, 'gemini_response.txt'));
      await textFile.writeAsString(fullText);
      print('📄 Сохранен текст: gemini_response.txt');
    }

    // Выводим статистику
    print('');
    print('📊 Статистика:');
    print('   - Изображений получено: $imageCount');
    print('   - Текстовых частей: ${textParts.length}');
    print('   - Общий размер текста: ${textParts.join().length} символов');
  }

  /// Получение MIME типа по расширению файла
  String _getMimeType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.bmp':
        return 'image/bmp';
      case '.webp':
        return 'image/webp';
      default:
        return 'image/jpeg'; // По умолчанию
    }
  }

  /// Получение расширения файла по MIME типу
  String _getExtensionFromMimeType(String mimeType) {
    switch (mimeType) {
      case 'image/jpeg':
        return '.jpg';
      case 'image/png':
        return '.png';
      case 'image/gif':
        return '.gif';
      case 'image/bmp':
        return '.bmp';
      case 'image/webp':
        return '.webp';
      default:
        return '.jpg'; // По умолчанию
    }
  }
}

/// Главная функция для запуска теста
Future<void> main() async {
  print('🎨 Тест Gemini Image Generation (Упрощенная версия)');
  print('==================================================');
  print('');

  // Читаем .env файл
  final envFile = File('.env');
  if (!await envFile.exists()) {
    print('❌ Файл .env не найден');
    print('💡 Создайте файл .env с переменными окружения');
    return;
  }

  final envContent = await envFile.readAsString();
  final envVars = <String, String>{};
  
  for (final line in envContent.split('\n')) {
    if (line.trim().isEmpty || line.startsWith('#')) continue;
    final parts = line.split('=');
    if (parts.length >= 2) {
      final key = parts[0].trim();
      final value = parts.sublist(1).join('=').trim().replaceAll('"', '');
      envVars[key] = value;
    }
  }

  print('✅ Переменные окружения загружены из .env');
  print('   Google ключ: ${envVars['GOOGLE_API_KEY']?.substring(0, 10)}...');
  print('   Прокси: ${envVars['ALL_PROXY']?.substring(0, 20)}...\n');

  // Получаем API ключ из .env файла
  final apiKey = envVars['GOOGLE_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    print('❌ Ошибка: Не найден GOOGLE_API_KEY в .env файле');
    print('');
    print('💡 Добавьте в .env файл:');
    print('   GOOGLE_API_KEY=your_api_key_here');
    print('');
    print('🔑 Получить API ключ можно здесь: https://aistudio.google.com/app/apikey');
    return;
  }

  // Получаем настройки прокси
  final proxyUrl = envVars['ALL_PROXY'];
  final backupProxiesStr = envVars['BACKUP_PROXIES'] ?? '';
  final backupProxies = backupProxiesStr.split(',').where((proxy) => proxy.isNotEmpty).toList();

  // Определяем пути
  final currentDir = Directory.current.path;
  final testImagesDir = path.join(currentDir, 'test-images');
  final outputDir = path.join(testImagesDir, 'test-gemini');

  // Создаем и запускаем тест
  final test = GeminiImageTest(
    apiKey: apiKey,
    testImagesDir: testImagesDir,
    outputDir: outputDir,
    proxyUrl: proxyUrl?.isNotEmpty ?? false ? proxyUrl : null,
    backupProxies: backupProxies,
  );

  try {
    await test.runTest();
  } catch (e) {
    print('');
    print('💥 Тест завершился с ошибкой: $e');
    exit(1);
  }
}
