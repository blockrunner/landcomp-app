# Landscape AI App - Development Makefile
# This Makefile provides convenient commands for development

.PHONY: help dev-setup build-all test-full deploy-dev clean format analyze

# Default target
help: ## Show this help message
	@echo "Landscape AI App - Development Commands"
	@echo "======================================"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Development setup
dev-setup: ## Setup development environment
	@echo "🚀 Setting up development environment..."
	flutter doctor
	flutter pub get
	@echo "✅ Development environment ready!"

# Build commands
build-all: ## Build for all platforms
	@echo "🔨 Building for all platforms..."
	flutter clean
	flutter pub get
	flutter analyze
	flutter test --coverage
	flutter build apk --debug
	flutter build apk --release
	flutter build appbundle --release
	flutter build web --release
	@echo "✅ All builds completed!"

build-android: ## Build Android APK and Bundle
	@echo "📱 Building Android..."
	flutter build apk --debug
	flutter build apk --release
	flutter build appbundle --release
	@echo "✅ Android build completed!"

build-web: ## Build Web application
	@echo "🌐 Building Web..."
	flutter build web --debug
	flutter build web --release
	@echo "✅ Web build completed!"

build-ios: ## Build iOS application (macOS only)
	@echo "🍎 Building iOS..."
	cd ios && pod install && cd ..
	flutter build ios --simulator
	flutter build ios --release --no-codesign
	@echo "✅ iOS build completed!"

# Testing
test-full: ## Run all tests with coverage
	@echo "🧪 Running full test suite..."
	flutter test --coverage
	@echo "✅ Tests completed!"

test-unit: ## Run unit tests only
	@echo "🧪 Running unit tests..."
	flutter test test/unit/
	@echo "✅ Unit tests completed!"

test-widget: ## Run widget tests only
	@echo "🧪 Running widget tests..."
	flutter test test/widget/
	@echo "✅ Widget tests completed!"

test-integration: ## Run integration tests only
	@echo "🧪 Running integration tests..."
	flutter test integration_test/
	@echo "✅ Integration tests completed!"

# Code quality
format: ## Format code
	@echo "🎨 Formatting code..."
	dart format .
	@echo "✅ Code formatted!"

analyze: ## Analyze code
	@echo "📊 Analyzing code..."
	flutter analyze
	@echo "✅ Code analysis completed!"

lint: ## Run linting
	@echo "🔍 Running lints..."
	flutter analyze --no-fatal-infos
	@echo "✅ Linting completed!"

# Development
dev: ## Start development server
	@echo "🚀 Starting development server..."
	flutter run

dev-web: ## Start web development server
	@echo "🌐 Starting web development server..."
	flutter run -d chrome

dev-android: ## Start Android development
	@echo "📱 Starting Android development..."
	flutter run -d android

dev-ios: ## Start iOS development (macOS only)
	@echo "🍎 Starting iOS development..."
	flutter run -d ios

# Deployment
deploy-dev: ## Deploy to development environment
	@echo "🚀 Deploying to development..."
	flutter build web --release
	@echo "✅ Deployed to development!"

deploy-prod: ## Deploy to production environment
	@echo "🚀 Deploying to production..."
	flutter build web --release
	@echo "✅ Deployed to production!"

# Maintenance
clean: ## Clean build artifacts
	@echo "🧹 Cleaning build artifacts..."
	flutter clean
	flutter pub get
	@echo "✅ Clean completed!"

clean-deps: ## Clean dependencies
	@echo "🧹 Cleaning dependencies..."
	flutter clean
	rm -rf .dart_tool/
	rm -rf build/
	flutter pub get
	@echo "✅ Dependencies cleaned!"

# Code generation
generate: ## Generate code (injectable, json_serializable, etc.)
	@echo "⚙️ Generating code..."
	flutter packages pub run build_runner build --delete-conflicting-outputs
	@echo "✅ Code generation completed!"

generate-watch: ## Watch for changes and generate code
	@echo "⚙️ Watching for changes..."
	flutter packages pub run build_runner watch --delete-conflicting-outputs

# Dependencies
upgrade: ## Upgrade dependencies
	@echo "⬆️ Upgrading dependencies..."
	flutter pub upgrade
	@echo "✅ Dependencies upgraded!"

outdated: ## Check for outdated dependencies
	@echo "📋 Checking outdated dependencies..."
	flutter pub outdated
	@echo "✅ Outdated dependencies checked!"

# Platform specific
enable-web: ## Enable web platform
	@echo "🌐 Enabling web platform..."
	flutter config --enable-web
	@echo "✅ Web platform enabled!"

enable-android: ## Enable Android platform
	@echo "📱 Enabling Android platform..."
	flutter config --enable-android
	@echo "✅ Android platform enabled!"

enable-ios: ## Enable iOS platform
	@echo "🍎 Enabling iOS platform..."
	flutter config --enable-ios
	@echo "✅ iOS platform enabled!"

# Health checks
doctor: ## Run Flutter doctor
	@echo "🏥 Running Flutter doctor..."
	flutter doctor -v
	@echo "✅ Flutter doctor completed!"

check: ## Run all checks (format, analyze, test)
	@echo "🔍 Running all checks..."
	$(MAKE) format
	$(MAKE) analyze
	$(MAKE) test-full
	@echo "✅ All checks completed!"

# Quick development cycle
quick: ## Quick development cycle (format, analyze, test)
	@echo "⚡ Quick development cycle..."
	$(MAKE) format
	$(MAKE) analyze
	$(MAKE) test-unit
	@echo "✅ Quick cycle completed!"

# Docker commands
docker-build: ## Build Docker image
	@echo "🐳 Building Docker image..."
	docker build -t landcomp-app:latest .
	@echo "✅ Docker image built!"

docker-run: ## Run Docker container locally
	@echo "🐳 Running Docker container..."
	docker run -p 8080:80 --name landcomp-app landcomp-app:latest
	@echo "✅ Docker container running on http://localhost:8080"

docker-stop: ## Stop Docker container
	@echo "🐳 Stopping Docker container..."
	docker stop landcomp-app || true
	docker rm landcomp-app || true
	@echo "✅ Docker container stopped!"

docker-dev: ## Run development environment with Docker Compose
	@echo "🐳 Starting development environment..."
	docker-compose up -d
	@echo "✅ Development environment running!"

docker-prod: ## Run production environment with Docker Compose
	@echo "🐳 Starting production environment..."
	docker-compose -f docker-compose.prod.yml up -d
	@echo "✅ Production environment running!"

docker-logs: ## View Docker container logs
	@echo "🐳 Viewing Docker logs..."
	docker-compose logs -f

docker-clean: ## Clean Docker containers and images
	@echo "🐳 Cleaning Docker environment..."
	docker-compose down || true
	docker system prune -f
	@echo "✅ Docker environment cleaned!"

# Deployment commands
deploy-setup: ## Setup deployment environment on server
	@echo "🚀 Setting up deployment environment..."
	chmod +x scripts/deploy.sh
	./scripts/deploy.sh
	@echo "✅ Deployment environment setup completed!"

deploy: ## Deploy application to server
	@echo "🚀 Deploying application..."
	./scripts/deploy.sh --deploy
	@echo "✅ Application deployed!"

# Health checks
health: ## Check application health
	@echo "🏥 Checking application health..."
	curl -f http://localhost/health || echo "❌ Health check failed"
	@echo "✅ Health check completed!"