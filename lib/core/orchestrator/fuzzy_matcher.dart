/// Fuzzy keyword matcher for generation intents
///
/// This utility provides fuzzy matching capabilities for generation keywords
/// with support for typos, variations, and bilingual input (Russian/English).
library;

import 'dart:developer' as developer;

/// Fuzzy keyword matcher for generation intents
class FuzzyMatcher {
  /// Generation keywords in different languages
  static const Map<String, List<String>> generationKeywords = {
    'ru': [
      'создай',
      'сделай',
      'нарисуй',
      'сгенерируй',
      'покажи',
      'покажи как будет',
      'измени',
      'адаптируй',
      'примени',
      'объедини',
      'смешай',
      'стилизуй',
      'сгенерируй',
      'покажи как',
      'создай изображение',
      'нарисуй картинку',
      'сделай дизайн',
    ],
    'en': [
      'create',
      'make',
      'draw',
      'generate',
      'show',
      'show how it will look',
      'modify',
      'change',
      'adapt',
      'apply',
      'combine',
      'merge',
      'stylize',
      'generate image',
      'create image',
      'draw picture',
      'make design',
    ],
  };

  /// Check if message contains generation keywords with fuzzy matching
  static bool containsGenerationKeyword(
    String message, {
    String? language,
    int maxDistance = 2,
  }) {
    developer.log(
      'FuzzyMatcher: Checking message for generation keywords',
      name: 'FuzzyMatcher',
    );

    final normalizedMessage = _normalizeText(message);
    final detectedLanguage = language ?? _detectLanguage(normalizedMessage);

    final keywords = generationKeywords[detectedLanguage] ?? [];
    if (keywords.isEmpty) {
      // Fallback to English if language not supported
      final englishKeywords = generationKeywords['en'] ?? [];
      return _checkKeywords(normalizedMessage, englishKeywords, maxDistance);
    }

    return _checkKeywords(normalizedMessage, keywords, maxDistance);
  }

  /// Check keywords against message with fuzzy matching
  static bool _checkKeywords(
    String message,
    List<String> keywords,
    int maxDistance,
  ) {
    for (final keyword in keywords) {
      final normalizedKeyword = _normalizeText(keyword);
      
      // Exact match
      if (message.contains(normalizedKeyword)) {
        developer.log(
          'FuzzyMatcher: Exact match found for "$normalizedKeyword"',
          name: 'FuzzyMatcher',
        );
        return true;
      }

      // Fuzzy match using Levenshtein distance
      final words = message.split(' ');
      for (final word in words) {
        if (word.length >= 3) { // Only check words with 3+ characters
          final distance = _levenshteinDistance(word, normalizedKeyword);
          if (distance <= maxDistance && distance < normalizedKeyword.length) {
            developer.log(
              'FuzzyMatcher: Fuzzy match found for "$word" -> '
            '"$normalizedKeyword" (distance: $distance)',
              name: 'FuzzyMatcher',
            );
            return true;
          }
        }
      }

      // Check for partial matches (substring with fuzzy tolerance)
      if (_hasPartialMatch(message, normalizedKeyword, maxDistance)) {
        developer.log(
          'FuzzyMatcher: Partial match found for "$normalizedKeyword"',
          name: 'FuzzyMatcher',
        );
        return true;
      }
    }

    return false;
  }

  /// Check for partial matches with fuzzy tolerance
  static bool _hasPartialMatch(
    String message,
    String keyword,
    int maxDistance,
  ) {
    if (keyword.length < 4) return false; // Skip very short keywords

    for (var i = 0; i <= message.length - keyword.length; i++) {
      final substring = message.substring(i, i + keyword.length);
      final distance = _levenshteinDistance(substring, keyword);
      if (distance <= maxDistance) {
        return true;
      }
    }

    return false;
  }

  /// Calculate Levenshtein distance between two strings
  static int _levenshteinDistance(String s1, String s2) {
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    final matrix = List.generate(
      s1.length + 1,
      (i) => List.generate(s2.length + 1, (j) => 0),
    );

    // Initialize first row and column
    for (var i = 0; i <= s1.length; i++) {
      matrix[i][0] = i;
    }
    for (var j = 0; j <= s2.length; j++) {
      matrix[0][j] = j;
    }

    // Fill the matrix
    for (var i = 1; i <= s1.length; i++) {
      for (var j = 1; j <= s2.length; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,      // deletion
          matrix[i][j - 1] + 1,      // insertion
          matrix[i - 1][j - 1] + cost, // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[s1.length][s2.length];
  }

  /// Normalize text for better matching
  static String _normalizeText(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ') // Remove punctuation
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
        .trim();
  }

  /// Detect language based on text content
  static String _detectLanguage(String text) {
    // Simple language detection based on character sets
    final cyrillicPattern = RegExp('[а-яё]', caseSensitive: false);
    final latinPattern = RegExp('[a-z]', caseSensitive: false);

    final hasCyrillic = cyrillicPattern.hasMatch(text);
    final hasLatin = latinPattern.hasMatch(text);

    if (hasCyrillic && !hasLatin) {
      return 'ru';
    } else if (hasLatin && !hasCyrillic) {
      return 'en';
    } else if (hasCyrillic && hasLatin) {
      // Mixed text - check which is more prevalent
      final cyrillicCount = cyrillicPattern.allMatches(text).length;
      final latinCount = latinPattern.allMatches(text).length;
      return cyrillicCount > latinCount ? 'ru' : 'en';
    }

    return 'en'; // Default to English
  }

  /// Get all generation keywords for a specific language
  static List<String> getKeywordsForLanguage(String language) {
    return generationKeywords[language] ?? generationKeywords['en'] ?? [];
  }

  /// Check if a specific word is a generation keyword
  static bool isGenerationKeyword(String word, {String? language}) {
    final normalizedWord = _normalizeText(word);
    final detectedLanguage = language ?? _detectLanguage(normalizedWord);
    final keywords = getKeywordsForLanguage(detectedLanguage);
    
    return keywords.any((keyword) => 
        _normalizeText(keyword) == normalizedWord);
  }

  /// Get confidence score for generation intent based on keyword matching
  static double getGenerationConfidence(String message, {String? language}) {
    final normalizedMessage = _normalizeText(message);
    final detectedLanguage = language ?? _detectLanguage(normalizedMessage);
    final keywords = getKeywordsForLanguage(detectedLanguage);

    var maxConfidence = 0.0;

    for (final keyword in keywords) {
      final normalizedKeyword = _normalizeText(keyword);
      
      // Exact match gets highest confidence
      if (normalizedMessage.contains(normalizedKeyword)) {
        maxConfidence = 1.0;
        break;
      }

      // Fuzzy match gets lower confidence based on distance
      final words = normalizedMessage.split(' ');
      for (final word in words) {
        if (word.length >= 3) {
          final distance = _levenshteinDistance(word, normalizedKeyword);
          if (distance <= 2) {
            final confidence = 1.0 - (distance / normalizedKeyword.length);
            if (confidence > maxConfidence) {
              maxConfidence = confidence;
            }
          }
        }
      }
    }

    return maxConfidence;
  }
}
