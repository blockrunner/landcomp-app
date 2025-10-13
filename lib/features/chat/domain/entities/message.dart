/// Message entity for chat functionality
/// 
/// This entity represents a message in the chat conversation
/// with support for different message types and AI agents.
library;

import 'package:equatable/equatable.dart';
import 'package:landcomp_app/features/chat/domain/entities/attachment.dart';

/// Message type enumeration
enum MessageType {
  /// User message
  user,
  /// AI agent message
  ai,
  /// System message (errors, notifications)
  system,
}

/// Message entity
class Message extends Equatable {

  /// Create a user message
  factory Message.user({
    required String id,
    required String content,
    DateTime? timestamp,
    List<Attachment>? attachments,
    String? imageAnalysis,
  }) {
    return Message(
      id: id,
      content: content,
      type: MessageType.user,
      timestamp: timestamp ?? DateTime.now(),
      attachments: attachments,
      imageAnalysis: imageAnalysis,
    );
  }

  /// Create an AI message
  factory Message.ai({
    required String id,
    required String content,
    required String agentId,
    DateTime? timestamp,
    List<Attachment>? attachments,
    String? imageAnalysis,
  }) {
    return Message(
      id: id,
      content: content,
      type: MessageType.ai,
      agentId: agentId,
      timestamp: timestamp ?? DateTime.now(),
      attachments: attachments,
      imageAnalysis: imageAnalysis,
    );
  }

  /// Create a system message
  factory Message.system({
    required String id,
    required String content,
    DateTime? timestamp,
    bool isError = false,
  }) {
    return Message(
      id: id,
      content: content,
      type: MessageType.system,
      timestamp: timestamp ?? DateTime.now(),
      isError: isError,
    );
  }

  /// Create a typing indicator
  factory Message.typing({
    required String id,
    required String agentId,
  }) {
    return Message(
      id: id,
      content: '',
      type: MessageType.ai,
      agentId: agentId,
      isTyping: true,
      timestamp: DateTime.now(),
    );
  }

  /// Create message from JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    List<Attachment>? attachments;
    if (json['attachments'] != null) {
      try {
        final List<dynamic> attachmentsList = json['attachments'] as List<dynamic>;
        attachments = attachmentsList.map((attachmentJson) {
          return Attachment.fromJson(attachmentJson as Map<String, dynamic>);
        }).toList();
        
        print('📄 Message.fromJson: Successfully deserialized ${attachments.length} attachments for message ${json['id']}');
        print('📄 Attachment types: ${attachments.map((a) => a.type.name).toList()}');
      } catch (e) {
        print('❌ Error deserializing attachments: $e');
        attachments = null;
      }
    } else {
      print('📄 Message.fromJson: No attachments found for message ${json['id']}');
    }
    
    return Message(
      id: json['id'] as String,
      content: json['content'] as String,
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.user,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      agentId: json['agentId'] as String?,
      isError: json['isError'] as bool? ?? false,
      isTyping: json['isTyping'] as bool? ?? false,
      attachments: attachments,
      imageAnalysis: json['imageAnalysis'] as String?,
    );
  }
  /// Creates a message
  const Message({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.agentId,
    this.isError = false,
    this.isTyping = false,
    this.attachments,
    this.imageAnalysis,
  });

  /// Unique identifier for the message
  final String id;

  /// Message content
  final String content;

  /// Type of the message
  final MessageType type;

  /// Timestamp when the message was created
  final DateTime timestamp;

  /// ID of the AI agent (if message is from AI)
  final String? agentId;

  /// Whether this is an error message
  final bool isError;

  /// Whether this is a typing indicator
  final bool isTyping;

  /// Attachments for messages with files/images
  final List<Attachment>? attachments;

  /// Analysis of images in this message (for context preservation)
  final String? imageAnalysis;

  /// Create a copy of this message with updated fields
  Message copyWith({
    String? id,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    String? agentId,
    bool? isError,
    bool? isTyping,
    List<Attachment>? attachments,
    String? imageAnalysis,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      agentId: agentId ?? this.agentId,
      isError: isError ?? this.isError,
      isTyping: isTyping ?? this.isTyping,
      attachments: attachments ?? this.attachments,
      imageAnalysis: imageAnalysis ?? this.imageAnalysis,
    );
  }

  /// Convert message to JSON
  Map<String, dynamic> toJson() {
    // Convert attachments to JSON
    final attachmentsJson = attachments?.map((attachment) => attachment.toJson()).toList();
    
    // Debug: Log attachment serialization
    if (attachments != null && attachments!.isNotEmpty) {
      print('📄 Message.toJson: Processing ${attachments!.length} attachments for message $id');
      print('📄 Attachment types: ${attachments!.map((a) => a.type.name).toList()}');
    }
    
    return {
      'id': id,
      'content': content,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'agentId': agentId,
      'isError': isError,
      'isTyping': isTyping,
      'attachments': attachmentsJson,
      'imageAnalysis': imageAnalysis,
    };
  }

  @override
  List<Object?> get props => [
        id,
        content,
        type,
        timestamp,
        agentId,
        isError,
        isTyping,
        attachments,
        imageAnalysis,
      ];

  @override
  String toString() {
    return 'Message(id: $id, type: $type, content: ${content.length > 50 ? '${content.substring(0, 50)}...' : content})';
  }
}
