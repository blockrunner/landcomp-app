/// JSON utilities for compression and optimization
///
/// This utility provides functions for compressing JSON data
/// and optimizing storage size.
library;

import 'dart:convert';

/// JSON utilities class
class JsonUtils {
  JsonUtils._();

  /// Compress base64 string by removing padding and whitespace
  static String compressBase64(String base64String) {
    try {
      // Remove padding
      var compressed = base64String.replaceAll('=', '');

      // Remove whitespace and newlines
      compressed = compressed.replaceAll(RegExp(r'\s'), '');

      return compressed;
    } catch (e) {
      print('❌ Error compressing base64: $e');
      return base64String;
    }
  }

  /// Decompress base64 string by adding padding back
  static String decompressBase64(String compressedBase64) {
    try {
      // Add padding back
      var decompressed = compressedBase64;
      final paddingLength = 4 - (decompressed.length % 4);
      if (paddingLength != 4) {
        decompressed += '=' * paddingLength;
      }

      return decompressed;
    } catch (e) {
      print('❌ Error decompressing base64: $e');
      return compressedBase64;
    }
  }

  /// Compress JSON by removing unnecessary whitespace
  static String compressJson(Map<String, dynamic> json) {
    try {
      // Convert to JSON string without indentation
      final jsonString = jsonEncode(json);

      // Remove unnecessary whitespace
      final compressed = jsonString.replaceAll(RegExp(r'\s+'), ' ');

      return compressed;
    } catch (e) {
      print('❌ Error compressing JSON: $e');
      return jsonEncode(json);
    }
  }

  /// Optimize image data in JSON
  static Map<String, dynamic> optimizeImageData(Map<String, dynamic> json) {
    try {
      final optimized = Map<String, dynamic>.from(json);

      // Optimize imageBytes if present
      if (optimized['imageBytes'] != null) {
        final imageBytes = optimized['imageBytes'] as List<dynamic>;
        final optimizedImages = <String>[];

        for (final imageData in imageBytes) {
          if (imageData is String) {
            // Compress base64 string
            final compressed = compressBase64(imageData);
            optimizedImages.add(compressed);
          } else {
            optimizedImages.add(imageData.toString());
          }
        }

        optimized['imageBytes'] = optimizedImages;
      }

      return optimized;
    } catch (e) {
      print('❌ Error optimizing image data: $e');
      return json;
    }
  }

  /// Restore image data from optimized JSON
  static Map<String, dynamic> restoreImageData(Map<String, dynamic> json) {
    try {
      final restored = Map<String, dynamic>.from(json);

      // Restore imageBytes if present
      if (restored['imageBytes'] != null) {
        final imageBytes = restored['imageBytes'] as List<dynamic>;
        final restoredImages = <String>[];

        for (final imageData in imageBytes) {
          if (imageData is String) {
            // Decompress base64 string
            final decompressed = decompressBase64(imageData);
            restoredImages.add(decompressed);
          } else {
            restoredImages.add(imageData.toString());
          }
        }

        restored['imageBytes'] = restoredImages;
      }

      return restored;
    } catch (e) {
      print('❌ Error restoring image data: $e');
      return json;
    }
  }

  /// Calculate JSON size in bytes
  static int calculateJsonSize(Map<String, dynamic> json) {
    try {
      final jsonString = jsonEncode(json);
      return jsonString.length * 2; // UTF-16 encoding
    } catch (e) {
      print('❌ Error calculating JSON size: $e');
      return 0;
    }
  }

  /// Calculate compression ratio
  static double calculateCompressionRatio(
    int originalSize,
    int compressedSize,
  ) {
    if (originalSize == 0) return 0;
    return (1.0 - (compressedSize / originalSize)) * 100.0;
  }
}
