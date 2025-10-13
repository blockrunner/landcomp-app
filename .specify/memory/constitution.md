# LandComp AI App Constitution

## Core Principles

### I. Clean Architecture
Every feature MUST follow Clean Architecture principles with clear separation of concerns: Presentation → Domain → Data layers. Domain entities MUST be independent of external frameworks. Use cases MUST encapsulate business logic. Data sources MUST implement domain repository interfaces.

### II. Test-Driven Development (NON-NEGOTIABLE)
TDD mandatory: Tests written → User approved → Tests fail → Then implement. Red-Green-Refactor cycle strictly enforced. Unit tests MUST cover all business logic. Widget tests MUST verify UI behavior. Integration tests MUST validate user flows.

### III. State Management Consistency
Provider pattern MUST be used for state management across the application. State MUST be immutable using Equatable. Complex state MUST be managed through dedicated providers. Local state SHOULD be minimized in favor of global state when appropriate.

### IV. Dependency Injection
GetIt MUST be used for dependency injection. Injectable annotations MUST be applied to all service classes. Dependencies MUST be registered in injection.dart. Mock dependencies MUST be provided for testing.

### V. AI Integration Standards
AI features MUST have fallback mechanisms for offline scenarios. API responses MUST be cached locally using Hive. AI interactions MUST be logged for debugging. User data privacy MUST be protected in AI communications. For Google and Open AI API we must use proxy servers

## Technology Stack Requirements

- Flutter SDK: ^3.9.2 (minimum)
- State Management: Provider ^6.1.2
- Navigation: GoRouter ^14.2.3
- Local Storage: Hive ^2.2.3, SQLite via sqflite ^2.3.3+1
- Networking: Dio ^5.4.3+1
- Code Quality: Very Good Analysis ^6.0.0

## Development Workflow

All code MUST pass flutter analyze with zero warnings. All tests MUST pass before merge. Code coverage MUST be maintained above 80%. PR reviews MUST verify Clean Architecture compliance. Feature branches MUST be created from master. Hotfixes MUST be merged directly to master with immediate backport to develop.

## Governance

Constitution supersedes all other practices. Amendments require documentation, approval, and migration plan. All PRs/reviews must verify compliance. Complexity must be justified with business value. Use README.md for runtime development guidance.

**Version**: 1.0.0 | **Ratified**: 2025-01-27 | **Last Amended**: 2025-01-27