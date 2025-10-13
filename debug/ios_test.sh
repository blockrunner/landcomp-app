#!/bin/bash

# iOS Testing Script for LandComp
# Этот скрипт автоматизирует процесс тестирования приложения на iOS

set -e  # Остановка при ошибке

echo "🧪 LandComp iOS Testing Script"
echo "================================"

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функция для вывода сообщений
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Проверка наличия Flutter
check_flutter() {
    log_info "Проверка установки Flutter..."
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter не установлен. Установите Flutter с https://flutter.dev"
        exit 1
    fi
    log_success "Flutter установлен: $(flutter --version | head -n 1)"
}

# Проверка наличия Xcode
check_xcode() {
    log_info "Проверка установки Xcode..."
    if ! command -v xcodebuild &> /dev/null; then
        log_error "Xcode не установлен. Установите Xcode из App Store"
        exit 1
    fi
    log_success "Xcode установлен: $(xcodebuild -version | head -n 1)"
}

# Проверка Flutter doctor
check_flutter_doctor() {
    log_info "Проверка конфигурации Flutter..."
    if ! flutter doctor | grep -q "iOS toolchain"; then
        log_warning "iOS toolchain не настроен. Запустите 'flutter doctor' для диагностики"
    else
        log_success "iOS toolchain настроен"
    fi
}

# Очистка и установка зависимостей
setup_dependencies() {
    log_info "Очистка и установка зависимостей..."
    
    # Очистка
    flutter clean
    
    # Установка зависимостей
    flutter pub get
    
    # Установка iOS зависимостей
    if [ -d "ios" ]; then
        log_info "Установка iOS зависимостей (CocoaPods)..."
        cd ios
        if command -v pod &> /dev/null; then
            pod install
            log_success "CocoaPods зависимости установлены"
        else
            log_warning "CocoaPods не установлен. Установите: sudo gem install cocoapods"
        fi
        cd ..
    fi
    
    log_success "Зависимости установлены"
}

# Проверка доступных устройств
check_devices() {
    log_info "Проверка доступных устройств..."
    
    # Список устройств
    flutter devices
    
    # Проверка iOS симуляторов
    if command -v xcrun &> /dev/null; then
        log_info "Доступные iOS симуляторы:"
        xcrun simctl list devices available | grep iPhone
    fi
}

# Запуск на симуляторе
run_simulator() {
    log_info "Запуск приложения на iOS симуляторе..."
    
    # Проверка доступности симулятора
    if ! flutter devices | grep -q "iOS Simulator"; then
        log_warning "iOS симулятор не найден. Запустите симулятор вручную"
        log_info "Команда для запуска симулятора: open -a Simulator"
        return 1
    fi
    
    # Запуск приложения
    flutter run -d ios --debug
}

# Запуск на реальном устройстве
run_device() {
    log_info "Запуск приложения на реальном iOS устройстве..."
    
    # Проверка подключенных устройств
    if ! flutter devices | grep -q "iPhone"; then
        log_warning "iPhone не подключен или не доверен"
        log_info "Убедитесь, что:"
        log_info "1. iPhone подключен через USB"
        log_info "2. На iPhone: Настройки → Основные → Управление устройством → Доверять"
        return 1
    fi
    
    # Запуск приложения
    flutter run -d ios --debug
}

# Сборка для релиза
build_release() {
    log_info "Сборка приложения для релиза..."
    
    # Сборка iOS
    flutter build ios --release
    
    log_success "Сборка завершена. Файлы в: build/ios/iphoneos/"
    log_info "Для создания IPA файла откройте ios/Runner.xcworkspace в Xcode"
}

# Запуск тестов
run_tests() {
    log_info "Запуск тестов..."
    
    # Unit тесты
    flutter test
    
    # Integration тесты (если есть)
    if [ -d "integration_test" ]; then
        flutter test integration_test/
    fi
    
    log_success "Тесты завершены"
}

# Анализ кода
analyze_code() {
    log_info "Анализ кода..."
    
    # Flutter analyze
    flutter analyze
    
    log_success "Анализ кода завершен"
}

# Основное меню
show_menu() {
    echo ""
    echo "Выберите действие:"
    echo "1) Полная проверка и запуск на симуляторе"
    echo "2) Запуск на реальном iPhone"
    echo "3) Сборка для релиза"
    echo "4) Запуск тестов"
    echo "5) Анализ кода"
    echo "6) Только проверка зависимостей"
    echo "7) Показать доступные устройства"
    echo "0) Выход"
    echo ""
    read -p "Введите номер (0-7): " choice
}

# Главная функция
main() {
    echo "Добро пожаловать в LandComp iOS Testing!"
    echo ""
    
    # Базовые проверки
    check_flutter
    check_xcode
    check_flutter_doctor
    
    while true; do
        show_menu
        
        case $choice in
            1)
                setup_dependencies
                run_tests
                analyze_code
                run_simulator
                ;;
            2)
                setup_dependencies
                run_device
                ;;
            3)
                setup_dependencies
                build_release
                ;;
            4)
                run_tests
                ;;
            5)
                analyze_code
                ;;
            6)
                setup_dependencies
                ;;
            7)
                check_devices
                ;;
            0)
                log_success "До свидания!"
                exit 0
                ;;
            *)
                log_error "Неверный выбор. Попробуйте снова."
                ;;
        esac
        
        echo ""
        read -p "Нажмите Enter для продолжения..."
    done
}

# Обработка аргументов командной строки
if [ $# -eq 0 ]; then
    main
else
    case $1 in
        "simulator")
            setup_dependencies
            run_simulator
            ;;
        "device")
            setup_dependencies
            run_device
            ;;
        "build")
            setup_dependencies
            build_release
            ;;
        "test")
            run_tests
            ;;
        "analyze")
            analyze_code
            ;;
        "deps")
            setup_dependencies
            ;;
        "devices")
            check_devices
            ;;
        *)
            echo "Использование: $0 [simulator|device|build|test|analyze|deps|devices]"
            echo "Или запустите без аргументов для интерактивного меню"
            exit 1
            ;;
    esac
fi
