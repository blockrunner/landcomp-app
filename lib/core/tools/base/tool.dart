/// Base Tool interface for orchestrator
/// 
/// This interface defines the contract for all tools in the system,
/// including capability checking and execution.
library;

import 'package:landcomp_app/shared/models/context.dart';
import 'package:landcomp_app/core/tools/base/tool_result.dart';

/// Base interface for all tools
abstract class Tool {
  /// Unique identifier for the tool
  String get id;

  /// Display name of the tool
  String get name;

  /// Description of what this tool does
  String get description;

  /// List of capabilities required to use this tool
  List<String> get requiredCapabilities;

  /// Check if this tool can execute with the given context
  Future<bool> canExecute(RequestContext context);

  /// Execute the tool with given parameters
  Future<ToolResult> execute(Map<String, dynamic> parameters);

  /// Get performance metrics for this tool
  Map<String, dynamic> getMetrics();

  /// Initialize the tool (optional)
  Future<void> initialize() async {}

  /// Dispose the tool (optional)
  Future<void> dispose() async {}
}

/// Capability constants for tools
class ToolCapabilities {
  static const String vision = 'vision';
  static const String textGeneration = 'text_generation';
  static const String imageGeneration = 'image_generation';
  static const String analysis = 'analysis';
  static const String search = 'search';
  static const String fileProcessing = 'file_processing';
  static const String apiIntegration = 'api_integration';
  static const String dataProcessing = 'data_processing';
}
