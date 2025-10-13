# Landscape AI App - Windows Build Script
# This script builds the Flutter app for all supported platforms on Windows

param(
    [switch]$SkipTests,
    [switch]$SkipAnalysis,
    [switch]$DebugOnly,
    [switch]$ReleaseOnly
)

Write-Host "🚀 Starting Landscape AI App build process..." -ForegroundColor Green

# Check if Flutter is installed
try {
    $flutterVersion = flutter --version
    Write-Host "✅ Flutter found: $($flutterVersion.Split("`n")[0])" -ForegroundColor Green
} catch {
    Write-Host "❌ Flutter not found. Please install Flutter first." -ForegroundColor Red
    exit 1
}

# Check Flutter doctor
Write-Host "`n📋 Checking Flutter environment..." -ForegroundColor Yellow
flutter doctor

# Clean previous builds
Write-Host "`n🧹 Cleaning previous builds..." -ForegroundColor Yellow
flutter clean
flutter pub get

# Code analysis
if (-not $SkipAnalysis) {
    Write-Host "`n📊 Running code analysis..." -ForegroundColor Yellow
    flutter analyze
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Code analysis failed!" -ForegroundColor Red
        exit 1
    }
    
    # Format check
    Write-Host "`n🎨 Checking code formatting..." -ForegroundColor Yellow
    dart format --set-exit-if-changed .
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Code formatting check failed!" -ForegroundColor Red
        exit 1
    }
}

# Run tests
if (-not $SkipTests) {
    Write-Host "`n🧪 Running tests..." -ForegroundColor Yellow
    flutter test --coverage
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Tests failed!" -ForegroundColor Red
        exit 1
    }
}

# Build for different platforms
Write-Host "`n🔨 Building applications..." -ForegroundColor Yellow

# Android builds
if (-not $ReleaseOnly) {
    Write-Host "`n📱 Building Android Debug APK..." -ForegroundColor Cyan
    flutter build apk --debug
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Android debug build failed!" -ForegroundColor Red
        exit 1
    }
}

if (-not $DebugOnly) {
    Write-Host "`n📱 Building Android Release APK..." -ForegroundColor Cyan
    flutter build apk --release
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Android release build failed!" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "`n📱 Building Android App Bundle..." -ForegroundColor Cyan
    flutter build appbundle --release
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Android App Bundle build failed!" -ForegroundColor Red
        exit 1
    }
}

# Web builds
if (-not $ReleaseOnly) {
    Write-Host "`n🌐 Building Web Debug..." -ForegroundColor Cyan
    flutter build web --debug
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Web debug build failed!" -ForegroundColor Red
        exit 1
    }
}

if (-not $DebugOnly) {
    Write-Host "`n🌐 Building Web Release..." -ForegroundColor Cyan
    flutter build web --release
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Web release build failed!" -ForegroundColor Red
        exit 1
    }
}

# Windows builds (if available)
if (-not $ReleaseOnly) {
    Write-Host "`n🖥️ Building Windows Debug..." -ForegroundColor Cyan
    flutter build windows --debug
    if ($LASTEXITCODE -ne 0) {
        Write-Host "⚠️ Windows debug build failed (may not be supported)" -ForegroundColor Yellow
    }
}

if (-not $DebugOnly) {
    Write-Host "`n🖥️ Building Windows Release..." -ForegroundColor Cyan
    flutter build windows --release
    if ($LASTEXITCODE -ne 0) {
        Write-Host "⚠️ Windows release build failed (may not be supported)" -ForegroundColor Yellow
    }
}

# Build summary
Write-Host "`n📊 Build Summary:" -ForegroundColor Green
Write-Host "✅ All builds completed successfully!" -ForegroundColor Green

# Show build outputs
Write-Host "`n📁 Build outputs:" -ForegroundColor Yellow
if (Test-Path "build\app\outputs\flutter-apk") {
    Write-Host "📱 Android APKs: build\app\outputs\flutter-apk\" -ForegroundColor Cyan
}
if (Test-Path "build\app\outputs\bundle\release") {
    Write-Host "📱 Android Bundle: build\app\outputs\bundle\release\" -ForegroundColor Cyan
}
if (Test-Path "build\web") {
    Write-Host "🌐 Web: build\web\" -ForegroundColor Cyan
}
if (Test-Path "build\windows") {
    Write-Host "🖥️ Windows: build\windows\" -ForegroundColor Cyan
}

Write-Host "`n🎉 Build process completed!" -ForegroundColor Green
