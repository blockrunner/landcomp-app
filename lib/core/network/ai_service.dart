/// AI Service for OpenAI and Google Gemini integration
/// 
/// This service handles AI API calls with proxy support,
/// fallback mechanisms, and error handling.
library;

import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio/browser.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:landcomp_app/core/config/env_config.dart';
import 'package:landcomp_app/core/ai/agent_selector.dart';
import 'package:landcomp_app/features/chat/domain/entities/ai_agent.dart';
import 'package:landcomp_app/features/chat/domain/entities/image_generation_response.dart';
import 'package:landcomp_app/features/chat/domain/entities/message.dart';
import 'package:landcomp_app/features/chat/domain/entities/attachment.dart';

/// AI Service for handling AI API requests
class AIService {
  AIService._();

  static final AIService _instance = AIService._();
  static AIService get instance => _instance;

  late Dio _dio;
  String _currentProxy = '';
  String _currentGoogleApiKey = '';
  String _currentOpenAIApiKey = '';

  /// Initialize the AI service
  Future<void> initialize() async {
    print('🔧 Initializing AIService...');
    
    _currentProxy = EnvConfig.getCurrentProxy();
    _currentGoogleApiKey = EnvConfig.googleApiKey;
    _currentOpenAIApiKey = EnvConfig.openaiApiKey;

    print('   Proxy configured: ${_currentProxy.isNotEmpty ? '✅' : '❌'}');
    print('   Google API key configured: ${_currentGoogleApiKey.isNotEmpty ? '✅' : '❌'}');
    print('   OpenAI API key configured: ${EnvConfig.isOpenAIConfigured ? '✅' : '❌'}');
    print('   Platform: ${kIsWeb ? 'Web' : 'Native'}');

    _dio = Dio();
    
    // Configure proxy if available
    if (_currentProxy.isNotEmpty) {
      print('   Configuring proxy...');
      _configureProxy();
    } else {
      print('   No proxy configured, using default settings');
      if (kIsWeb) {
        _dio.httpClientAdapter = BrowserHttpClientAdapter();
      }
    }

    // Configure timeouts
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 60);
    _dio.options.sendTimeout = const Duration(seconds: 30);

    // Add interceptors
    _dio.interceptors.add(_createLoggingInterceptor());
    _dio.interceptors.add(_createRetryInterceptor());
    
