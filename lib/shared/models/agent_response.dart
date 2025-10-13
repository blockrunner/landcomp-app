/// Agent response model for orchestrator
/// 
/// This model represents the response from an agent after processing
/// a request, including success status and generated content.
library;

import 'package:equatable/equatable.dart';
import 'package:landcomp_app/features/chat/domain/entities/ai_agent.dart';
import 'package:landcomp_app/features/chat/domain/entities/attachment.dart';
import 'package:landcomp_app/features/chat/data/config/ai_agents_config.dart';

/// Response from an agent after processing a request
class AgentResponse extends Equatable {
  /// Create successful response
  factory AgentResponse.success({
    required String requestId,
    required String message,
    AIAgent? selectedAgent,
    List<Attachment>? generatedAttachments,
    Map<String, dynamic>? metadata,
  }) {
    return AgentResponse(
      requestId: requestId,
      isSuccess: true,
      message: message,
      selectedAgent: selectedAgent,
      generatedAttachments: generatedAttachments,
      metadata: metadata ?? {},
      timestamp: DateTime.now(),
    );
  }

  /// Create error response
  factory AgentResponse.error({
    required String requestId,
    required String error,
    Map<String, dynamic>? metadata,
  }) {
    return AgentResponse(
      requestId: requestId,
      isSuccess: false,
      error: error,
      metadata: metadata ?? {},
      timestamp: DateTime.now(),
    );
  }

  /// Create response from JSON
  factory AgentResponse.fromJson(Map<String, dynamic> json) {
    return AgentResponse(
      requestId: json['requestId'] as String,
      isSuccess: json['isSuccess'] as bool,
      message: json['message'] as String?,
      selectedAgent: json['selectedAgent'] != null
          ? AIAgentsConfig.getAgentById(json['selectedAgent']['id'] as String)
          : null,
      generatedAttachments: json['generatedAttachments'] != null
          ? (json['generatedAttachments'] as List)
              .map((a) => Attachment.fromJson(a as Map<String, dynamic>))
              .toList()
          : null,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
      error: json['error'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Create agent response
  const AgentResponse({
    required this.requestId,
    required this.isSuccess,
    required this.timestamp,
    this.message,
    this.selectedAgent,
    this.generatedAttachments,
    this.metadata = const {},
    this.error,
  });

  /// Request ID this response corresponds to
  final String requestId;

  /// Whether the request was successful
  final bool isSuccess;

  /// Response message
  final String? message;

  /// Selected agent
  final AIAgent? selectedAgent;

  /// Generated attachments (images, files)
  final List<Attachment>? generatedAttachments;

  /// Additional metadata
  final Map<String, dynamic> metadata;

  /// Error message (if failed)
  final String? error;

  /// Response timestamp
  final DateTime timestamp;

  /// Check if response has generated attachments
  bool get hasGeneratedAttachments =>
      generatedAttachments != null && generatedAttachments!.isNotEmpty;

  /// Check if response has generated images
  bool get hasGeneratedImages {
    if (!hasGeneratedAttachments) return false;
    return generatedAttachments!.any((attachment) => attachment.isImage);
  }

  /// Get generated image attachments
  List<Attachment> get generatedImageAttachments {
    if (!hasGeneratedAttachments) return [];
    return generatedAttachments!.where((attachment) => attachment.isImage).toList();
  }

  /// Get selected agent ID
  String? get selectedAgentId => selectedAgent?.id;

  /// Get selected agent name
  String? get selectedAgentName => selectedAgent?.name;

  /// Copy response with new values
  AgentResponse copyWith({
    String? requestId,
    bool? isSuccess,
    String? message,
    AIAgent? selectedAgent,
    List<Attachment>? generatedAttachments,
    Map<String, dynamic>? metadata,
    String? error,
    DateTime? timestamp,
  }) {
    return AgentResponse(
      requestId: requestId ?? this.requestId,
      isSuccess: isSuccess ?? this.isSuccess,
      message: message ?? this.message,
      selectedAgent: selectedAgent ?? this.selectedAgent,
      generatedAttachments: generatedAttachments ?? this.generatedAttachments,
      metadata: metadata ?? this.metadata,
      error: error ?? this.error,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'isSuccess': isSuccess,
      'message': message,
      'selectedAgent': selectedAgent != null ? {'id': selectedAgent!.id, 'name': selectedAgent!.name} : null,
      'generatedAttachments': generatedAttachments?.map((a) => a.toJson()).toList(),
      'metadata': metadata,
      'error': error,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        requestId,
        isSuccess,
        message,
        selectedAgent,
        generatedAttachments,
        metadata,
        error,
        timestamp,
      ];

  @override
  String toString() {
    return 'AgentResponse(requestId: $requestId, isSuccess: $isSuccess, agent: ${selectedAgent?.name})';
  }
}
