/// Language provider for managing app language
///
/// This provider manages the current language and notifies listeners
/// when the language changes.
library;

import 'package:flutter/material.dart';
import 'package:landcomp_app/core/localization/app_localizations.dart';

/// Language provider class
class LanguageProvider extends ChangeNotifier {
  /// Current locale
  Locale _currentLocale = const Locale('ru');

  /// Get current locale
  Locale get currentLocale => _currentLocale;

  /// Get current language code
  String get currentLanguageCode => _currentLocale.languageCode;

  /// Check if current language is Russian
  bool get isRussian => _currentLocale.languageCode == 'ru';

  /// Check if current language is English
  bool get isEnglish => _currentLocale.languageCode == 'en';

  /// Set language
  void setLanguage(Locale locale) {
    if (AppLocalizations.isSupported(locale)) {
      _currentLocale = locale;
      AppLocalizations.setLocale(locale);
      notifyListeners();
    }
  }

  /// Toggle between English and Russian
  void toggleLanguage() {
    if (isEnglish) {
      setLanguage(const Locale('ru'));
    } else {
      setLanguage(const Locale('en'));
    }
  }

  /// Get localized string
  String getString(String key) {
    return AppLocalizations.getString(key);
  }

  /// Get language display name
  String getLanguageDisplayName() {
    switch (_currentLocale.languageCode) {
      case 'ru':
        return 'Русский';
      case 'en':
      default:
        return 'English';
    }
  }

  /// Get theme display name
  String getThemeDisplayName(String theme) {
    switch (theme) {
      case 'light':
        return isRussian ? 'Светлая' : 'Light';
      case 'dark':
        return isRussian ? 'Темная' : 'Dark';
      case 'system':
        return isRussian ? 'Системная' : 'System';
      default:
        return isRussian ? 'Системная' : 'System';
    }
  }

  /// Format relative time (e.g., "2h ago", "5m ago", "Just now")
  String formatRelativeTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${timestamp.day}/${timestamp.month} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}${getString('hoursAgo')}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}${getString('minutesAgo')}';
    } else {
      return getString('justNow');
    }
  }

  /// Format image counter (e.g., "Image 1 of 3")
  String formatImageCounter(int current, int total) {
    return '${getString('imageCounter')} ${current + 1} ${getString('of')} $total';
  }

  /// Format image count with pluralization
  String formatImageCount(int count) {
    if (count == 1) {
      return getString('image');
    } else {
      return getString('images');
    }
  }

  /// Format add photos button text
  String formatAddPhotosText(int current, int max) {
    if (current == 0) {
      return getString('selectPhotos');
    } else {
      return '${getString('addPhotos')} ($current/$max)';
    }
  }

  /// Format can select up to text
  String formatCanSelectUpTo(int max) {
    return '${getString('canSelectUpTo')} $max ${getString('imagesCount')}';
  }
}
