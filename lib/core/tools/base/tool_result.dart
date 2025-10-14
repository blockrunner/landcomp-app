/// Tool execution result model
///
/// This model represents the result of executing a tool,
/// including success status, data, and execution metrics.
library;

import 'package:equatable/equatable.dart';

/// Result of tool execution
class ToolResult extends Equatable {

  /// Create tool result
  const ToolResult({
    required this.toolId,
    required this.isSuccess,
    required this.executionTime,
    this.data,
    this.error,
    this.metadata = const {},
  });
  /// Create successful result
  factory ToolResult.success({
    required String toolId,
    required dynamic data,
    Duration? executionTime,
    Map<String, dynamic>? metadata,
  }) {
    return ToolResult(
      toolId: toolId,
      isSuccess: true,
      data: data,
      executionTime: executionTime ?? Duration.zero,
      metadata: metadata ?? {},
    );
  }

  /// Create error result
  factory ToolResult.error({
    required String toolId,
    required String error,
    Duration? executionTime,
    Map<String, dynamic>? metadata,
  }) {
    return ToolResult(
      toolId: toolId,
      isSuccess: false,
      error: error,
      executionTime: executionTime ?? Duration.zero,
      metadata: metadata ?? {},
    );
  }

  /// Create result from JSON
  factory ToolResult.fromJson(Map<String, dynamic> json) {
    return ToolResult(
      toolId: json['toolId'] as String,
      isSuccess: json['isSuccess'] as bool,
      data: json['data'],
      error: json['error'] as String?,
      executionTime: Duration(milliseconds: json['executionTime'] as int),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  /// Tool ID that produced this result
  final String toolId;

  /// Whether the execution was successful
  final bool isSuccess;

  /// Result data
  final dynamic data;

  /// Error message (if failed)
  final String? error;

  /// Execution time
  final Duration executionTime;

  /// Additional metadata
  final Map<String, dynamic> metadata;

  /// Check if execution was fast (< 1 second)
  bool get isFastExecution => executionTime.inMilliseconds < 1000;

  /// Check if execution was slow (> 5 seconds)
  bool get isSlowExecution => executionTime.inMilliseconds > 5000;

  /// Get execution time in milliseconds
  int get executionTimeMs => executionTime.inMilliseconds;

  /// Copy result with new values
  ToolResult copyWith({
    String? toolId,
    bool? isSuccess,
    dynamic data,
    String? error,
    Duration? executionTime,
    Map<String, dynamic>? metadata,
  }) {
    return ToolResult(
      toolId: toolId ?? this.toolId,
      isSuccess: isSuccess ?? this.isSuccess,
      data: data ?? this.data,
      error: error ?? this.error,
      executionTime: executionTime ?? this.executionTime,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'toolId': toolId,
      'isSuccess': isSuccess,
      'data': data,
      'error': error,
      'executionTime': executionTime.inMilliseconds,
      'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [
    toolId,
    isSuccess,
    data,
    error,
    executionTime,
    metadata,
  ];

  @override
  String toString() {
    return 'ToolResult(toolId: $toolId, isSuccess: $isSuccess, executionTime: ${executionTimeMs}ms)';
  }
}
