/// Agent Registry for managing agents in the orchestrator
///
/// This registry manages the registration, discovery, and metrics
/// of all agents in the system.
library;

import 'package:landcomp_app/core/agents/base/agent.dart';

/// Registry for managing agents
class AgentRegistry {
  AgentRegistry._();

  static final AgentRegistry _instance = AgentRegistry._();
  static AgentRegistry get instance => _instance;

  final Map<String, Agent> _agents = {};
  final Map<String, List<Duration>> _executionTimes = {};
  final Map<String, int> _successCounts = {};
  final Map<String, int> _errorCounts = {};

  /// Register an agent
  void registerAgent(Agent agent) {
    _agents[agent.id] = agent;
    _executionTimes[agent.id] = [];
    _successCounts[agent.id] = 0;
    _errorCounts[agent.id] = 0;
    print('✅ Registered agent: ${agent.id} (${agent.name})');
  }

  /// Unregister an agent
  void unregisterAgent(String agentId) {
    if (_agents.containsKey(agentId)) {
      _agents.remove(agentId);
      _executionTimes.remove(agentId);
      _successCounts.remove(agentId);
      _errorCounts.remove(agentId);
      print('🗑️ Unregistered agent: $agentId');
    }
  }

  /// Get agent by ID
  Agent? getAgent(String agentId) {
    return _agents[agentId];
  }

  /// Get all registered agents
  List<Agent> getAllAgents() {
    return _agents.values.toList();
  }

  /// Get agents by capability
  List<Agent> getAgentsByCapability(String capability) {
    return _agents.values
        .where((agent) => agent.capabilities.contains(capability))
        .toList();
  }

  /// Get agents that can handle specific capabilities
  List<Agent> getAgentsByCapabilities(List<String> capabilities) {
    return _agents.values
        .where(
          (agent) =>
              capabilities.every((cap) => agent.capabilities.contains(cap)),
        )
        .toList();
  }

  /// Get agents that can handle any of the specified capabilities
  List<Agent> getCapableAgents(List<String> requiredCapabilities) {
    return _agents.values
        .where(
          (agent) => requiredCapabilities.any(
            (cap) => agent.capabilities.contains(cap),
          ),
        )
        .toList();
  }

  /// Get all agents metrics
  Map<String, dynamic> getAllAgentsMetrics() {
    return getRegistryMetrics();
  }

  /// Check if agent is registered
  bool isAgentRegistered(String agentId) {
    return _agents.containsKey(agentId);
  }

  /// Get number of registered agents
  int get agentCount => _agents.length;

  /// Track agent execution metrics
  void trackExecution(String agentId, Duration executionTime, bool success) {
    if (_executionTimes.containsKey(agentId)) {
      _executionTimes[agentId]!.add(executionTime);

      // Keep only last 100 execution times
      if (_executionTimes[agentId]!.length > 100) {
        _executionTimes[agentId]!.removeAt(0);
      }
    }

    if (success) {
      _successCounts[agentId] = (_successCounts[agentId] ?? 0) + 1;
    } else {
      _errorCounts[agentId] = (_errorCounts[agentId] ?? 0) + 1;
    }
  }

  /// Get metrics for a specific agent
  Map<String, dynamic> getAgentMetrics(String agentId) {
    final agent = _agents[agentId];
    if (agent == null) {
      return {'error': 'Agent not found'};
    }

    final executionTimes = _executionTimes[agentId] ?? [];
    final successCount = _successCounts[agentId] ?? 0;
    final errorCount = _errorCounts[agentId] ?? 0;
    final totalCount = successCount + errorCount;

    return {
      'agentId': agentId,
      'agentName': agent.name,
      'capabilities': agent.capabilities,
      'totalExecutions': totalCount,
      'successCount': successCount,
      'errorCount': errorCount,
      'successRate': totalCount > 0 ? successCount / totalCount : 0.0,
      'averageExecutionTime': executionTimes.isNotEmpty
          ? executionTimes
                    .map((d) => d.inMilliseconds)
                    .reduce((a, b) => a + b) /
                executionTimes.length
          : 0.0,
      'minExecutionTime': executionTimes.isNotEmpty
          ? executionTimes
                .map((d) => d.inMilliseconds)
                .reduce((a, b) => a < b ? a : b)
          : 0,
      'maxExecutionTime': executionTimes.isNotEmpty
          ? executionTimes
                .map((d) => d.inMilliseconds)
                .reduce((a, b) => a > b ? a : b)
          : 0,
    };
  }

  /// Get metrics for all agents
  Map<String, dynamic> getRegistryMetrics() {
    final agentMetrics = <String, Map<String, dynamic>>{};
    for (final agentId in _agents.keys) {
      agentMetrics[agentId] = getAgentMetrics(agentId);
    }

    final totalExecutions =
        _successCounts.values.fold(0, (a, b) => a + b) +
        _errorCounts.values.fold(0, (a, b) => a + b);

    return {
      'totalAgents': _agents.length,
      'totalExecutions': totalExecutions,
      'agents': agentMetrics,
    };
  }

  /// Get all capabilities available in the registry
  Set<String> getAllCapabilities() {
    final capabilities = <String>{};
    for (final agent in _agents.values) {
      capabilities.addAll(agent.capabilities);
    }
    return capabilities;
  }

  /// Clear all metrics
  void clearMetrics() {
    for (final agentId in _agents.keys) {
      _executionTimes[agentId]?.clear();
      _successCounts[agentId] = 0;
      _errorCounts[agentId] = 0;
    }
  }

  /// Initialize all registered agents
  Future<void> initializeAllAgents() async {
    for (final agent in _agents.values) {
      try {
        await agent.initialize();
        print('✅ Initialized agent: ${agent.id}');
      } catch (e) {
        print('❌ Failed to initialize agent ${agent.id}: $e');
      }
    }
  }

  /// Dispose all registered agents
  Future<void> disposeAllAgents() async {
    for (final agent in _agents.values) {
      try {
        await agent.dispose();
        print('✅ Disposed agent: ${agent.id}');
      } catch (e) {
        print('❌ Failed to dispose agent ${agent.id}: $e');
      }
    }
  }
}