    print('✅ AIService initialized successfully');
  }

  /// Configure proxy for HTTP requests
  void _configureProxy() {
    if (_currentProxy.isEmpty) {
      // No proxy configured, use default settings
      if (kIsWeb) {
        _dio.httpClientAdapter = BrowserHttpClientAdapter();
      }
      return;
    }

    try {
      // Parse proxy URL
      final proxyUri = Uri.parse(_currentProxy);
      
      if (kIsWeb) {
        // For web platform, we cannot use IOHttpClientAdapter
        // Instead, we'll use BrowserHttpClientAdapter and handle proxy differently
        _dio.httpClientAdapter = BrowserHttpClientAdapter();
        
        // For web, we need to use a proxy server or CORS proxy
        // Add proxy prefix to base URLs
        _configureWebProxy(proxyUri);
      } else {
        // For native platforms, use IOHttpClientAdapter with proxy
        // Reset baseUrl for native platforms
        _dio.options.baseUrl = '';
        
        (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
          final client = HttpClient();
          client.findProxy = (uri) {
            return 'PROXY ${proxyUri.host}:${proxyUri.port}';
          };
          
          // Handle authentication if present
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
      print('❌ Error configuring proxy: $e');
      // Continue without proxy configuration
      if (kIsWeb) {
        _dio.httpClientAdapter = BrowserHttpClientAdapter();
      }
    }
  }

  /// Configure proxy for web platform
  void _configureWebProxy(Uri proxyUri) {
    // For web, we'll use a local proxy server
    // The proxy server will handle the SOCKS5 proxy connection
    _dio.options.baseUrl = 'http://localhost:3001';
    
    // Add proxy information to headers for the proxy server
    _dio.options.headers['X-Proxy-URL'] = _currentProxy;
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

  /// Create logging interceptor
  Interceptor _createLoggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        print('🚀 AI Request: ${options.method} ${options.uri}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        print('✅ AI Response: ${response.statusCode}');
        handler.next(response);
      },
      onError: (error, handler) {
        print('❌ AI Error: ${error.message}');
        handler.next(error);
      },
    );
  }

  /// Create retry interceptor with fallback mechanisms
  Interceptor _createRetryInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) async {
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout) {
          // Try with backup proxy
          if (await _tryBackupProxy()) {
            // Retry the request
            try {
              final response = await _dio.fetch<Map<String, dynamic>>(error.requestOptions);
              handler.resolve(response);
              return;
            } catch (e) {
              // Continue with error handling
            }
          }
        }
        
        handler.next(error);
      },
    );
  }

  /// Try backup proxy
  Future<bool> _tryBackupProxy() async {
    final nextProxy = EnvConfig.getNextBackupProxy(_currentProxy);
    if (nextProxy != null) {
      _currentProxy = nextProxy;
      _configureProxy();
      return true;
    }
    return false;
  }

  /// Send message to OpenAI
  Future<String> sendToOpenAI({
    required String message,
    required String systemPrompt,
    String model = 'gpt-4o', // Changed from 'gpt-4' to 'gpt-4o' for Vision API support
    List<Message>? conversationHistory,
    int maxHistoryMessages = 20,
  }) async {
    if (!EnvConfig.isOpenAIConfigured) {
      throw Exception('OpenAI API key not configured');
    }

    try {
      const url = kIsWeb ? '/proxy/openai/v1/chat/completions' : 'https://api.openai.com/v1/chat/completions';
      
      final response = await _dio.post<Map<String, dynamic>>(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${EnvConfig.openaiApiKey}',
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
        data: {
          'model': model,
          'messages': await _buildOpenAIMessages(systemPrompt, message, conversationHistory, maxHistoryMessages),
          'max_tokens': 4000, // Increased for detailed responses
          'temperature': 0.7,
          'stream': false,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data!;
        final choices = data['choices'] as List<dynamic>;
        if (choices.isNotEmpty) {
          final messageObj = choices[0]['message'] as Map<String, dynamic>;
          final content = messageObj['content'] as String?;
          if (content != null && content.isNotEmpty) {
            return content;
          }
        }
        throw Exception('Empty response from OpenAI');
      } else {
        final errorData = response.data;
        final errorMessage = errorData?['error']?['message'] ?? 'Unknown error';
        throw Exception('OpenAI API error (${response.statusCode}): $errorMessage');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        throw Exception('OpenAI rate limit exceeded. Please try again later.');
      } else if (e.response?.statusCode == 401) {
        throw Exception('OpenAI API key is invalid or expired.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('OpenAI API access forbidden. Check your API key permissions.');
      } else if (e.response?.statusCode == 400) {
        final errorData = e.response?.data as Map<String, dynamic>?;
        final errorMessage = errorData?['error']?['message'] ?? 'Bad request';
        throw Exception('OpenAI API bad request: $errorMessage');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Request timeout. The server took too long to respond.');
      } else {
        throw Exception('OpenAI API error: ${e.message}');
      }
    }
  }

  /// Build messages array for OpenAI API with conversation history
  Future<List<Map<String, dynamic>>> _buildOpenAIMessages(
    String systemPrompt,
    String message,
    List<Message>? conversationHistory,
    int maxHistoryMessages,
  ) async {
    // Detect user language and enhance system prompt
    final enhancedSystemPrompt = _enhanceSystemPromptWithLanguage(systemPrompt, message, conversationHistory);
    
    final messages = <Map<String, dynamic>>[
      {'role': 'system', 'content': enhancedSystemPrompt},
    ];
    
    // Add conversation history (last N messages)
    if (conversationHistory != null) {
      final relevantHistory = conversationHistory
          .where((m) => !m.isTyping && !m.isError)
          .toList()
          .reversed
          .take(maxHistoryMessages)
          .toList()
          .reversed;
      
      // Find the LAST message with images (most recent)
      Message? lastImageMessage;
      
      for (final msg in relevantHistory.toList().reversed) {
        if (msg.attachments?.any((Attachment a) => a.isImage) ?? false) {
          lastImageMessage = msg;
          break;
        }
      }
      
      for (final msg in relevantHistory) {
        // Check if message has image attachments
        final hasImages = msg.attachments?.any((a) => a.isImage) ?? false;
        
        // Only include images for THE LAST message with images (up to 5 images)
        if (hasImages && msg == lastImageMessage) {
          // Build multipart content with text and ALL images (like in sendImageToOpenAI)
          final contentParts = <Map<String, dynamic>>[];
          
          // Add text content if not empty
          if (msg.content.isNotEmpty) {
            contentParts.add({
              'type': 'text',
              'text': msg.content,
            });
          }
          
          // Add ALL images from this message (up to 5) with compression
          final imageAttachments = msg.attachments?.where((a) => a.isImage).take(5).toList() ?? [];
          
          print('📸 Adding ${imageAttachments.length} images to OpenAI request');
          
          for (final attachment in imageAttachments) {
            if (attachment.data != null) {
              // Compress image before sending (target 25KB for OpenAI compatibility)
              final compressedData = await _compressImage(attachment.data!, maxSizeKb: 25);
              final base64Image = base64Encode(compressedData);
              print('📸 Final image size: ${compressedData.length} bytes (base64: ${base64Image.length} chars)');
              
              contentParts.add({
                'type': 'image_url',
                'image_url': {
                  'url': 'data:image/jpeg;base64,$base64Image',
                },
              });
            }
          }
          
          messages.add({
            'role': msg.type == MessageType.user ? 'user' : 'assistant',
            'content': contentParts,
          });
        } else {
          // Text-only message (or old image message)
          messages.add({
            'role': msg.type == MessageType.user ? 'user' : 'assistant',
            'content': msg.content,
          });
        }
      }
    }
    
    // Add current message (text-only, images should be in history)
    messages.add({'role': 'user', 'content': message});
    
    return messages;
  }

  /// Enhance system prompt with language detection
  String _enhanceSystemPromptWithLanguage(
    String systemPrompt,
    String currentMessage,
    List<Message>? conversationHistory,
  ) {
    // Detect language from current message and conversation history
    final detectedLanguage = _detectUserLanguage(currentMessage, conversationHistory);
    
    if (detectedLanguage == 'ru') {
      // Add Russian language instruction
      return '''$systemPrompt

ВАЖНО: 
1. Пользователь пишет на русском языке. Отвечай ТОЛЬКО на русском языке. Используй русские термины и учитывай российский климат и условия.
2. Давай ПОДРОБНЫЕ и РАЗВЕРНУТЫЕ ответы. Если пользователь просит больше деталей, предоставь максимально детальную информацию.
3. Учитывай весь контекст предыдущих сообщений и изображений в разговоре.
4. Если пользователь прислал изображение ранее, помни о нем и учитывай его в своих ответах.''';
    } else {
      // Keep English as default
      return '''$systemPrompt

IMPORTANT: 
1. Respond in the same language as the user. If the user writes in Russian, respond in Russian. If in English, respond in English.
2. Provide DETAILED and COMPREHENSIVE answers. If the user asks for more details, provide maximum detailed information.
3. Consider the entire context of previous messages and images in the conversation.
4. If the user sent an image earlier, remember it and take it into account in your answers.''';
    }
  }

  /// Detect user language from message content
  String _detectUserLanguage(String message, List<Message>? conversationHistory) {
    // Check current message for Russian text
    if (_containsRussianText(message)) {
      return 'ru';
    }
    
    // Check conversation history for Russian text
    if (conversationHistory != null) {
      for (final msg in conversationHistory) {
        if (msg.type == MessageType.user && _containsRussianText(msg.content)) {
          return 'ru';
        }
      }
    }
    
    return 'en'; // Default to English
  }

  /// Check if text contains Russian characters
  bool _containsRussianText(String text) {
    // Russian Unicode range: \u0400-\u04FF
    return RegExp(r'[\u0400-\u04FF]').hasMatch(text);
  }

  /// Compress image to reduce size for API requests
  /// Targets max 100KB per image for OpenAI compatibility
  Future<Uint8List> _compressImage(Uint8List imageData, {int maxSizeKb = 100}) async {
    try {
      final image = img.decodeImage(imageData);
      if (image == null) {
        print('⚠️ Could not decode image, returning original');
        return imageData;
      }

      final originalSizeKb = imageData.length / 1024;
      print('📸 Original image: ${image.width}x${image.height}, ${originalSizeKb.toStringAsFixed(1)}KB');

      // If already small enough, return as-is
      if (originalSizeKb <= maxSizeKb) {
        print('✅ Image already small enough');
        return imageData;
      }

      // Calculate resize ratio to target size
      // Assuming JPEG compression ratio of ~10:1
      final targetPixels = (maxSizeKb * 1024 * 10) / 3; // RGB = 3 bytes per pixel
      final currentPixels = image.width * image.height;
      final ratio = sqrt(targetPixels / currentPixels);
      
      final newWidth = (image.width * ratio).toInt();
      final newHeight = (image.height * ratio).toInt();

      print('📸 Resizing to ${newWidth}x${newHeight}');
      final resized = img.copyResize(image, width: newWidth, height: newHeight);

      // Encode as JPEG with quality 85
      final compressed = Uint8List.fromList(img.encodeJpg(resized, quality: 85));
      final compressedSizeKb = compressed.length / 1024;

      print('✅ Compressed: ${compressedSizeKb.toStringAsFixed(1)}KB (${((1 - compressedSizeKb / originalSizeKb) * 100).toStringAsFixed(1)}% reduction)');
      
      return compressed;
    } catch (e) {
      print('⚠️ Image compression failed: $e, returning original');
      return imageData;
    }
  }

  /// Send message to Google Gemini
  Future<String> sendToGemini({
    required String message,
    required String systemPrompt,
    String model = 'gemini-2.0-flash-exp',
    List<Message>? conversationHistory,
    int maxHistoryMessages = 20,
  }) async {
    if (!EnvConfig.isGoogleConfigured) {
      throw Exception('Google API key not configured');
    }

    try {
      final url = kIsWeb 
        ? '/proxy/gemini/v1beta/models/$model:generateContent'
        : 'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent';
      
      final response = await _dio.post<Map<String, dynamic>>(
        url,
        queryParameters: {
          'key': _currentGoogleApiKey,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
        data: {
          'contents': _buildGeminiContents(systemPrompt, message, conversationHistory, maxHistoryMessages),
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1000,
          },
        },
      );

      if (response.statusCode == 200) {
        final data = response.data!;
        final candidates = data['candidates'] as List<dynamic>;
        if (candidates.isNotEmpty) {
          final candidate = candidates[0] as Map<String, dynamic>;
          final content = candidate['content'] as Map<String, dynamic>?;
          if (content != null) {
            final parts = content['parts'] as List<dynamic>?;
            if (parts != null && parts.isNotEmpty) {
              final text = parts[0]['text'] as String?;
              if (text != null && text.isNotEmpty) {
                return text;
              }
            }
          }
        }
        throw Exception('Empty response from Google Gemini');
      } else {
        final errorData = response.data;
        final errorMessage = errorData?['error']?['message'] ?? 'Unknown error';
        throw Exception('Google Gemini API error (${response.statusCode}): $errorMessage');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        // Try with fallback key
        if (await _tryFallbackGoogleKey()) {
          return sendToGemini(
            message: message,
            systemPrompt: systemPrompt,
            model: model,
          );
        }
        throw Exception('Google Gemini rate limit exceeded. Please try again later.');
      } else if (e.response?.statusCode == 400) {
        final errorData = e.response?.data as Map<String, dynamic>?;
        final errorMessage = errorData?['error']?['message'] as String? ?? 'Bad request';
        if (errorMessage.contains('RESOURCE_EXHAUSTED') || errorMessage.contains('QUOTA_EXCEEDED')) {
          // Try with fallback key
          if (await _tryFallbackGoogleKey()) {
            return sendToGemini(
              message: message,
              systemPrompt: systemPrompt,
              model: model,
            );
          }
        }
        throw Exception('Google Gemini API bad request: $errorMessage');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Google Gemini API key is invalid or expired.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Google Gemini API access forbidden. Check your API key permissions.');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Request timeout. The server took too long to respond.');
      } else {
        throw Exception('Google Gemini API error: ${e.message}');
      }
    }
  }

  /// Build contents array for Gemini API with conversation history
  List<Map<String, dynamic>> _buildGeminiContents(
    String systemPrompt,
    String message,
    List<Message>? conversationHistory,
    int maxHistoryMessages,
  ) {
    // Detect user language and enhance system prompt
    final enhancedSystemPrompt = _enhanceSystemPromptWithLanguage(systemPrompt, message, conversationHistory);
    
    final contents = <Map<String, dynamic>>[];
    
    // Add conversation history
    if (conversationHistory != null) {
      final relevantHistory = conversationHistory
          .where((m) => !m.isTyping && !m.isError)
          .toList()
          .reversed
          .take(maxHistoryMessages)
          .toList()
          .reversed;
      
      for (final msg in relevantHistory) {
        contents.add({
          'role': msg.type == MessageType.user ? 'user' : 'model',
          'parts': [{'text': msg.content}],
        });
      }
    }
    
    // Add current message with enhanced system prompt
    contents.add({
      'role': 'user',
      'parts': [{'text': '$enhancedSystemPrompt\n\nUser: $message'}],
    });
    
    return contents;
  }

  /// Try fallback Google API key
  Future<bool> _tryFallbackGoogleKey() async {
    final nextKey = EnvConfig.getNextGoogleApiKey(_currentGoogleApiKey);
    if (nextKey != null) {
      _currentGoogleApiKey = nextKey;
      return true;
    }
    return false;
  }

  /// Send images with text prompt to OpenAI Vision
  Future<String> sendImageToOpenAI({
    required String prompt,
    required List<Uint8List> images,
    String model = 'gpt-4o',
  }) async {
    if (!EnvConfig.isOpenAIConfigured) {
      throw Exception('OpenAI API key not configured');
    }

    if (images.isEmpty) {
      throw Exception('No images provided');
    }

    if (images.length > 5) {
      throw Exception('Maximum 5 images allowed');
    }

    try {
      const url = kIsWeb
          ? '/proxy/openai/v1/chat/completions'
          : 'https://api.openai.com/v1/chat/completions';

      // Prepare content with images
      final content = <Map<String, dynamic>>[
        {
          'type': 'text',
          'text': prompt,
        }
      ];

      // Add images as base64
      for (final imageBytes in images) {
        final base64Image = base64Encode(imageBytes);
        content.add({
          'type': 'image_url',
          'image_url': {
            'url': 'data:image/jpeg;base64,$base64Image',
          },
        });
      }

      final response = await _dio.post<Map<String, dynamic>>(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_currentOpenAIApiKey',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
        data: {
          'model': model,
          'messages': [
            {
              'role': 'user',
              'content': content,
            }
          ],
          'max_tokens': 1000,
          'temperature': 0.7,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data!;
        final choices = data['choices'] as List<dynamic>;
        if (choices.isNotEmpty) {
          final choice = choices[0] as Map<String, dynamic>;
          final message = choice['message'] as Map<String, dynamic>;
          final content = message['content'] as String?;
          if (content != null && content.isNotEmpty) {
            return content;
          }
        }
        throw Exception('Empty response from OpenAI');
      } else {
        final errorData = response.data;
        final errorMessage = errorData?['error']?['message'] ?? 'Unknown error';
        throw Exception('OpenAI API error (${response.statusCode}): $errorMessage');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        throw Exception('OpenAI rate limit exceeded. Please try again later.');
      } else if (e.response?.statusCode == 400) {
        final errorData = e.response?.data as Map<String, dynamic>?;
        final errorMessage = errorData?['error']?['message'] as String? ?? 'Bad request';
        throw Exception('OpenAI API bad request: $errorMessage');
      } else if (e.response?.statusCode == 401) {
        throw Exception('OpenAI API key is invalid or expired.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('OpenAI API access forbidden. Check your API key permissions.');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Request timeout. The server took too long to respond.');
      } else {
        throw Exception('OpenAI API error: ${e.message}');
      }
    }
  }

  /// Send images with text prompt to Gemini 2.5 Flash Image
  Future<String> sendImageToGemini({
    required String prompt,
    required List<Uint8List> images,
    String model = 'gemini-2.0-flash',
  }) async {
    if (!EnvConfig.isGoogleConfigured) {
      throw Exception('Google API key not configured');
    }

    if (images.isEmpty) {
      throw Exception('No images provided');
    }

    if (images.length > 5) {
      throw Exception('Maximum 5 images allowed');
    }

    try {
      final url = kIsWeb 
        ? '/proxy/gemini/v1beta/models/$model:generateContent'
        : 'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent';
      
      // Prepare content parts
      final parts = <Map<String, dynamic>>[
        {'text': prompt}
      ];

      // Add images as base64
      for (final imageBytes in images) {
        final base64Image = base64Encode(imageBytes);
        parts.add({
          'inline_data': {
            'mime_type': 'image/jpeg',
            'data': base64Image,
          }
        });
      }

      final response = await _dio.post<Map<String, dynamic>>(
        url,
        queryParameters: {
          'key': _currentGoogleApiKey,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
        data: {
          'contents': [
            {
              'role': 'user',
              'parts': parts,
            },
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1000,
          },
        },
      );

      if (response.statusCode == 200) {
        final data = response.data!;
        final candidates = data['candidates'] as List<dynamic>;
        if (candidates.isNotEmpty) {
          final candidate = candidates[0] as Map<String, dynamic>;
          final content = candidate['content'] as Map<String, dynamic>?;
          if (content != null) {
            final parts = content['parts'] as List<dynamic>?;
            if (parts != null && parts.isNotEmpty) {
              final text = parts[0]['text'] as String?;
              if (text != null && text.isNotEmpty) {
                return text;
              }
            }
          }
        }
        throw Exception('Empty response from Google Gemini');
      } else {
        final errorData = response.data;
        final errorMessage = errorData?['error']?['message'] ?? 'Unknown error';
        throw Exception('Google Gemini API error (${response.statusCode}): $errorMessage');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        // Try with fallback key
        if (await _tryFallbackGoogleKey()) {
          return sendImageToGemini(
            prompt: prompt,
            images: images,
            model: model,
          );
        }
        throw Exception('Google Gemini rate limit exceeded. Please try again later.');
      } else if (e.response?.statusCode == 400) {
        final errorData = e.response?.data as Map<String, dynamic>?;
        final errorMessage = errorData?['error']?['message'] as String? ?? 'Bad request';
        if (errorMessage.contains('RESOURCE_EXHAUSTED') || errorMessage.contains('QUOTA_EXCEEDED')) {
          // Try with fallback key
          if (await _tryFallbackGoogleKey()) {
            return sendImageToGemini(
              prompt: prompt,
              images: images,
              model: model,
            );
          }
        }
        throw Exception('Google Gemini API bad request: $errorMessage');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Google Gemini API key is invalid or expired.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Google Gemini API access forbidden. Check your API key permissions.');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Request timeout. The server took too long to respond.');
      } else {
        throw Exception('Google Gemini API error: ${e.message}');
      }
    }
  }

  /// Send images with text prompt to Gemini 2.5 Flash Image for generation
  Future<ImageGenerationResponse> sendImageGenerationToGemini({
    required String prompt,
    required List<Uint8List> images,
    String model = 'gemini-2.5-flash-image-preview',
  }) async {
    if (!EnvConfig.isGoogleConfigured) {
      throw Exception('Google API key not configured');
    }

    if (images.isEmpty) {
      throw Exception('No images provided');
    }

    if (images.length > 5) {
      throw Exception('Maximum 5 images allowed');
    }

    try {
      final url = kIsWeb 
        ? '/proxy/gemini/v1beta/models/$model:generateContent'
        : 'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent';
      
      // Prepare content parts - start with text prompt
      final parts = <Map<String, dynamic>>[
        {'text': prompt}
      ];

      // Add input images as base64
      for (final imageBytes in images) {
        final base64Image = base64Encode(imageBytes);
        parts.add({
          'inline_data': {
            'mime_type': 'image/jpeg',
            'data': base64Image,
          }
        });
      }

      print('🎨 Sending image generation request to Gemini');
      print('🎨 Model: $model');
      print('🎨 Prompt: ${prompt.length} characters');
      print('🎨 Input images: ${images.length}');

      final response = await _dio.post<Map<String, dynamic>>(
        url,
        queryParameters: {
          'key': _currentGoogleApiKey,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
        data: {
          'contents': [
            {
              'parts': parts,
            },
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 2000, // Increased for longer responses
          },
        },
      );

      if (response.statusCode == 200) {
        final data = response.data!;
        print('🎨 Received response from Gemini image generation');
        
        final candidates = data['candidates'] as List<dynamic>?;
        if (candidates == null || candidates.isEmpty) {
          throw Exception('No candidates in response');
        }

        final candidate = candidates.first as Map<String, dynamic>;
        final content = candidate['content'] as Map<String, dynamic>?;
        if (content == null) {
          throw Exception('No content in response');
        }

        final responseParts = content['parts'] as List<dynamic>?;
        if (responseParts == null || responseParts.isEmpty) {
          throw Exception('No parts in response content');
        }

        // Process response parts
        final textParts = <String>[];
        final generatedImages = <Uint8List>[];
        final imageMimeTypes = <String>[];

        print('🎨 Processing ${responseParts.length} response parts');

        for (var i = 0; i < responseParts.length; i++) {
          final part = responseParts[i] as Map<String, dynamic>;
          
          if (part['text'] != null) {
            // Text response
            final text = part['text'] as String;
            textParts.add(text);
            print('🎨 Text part ${i + 1}: ${text.length} characters');
          } else if (part['inline_data'] != null || part['inlineData'] != null) {
            // Generated image
            final inlineData = (part['inline_data'] ?? part['inlineData']) as Map<String, dynamic>;
            final imageData = inlineData['data'] as String;
            final mimeType = (inlineData['mime_type'] ?? inlineData['mimeType']) as String;
            
            // Decode base64 image
            final imageBytes = base64Decode(imageData);
            generatedImages.add(imageBytes);
            imageMimeTypes.add(mimeType);
            
            print('🎨 Generated image ${i + 1}: ${imageBytes.length} bytes, type: $mimeType');
          }
        }

        // Combine text parts
        final fullTextResponse = textParts.join('\n\n');
        
        print('🎨 Generation complete:');
        print('🎨   - Text response: ${fullTextResponse.length} characters');
        print('🎨   - Generated images: ${generatedImages.length}');

        return ImageGenerationResponse.withImages(
          text: fullTextResponse,
          images: generatedImages,
          mimeTypes: imageMimeTypes,
        );

      } else {
        final errorData = response.data;
        final errorMessage = errorData?['error']?['message'] ?? 'Unknown error';
        throw Exception('Google Gemini API error (${response.statusCode}): $errorMessage');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        // Try with fallback key
        if (await _tryFallbackGoogleKey()) {
          return sendImageGenerationToGemini(
            prompt: prompt,
            images: images,
            model: model,
          );
        }
        throw Exception('Google Gemini rate limit exceeded. Please try again later.');
      } else if (e.response?.statusCode == 400) {
        final errorData = e.response?.data as Map<String, dynamic>?;
        final errorMessage = errorData?['error']?['message'] as String? ?? 'Bad request';
        if (errorMessage.contains('RESOURCE_EXHAUSTED') || errorMessage.contains('QUOTA_EXCEEDED')) {
          // Try with fallback key
          if (await _tryFallbackGoogleKey()) {
            return sendImageGenerationToGemini(
              prompt: prompt,
              images: images,
              model: model,
            );
          }
        }
        throw Exception('Google Gemini API bad request: $errorMessage');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Google Gemini API key is invalid or expired.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Google Gemini API access forbidden. Check your API key permissions.');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Request timeout. The server took too long to respond.');
      } else {
        throw Exception('Google Gemini API error: ${e.message}');
      }
    }
  }

  /// Send message with automatic provider selection
  Future<String> sendMessage({
    required String message,
    required String systemPrompt,
    String preferredProvider = 'openai',
    List<Message>? conversationHistory,
  }) async {
    try {
      if (preferredProvider == 'openai' && EnvConfig.isOpenAIConfigured) {
        return await sendToOpenAI(
          message: message,
          systemPrompt: systemPrompt,
          conversationHistory: conversationHistory,
        );
      } else if (preferredProvider == 'gemini' && EnvConfig.isGoogleConfigured) {
        return await sendToGemini(
          message: message,
          systemPrompt: systemPrompt,
          conversationHistory: conversationHistory,
        );
      } else {
        // Try both providers
        if (EnvConfig.isOpenAIConfigured) {
          return await sendToOpenAI(
            message: message,
            systemPrompt: systemPrompt,
            conversationHistory: conversationHistory,
          );
        } else if (EnvConfig.isGoogleConfigured) {
          return await sendToGemini(
            message: message,
            systemPrompt: systemPrompt,
            conversationHistory: conversationHistory,
          );
        } else {
          throw Exception('No AI providers configured');
        }
      }
    } catch (e) {
      // Try fallback provider
      if (preferredProvider == 'openai' && EnvConfig.isGoogleConfigured) {
        return sendToGemini(
          message: message,
          systemPrompt: systemPrompt,
          conversationHistory: conversationHistory,
        );
      } else if (preferredProvider == 'gemini' && EnvConfig.isOpenAIConfigured) {
        return sendToOpenAI(
          message: message,
          systemPrompt: systemPrompt,
          conversationHistory: conversationHistory,
        );
      } else {
        rethrow;
      }
    }
  }

  /// Send message with smart agent selection
  Future<SmartAIResponse> sendMessageWithSmartSelection({
    required String message,
    String preferredProvider = 'openai',
    List<Message>? conversationHistory,
  }) async {
    try {
      // First, analyze the message to select appropriate agent
      final selectionResult = await AgentSelector.instance.selectAgent(message);
      
      if (selectionResult.isOutOfScope) {
        return SmartAIResponse.outOfScope(
          message: selectionResult.outOfScopeMessage!,
        );
      }
      
      if (!selectionResult.isSuccess || selectionResult.agent == null) {
        throw Exception('Failed to select appropriate agent');
      }
      
      final selectedAgent = selectionResult.agent!;
      final systemPrompt = selectedAgent.systemPrompt;
      
      // Send message to AI with selected agent's system prompt
      final aiResponse = await sendMessage(
        message: message,
        systemPrompt: systemPrompt,
        preferredProvider: preferredProvider,
        conversationHistory: conversationHistory,
      );
      
      return SmartAIResponse.success(
        message: aiResponse,
        agent: selectedAgent,
        confidence: selectionResult.confidence ?? 0.5,
      );
      
    } catch (e) {
      return SmartAIResponse.error(
        message: 'Произошла ошибка при обработке запроса: ${e}',
      );
    }
  }

  /// Analyze image with OpenAI Vision and detect user intent
  /// Returns ImageGenerationResponse with analysis data
  Future<ImageGenerationResponse> analyzeImageWithVision({
    required List<Uint8List> images,
    required String userQuestion,
    List<Message>? conversationHistory,
  }) async {
    print('🔍🎯 Analyzing image and detecting intent...');
    
    final contextSummary = _buildConversationSummary(conversationHistory);
    
    final analysisPrompt = '''
Проанализируй загруженное изображение и определи намерение пользователя.

КОНТЕКСТ РАЗГОВОРА:
$contextSummary

ВОПРОС ПОЛЬЗОВАТЕЛЯ:
$userQuestion

ЗАДАЧИ:
1. Подробно опиши что изображено (ландшафт, растения, освещение, почва)
2. Определи намерение: "consultation", "visualization" или "unclear"
3. Оцени уверенность (0.0-1.0)
4. Объясни почему выбрано такое намерение
5. Оцени пригодность участка для обсуждаемого
6. Дай рекомендации

ВАЖНО: Отвечай ТОЛЬКО валидным JSON без markdown форматирования:
{
  "image_analysis": "подробное описание изображения",
  "user_intent": "consultation|visualization|unclear",
  "confidence": 0.8,
  "reasoning": "объяснение выбора намерения",
  "suitability": "оценка пригодности участка",
  "recommendations": ["рекомендация 1", "рекомендация 2"]
}

НЕ используй ```json или ``` блоки. Только чистый JSON.
''';

    try {
      // Prepare images for OpenAI Vision
      final imageContents = images.map((imageData) {
        final base64Image = base64Encode(imageData);
        return {
          'type': 'image_url',
          'image_url': {
            'url': 'data:image/jpeg;base64,$base64Image',
          },
        };
      }).toList();

      final messages = [
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': analysisPrompt},
            ...imageContents,
          ],
        },
      ];

      // Try different models in order of preference
      final models = ['gpt-4o', 'gpt-4o-mini', 'gpt-4-vision-preview'];
      Response<Map<String, dynamic>>? response;
      String? usedModel;

      const url = kIsWeb ? '/proxy/openai/v1/chat/completions' : 'https://api.openai.com/v1/chat/completions';
      
      for (final model in models) {
        try {
          final requestBody = {
            'model': model,
            'messages': messages,
            'max_tokens': 2000,
            'temperature': 0.1,
          };

          print('🚀 AI Request: POST $url with model: $model');
          response = await _dio.post<Map<String, dynamic>>(
            url,
            data: requestBody,
            options: Options(
              headers: {
                'Authorization': 'Bearer $_currentOpenAIApiKey',
                'Content-Type': 'application/json',
              },
            ),
          );
          
          usedModel = model;
          print('✅ AI Response: ${response.statusCode} with model: $model');
          break; // Success, exit the loop
          
        } catch (e) {
          print('❌ Model $model failed: $e');
          if (model == models.last) {
            rethrow; // If all models failed, throw the last error
          }
          // Continue to next model
        }
      }

      if (response == null) {
        throw Exception('All Vision models failed');
      }
      
      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final choices = responseData['choices'] as List<dynamic>;
        
        if (choices.isNotEmpty) {
          final choice = choices.first as Map<String, dynamic>;
          final message = choice['message'] as Map<String, dynamic>;
          final content = message['content'] as String;
          
          print('🔍 Vision analysis received: ${content.length} characters using model: $usedModel');
          
          // Clean and parse JSON response (remove markdown formatting)
          final cleanedContent = _cleanJsonResponse(content);
          print('🧹 Cleaned JSON: ${cleanedContent.length} characters');
          
          // Parse JSON response
          final jsonData = jsonDecode(cleanedContent) as Map<String, dynamic>;
          
          // ИСПОЛЬЗУЕМ СУЩЕСТВУЮЩУЮ МОДЕЛЬ с новыми полями!
          return ImageGenerationResponse.fromAnalysis(
            imageAnalysis: jsonData['image_analysis'] as String,
            userIntent: jsonData['user_intent'] as String,
            intentConfidence: (jsonData['confidence'] as num).toDouble(),
            intentReasoning: jsonData['reasoning'] as String,
            suitability: jsonData['suitability'] as String,
            recommendations: (jsonData['recommendations'] as List)
                .map((e) => e as String)
                .toList(),
          );
        }
      }
      
      throw Exception('Invalid response from OpenAI Vision API');
    } catch (e) {
      print('❌ Error in analyzeImageWithVision: $e');
      
      // Fallback: Provide basic analysis without image processing
      print('🔄 Falling back to basic text analysis...');
      
      return ImageGenerationResponse.fromAnalysis(
        imageAnalysis: 'Изображение участка получено, но детальный анализ недоступен из-за технических ограничений.',
        userIntent: 'unclear',
        intentConfidence: 0.3,
        intentReasoning: 'Не удалось проанализировать изображение, намерение пользователя неясно.',
        suitability: 'Требуется дополнительная информация для оценки пригодности участка.',
        recommendations: [
          'Опишите участок подробнее: освещение, тип почвы, размеры',
          'Укажите какие растения вас интересуют',
          'Расскажите о ваших предпочтениях и целях'
        ],
        textResponse: 'К сожалению, не удалось проанализировать изображение. Пожалуйста, опишите ваш участок подробнее, и я смогу дать рекомендации по посадке растений.',
      );
    }
  }

  /// Clean JSON response from markdown formatting
  String _cleanJsonResponse(String content) {
    // Remove markdown code blocks
    String cleaned = content.trim();
    
    // Remove ```json and ``` markers
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }
    
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }
    
    // Remove any leading/trailing whitespace
    cleaned = cleaned.trim();
    
    // If still not valid JSON, try to extract JSON from the content
    if (!cleaned.startsWith('{') && !cleaned.startsWith('[')) {
      // Look for JSON object in the content
      final jsonStart = cleaned.indexOf('{');
      final jsonEnd = cleaned.lastIndexOf('}');
      
      if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
        cleaned = cleaned.substring(jsonStart, jsonEnd + 1);
      }
    }
    
    return cleaned;
  }

  /// Build conversation summary
  String _buildConversationSummary(List<Message>? history) {
    if (history == null || history.isEmpty) {
      return 'Начало нового разговора';
    }
    
    final summary = StringBuffer();
    final recentMessages = history
        .where((m) => !m.isTyping && !m.isError)
        .toList()
        .reversed
        .take(5)
        .toList()
        .reversed;
    
    for (final msg in recentMessages) {
      final role = msg.type == MessageType.user ? 'Пользователь' : 'AI';
      summary.writeln('$role: ${msg.content}');
      
      // Добавить анализ изображений если есть
      if (msg.imageAnalysis != null) {
        summary.writeln('[Изображение: ${msg.imageAnalysis}]');
      }
    }
    
    return summary.toString();
  }

  /// Get service status
  Map<String, dynamic> getStatus() {
    return {
      'openai_configured': EnvConfig.isOpenAIConfigured,
      'google_configured': EnvConfig.isGoogleConfigured,
      'proxy_configured': EnvConfig.isProxyConfigured,
      'current_proxy': _currentProxy,
      'current_google_key': _currentGoogleApiKey.isNotEmpty ? '***' : '',
    };
  }
}

