/// Chat session entity
///
/// This entity represents a chat session with an AI agent,
/// containing messages and session metadata.
library;

import 'package:equatable/equatable.dart';
import 'package:landcomp_app/features/chat/domain/entities/message.dart';

/// Chat session entity
class ChatSession extends Equatable {

  /// Creates a chat session
  const ChatSession({
    required this.id,
    required this.agentId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.messages = const [],
    this.isActive = true,
  });
  /// Create session from JSON
  factory ChatSession.fromJson(Map<String, dynamic> json) {
    // Debug: Check messages before deserialization
    final messagesJson = json['messages'] as List<dynamic>;
    print(
      '📂 ChatSession.fromJson: Processing ${messagesJson.length} messages',
    );

    for (final messageJson in messagesJson) {
      final messageData = messageJson as Map<String, dynamic>;
      final imageBytes = messageData['imageBytes'];
      if (imageBytes != null) {
        print(
          '📂 ChatSession.fromJson: Message ${messageData['id']} has ${(imageBytes as List).length} images in JSON',
        );
      }
    }

    final messages = messagesJson
        .map((m) => Message.fromJson(m as Map<String, dynamic>))
        .toList();

    // Debug: Check messages after deserialization
    for (final message in messages) {
      if (message.attachments != null && message.attachments!.isNotEmpty) {
        final imageAttachments = message.attachments!
            .where((a) => a.isImage)
            .toList();
        print(
          '📂 ChatSession.fromJson: Message ${message.id} has ${imageAttachments.length} images after deserialization',
        );
      }
    }

    return ChatSession(
      id: json['id'] as String,
      agentId: json['agentId'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      messages: messages,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  /// Unique identifier for the chat session
  final String id;

  /// ID of the AI agent for this session
  final String agentId;

  /// Title of the chat session
  final String title;

  /// When the session was created
  final DateTime createdAt;

  /// When the session was last updated
  final DateTime updatedAt;

  /// List of messages in this session
  final List<Message> messages;

  /// Whether this session is currently active
  final bool isActive;

  /// Get the last message in the session
  Message? get lastMessage {
    if (messages.isEmpty) return null;
    return messages.last;
  }

  /// Get the number of messages in the session
  int get messageCount => messages.length;

  /// Get user messages count
  int get userMessageCount =>
      messages.where((m) => m.type == MessageType.user).length;

  /// Get AI messages count
  int get aiMessageCount =>
      messages.where((m) => m.type == MessageType.ai).length;

  /// Create a copy of this session with updated fields
  ChatSession copyWith({
    String? id,
    String? agentId,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Message>? messages,
    bool? isActive,
  }) {
    return ChatSession(
      id: id ?? this.id,
      agentId: agentId ?? this.agentId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Add a message to this session
  ChatSession addMessage(Message message) {
    final updatedMessages = List<Message>.from(messages)..add(message);
    return copyWith(messages: updatedMessages, updatedAt: DateTime.now());
  }

  /// Remove a message from this session
  ChatSession removeMessage(String messageId) {
    final updatedMessages = messages.where((m) => m.id != messageId).toList();
    return copyWith(messages: updatedMessages, updatedAt: DateTime.now());
  }

  /// Clear all messages from this session
  ChatSession clearMessages() {
    return copyWith(messages: const [], updatedAt: DateTime.now());
  }

  /// Convert session to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agentId': agentId,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'messages': messages.map((m) => m.toJson()).toList(),
      'isActive': isActive,
    };
  }

  @override
  List<Object?> get props => [
    id,
    agentId,
    title,
    createdAt,
    updatedAt,
    messages,
    isActive,
  ];

  @override
  String toString() {
    return 'ChatSession(id: $id, agentId: $agentId, title: $title, messageCount: $messageCount)';
  }
}
