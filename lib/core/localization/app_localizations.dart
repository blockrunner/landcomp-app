/// Application localizations
/// 
/// This file contains all the localized strings for the application
/// supporting English and Russian languages.
library;

import 'package:flutter/material.dart';

/// Application localizations class
class AppLocalizations {
  /// Private constructor to prevent instantiation
  AppLocalizations._();

  /// Current locale
  static Locale _currentLocale = const Locale('ru');

  /// Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ru'),
  ];

  /// Set current locale
  static void setLocale(Locale locale) {
    _currentLocale = locale;
  }

  /// Get current locale
  static Locale get currentLocale => _currentLocale;

  /// Check if locale is supported
  static bool isSupported(Locale locale) {
    return supportedLocales.any((supportedLocale) => 
        supportedLocale.languageCode == locale.languageCode);
  }

  /// Get localized string
  static String getString(String key) {
    return _localizedStrings[_currentLocale.languageCode]?[key] ?? key;
  }

  /// Localized strings
  static const Map<String, Map<String, String>> _localizedStrings = {
    'en': {
      // App
      'appName': 'LandComp',
      'appDescription': 'AI-powered landscape design and gardening assistant',
      
      // Navigation
      'home': 'Home',
      'chat': 'Chat',
      'catalog': 'Catalog',
      'planner': 'Planner',
      'settings': 'Settings',
      'profile': 'Profile',
      'comingSoon': 'Coming soon',
      
      // Chat
      'chatTitle': 'LandComp Chat',
      'welcomeTitle': 'Welcome to LandComp!',
      'welcomeSubtitle': 'Your AI-powered landscape design assistant',
      'getStarted': 'Get started:',
      'plantSelection': '🌱 Ask about plant selection for your garden',
      'landscapeDesign': '🏡 Get landscape design recommendations',
      'construction': '🔨 Learn about construction and materials',
      'ecoFriendly': '🌍 Discover eco-friendly solutions',
      'messageHint': 'Ask about landscape design...',
      'messageHintWithImage': 'Describe the images...',
      'messageHintExtended': 'Ask about landscape design, gardening or construction...',
      'sendMessage': 'Send',
      
      // Settings
      'settingsTitle': 'Settings',
      'aiProvider': 'AI Provider',
      'openaiGpt4': 'OpenAI GPT-4',
      'openaiGpt4Subtitle': 'High quality responses',
      'googleGemini': 'Google Gemini',
      'googleGeminiSubtitle': 'Alternative AI provider',
      'appearance': 'Appearance',
      'language': 'Language',
      'theme': 'Theme',
      'light': 'Light',
      'dark': 'Dark',
      'system': 'System',
      'features': 'Features',
      'notifications': 'Notifications',
      'notificationsSubtitle': 'Receive app notifications',
      'offlineMode': 'Offline Mode',
      'offlineModeSubtitle': 'Use cached responses when offline',
      'about': 'About',
      'version': 'Version',
      'privacyPolicy': 'Privacy Policy',
      'termsOfService': 'Terms of Service',
      
      // Profile
      'profileTitle': 'Profile',
      'landcompUser': 'LandComp User',
      'usageStatistics': 'Usage Statistics',
      'messages': 'Messages',
      'sessions': 'Sessions',
      'daysActive': 'Days Active',
      'account': 'Account',
      'editProfile': 'Edit Profile',
      'privacySecurity': 'Privacy & Security',
      'exportData': 'Export Data',
      'support': 'Support',
      'helpSupport': 'Help & Support',
      'sendFeedback': 'Send Feedback',
      'rateApp': 'Rate App',
      'dangerZone': 'Danger Zone',
      'signOut': 'Sign Out',
      'deleteAccount': 'Delete Account',
      'signOutConfirm': 'Are you sure you want to sign out?',
      'deleteAccountConfirm': 'Are you sure you want to delete your account? This action cannot be undone.',
      'cancel': 'Cancel',
      'delete': 'Delete',
      
      // Common
      'ok': 'OK',
      'save': 'Save',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      
      // Home Page
      'homeHeroTitle': 'Create landscape compositions easily and quickly',
      'homeHeroSubtitle': 'Your personal AI garden designer will help create professional compositions',
      'quickStart': 'Quick Start',
      'newProject': 'New Project',
      'newProjectDescription': 'Create a new landscape project',
      'myProjects': 'My Projects',
      'myProjectsDescription': 'View saved projects',
      'versionNumber': 'Version 1.0.0',
      'homeFooterDescription': 'Your AI assistant for creating landscape compositions',
      
      // Projects
      'projects': 'Projects',
      'projectTitle': 'Project Title',
      'renameProject': 'Rename Project',
      'deleteProject': 'Delete Project',
      'deleteProjectConfirm': 'Delete this project?',
      'projectDeleted': 'Project deleted',
      'defaultProjectTitle': 'New Project',
      'projectsEmpty': 'No projects yet',
      'createFirstProject': 'Create your first project',
      'projectCreated': 'Project created',
      'projectRenamed': 'Project renamed',
      'switchProject': 'Switch Project',
      'currentProject': 'Current Project',
      'recentProjects': 'Recent Projects',
      'favoriteProjects': 'Favorite Projects',
      'allProjects': 'All Projects',
      'searchProjects': 'Search projects...',
      'noProjectsFound': 'No projects found',
      'projectOptions': 'Project Options',
      'markAsFavorite': 'Mark as Favorite',
      'removeFromFavorites': 'Remove from Favorites',
      'duplicateProject': 'Duplicate Project',
      'exportProject': 'Export Project',
      'projectStats': 'Project Statistics',
      'messageCount': 'Messages',
      'lastModified': 'Last Modified',
      'created': 'Created',
      'favorites': 'Favorites',
      'sortBy': 'Sort by',
      'newProjectDialog': 'Create New Project',
      'enterProjectTitle': 'Enter project title',
      'projectTitleHint': 'e.g., Garden Design for Small Yard',
      'createProject': 'Create Project',
      
      // Router Error
      'pageNotFound': 'Page not found',
      'pageNotFoundDescription': 'The page could not be found.',
      'goToHome': 'Go to Home',
      
      // Profile Page
      'userEmail': 'user@example.com',
      
      // Settings Inline
      'russian': 'Russian',
      'english': 'English',
      
      // Message Bubble
      'retry': 'Retry',
      'originalImages': 'Original Images',
      'generatedVariants': 'Generated Variants',
      'hoursAgo': 'h ago',
      'minutesAgo': 'm ago',
      'justNow': 'Just now',
      'images': 'Images',
      'image': 'Image',
      'loadingError': 'Loading Error',
      
      // Image Picker
      'imageSelectionError': 'Error selecting images:',
      'selectPhotos': 'Select Photos',
      'addPhotos': 'Add Photos',
      'clear': 'Clear',
      'canSelectUpTo': 'You can select up to',
      'imagesCount': 'images',
      
      // Image Viewer
      'imageCounter': 'Image',
      'of': 'of',
      'failedToLoadImage': 'Failed to load image',
      
      // Error Messages
      'networkErrorMessage': 'Network connection error. Please check your internet connection.',
      'serverErrorMessage': 'Server error. Please try again later.',
      'unknownErrorMessage': 'An unknown error occurred. Please try again.',
      'aiServiceErrorMessage': 'AI service is temporarily unavailable. Please try again later.',
      'messageSentMessage': 'Message sent successfully',
      'settingsSavedMessage': 'Settings saved successfully',
    },
    'ru': {
      // App
      'appName': 'LandComp',
      'appDescription': 'ИИ-помощник для ландшафтного дизайна и садоводства',
      
      // Navigation
      'home': 'Главная',
      'chat': 'Чат',
      'catalog': 'Каталог',
      'planner': 'Планировщик',
      'settings': 'Настройки',
      'profile': 'Профиль',
      'comingSoon': 'Скоро',
      
      // Chat
      'chatTitle': 'LandComp Чат',
      'welcomeTitle': 'Добро пожаловать в LandComp!',
      'welcomeSubtitle': 'Ваш ИИ-помощник для ландшафтного дизайна',
      'getStarted': 'Начните с:',
      'plantSelection': '🌱 Спросите о выборе растений для вашего сада',
      'landscapeDesign': '🏡 Получите рекомендации по ландшафтному дизайну',
      'construction': '🔨 Узнайте о строительстве и материалах',
      'ecoFriendly': '🌍 Откройте экологичные решения',
      'messageHint': 'Спросите о ландшафтном дизайне...',
      'messageHintWithImage': 'Опишите изображения...',
      'messageHintExtended': 'Спросите о ландшафтном дизайне, садоводстве или строительстве...',
      'sendMessage': 'Отправить',
      
      // Settings
      'settingsTitle': 'Настройки',
      'aiProvider': 'ИИ Провайдер',
      'openaiGpt4': 'OpenAI GPT-4',
      'openaiGpt4Subtitle': 'Высокое качество ответов',
      'googleGemini': 'Google Gemini',
      'googleGeminiSubtitle': 'Альтернативный ИИ провайдер',
      'appearance': 'Внешний вид',
      'language': 'Язык',
      'theme': 'Тема',
      'light': 'Светлая',
      'dark': 'Темная',
      'system': 'Системная',
      'features': 'Функции',
      'notifications': 'Уведомления',
      'notificationsSubtitle': 'Получать уведомления приложения',
      'offlineMode': 'Офлайн режим',
      'offlineModeSubtitle': 'Использовать кэшированные ответы без интернета',
      'about': 'О приложении',
      'version': 'Версия',
      'privacyPolicy': 'Политика конфиденциальности',
      'termsOfService': 'Условия использования',
      
      // Profile
      'profileTitle': 'Профиль',
      'landcompUser': 'Пользователь LandComp',
      'usageStatistics': 'Статистика использования',
      'messages': 'Сообщения',
      'sessions': 'Сессии',
      'daysActive': 'Активных дней',
      'account': 'Аккаунт',
      'editProfile': 'Редактировать профиль',
      'privacySecurity': 'Приватность и безопасность',
      'exportData': 'Экспорт данных',
      'support': 'Поддержка',
      'helpSupport': 'Помощь и поддержка',
      'sendFeedback': 'Отправить отзыв',
      'rateApp': 'Оценить приложение',
      'dangerZone': 'Опасная зона',
      'signOut': 'Выйти',
      'deleteAccount': 'Удалить аккаунт',
      'signOutConfirm': 'Вы уверены, что хотите выйти?',
      'deleteAccountConfirm': 'Вы уверены, что хотите удалить свой аккаунт? Это действие нельзя отменить.',
      'cancel': 'Отмена',
      'delete': 'Удалить',
      
      // Common
      'ok': 'ОК',
      'save': 'Сохранить',
      'loading': 'Загрузка...',
      'error': 'Ошибка',
      'success': 'Успешно',
      
      // Home Page
      'homeHeroTitle': 'Создавайте ландшафтные композиции легко и быстро',
      'homeHeroSubtitle': 'Ваш персональный AI-дизайнер сада поможет создать профессиональные композиции',
      'quickStart': 'Быстрый старт',
      'newProject': 'Новый проект',
      'newProjectDescription': 'Создайте новый ландшафтный проект',
      'myProjects': 'Мои проекты',
      'myProjectsDescription': 'Просмотрите сохраненные проекты',
      'versionNumber': 'Версия 1.0.0',
      'homeFooterDescription': 'Ваш AI-помощник для создания ландшафтных композиций',
      
      // Projects
      'projects': 'Проекты',
      'projectTitle': 'Название проекта',
      'renameProject': 'Переименовать проект',
      'deleteProject': 'Удалить проект',
      'deleteProjectConfirm': 'Удалить этот проект?',
      'projectDeleted': 'Проект удален',
      'defaultProjectTitle': 'Новый проект',
      'projectsEmpty': 'Нет проектов',
      'createFirstProject': 'Создайте первый проект',
      'projectCreated': 'Проект создан',
      'projectRenamed': 'Проект переименован',
      'switchProject': 'Переключить проект',
      'currentProject': 'Текущий проект',
      'recentProjects': 'Недавние проекты',
      'favoriteProjects': 'Избранные проекты',
      'allProjects': 'Все проекты',
      'searchProjects': 'Поиск проектов...',
      'noProjectsFound': 'Проекты не найдены',
      'projectOptions': 'Опции проекта',
      'markAsFavorite': 'Добавить в избранное',
      'removeFromFavorites': 'Убрать из избранного',
      'duplicateProject': 'Дублировать проект',
      'exportProject': 'Экспортировать проект',
      'projectStats': 'Статистика проекта',
      'messageCount': 'Сообщения',
      'lastModified': 'Последнее изменение',
      'created': 'Создан',
      'favorites': 'Избранное',
      'sortBy': 'Сортировать по',
      'newProjectDialog': 'Создать новый проект',
      'enterProjectTitle': 'Введите название проекта',
      'projectTitleHint': 'например, Дизайн сада для маленького двора',
      'createProject': 'Создать проект',
      
      // Router Error
      'pageNotFound': 'Страница не найдена',
      'pageNotFoundDescription': 'Страница не может быть найдена.',
      'goToHome': 'На главную',
      
      // Profile Page
      'userEmail': 'user@example.com',
      
      // Settings Inline
      'russian': 'Русский',
      'english': 'Английский',
      
      // Message Bubble
      'retry': 'Повторить',
      'originalImages': 'Исходные изображения',
      'generatedVariants': 'Сгенерированные варианты',
      'hoursAgo': 'ч назад',
      'minutesAgo': 'м назад',
      'justNow': 'Только что',
      'images': 'Изображения',
      'image': 'Изображение',
      'loadingError': 'Ошибка загрузки',
      
      // Image Picker
      'imageSelectionError': 'Ошибка при выборе изображений:',
      'selectPhotos': 'Выбрать фото',
      'addPhotos': 'Добавить фото',
      'clear': 'Очистить',
      'canSelectUpTo': 'Можно выбрать до',
      'imagesCount': 'изображений',
      
      // Image Viewer
      'imageCounter': 'Изображение',
      'of': 'из',
      'failedToLoadImage': 'Не удалось загрузить изображение',
      
      // Error Messages
      'networkErrorMessage': 'Ошибка сетевого подключения. Проверьте подключение к интернету.',
      'serverErrorMessage': 'Ошибка сервера. Попробуйте позже.',
      'unknownErrorMessage': 'Произошла неизвестная ошибка. Попробуйте снова.',
      'aiServiceErrorMessage': 'ИИ-сервис временно недоступен. Попробуйте позже.',
      'messageSentMessage': 'Сообщение успешно отправлено',
      'settingsSavedMessage': 'Настройки успешно сохранены',
    },
  };
}
