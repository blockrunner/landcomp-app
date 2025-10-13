/// Тестовый скрипт для отправки изображений в модель Gemini 2.5 Flash Image
/// 
/// Этот скрипт:
/// 1. Загружает все изображения из папки test-images
/// 2. Отправляет их в модель gemini-2.5-flash-image с промптом
/// 3. Сохраняет полученные изображения и текст в папку test-images/test-gemini
library;

import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio/browser.dart';
import 'package:path/path.dart' as path;
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import 'package:landcomp_app/core/config/env_config.dart';

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
  static const String _prompt = 'объедини эти фото в один участок с красивым садом в скандинавском стиле сделай 3 отдельных вараинта и опиши каждый из них';
  
  final String apiKey;
  final String testImagesDir;
  final String outputDir;
  final String? proxyUrl;
  final List<String> backupProxies;
  late Box<dynamic> _cacheBox;
  late Dio _dio;

  /// Инициализация кэша
  Future<void> _initCache() async {
    try {
      _cacheBox = await Hive.openBox('gemini_cache');
      print('💾 Кэш инициализирован');
    } catch (e) {
      print('⚠️ Ошибка инициализации кэша: $e');
      // Создаем временный кэш в памяти
      _cacheBox = Hive.box('temp_cache');
    }
  }

  /// Инициализация Dio с прокси
  void _initDio() {
    _dio = Dio();
    
    // Настройка таймаутов
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 60);
    _dio.options.sendTimeout = const Duration(seconds: 30);
    
    // Настройка прокси
    _configureProxy();
    
    // Добавляем интерцепторы
    _dio.interceptors.add(_createLoggingInterceptor());
    _dio.interceptors.add(_createRetryInterceptor());
  }

  /// Конфигурация прокси для HTTP запросов
  void _configureProxy() {
    if (proxyUrl == null || proxyUrl!.isEmpty) {
      // Нет прокси, используем настройки по умолчанию
      if (kIsWeb) {
        _dio.httpClientAdapter = BrowserHttpClientAdapter();
      }
      return;
    }

    try {
      // Парсим прокси URL
      final proxyUri = Uri.parse(proxyUrl!);
      
      if (kIsWeb) {
        // Для веб платформы используем BrowserHttpClientAdapter
        _dio.httpClientAdapter = BrowserHttpClientAdapter();
        
        // Для веб используем прокси сервер или CORS прокси
        _configureWebProxy(proxyUri);
      } else {
        // Для нативных платформ используем IOHttpClientAdapter с прокси
        _dio.options.baseUrl = '';
        
        (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
          final client = HttpClient();
          client.findProxy = (uri) {
            return 'PROXY ${proxyUri.host}:${proxyUri.port}';
          };
          
          // Обработка аутентификации если есть
          if (proxyUri.userInfo.isNotEmpty) {
            final credentials = proxyUri.userInfo.split(':');
            if (credentials.length == 2) {
              client.authenticate = (uri, scheme, realm) async {
                client.addCredentials(uri, scheme, 
                  HttpClientBasicCredentials(credentials[0], credentials[1]));
                return true;
              };
            }
          }
          
          return client;
        };
      }
    } catch (e) {
      print('❌ Ошибка конфигурации прокси: $e');
      // Продолжаем без конфигурации прокси
      if (kIsWeb) {
        _dio.httpClientAdapter = BrowserHttpClientAdapter();
      }
    }
  }

  /// Конфигурация прокси для веб платформы
  void _configureWebProxy(Uri proxyUri) {
    // Прокси сервер будет обрабатывать SOCKS5 прокси соединение
    _dio.options.baseUrl = 'http://localhost:3001';
    
    // Добавляем информацию о прокси в заголовки для прокси сервера
    _dio.options.headers['X-Proxy-URL'] = proxyUrl;
    _dio.options.headers['X-Proxy-Host'] = proxyUri.host;
    _dio.options.headers['X-Proxy-Port'] = proxyUri.port.toString();
    
    if (proxyUri.userInfo.isNotEmpty) {
      final credentials = proxyUri.userInfo.split(':');
      if (credentials.length == 2) {
        _dio.options.headers['X-Proxy-User'] = credentials[0];
        _dio.options.headers['X-Proxy-Pass'] = credentials[1];
      }
    }
  }

  /// Создание интерцептора логирования
  Interceptor _createLoggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        print('🚀 Gemini Request: ${options.method} ${options.uri}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        print('✅ Gemini Response: ${response.statusCode}');
        handler.next(response);
      },
      onError: (error, handler) {
        print('❌ Gemini Error: ${error.message}');
        handler.next(error);
      },
    );
  }

  /// Создание интерцептора повтора с fallback механизмами
  Interceptor _createRetryInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) async {
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout) {
          // Пробуем с резервным прокси
          if (await _tryBackupProxy()) {
            // Повторяем запрос
            try {
              final response = await _dio.fetch<Map<String, dynamic>>(error.requestOptions);
              handler.resolve(response);
              return;
            } catch (e) {
              // Продолжаем с обработкой ошибки
            }
          }
        }
        
        handler.next(error);
      },
    );
  }

  /// Попытка использовать резервный прокси
  Future<bool> _tryBackupProxy() async {
    final nextProxy = EnvConfig.getNextBackupProxy(proxyUrl ?? '');
    if (nextProxy != null) {
      // Обновляем прокси и переконфигурируем
      final test = GeminiImageTest(
        apiKey: apiKey,
        testImagesDir: testImagesDir,
        outputDir: outputDir,
        proxyUrl: nextProxy,
        backupProxies: backupProxies,
      );
      test._initDio();
      _dio = test._dio;
      return true;
    }
    return false;
  }

  /// Генерация ключа кэша на основе изображений и промпта
  String _generateCacheKey(List<File> imageFiles) {
    final imageHashes = imageFiles.map((file) => file.path.hashCode).join('_');
    return '${_prompt.hashCode}_$imageHashes';
  }

  /// Получение кэшированного ответа
  Map<String, dynamic>? _getCachedResponse(String cacheKey) {
    try {
      final cached = _cacheBox.get(cacheKey);
      if (cached != null) {
        print('💾 Найден кэшированный ответ');
        return Map<String, dynamic>.from(cached as Map);
      }
    } catch (e) {
      print('⚠️ Ошибка чтения кэша: $e');
    }
    return null;
  }

  /// Сохранение ответа в кэш
  Future<void> _cacheResponse(String cacheKey, Map<String, dynamic> response) async {
    try {
      await _cacheBox.put(cacheKey, response);
      print('💾 Ответ сохранен в кэш');
    } catch (e) {
      print('⚠️ Ошибка сохранения в кэш: $e');
    }
  }

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
      // Инициализируем кэш
      await _initCache();
      
      // Инициализируем Dio с прокси
      _initDio();
      
      // Создаем папку для результатов
      await _createOutputDirectory();
      
      // Получаем список изображений
      final imageFiles = await _getImageFiles();
      print('📸 Найдено изображений: ${imageFiles.length}');
      
      if (imageFiles.isEmpty) {
        print('❌ Изображения не найдены в папке $testImagesDir');
        return;
      }
      
      // Проверяем кэш
      final cacheKey = _generateCacheKey(imageFiles);
      var response = _getCachedResponse(cacheKey);
      
      if (response == null) {
        // Отправляем запрос в Gemini
        print('📤 Отправка запроса в Gemini API...');
        response = await _sendToGemini(imageFiles);
        
        // Сохраняем в кэш
        await _cacheResponse(cacheKey, response);
      } else {
        print('💾 Используем кэшированный ответ');
      }
      
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


  /// Логирование взаимодействия с AI
  void _logAIInteraction(String action, Map<String, dynamic> data) {
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = {
      'timestamp': timestamp,
      'action': action,
      'model': _modelName,
      'proxy': proxyUrl ?? 'direct',
      'data': data,
    };
    
    try {
      _cacheBox.put('log_$timestamp', logEntry);
      print('📝 Лог записан: $action');
    } catch (e) {
      print('⚠️ Ошибка записи лога: $e');
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

    // Логируем запрос
    _logAIInteraction('request_sent', {
      'image_count': imageFiles.length,
      'prompt_length': _prompt.length,
      'proxy': proxyUrl ?? 'direct',
    });

    try {
      // Отправляем запрос через Dio
      final response = await _dio.post<Map<String, dynamic>>(
        '$_apiUrl?key=$apiKey',
        data: requestBody,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200) {
        _logAIInteraction('request_failed', {
          'status_code': response.statusCode,
          'error': response.data?.toString() ?? 'Unknown error',
        });
        throw Exception('Ошибка API: ${response.statusCode} - ${response.data}');
      }

      final responseData = response.data!;
      
      // Логируем успешный ответ
      _logAIInteraction('response_received', {
        'status_code': response.statusCode,
        'response_size': response.data.toString().length,
        'candidates_count': (responseData['candidates'] as List?)?.length ?? 0,
      });

      return responseData;
    } catch (e) {
      _logAIInteraction('request_failed', {
        'error': e.toString(),
        'proxy': proxyUrl ?? 'direct',
      });
      rethrow;
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
    for (final part in parts) {
      if (part['text'] != null) {
        // Текстовая часть
        final text = part['text'] as String;
        textParts.add(text);
        print('📝 Получен текст: ${text.length} символов');
      } else if (part['inline_data'] != null) {
        // Изображение
        final inlineData = part['inline_data'] as Map<String, dynamic>;
        final imageData = inlineData['data'] as String;
        final mimeType = inlineData['mime_type'] as String;
        
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
  print('🎨 Тест Gemini Image Generation');
  print('================================');
  print('');

  // Получаем конфигурацию из EnvConfig
  final apiKey = EnvConfig.googleApiKey;
  if (apiKey.isEmpty) {
    print('❌ Ошибка: Не найден GOOGLE_API_KEY в переменных окружения');
    print('');
    print('💡 Для запуска теста установите переменную окружения:');
    print('   set GOOGLE_API_KEY=your_api_key_here');
    print('');
    print('🔑 Получить API ключ можно здесь: https://aistudio.google.com/app/apikey');
    return;
  }

  // Получаем настройки прокси
  final proxyUrl = EnvConfig.getCurrentProxy();
  final backupProxies = EnvConfig.backupProxies;

  // Определяем пути
  final currentDir = Directory.current.path;
  final testImagesDir = path.join(currentDir, 'test-images');
  final outputDir = path.join(testImagesDir, 'test-gemini');

  // Создаем и запускаем тест
  final test = GeminiImageTest(
    apiKey: apiKey,
    testImagesDir: testImagesDir,
    outputDir: outputDir,
    proxyUrl: proxyUrl.isNotEmpty ? proxyUrl : null,
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
