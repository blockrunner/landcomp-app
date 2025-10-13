/// Metrics Tracker for orchestrator components
/// 
/// This utility tracks performance metrics for agents, tools, and other components
/// in the orchestrator system.
library;

/// Metrics tracking service
class MetricsTracker {
  MetricsTracker._();

  static final MetricsTracker _instance = MetricsTracker._();
  static MetricsTracker get instance => _instance;

  final Map<String, List<Duration>> _executionTimes = {};
  final Map<String, int> _successCounts = {};
  final Map<String, int> _errorCounts = {};
  final Map<String, DateTime> _lastExecutionTimes = {};

  /// Track execution of a component
  void trackExecution(String component, Duration duration, bool success) {
    // Initialize if not exists
    _executionTimes[component] ??= [];
    _successCounts[component] ??= 0;
    _errorCounts[component] ??= 0;

    // Add execution time
    _executionTimes[component]!.add(duration);
    
    // Keep only last 100 execution times
    if (_executionTimes[component]!.length > 100) {
      _executionTimes[component]!.removeAt(0);
    }

    // Update counts
    if (success) {
      _successCounts[component] = _successCounts[component]! + 1;
    } else {
      _errorCounts[component] = _errorCounts[component]! + 1;
    }

    // Update last execution time
    _lastExecutionTimes[component] = DateTime.now();
  }

  /// Get metrics for a specific component
  Map<String, dynamic> getMetrics(String component) {
    final executionTimes = _executionTimes[component] ?? [];
    final successCount = _successCounts[component] ?? 0;
    final errorCount = _errorCounts[component] ?? 0;
    final totalCount = successCount + errorCount;
    final lastExecution = _lastExecutionTimes[component];

    if (executionTimes.isEmpty) {
      return {
        'component': component,
        'totalExecutions': totalCount,
        'successCount': successCount,
        'errorCount': errorCount,
        'successRate': totalCount > 0 ? successCount / totalCount : 0.0,
        'averageExecutionTime': 0.0,
        'minExecutionTime': 0,
        'maxExecutionTime': 0,
        'lastExecution': lastExecution?.toIso8601String(),
      };
    }

    final timesInMs = executionTimes.map((d) => d.inMilliseconds).toList();
    final averageTime = timesInMs.reduce((a, b) => a + b) / timesInMs.length;
    final minTime = timesInMs.reduce((a, b) => a < b ? a : b);
    final maxTime = timesInMs.reduce((a, b) => a > b ? a : b);

    return {
      'component': component,
      'totalExecutions': totalCount,
      'successCount': successCount,
      'errorCount': errorCount,
      'successRate': totalCount > 0 ? successCount / totalCount : 0.0,
      'averageExecutionTime': averageTime,
      'minExecutionTime': minTime,
      'maxExecutionTime': maxTime,
      'lastExecution': lastExecution?.toIso8601String(),
    };
  }

  /// Get metrics for all components
  Map<String, dynamic> getAllMetrics() {
    final componentMetrics = <String, Map<String, dynamic>>{};
    
    for (final component in _executionTimes.keys) {
      componentMetrics[component] = getMetrics(component);
    }

    final totalExecutions = _successCounts.values.fold(0, (a, b) => a + b) +
        _errorCounts.values.fold(0, (a, b) => a + b);

    return {
      'totalComponents': _executionTimes.length,
      'totalExecutions': totalExecutions,
      'components': componentMetrics,
    };
  }

  /// Get top performing components by success rate
  List<Map<String, dynamic>> getTopPerformers({int limit = 10}) {
    final allMetrics = getAllMetrics()['components'] as Map<String, dynamic>;
    final components = <Map<String, dynamic>>[];

    for (final entry in allMetrics.entries) {
      final metrics = entry.value as Map<String, dynamic>;
      if ((metrics['totalExecutions'] as int) > 0) {
        components.add(metrics);
      }
    }

    components.sort((a, b) => (b['successRate'] as double).compareTo(a['successRate'] as double));
    
    return components.take(limit).toList();
  }

  /// Get slowest components by average execution time
  List<Map<String, dynamic>> getSlowestComponents({int limit = 10}) {
    final allMetrics = getAllMetrics()['components'] as Map<String, dynamic>;
    final components = <Map<String, dynamic>>[];

    for (final entry in allMetrics.entries) {
      final metrics = entry.value as Map<String, dynamic>;
      if ((metrics['totalExecutions'] as int) > 0) {
        components.add(metrics);
      }
    }

    components.sort((a, b) => (b['averageExecutionTime'] as double).compareTo(a['averageExecutionTime'] as double));
    
    return components.take(limit).toList();
  }

  /// Get components with errors
  List<Map<String, dynamic>> getComponentsWithErrors() {
    final allMetrics = getAllMetrics()['components'] as Map<String, dynamic>;
    final components = <Map<String, dynamic>>[];

    for (final entry in allMetrics.entries) {
      final metrics = entry.value as Map<String, dynamic>;
      if ((metrics['errorCount'] as int) > 0) {
        components.add(metrics);
      }
    }

    components.sort((a, b) => (b['errorCount'] as int).compareTo(a['errorCount'] as int));
    
    return components;
  }

  /// Reset metrics for a specific component
  void resetComponent(String component) {
    _executionTimes.remove(component);
    _successCounts.remove(component);
    _errorCounts.remove(component);
    _lastExecutionTimes.remove(component);
    print('🔄 Reset metrics for component: $component');
  }

  /// Reset all metrics
  void reset() {
    _executionTimes.clear();
    _successCounts.clear();
    _errorCounts.clear();
    _lastExecutionTimes.clear();
    print('🔄 Reset all metrics');
  }

  /// Get summary statistics
  Map<String, dynamic> getSummary() {
    final allMetrics = getAllMetrics();
    final components = allMetrics['components'] as Map<String, dynamic>;
    
    if (components.isEmpty) {
      return {
        'totalComponents': 0,
        'totalExecutions': 0,
        'averageSuccessRate': 0.0,
        'averageExecutionTime': 0.0,
      };
    }

    final successRates = components.values
        .map((m) => m['successRate'] as double)
        .where((rate) => rate > 0)
        .toList();
    
    final executionTimes = components.values
        .map((m) => m['averageExecutionTime'] as double)
        .where((time) => time > 0)
        .toList();

    return {
      'totalComponents': components.length,
      'totalExecutions': allMetrics['totalExecutions'],
      'averageSuccessRate': successRates.isNotEmpty 
          ? successRates.reduce((a, b) => a + b) / successRates.length 
          : 0.0,
      'averageExecutionTime': executionTimes.isNotEmpty 
          ? executionTimes.reduce((a, b) => a + b) / executionTimes.length 
          : 0.0,
    };
  }
}