/// Response from smart AI service
class SmartAIResponse {
  const SmartAIResponse._({
    required this.isSuccess,
    required this.isOutOfScope,
    required this.isError,
    this.message,
    this.agent,
    this.confidence,
  });
  
  /// Create successful response
  factory SmartAIResponse.success({
    required String message,
    required AIAgent agent,
    required double confidence,
  }) {
    return SmartAIResponse._(
      isSuccess: true,
      isOutOfScope: false,
      isError: false,
      message: message,
      agent: agent,
      confidence: confidence,
    );
  }
  
  /// Create out-of-scope response
  factory SmartAIResponse.outOfScope({
    required String message,
  }) {
    return SmartAIResponse._(
      isSuccess: false,
      isOutOfScope: true,
      isError: false,
      message: message,
    );
  }
  
  /// Create error response
  factory SmartAIResponse.error({
    required String message,
  }) {
    return SmartAIResponse._(
      isSuccess: false,
      isOutOfScope: false,
      isError: true,
      message: message,
    );
  }
  
  /// Whether the response is successful
  final bool isSuccess;
  
  /// Whether the query was out of scope
  final bool isOutOfScope;
  
  /// Whether there was an error
  final bool isError;
  
  /// Response message
  final String? message;
  
  /// Selected agent (if successful)
  final AIAgent? agent;
  
  /// Confidence level (0.0 to 1.0)
  final double? confidence;
}
