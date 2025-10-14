/// Context Manager for orchestrator
///
/// This manager builds and manages request context including
/// conversation history, image analyses, and metadata.
library;

import 'package:landcomp_app/core/storage/chat_storage.dart';
import 'package:landcomp_app/shared/models/context.dart';
import 'package:landcomp_app/shared/models/intent.dart';
import 'package:landcomp_app/features/chat/domain/entities/message.dart';
import 'package:landcomp_app/features/chat/domain/entities/attachment.dart';

/// Context management service
class ContextManager {
  ContextManager._();

  static final ContextManager _instance = ContextManager._();
  static ContextManager get instance => _instance;

  final ChatStorage _storage = ChatStorage.instance;

  /// Build request context from user message and conversation history
  Future<RequestContext> buildContext({
    required String userMessage,
    required List<Message> conversationHistory,
    List<Attachment>? attachments,
    String? currentAgentId,
  }) async {
    print(
      '🔍 Building context for message: ${userMessage.substring(0, userMessage.length > 50 ? 50 : userMessage.length)}...',
    );

    // Extract image analyses from conversation history
    final imageAnalyses = _extractImageAnalyses(conversationHistory);

    // Check for recent images
    final hasRecentImages = _checkRecentImages(conversationHistory);

    // Detect user language
    final language = _detectLanguage(userMessage, conversationHistory);

    // Build metadata
    final metadata = _buildMetadata(conversationHistory, currentAgentId);

    // If no attachments provided, try to extract from recent messages
    var finalAttachments = attachments;
    if (finalAttachments == null || finalAttachments.isEmpty) {
      finalAttachments = _extractAttachmentsFromHistory(conversationHistory);
    }

    final context = RequestContext(
      userMessage: userMessage,
      conversationHistory: conversationHistory,
      attachments: finalAttachments,
      currentAgentId: currentAgentId,
      timestamp: DateTime.now(),
      metadata: metadata,
      previousImageAnalyses: imageAnalyses.isNotEmpty ? imageAnalyses : null,
      hasRecentImages: hasRecentImages,
      userLanguage: language,
    );

    print(
      '✅ Context built: ${conversationHistory.length} messages, ${finalAttachments?.length ?? 0} attachments, language: $language',
    );
    return context;
  }

  /// Extract image analyses from conversation history
  List<String> _extractImageAnalyses(List<Message> history) {
    final analyses = <String>[];

    for (final message in history) {
      if (message.imageAnalysis != null && message.imageAnalysis!.isNotEmpty) {
        analyses.add(message.imageAnalysis!);
      }
    }

    // Keep only recent analyses (last 5)
    if (analyses.length > 5) {
      analyses.removeRange(0, analyses.length - 5);
    }

    print('📸 Extracted ${analyses.length} image analyses from history');
    return analyses;
  }

  /// Check if there are recent images in conversation
  bool _checkRecentImages(List<Message> history) {
    if (history.isEmpty) return false;

    // Check last 10 messages for images
    final recentMessages = history.length > 10
        ? history.sublist(history.length - 10)
        : history;

    for (final message in recentMessages) {
      if (message.attachments != null && message.attachments!.isNotEmpty) {
        final hasImages = message.attachments!.any(
          (attachment) => attachment.isImage,
        );
        if (hasImages) {
          print('📸 Found recent images in conversation');
          return true;
        }
      }
    }

    return false;
  }

  /// Detect user language from message and history
  String? _detectLanguage(String userMessage, List<Message> history) {
    // Simple language detection based on character sets
    final cyrillicPattern = RegExp('[а-яё]', caseSensitive: false);
    final latinPattern = RegExp('[a-z]', caseSensitive: false);

    // Check current message
    final hasCyrillic = cyrillicPattern.hasMatch(userMessage);
    final hasLatin = latinPattern.hasMatch(userMessage);

    if (hasCyrillic && !hasLatin) {
      return 'ru';
    } else if (hasLatin && !hasCyrillic) {
      return 'en';
    }

    // Check recent messages if current message is unclear
    final recentMessages = history.length > 5
        ? history.sublist(history.length - 5)
        : history;

    var cyrillicCount = 0;
    var latinCount = 0;

    for (final message in recentMessages) {
      if (message.type == MessageType.user) {
        if (cyrillicPattern.hasMatch(message.content)) {
          cyrillicCount++;
        }
        if (latinPattern.hasMatch(message.content)) {
          latinCount++;
        }
      }
    }

    if (cyrillicCount > latinCount) {
      return 'ru';
    } else if (latinCount > cyrillicCount) {
      return 'en';
    }

    return null; // Unknown language
  }

  /// Build metadata from conversation history
  Map<String, dynamic> _buildMetadata(
    List<Message> history,
    String? currentAgentId,
  ) {
    final metadata = <String, dynamic>{
      'conversation_length': history.length,
      'user_message_count': history
          .where((m) => m.type == MessageType.user)
          .length,
      'ai_message_count': history.where((m) => m.type == MessageType.ai).length,
      'system_message_count': history
          .where((m) => m.type == MessageType.system)
          .length,
      'current_agent_id': currentAgentId,
      'has_attachments': history.any(
        (m) => m.attachments != null && m.attachments!.isNotEmpty,
      ),
      'has_image_analyses': history.any(
        (m) => m.imageAnalysis != null && m.imageAnalysis!.isNotEmpty,
      ),
    };

    // Add agent usage statistics
    final agentUsage = <String, int>{};
    for (final message in history) {
      if (message.type == MessageType.ai && message.agentId != null) {
        agentUsage[message.agentId!] = (agentUsage[message.agentId!] ?? 0) + 1;
      }
    }
    metadata['agent_usage'] = agentUsage;

    // Add recent message types
    if (history.isNotEmpty) {
      final recentMessages = history.length > 5
          ? history.sublist(history.length - 5)
          : history;

      final recentTypes = recentMessages.map((m) => m.type.name).toList();
      metadata['recent_message_types'] = recentTypes;
    }

    // Add conversation duration
    if (history.length >= 2) {
      final firstMessage = history.first;
      final lastMessage = history.last;
      final duration = lastMessage.timestamp.difference(firstMessage.timestamp);
      metadata['conversation_duration_minutes'] = duration.inMinutes;
    }

    return metadata;
  }

