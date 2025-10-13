# LandComp

AI-powered landscape design and gardening assistant app built with Flutter.

## 🚀 Features

- **AI Chat Interface**: Interactive chat with specialized AI agents for landscape design
- **Multi-Platform Support**: Android, iOS, and Web
- **Specialized Agents**: 
  - Landscape Designer
  - Gardener
  - Builder
  - Ecologist
- **Offline Mode**: Basic functionality without internet connection
- **Multi-language Support**: Russian and English
- **Modern UI**: Material Design 3 with light/dark themes

## 🏗️ Architecture

This project follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── app/                    # App configuration
├── core/                   # Core functionality
├── features/               # Feature modules
│   ├── chat/              # Chat feature
│   ├── settings/          # Settings feature
│   └── profile/           # Profile feature
├── shared/                # Shared components
└── di/                    # Dependency injection
```

### Technology Stack

- **Framework**: Flutter 3.24+
- **State Management**: Provider
- **Dependency Injection**: GetIt + Injectable
- **Navigation**: Go Router
- **Local Storage**: SQLite + Hive
- **Networking**: Dio
- **AI Integration**: OpenAI GPT-4 / Google Gemini

## 🛠️ Development Setup

### Prerequisites

- Flutter SDK 3.24+ (stable channel)
- Dart 3.5+
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd landscape-ai-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # Web
   flutter run -d chrome
   
   # Android (requires Android SDK)
   flutter run -d android
   
   # iOS (macOS only)
   flutter run -d ios
   ```

## 📱 Building for Production

### Web
```bash
flutter build web --release
```

### Android
```bash
# APK
flutter build apk --release

# App Bundle
flutter build appbundle --release
```

### iOS (macOS only)
```bash
flutter build ios --release --no-codesign
```

### Using Build Scripts

**Windows:**
```powershell
.\scripts\build.ps1
```

**Linux/macOS:**
```bash
./scripts/build.sh
```

**Using Makefile:**
```bash
make build-all
```

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test types
make test-unit
make test-widget
make test-integration
```

## 📊 Code Quality

### Analysis
```bash
flutter analyze
```

### Formatting
```bash
dart format .
```

### Linting
```bash
make lint
```

## 🚀 CI/CD

The project includes GitHub Actions workflows for:

- **Android Build**: Builds APK and App Bundle
- **iOS Build**: Builds iOS app (macOS runners)
- **Web Build**: Builds and deploys web version
- **Quality Checks**: Code analysis, testing, and coverage

### Workflow Files
- `.github/workflows/android.yml`
- `.github/workflows/ios.yml`
- `.github/workflows/web.yml`
- `.github/workflows/quality.yml`

## 🔧 Development Commands

Using the provided Makefile:

```bash
# Setup development environment
make dev-setup

# Quick development cycle
make quick

# Run all checks
make check

# Clean build artifacts
make clean

# Generate code (injectable, etc.)
make generate

# Upgrade dependencies
make upgrade
```

## 📁 Project Structure

```
├── lib/
│   ├── app/                    # App configuration
│   │   ├── app.dart           # Main app widget
│   │   ├── router.dart        # Navigation setup
│   │   └── theme.dart         # Theme configuration
│   ├── core/                   # Core functionality
│   │   ├── constants/         # App constants
│   │   ├── errors/            # Error handling
│   │   ├── network/           # Network configuration
│   │   ├── storage/           # Storage abstractions
│   │   └── utils/             # Utility functions
│   ├── features/               # Feature modules
│   │   ├── chat/              # Chat feature
│   │   │   ├── data/          # Data layer
│   │   │   ├── domain/        # Domain layer
│   │   │   └── presentation/  # Presentation layer
│   │   ├── settings/          # Settings feature
│   │   └── profile/           # Profile feature
│   ├── shared/                # Shared components
│   │   ├── widgets/           # Common widgets
│   │   ├── models/            # Shared models
│   │   └── services/          # Shared services
│   └── di/                    # Dependency injection
├── test/                      # Tests
├── scripts/                   # Build scripts
├── .github/workflows/         # CI/CD workflows
└── assets/                    # App assets
```

## 🎯 Roadmap

### Version 1.0 (Current)
- ✅ Basic chat interface
- ✅ Multi-platform support
- ✅ Settings and profile pages
- ✅ CI/CD pipeline

### Version 1.1 (Planned)
- [ ] AI service integration
- [ ] Chat history persistence
- [ ] Message search
- [ ] Export functionality

### Version 1.2 (Future)
- [ ] Voice input/output
- [ ] Image upload support
- [ ] AR features
- [ ] Social features

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow Clean Architecture principles
- Write tests for new features
- Maintain 90%+ test coverage
- Use meaningful commit messages
- Follow the existing code style

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:
- Create an issue in the repository
- Check the documentation
- Review the code examples

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- OpenAI and Google for AI services
- The open-source community for various packages used

---

**Built with ❤️ using Flutter and AI**