/// Chat provider for managing chat state
///
/// This provider manages the chat conversation state,
/// AI agent selection, and message handling.
library;

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:landcomp_app/features/chat/domain/entities/message.dart';
import 'package:landcomp_app/features/chat/domain/entities/chat_session.dart';
import 'package:landcomp_app/features/chat/domain/entities/attachment.dart';
import 'package:landcomp_app/features/chat/domain/entities/ai_agent.dart';
import 'package:landcomp_app/features/chat/domain/entities/image_generation_response.dart';
import 'package:landcomp_app/features/chat/data/config/ai_agents_config.dart';
import 'package:landcomp_app/core/network/ai_service.dart';
import 'package:landcomp_app/core/localization/language_provider.dart';
import 'package:landcomp_app/core/storage/chat_storage.dart';
import 'package:landcomp_app/core/orchestrator/agent_orchestrator.dart';

/// Chat provider for state management
class ChatProvider extends ChangeNotifier {
  ChatProvider() {
    _initializeProvider();
  }

  final _uuid = const Uuid();
  final _aiService = AIService.instance;
  final _chatStorage = ChatStorage.instance;
  final _orchestrator = AgentOrchestrator.instance;

  // Current state
  ChatSession? _currentSession;
  AIAgent? _currentAgent; // Will be set dynamically based on user queries
  List<ChatSession> _sessions = [];
  bool _isLoading = false;
  String? _error;
  LanguageProvider? _languageProvider;
  bool _isInitialized = false;

  // Getters
  ChatSession? get currentSession => _currentSession;
  AIAgent? get currentAgent => _currentAgent;
  List<ChatSession> get sessions => _sessions;
  List<Message> get messages => _currentSession?.messages ?? [];
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMessages => messages.isNotEmpty;
  bool get hasSessions => _sessions.isNotEmpty;
  bool get isInitialized => _isInitialized;