  /// Get context metadata for a session
  Future<Map<String, dynamic>?> getContextMetadata(String sessionId) async {
    try {
      return await _storage.getContextMetadata(sessionId);
    } catch (e) {
      print('❌ Failed to get context metadata for session $sessionId: $e');
      return null;
    }
  }

  /// Save context metadata for a session
  Future<void> saveContextMetadata(
    String sessionId,
    Map<String, dynamic> metadata,
  ) async {
    try {
      await _storage.saveContextMetadata(sessionId, metadata);
      print('💾 Saved context metadata for session $sessionId');
    } catch (e) {
      print('❌ Failed to save context metadata for session $sessionId: $e');
    }
  }

  /// Clear context metadata for a session
  Future<void> clearContextMetadata(String sessionId) async {
    try {
      await _storage.clearContextMetadata(sessionId);
      print('🗑️ Cleared context metadata for session $sessionId');
    } catch (e) {
      print('❌ Failed to clear context metadata for session $sessionId: $e');
    }
  }

  /// Extract attachments from recent conversation history
  List<Attachment>? _extractAttachmentsFromHistory(List<Message> history) {
    if (history.isEmpty) return null;

    // Look for attachments in the last few messages
    final recentMessages = history.length > 5
        ? history.sublist(history.length - 5)
        : history;

    // Find the most recent message with attachments
    for (var i = recentMessages.length - 1; i >= 0; i--) {
      final message = recentMessages[i];
      if (message.attachments != null && message.attachments!.isNotEmpty) {
        print(
          '📸 Found attachments in message ${message.id}: ${message.attachments!.length} items',
        );
        return message.attachments;
      }
    }

    return null;
  }

  /// Get relevant images based on user intent and conversation context
  Future<List<Attachment>> getRelevantImages({
    required String userMessage,
    required List<Message> conversationHistory,
    required Intent intent,
    List<Attachment>? currentAttachments,
  }) async {
    print('🖼️ Smart image selection for intent: ${intent.imageIntent}');

    switch (intent.imageIntent) {
      case ImageIntent.analyzeNew:
        return _getNewImages(currentAttachments);

      case ImageIntent.analyzeRecent:
        return _getRecentImages(
          conversationHistory,
          limit: intent.imagesNeeded ?? 5,
        );

      case ImageIntent.compareMultiple:
        return _getComparisonImages(conversationHistory, currentAttachments);

      case ImageIntent.referenceSpecific:
        return _getSpecificImages(
          conversationHistory,
          intent.referencedImageIndices,
        );

      case ImageIntent.generateBased:
        return _getNewImages(currentAttachments, limit: 1);

      case ImageIntent.noImageNeeded:
      case ImageIntent.unclear:
      default:
        return [];
    }
  }

  /// Get new images from current message
  List<Attachment> _getNewImages(List<Attachment>? attachments, {int? limit}) {
    if (attachments == null || attachments.isEmpty) return [];

    final images = attachments.where((a) => a.isImage).toList();
    if (limit != null && images.length > limit) {
      return images.take(limit).toList();
    }
    return images;
  }

  /// Get recent images from conversation history
  List<Attachment> _getRecentImages(List<Message> history, {int limit = 5}) {
    final images = <Attachment>[];

    // Iterate from most recent to oldest
    for (final msg in history.reversed) {
      if (msg.attachments != null) {
        for (final attachment in msg.attachments!.where((a) => a.isImage)) {
          images.add(attachment);
          if (images.length >= limit) return images;
        }
      }
    }

    return images;
  }

  /// Get images for comparison (new + recent)
  List<Attachment> _getComparisonImages(
    List<Message> history,
    List<Attachment>? currentAttachments,
  ) {
    final images = <Attachment>[];

    // Add new images first
    if (currentAttachments != null) {
      images.addAll(currentAttachments.where((a) => a.isImage));
    }

    // Add recent images from history (up to 5 total)
    final needed = 5 - images.length;
    if (needed > 0) {
      images.addAll(_getRecentImages(history, limit: needed));
    }

    return images;
  }

  /// Get specific referenced images by indices
  List<Attachment> _getSpecificImages(
    List<Message> history,
    List<int>? indices,
  ) {
    if (indices == null || indices.isEmpty) return [];

    // Collect all images from history with their message index
    final allImages = <({int msgIndex, Attachment attachment})>[];

    for (var i = 0; i < history.length; i++) {
      final msg = history[i];
      if (msg.attachments != null) {
        for (final attachment in msg.attachments!.where((a) => a.isImage)) {
          allImages.add((msgIndex: i, attachment: attachment));
        }
      }
    }

    // Get images at specified indices
    final result = <Attachment>[];
    for (final index in indices) {
      if (index >= 0 && index < allImages.length) {
        result.add(allImages[index].attachment);
      }
    }

    return result;
  }
}
