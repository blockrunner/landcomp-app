/// Tool Registry for managing tools in the orchestrator
/// 
/// This registry manages the registration, discovery, and metrics
/// of all tools in the system.
library;

import 'package:landcomp_app/core/tools/base/tool.dart';

/// Registry for managing tools
class ToolRegistry {
  ToolRegistry._();

  static final ToolRegistry _instance = ToolRegistry._();
  static ToolRegistry get instance => _instance;

  final Map<String, Tool> _tools = {};
  final Map<String, List<Duration>> _executionTimes = {};
  final Map<String, int> _successCounts = {};
  final Map<String, int> _errorCounts = {};

  /// Register a tool
  void registerTool(Tool tool) {
    _tools[tool.id] = tool;
    _executionTimes[tool.id] = [];
    _successCounts[tool.id] = 0;
    _errorCounts[tool.id] = 0;
    print('✅ Registered tool: ${tool.id} (${tool.name})');
  }

  /// Unregister a tool
  void unregisterTool(String toolId) {
    if (_tools.containsKey(toolId)) {
      _tools.remove(toolId);
      _executionTimes.remove(toolId);
      _successCounts.remove(toolId);
      _errorCounts.remove(toolId);
      print('🗑️ Unregistered tool: $toolId');
    }
  }

  /// Get tool by ID
  Tool? getTool(String toolId) {
    return _tools[toolId];
  }

  /// Get all registered tools
  List<Tool> getAllTools() {
    return _tools.values.toList();
  }

  /// Get tools by capability
  List<Tool> getToolsByCapability(String capability) {
    return _tools.values
        .where((tool) => tool.requiredCapabilities.contains(capability))
        .toList();
  }

  /// Get tools that support specific capabilities
  List<Tool> getToolsByCapabilities(List<String> capabilities) {
    return _tools.values
        .where((tool) => capabilities.every((cap) => tool.requiredCapabilities.contains(cap)))
        .toList();
  }

  /// Check if tool is registered
  bool isToolRegistered(String toolId) {
    return _tools.containsKey(toolId);
  }

  /// Get number of registered tools
  int get toolCount => _tools.length;

  /// Track tool execution metrics
  void trackExecution(String toolId, Duration executionTime, bool success) {
    if (_executionTimes.containsKey(toolId)) {
      _executionTimes[toolId]!.add(executionTime);
      
      // Keep only last 100 execution times
      if (_executionTimes[toolId]!.length > 100) {
        _executionTimes[toolId]!.removeAt(0);
      }
    }

    if (success) {
      _successCounts[toolId] = (_successCounts[toolId] ?? 0) + 1;
    } else {
      _errorCounts[toolId] = (_errorCounts[toolId] ?? 0) + 1;
    }
  }

  /// Get metrics for a specific tool
  Map<String, dynamic> getToolMetrics(String toolId) {
    final tool = _tools[toolId];
    if (tool == null) {
      return {'error': 'Tool not found'};
    }

    final executionTimes = _executionTimes[toolId] ?? [];
    final successCount = _successCounts[toolId] ?? 0;
    final errorCount = _errorCounts[toolId] ?? 0;
    final totalCount = successCount + errorCount;

    return {
      'toolId': toolId,
      'toolName': tool.name,
      'description': tool.description,
      'requiredCapabilities': tool.requiredCapabilities,
      'totalExecutions': totalCount,
      'successCount': successCount,
      'errorCount': errorCount,
      'successRate': totalCount > 0 ? successCount / totalCount : 0.0,
      'averageExecutionTime': executionTimes.isNotEmpty
          ? executionTimes.map((d) => d.inMilliseconds).reduce((a, b) => a + b) / executionTimes.length
          : 0.0,
      'minExecutionTime': executionTimes.isNotEmpty
          ? executionTimes.map((d) => d.inMilliseconds).reduce((a, b) => a < b ? a : b)
          : 0,
      'maxExecutionTime': executionTimes.isNotEmpty
          ? executionTimes.map((d) => d.inMilliseconds).reduce((a, b) => a > b ? a : b)
          : 0,
    };
  }

  /// Get metrics for all tools
  Map<String, dynamic> getRegistryMetrics() {
    final toolMetrics = <String, Map<String, dynamic>>{};
    for (final toolId in _tools.keys) {
      toolMetrics[toolId] = getToolMetrics(toolId);
    }

    final totalExecutions = _successCounts.values.fold(0, (a, b) => a + b) +
        _errorCounts.values.fold(0, (a, b) => a + b);

    return {
      'totalTools': _tools.length,
      'totalExecutions': totalExecutions,
      'tools': toolMetrics,
    };
  }

  /// Get all capabilities available in the registry
  Set<String> getAllCapabilities() {
    final capabilities = <String>{};
    for (final tool in _tools.values) {
      capabilities.addAll(tool.requiredCapabilities);
    }
    return capabilities;
  }

  /// Clear all metrics
  void clearMetrics() {
    for (final toolId in _tools.keys) {
      _executionTimes[toolId]?.clear();
      _successCounts[toolId] = 0;
      _errorCounts[toolId] = 0;
    }
  }

  /// Initialize all registered tools
  Future<void> initializeAllTools() async {
    for (final tool in _tools.values) {
      try {
        await tool.initialize();
        print('✅ Initialized tool: ${tool.id}');
      } catch (e) {
        print('❌ Failed to initialize tool ${tool.id}: $e');
      }
    }
  }

  /// Dispose all registered tools
  Future<void> disposeAllTools() async {
    for (final tool in _tools.values) {
      try {
        await tool.dispose();
        print('✅ Disposed tool: ${tool.id}');
      } catch (e) {
        print('❌ Failed to dispose tool ${tool.id}: $e');
      }
    }
  }
}
