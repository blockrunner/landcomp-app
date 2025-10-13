/// Base Agent interface for orchestrator
/// 
/// This interface defines the contract for all agents in the system,
/// including capability checking and request execution.
library;

import 'package:landcomp_app/shared/models/intent.dart';
import 'package:landcomp_app/shared/models/context.dart';
import 'package:landcomp_app/shared/models/agent_request.dart';
import 'package:landcomp_app/shared/models/agent_response.dart';

/// Base interface for all agents
abstract class Agent {
  /// Unique identifier for the agent
  String get id;

  /// Display name of the agent
  String get name;

  /// List of capabilities this agent supports
  List<String> get capabilities;

  /// Check if this agent can handle the given intent and context
  Future<bool> canHandle(Intent intent, RequestContext context);

  /// Execute a request and return a response
  Future<AgentResponse> execute(AgentRequest request);

  /// Get performance metrics for this agent
  Map<String, dynamic> getMetrics();

  /// Initialize the agent (optional)
  Future<void> initialize() async {}

  /// Dispose the agent (optional)
  Future<void> dispose() async {}
}

/// Capability constants for agents
class AgentCapabilities {
  static const String textGeneration = 'text_generation';
  static const String imageAnalysis = 'image_analysis';
  static const String imageGeneration = 'image_generation';
  static const String consultation = 'consultation';
  static const String planning = 'planning';
  static const String analysis = 'analysis';
  static const String modification = 'modification';
  static const String gardening = 'gardening';
  static const String landscapeDesign = 'landscape_design';
  static const String construction = 'construction';
  static const String ecology = 'ecology';
}
