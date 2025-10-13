/// Request context model for orchestrator
///
/// This model represents the context of a user request including
/// conversation history, attachments, and extracted metadata.
library;

import 'package:equatable/equatable.dart';
import 'package:landcomp_app/features/chat/domain/entities/message.dart';
import 'package:landcomp_app/features/chat/domain/entities/attachment.dart';

/// Request context for orchestrator processing
class RequestContext extends Equatable {
  /// Create context from parameters
  const RequestContext({
    required this.userMessage,
    required this.conversationHistory,
    required this.timestamp,
    this.attachments,
    this.currentAgentId,
    this.metadata = const {},
    this.previousImageAnalyses,
    this.hasRecentImages = false,
    this.userLanguage,
  });

  /// User's message
  final String userMessage;

  /// Conversation history
  final List<Message> conversationHistory;

  /// Attachments (images, files)
  final List<Attachment>? attachments;

  /// Current agent ID
  final String? currentAgentId;

  /// Timestamp of the request
  final DateTime timestamp;

  /// Additional metadata
  final Map<String, dynamic> metadata;

  /// Previous image analyses from conversation
  final List<String>? previousImageAnalyses;

  /// Whether there are recent images in conversation
  final bool hasRecentImages;

  /// Detected user language
  final String? userLanguage;

  /// Check if context has attachments
  bool get hasAttachments => attachments != null && attachments!.isNotEmpty;

  /// Check if context has images
  bool get hasImages {
    if (!hasAttachments) return false;
    return attachments!.any((attachment) => attachment.isImage);
  }

  /// Get image attachments
  List<Attachment> get imageAttachments {
    if (!hasAttachments) return [];
    return attachments!.where((attachment) => attachment.isImage).toList();
  }

  /// Get conversation length
  int get conversationLength => conversationHistory.length;

  /// Check if conversation is empty
  bool get isConversationEmpty => conversationHistory.isEmpty;

  /// Get last message
  Message? get lastMessage {
    if (conversationHistory.isEmpty) return null;
    return conversationHistory.last;
  }

  /// Get user messages count
  int get userMessageCount {
    return conversationHistory.where((m) => m.type == MessageType.user).length;
  }

  /// Get AI messages count
  int get aiMessageCount {
    return conversationHistory.where((m) => m.type == MessageType.ai).length;
  }

  /// Check if context has recent images (within last 5 messages)
  bool get hasRecentImagesInHistory {
    if (conversationHistory.length < 5) return hasImages;

    final recentMessages = conversationHistory.length > 5
        ? conversationHistory.sublist(conversationHistory.length - 5)
        : conversationHistory;
    return recentMessages.any(
      (Message message) =>
          message.attachments?.any(
            (Attachment attachment) => attachment.isImage,
          ) ??
          false,
    );
  }

  /// Copy context with new values
  RequestContext copyWith({
    String? userMessage,
    List<Message>? conversationHistory,
    List<Attachment>? attachments,
    String? currentAgentId,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
    List<String>? previousImageAnalyses,
    bool? hasRecentImages,
    String? userLanguage,
  }) {
    return RequestContext(
      userMessage: userMessage ?? this.userMessage,
      conversationHistory: conversationHistory ?? this.conversationHistory,
      attachments: attachments ?? this.attachments,
      currentAgentId: currentAgentId ?? this.currentAgentId,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
      previousImageAnalyses:
          previousImageAnalyses ?? this.previousImageAnalyses,
      hasRecentImages: hasRecentImages ?? this.hasRecentImages,
      userLanguage: userLanguage ?? this.userLanguage,
    );
  }

  @override
  List<Object?> get props => [
    userMessage,
    conversationHistory,
    attachments,
    currentAgentId,
    timestamp,
    metadata,
    previousImageAnalyses,
    hasRecentImages,
    userLanguage,
  ];

  @override
  String toString() {
    return 'RequestContext(userMessage: ${userMessage.length} chars, conversationLength: $conversationLength, hasAttachments: $hasAttachments)';
  }
}
