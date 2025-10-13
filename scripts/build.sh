#!/bin/bash
# Landscape AI App - Linux/macOS Build Script
# This script builds the Flutter app for all supported platforms

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Parse command line arguments
SKIP_TESTS=false
SKIP_ANALYSIS=false
DEBUG_ONLY=false
RELEASE_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-tests)
            SKIP_TESTS=true
            shift
            ;;
        --skip-analysis)
            SKIP_ANALYSIS=true
            shift
            ;;
        --debug-only)
            DEBUG_ONLY=true
            shift
            ;;
        --release-only)
            RELEASE_ONLY=true
            shift
            ;;
        *)
            echo "Unknown option $1"
            exit 1
            ;;
    esac
done

echo -e "${GREEN}🚀 Starting Landscape AI App build process...${NC}"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter not found. Please install Flutter first.${NC}"
    exit 1
fi

# Check Flutter version
FLUTTER_VERSION=$(flutter --version | head -n 1)
echo -e "${GREEN}✅ Flutter found: $FLUTTER_VERSION${NC}"

# Check Flutter doctor
echo -e "\n${YELLOW}📋 Checking Flutter environment...${NC}"
flutter doctor

# Clean previous builds
echo -e "\n${YELLOW}🧹 Cleaning previous builds...${NC}"
flutter clean
flutter pub get

# Code analysis
if [ "$SKIP_ANALYSIS" = false ]; then
    echo -e "\n${YELLOW}📊 Running code analysis...${NC}"
    flutter analyze
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Code analysis failed!${NC}"
        exit 1
    fi
    
    # Format check
    echo -e "\n${YELLOW}🎨 Checking code formatting...${NC}"
    dart format --set-exit-if-changed .
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Code formatting check failed!${NC}"
        exit 1
    fi
fi

# Run tests
if [ "$SKIP_TESTS" = false ]; then
    echo -e "\n${YELLOW}🧪 Running tests...${NC}"
    flutter test --coverage
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Tests failed!${NC}"
        exit 1
    fi
fi

# Build for different platforms
echo -e "\n${YELLOW}🔨 Building applications...${NC}"

# Android builds
if [ "$RELEASE_ONLY" = false ]; then
    echo -e "\n${CYAN}📱 Building Android Debug APK...${NC}"
    flutter build apk --debug
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Android debug build failed!${NC}"
        exit 1
    fi
fi

if [ "$DEBUG_ONLY" = false ]; then
    echo -e "\n${CYAN}📱 Building Android Release APK...${NC}"
    flutter build apk --release
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Android release build failed!${NC}"
        exit 1
    fi
    
    echo -e "\n${CYAN}📱 Building Android App Bundle...${NC}"
    flutter build appbundle --release
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Android App Bundle build failed!${NC}"
        exit 1
    fi
fi

# iOS builds (only on macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    if [ "$RELEASE_ONLY" = false ]; then
        echo -e "\n${CYAN}🍎 Building iOS Debug...${NC}"
        cd ios && pod install && cd ..
        flutter build ios --simulator
        if [ $? -ne 0 ]; then
            echo -e "${RED}❌ iOS debug build failed!${NC}"
            exit 1
        fi
    fi
    
    if [ "$DEBUG_ONLY" = false ]; then
        echo -e "\n${CYAN}🍎 Building iOS Release (No Codesign)...${NC}"
        flutter build ios --release --no-codesign
        if [ $? -ne 0 ]; then
            echo -e "${RED}❌ iOS release build failed!${NC}"
            exit 1
        fi
    fi
fi

# Web builds
if [ "$RELEASE_ONLY" = false ]; then
    echo -e "\n${CYAN}🌐 Building Web Debug...${NC}"
    flutter build web --debug
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Web debug build failed!${NC}"
        exit 1
    fi
fi

if [ "$DEBUG_ONLY" = false ]; then
    echo -e "\n${CYAN}🌐 Building Web Release...${NC}"
    flutter build web --release
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Web release build failed!${NC}"
        exit 1
    fi
fi

# Linux builds (only on Linux)
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if [ "$RELEASE_ONLY" = false ]; then
        echo -e "\n${CYAN}🐧 Building Linux Debug...${NC}"
        flutter build linux --debug
        if [ $? -ne 0 ]; then
            echo -e "${YELLOW}⚠️ Linux debug build failed (may not be supported)${NC}"
        fi
    fi
    
    if [ "$DEBUG_ONLY" = false ]; then
        echo -e "\n${CYAN}🐧 Building Linux Release...${NC}"
        flutter build linux --release
        if [ $? -ne 0 ]; then
            echo -e "${YELLOW}⚠️ Linux release build failed (may not be supported)${NC}"
        fi
    fi
fi

# macOS builds (only on macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    if [ "$RELEASE_ONLY" = false ]; then
        echo -e "\n${CYAN}🍎 Building macOS Debug...${NC}"
        flutter build macos --debug
        if [ $? -ne 0 ]; then
            echo -e "${YELLOW}⚠️ macOS debug build failed (may not be supported)${NC}"
        fi
    fi
    
    if [ "$DEBUG_ONLY" = false ]; then
        echo -e "\n${CYAN}🍎 Building macOS Release...${NC}"
        flutter build macos --release
        if [ $? -ne 0 ]; then
            echo -e "${YELLOW}⚠️ macOS release build failed (may not be supported)${NC}"
        fi
    fi
fi

# Build summary
echo -e "\n${GREEN}📊 Build Summary:${NC}"
echo -e "${GREEN}✅ All builds completed successfully!${NC}"

# Show build outputs
echo -e "\n${YELLOW}📁 Build outputs:${NC}"
if [ -d "build/app/outputs/flutter-apk" ]; then
    echo -e "${CYAN}📱 Android APKs: build/app/outputs/flutter-apk/${NC}"
fi
if [ -d "build/app/outputs/bundle/release" ]; then
    echo -e "${CYAN}📱 Android Bundle: build/app/outputs/bundle/release/${NC}"
fi
if [ -d "build/web" ]; then
    echo -e "${CYAN}🌐 Web: build/web/${NC}"
fi
if [ -d "build/ios" ]; then
    echo -e "${CYAN}🍎 iOS: build/ios/${NC}"
fi
if [ -d "build/linux" ]; then
    echo -e "${CYAN}🐧 Linux: build/linux/${NC}"
fi
if [ -d "build/macos" ]; then
    echo -e "${CYAN}🍎 macOS: build/macos/${NC}"
fi

echo -e "\n${GREEN}🎉 Build process completed!${NC}"