  /// Initialize the provider
  Future<void> _initializeProvider() async {
    try {
      // Initialize chat storage
      await _chatStorage.initialize();

      // Initialize orchestrator
      await _orchestrator.initialize();

      // Load existing sessions
      await _loadSessions();

      // Create new session if none exist
      if (_sessions.isEmpty) {
        _createNewSession();
      } else {
        // Use the most recent session
        _currentSession = _sessions.first;
        _currentAgent = AIAgentsConfig.getAgentById(_currentSession!.agentId);
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('❌ Error initializing ChatProvider: $e');
      _setError('Failed to initialize chat: ${e}');
    }
  }

  /// Load sessions from storage
  Future<void> _loadSessions() async {
    try {
      _sessions = await _chatStorage.loadAllSessions();
      print('📂 Loaded ${_sessions.length} sessions from storage');

      // Debug: Check if any messages have images
      for (final session in _sessions) {
        for (final message in session.messages) {
          if (message.attachments != null && message.attachments!.isNotEmpty) {
            final imageAttachments = message.attachments!
                .where((a) => a.isImage)
                .toList();
            if (imageAttachments.isNotEmpty) {
              print(
                '📂 Found message with ${imageAttachments.length} images: ${message.id}',
              );
              print(
                '📂 Image sizes: ${imageAttachments.map((img) => img.size).toList()}',
              );
            }
          }
        }
      }
    } catch (e) {
      print('❌ Error loading sessions: $e');
      _sessions = [];
    }
  }

  /// Set language provider for localization
  void setLanguageProvider(LanguageProvider languageProvider) {
    if (_languageProvider != languageProvider) {
      _languageProvider = languageProvider;
      // Don't notify listeners here to avoid setState during build
    }
  }

  /// Create a new chat session
  void _createNewSession() {
    final sessionId = _uuid.v4();
    final session = ChatSession(
      id: sessionId,
      agentId:
          _currentAgent?.id ??
          'gardener', // Default to gardener if no agent selected
      title: _getLocalizedAgentName(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _currentSession = session;
    _sessions.add(session);

    // Save to storage
    _saveCurrentSession();

    notifyListeners();
  }

  /// Get localized agent name
  String _getLocalizedAgentName() {
    if (_currentAgent == null) return 'AI Assistant';
    if (_languageProvider != null) {
      return _currentAgent!.getLocalizedName(
        _languageProvider!.currentLocale.languageCode,
      );
    }
    return _currentAgent!.name;
  }

  /// Switch to a different AI agent
  Future<void> switchAgent(AIAgent agent) async {
    if (_currentAgent?.id == agent.id) return;

    _currentAgent = agent;

    // Create new session for new agent
    _createNewSession();

    notifyListeners();
  }

  /// Send a message to the AI agent
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty || _isLoading) return;

    final userMessage = Message.user(id: _uuid.v4(), content: content.trim());

    // Add user message to current session
    _addMessageToCurrentSession(userMessage);

    // Show typing indicator
    _showTypingIndicator();

    try {
      _setLoading(true);
      _clearError();

      // STEP 1: Check if this is a visualization request
      final isVisualizationRequest = _isVisualizationRequest(content.trim());
      final hasPreviousImages = _hasImagesInRecentMessages();

      print('🔍 Text message analysis:');
      print('   Content: ${content.trim()}');
      print('   Is visualization request: $isVisualizationRequest');
      print('   Has previous images: $hasPreviousImages');

      if (isVisualizationRequest && hasPreviousImages) {
        // STEP 2: Switch to image generation mode
        print('🎨 Switching to image generation mode...');
        await _handleVisualizationRequest(content.trim());
      } else {
        // STEP 3: Regular text response
        print('💬 Regular text response...');
        final smartResponse = await _getSmartAIResponse(content.trim());

        if (smartResponse.isSuccess) {
          // Update current agent if it changed
          if (smartResponse.agent != null &&
              smartResponse.agent != _currentAgent) {
            _currentAgent = smartResponse.agent;
            // Update session with new agent
            if (_currentSession != null) {
              _currentSession = _currentSession!.copyWith(
                agentId: _currentAgent!.id,
              );
              _saveCurrentSession();
            }
          }

          // Add AI response
          final aiMessage = Message.ai(
            id: _uuid.v4(),
            content: smartResponse.message!,
            agentId: _currentAgent?.id ?? 'unknown',
          );

          _addMessageToCurrentSession(aiMessage);
        } else if (smartResponse.isOutOfScope) {
          // Add out-of-scope message
          final outOfScopeMessage = Message.system(
            id: _uuid.v4(),
            content: smartResponse.message!,
          );

          _addMessageToCurrentSession(outOfScopeMessage);
        } else {
          // Add error message
          final errorMessage = Message.system(
            id: _uuid.v4(),
            content:
                smartResponse.message ?? _getLocalizedError('Unknown error'),
            isError: true,
          );

          _addMessageToCurrentSession(errorMessage);
        }
      }

      // Remove typing indicator
      _hideTypingIndicator();
    } catch (e) {
      _hideTypingIndicator();
      _setError('Failed to get AI response: ${e}');

      // Add error message
      final errorMessage = Message.system(
        id: _uuid.v4(),
        content: _getLocalizedError(e.toString()),
        isError: true,
      );

      _addMessageToCurrentSession(errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  /// Send a message with images to the AI agent
  Future<void> sendMessageWithImages({
    required String content,
    required List<Uint8List> images,
  }) async {
    if (content.trim().isEmpty || _isLoading) return;
    if (images.isEmpty) return;

    print('📸 Sending message with ${images.length} images');
    print('📸 Content: ${content.trim()}');
    print('📸 Image sizes: ${images.map((img) => img.length).toList()}');

    // Create attachments from images
    final attachments = images.map((imageData) {
      return Attachment.image(
        id: _uuid.v4(),
        name: 'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
        data: imageData,
        mimeType: 'image/jpeg',
      );
    }).toList();

    final userMessage = Message.user(
      id: _uuid.v4(),
      content: content.trim(),
      attachments: attachments,
    );

    print(
      '📸 Created user message with attachments: ${userMessage.attachments?.length ?? 0}',
    );

    // Add user message to current session
    _addMessageToCurrentSession(userMessage);

    // Show typing indicator
    _showTypingIndicator();

    try {
      _setLoading(true);
      _clearError();

      // Use new AgentOrchestrator for ALL requests (with or without images)
      print('🤖 Processing message with AgentOrchestrator...');
      final smartResponse = await _getSmartAIResponse(
        content.trim(),
        attachments,
      );

      if (smartResponse.isSuccess) {
        final aiMessage = Message.ai(
          id: _uuid.v4(),
          content: smartResponse.message!,
          agentId: smartResponse.agent?.id ?? 'unknown',
        );
        _addMessageToCurrentSession(aiMessage);
      } else {
        final errorMessage = Message.system(
          id: _uuid.v4(),
          content:
              smartResponse.message ?? 'Произошла ошибка при обработке запроса',
        );
        _addMessageToCurrentSession(errorMessage);
      }

      _hideTypingIndicator();
    } catch (e) {
      _hideTypingIndicator();
      _setError('Failed to get AI response: ${e}');

      // Add error message
      final errorMessage = Message.system(
        id: _uuid.v4(),
        content: _getLocalizedError(e.toString()),
        isError: true,
      );

      _addMessageToCurrentSession(errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  /// Get smart AI response from the orchestrator
  Future<SmartAIResponse> _getSmartAIResponse(
    String userMessage, [
    List<Attachment>? attachments,
  ]) async {
    print(
      '🤖 Getting smart AI response for message: ${userMessage.substring(0, userMessage.length > 50 ? 50 : userMessage.length)}...',
    );
    print('🎯 Using AgentOrchestrator for request processing...');

    // Get conversation history from current session
    final allMessages = _currentSession?.messages ?? [];
    print('📊 Total messages in session: ${allMessages.length}');
    print('   - Typing: ${allMessages.where((m) => m.isTyping).length}');
    print('   - Error: ${allMessages.where((m) => m.isError).length}');

    final history = allMessages
        .where((m) => !m.isTyping && !m.isError)
        .toList();

    print('📚 Passing ${history.length} messages as conversation history');
    print(
      '   - With attachments: ${history.where((m) => m.attachments != null && m.attachments!.isNotEmpty).length}',
    );

    try {
      final response = await _orchestrator.processRequest(
        userMessage: userMessage,
        conversationHistory: history,
        attachments: attachments,
        currentAgentId: _currentAgent?.id,
      );

      if (response.isSuccess) {
        print(
          '✅ Orchestrator response received: ${response.message!.substring(0, response.message!.length > 50 ? 50 : response.message!.length)}...',
        );
        print('   Selected agent: ${response.selectedAgent?.name}');

        return SmartAIResponse.success(
          agent: response.selectedAgent ?? AIAgentsConfig.getDefaultAgent(),
          message: response.message!,
          confidence:
              (response.metadata['confidence'] as num?)?.toDouble() ?? 0.8,
        );
      } else {
        print('❌ Error in orchestrator response: ${response.error}');
        // Return user-friendly error message instead of technical details
        return SmartAIResponse.error(
          message:
              'К сожалению, не удалось обработать ваш запрос. Пожалуйста, попробуйте еще раз или измените формулировку.',
        );
      }
    } catch (e) {
      print('❌ Error getting orchestrator response: $e');
      print('   Error type: ${e.runtimeType}');
      // Return user-friendly error message instead of technical exception details
      return SmartAIResponse.error(
        message:
            'К сожалению, произошла ошибка при обработке вашего запроса. Пожалуйста, попробуйте еще раз.',
      );
    }
  }

  /// Save current session to storage
  Future<void> _saveCurrentSession() async {
    await _saveCurrentSessionAsync();
  }

  /// Get localized error message
  String _getLocalizedError(String error) {
    if (_languageProvider != null) {
      final isRussian = _languageProvider!.currentLocale.languageCode == 'ru';
      if (isRussian) {
        return 'Произошла ошибка при получении ответа от ИИ. Попробуйте еще раз.';
      }
    }
    return 'An error occurred while getting AI response. Please try again.';
  }

  /// Add message to current session
  void _addMessageToCurrentSession(Message message) {
    if (_currentSession == null) return;

    print('💾 Adding message to session: ${message.id}');
    final imageAttachments =
        message.attachments?.where((a) => a.isImage).toList() ?? [];
    print('💾 Message has images: ${imageAttachments.length}');
    if (imageAttachments.isNotEmpty) {
      print(
        '💾 Image sizes: ${imageAttachments.map((img) => img.size).toList()}',
      );
    }

    // Create new session with added message
    final updatedSession = _currentSession!.addMessage(message);
    _currentSession = updatedSession;

    // Update session in sessions list
    final sessionIndex = _sessions.indexWhere(
      (s) => s.id == _currentSession!.id,
    );
    if (sessionIndex >= 0) {
      _sessions[sessionIndex] = _currentSession!;
    } else {
      // If session not found in list, add it
      _sessions.insert(0, _currentSession!);
    }

    // Save to storage asynchronously to avoid blocking UI
    _saveCurrentSessionAsync();

    notifyListeners();
  }

  /// Save current session to storage asynchronously
  Future<void> _saveCurrentSessionAsync() async {
    if (_currentSession != null) {
      try {
        await _chatStorage.saveSession(_currentSession!);
        print('💾 Session saved successfully: ${_currentSession!.id}');
      } catch (e) {
        print('❌ Error saving session: $e');
        // Don't throw error to avoid breaking UI
      }
    }
  }

  /// Show typing indicator
  void _showTypingIndicator() {
    final typingMessage = Message.typing(
      id: 'typing-${_uuid.v4()}',
      agentId: _currentAgent?.id ?? 'unknown',
    );
    _addMessageToCurrentSession(typingMessage);
  }

  /// Hide typing indicator
  void _hideTypingIndicator() {
    if (_currentSession == null) return;

    final updatedMessages = _currentSession!.messages
        .where((m) => !m.isTyping)
        .toList();

    _currentSession = _currentSession!.copyWith(messages: updatedMessages);

    // Update session in sessions list
    final sessionIndex = _sessions.indexWhere(
      (s) => s.id == _currentSession!.id,
    );
    if (sessionIndex >= 0) {
      _sessions[sessionIndex] = _currentSession!;
    }

    notifyListeners();
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear current session messages
  void clearCurrentSession() {
    if (_currentSession == null) return;

    _currentSession = _currentSession!.clearMessages();

    // Update session in sessions list
    final sessionIndex = _sessions.indexWhere(
      (s) => s.id == _currentSession!.id,
    );
    if (sessionIndex >= 0) {
      _sessions[sessionIndex] = _currentSession!;
    }

    notifyListeners();
  }

  /// Delete a message
  void deleteMessage(String messageId) {
    if (_currentSession == null) return;

    _currentSession = _currentSession!.removeMessage(messageId);

    // Update session in sessions list
    final sessionIndex = _sessions.indexWhere(
      (s) => s.id == _currentSession!.id,
    );
    if (sessionIndex >= 0) {
      _sessions[sessionIndex] = _currentSession!;
    }

    notifyListeners();
  }

  /// Switch to a different session
  void switchToSession(String sessionId) {
    final session = _sessions.firstWhere(
      (s) => s.id == sessionId,
      orElse: () => throw Exception('Session not found'),
    );

    _currentSession = session;

    // Update current agent based on session
    final agent = AIAgentsConfig.getAgentById(session.agentId);
    if (agent != null) {
      _currentAgent = agent;
    }

    notifyListeners();
  }

  /// Delete a session
  Future<void> deleteSession(String sessionId) async {
    try {
      // Remove from storage
      await _chatStorage.deleteSession(sessionId);

      // Remove from local list
      _sessions.removeWhere((s) => s.id == sessionId);

      // If we deleted the current session, create a new one
      if (_currentSession?.id == sessionId) {
        _createNewSession();
      }

      notifyListeners();
    } catch (e) {
      print('❌ Error deleting session: $e');
      _setError('Failed to delete session: ${e}');
    }
  }

  /// Get quick start suggestions for current agent
  List<String> getQuickStartSuggestions() {
    if (_currentAgent == null) return [];
    if (_languageProvider != null) {
      return _currentAgent!.getLocalizedQuickStartSuggestions(
        _languageProvider!.currentLocale.languageCode,
      );
    }
    return _currentAgent!.quickStartSuggestions;
  }

  /// Retry last AI message
  Future<void> retryLastMessage() async {
    if (_currentSession == null || messages.isEmpty) return;

    // Find last user message
    final userMessages = messages
        .where((m) => m.type == MessageType.user)
        .toList();
    if (userMessages.isEmpty) return;

    final lastUserMessage = userMessages.last;

    // Remove last AI message if it exists
    final aiMessages = messages.where((m) => m.type == MessageType.ai).toList();
    if (aiMessages.isNotEmpty) {
      deleteMessage(aiMessages.last.id);
    }

    // Resend the message
    await sendMessage(lastUserMessage.content);
  }

  /// Initialize the provider (public method)
  Future<void> initialize() async {
    await _initializeProvider();
  }

  /// Clear all chat history
  Future<void> clearAllHistory() async {
    try {
      await _chatStorage.clearAllSessions();
      _sessions.clear();
      _createNewSession();
      notifyListeners();
    } catch (e) {
      print('❌ Error clearing history: $e');
      _setError('Failed to clear history: ${e}');
    }
  }

  /// Load messages from project
  /// This synchronizes ChatProvider's session with the current project's messages
  void loadMessagesFromProject(List<Message> projectMessages) {
    if (_currentSession == null) {
      _createNewSession();
    }

    // Update current session with project messages
    _currentSession = _currentSession!.copyWith(
      messages: List.from(projectMessages),
    );

    notifyListeners();
  }

  /// Generate visualization
  Future<void> _generateVisualization(
    String content,
    List<Uint8List> images,
    ImageGenerationResponse? analysis,
  ) async {
    // Build enhanced prompt using analysis or context
    String enhancedPrompt;

    if (analysis != null) {
      enhancedPrompt =
          '''
АНАЛИЗ УЧАСТКА:
${analysis.imageAnalysis}

ПРИГОДНОСТЬ:
${analysis.suitability}

ВОПРОС:
$content

РЕКОМЕНДАЦИИ:
${analysis.recommendations?.join('\n')}

ЗАДАЧА: Создай реалистичную визуализацию согласно анализу и рекомендациям.
КРИТИЧНО: Соответствовать контексту разговора!
''';
    } else {
      // Build prompt from conversation context
      final contextSummary = _buildConversationSummary(
        _currentSession?.messages,
      );
      enhancedPrompt =
          '''
КОНТЕКСТ РАЗГОВОРА:
$contextSummary

ВОПРОС ПОЛЬЗОВАТЕЛЯ:
$content

ЗАДАЧА: Создай реалистичную визуализацию на основе контекста разговора.
Покажи как будет выглядеть участок с предложенными растениями.
''';
    }

    final generationResponse = await _aiService.sendImageGenerationToGemini(
      prompt: enhancedPrompt,
      images: images,
    );

    // Create attachments
    final generatedAttachments = <Attachment>[];
    for (var i = 0; i < generationResponse.generatedImages.length; i++) {
      generatedAttachments.add(
        Attachment.image(
          id: _uuid.v4(),
          name: 'generated_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
          data: generationResponse.generatedImages[i],
          mimeType: generationResponse.imageMimeTypes[i],
        ),
      );
    }

    final aiMessage = Message.ai(
      id: _uuid.v4(),
      content: generationResponse.textResponse,
      agentId: 'gemini-image-generator',
      attachments: generatedAttachments.isNotEmpty
          ? generatedAttachments
          : null,
      imageAnalysis: analysis?.imageAnalysis,
    );

    _addMessageToCurrentSession(aiMessage);
  }

  /// Offer visualization option for unclear cases

  /// Check if text message is a visualization request
  bool _isVisualizationRequest(String content) {
    final lowerContent = content.toLowerCase();

    // Direct visualization requests
    final directRequests = [
      'сгенерируй картинку',
      'сгенерируй изображение',
      'покажи как это будет выглядеть',
      'покажи визуализацию',
      'создай картинку',
      'нарисуй',
      'покажи результат',
      'да',
      'покажи',
      'визуализация',
      'картинка',
      'изображение',
    ];

    // Leading questions that imply visualization
    final leadingQuestions = [
      'как это будет смотреться',
      'как это будет выглядеть',
      'как будет выглядеть',
      'что получится',
      'какой результат',
      'покажи результат',
    ];

    // Check for direct requests
    for (final request in directRequests) {
      if (lowerContent.contains(request)) {
        return true;
      }
    }

    // Check for leading questions
    for (final question in leadingQuestions) {
      if (lowerContent.contains(question)) {
        return true;
      }
    }

    return false;
  }

  /// Check if there are images in recent messages
  bool _hasImagesInRecentMessages() {
    if (_currentSession?.messages == null) return false;

    // Look for images in the last 10 messages
    final recentMessages = _currentSession!.messages
        .where((m) => !m.isTyping && !m.isError)
        .toList()
        .reversed
        .take(10)
        .toList();

    for (final message in recentMessages) {
      if (message.attachments != null &&
          message.attachments!.any((a) => a.isImage)) {
        return true;
      }
    }

    return false;
  }

  /// Handle visualization request using previous images
  Future<void> _handleVisualizationRequest(String content) async {
    // Find the most recent message with images
    final recentMessages = _currentSession!.messages
        .where((m) => !m.isTyping && !m.isError)
        .toList()
        .reversed;

    Message? messageWithImages;
    for (final message in recentMessages) {
      if (message.attachments != null &&
          message.attachments!.any((a) => a.isImage)) {
        messageWithImages = message;
        break;
      }
    }

    if (messageWithImages?.attachments == null) {
      // No images found, fallback to text response
      print('❌ No images found for visualization request');
      final fallbackMessage = Message.system(
        id: _uuid.v4(),
        content:
            'Для создания визуализации нужны изображения участка. Пожалуйста, загрузите фото участка.',
      );
      _addMessageToCurrentSession(fallbackMessage);
      return;
    }

    // Extract image data
    final imageAttachments = messageWithImages!.attachments!
        .where((a) => a.isImage)
        .toList();

    final imageData = imageAttachments
        .map((a) => a.data)
        .where((data) => data != null)
        .cast<Uint8List>()
        .toList();

    print('🎨 Found ${imageData.length} images for visualization');

    // Use the existing image generation flow
    await _generateVisualization(content, imageData, null);
  }

  /// Build conversation summary for context
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
}
