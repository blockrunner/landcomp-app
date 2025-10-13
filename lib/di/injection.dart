/// Dependency injection configuration
/// 
/// This file contains the dependency injection setup using GetIt
/// for managing dependencies throughout the application.
library;

import 'package:get_it/get_it.dart';
// import 'package:injectable/injectable.dart';

// import 'injection.config.dart';

/// Global service locator instance
final GetIt getIt = GetIt.instance;

/// Configures all dependencies for the application
Future<void> configureDependencies() async {
  // TODO: Configure dependencies when injection.config.dart is generated
  // getIt.init();
}

/// Resets all dependencies (useful for testing)
Future<void> resetDependencies() async {
  await getIt.reset();
}
