/// Agent request model for orchestrator
///
/// This model represents a request to be processed by an agent
/// containing context and classified intent.
library;

import 'package:equatable/equatable.dart';
import 'package:landcomp_app/shared/models/context.dart';
import 'package:landcomp_app/shared/models/intent.dart';

/// Request to be processed by an agent
class AgentRequest extends Equatable {
  /// Create agent request
  const AgentRequest({
    required this.requestId,
    required this.context,
    required this.intent,
    required this.timestamp,
  });

  /// Unique request identifier
  final String requestId;

  /// Request context
  final RequestContext context;

  /// Classified intent
  final Intent intent;

  /// Request timestamp
  final DateTime timestamp;

  /// Get user message from context
  String get userMessage => context.userMessage;

  /// Get conversation history from context
  List<dynamic> get conversationHistory => context.conversationHistory;

  /// Get intent type
  String get intentType => intent.type.name;

  /// Get intent confidence
  double get intentConfidence => intent.confidence;

  /// Check if request has attachments
  bool get hasAttachments => context.hasAttachments;

  /// Check if request has images
  bool get hasImages => context.hasImages;

  /// Copy request with new values
  AgentRequest copyWith({
    String? requestId,
    RequestContext? context,
    Intent? intent,
    DateTime? timestamp,
  }) {
    return AgentRequest(
      requestId: requestId ?? this.requestId,
      context: context ?? this.context,
      intent: intent ?? this.intent,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  List<Object?> get props => [requestId, context, intent, timestamp];

  @override
  String toString() {
    return 'AgentRequest(requestId: $requestId, intentType: $intentType, confidence: $intentConfidence)';
  }
}
