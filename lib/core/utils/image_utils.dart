/// Image utilities for compression and validation
/// 
/// This utility provides functions for compressing images
/// and validating image data to ensure proper storage.
library;

import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

/// Image utilities class
class ImageUtils {
  ImageUtils._();

  /// Maximum image size in bytes (2MB)
  static const int maxImageSize = 2 * 1024 * 1024;
  
  /// Maximum image dimensions
  static const int maxImageWidth = 1024;
  static const int maxImageHeight = 1024;
  
  /// Compression quality (0.0 to 1.0)
  static const double compressionQuality = 0.8;

  /// Compress and validate image bytes
  /// Returns compressed image bytes or null if compression fails
  static Future<Uint8List?> compressImage(Uint8List imageBytes) async {
    try {
      print('🗜️ Compressing image: ${imageBytes.length} bytes');
      
      // Validate input
      if (imageBytes.isEmpty) {
        print('❌ Image bytes are empty');
        return null;
      }
      
      // If image is already small enough, return as is
      if (imageBytes.length <= maxImageSize) {
        print('✅ Image is already small enough: ${imageBytes.length} bytes');
        return imageBytes;
      }
      
      // Decode image
      final codec = await ui.instantiateImageCodec(
        imageBytes,
        targetWidth: maxImageWidth,
        targetHeight: maxImageHeight,
      );
      
      final frame = await codec.getNextFrame();
      final image = frame.image;
      
      // Convert to PNG with compression
      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      
      if (byteData == null) {
        print('❌ Failed to convert image to byte data');
        return null;
      }
      
      final compressedBytes = byteData.buffer.asUint8List();
      
      print('✅ Image compressed: ${imageBytes.length} -> ${compressedBytes.length} bytes');
      
      // Dispose image
      image.dispose();
      
      return compressedBytes;
    } catch (e) {
      print('❌ Error compressing image: $e');
      return null;
    }
  }

  /// Validate image bytes
  /// Returns true if image is valid and within size limits
  static bool validateImage(Uint8List imageBytes) {
    try {
      // Check if bytes are empty
      if (imageBytes.isEmpty) {
        print('❌ Image bytes are empty');
        return false;
      }
      
      // Check size limit
      if (imageBytes.length > maxImageSize) {
        print('❌ Image too large: ${imageBytes.length} bytes (max: $maxImageSize)');
        return false;
      }
      
      // Check minimum size (at least 100 bytes for a valid image)
      if (imageBytes.length < 100) {
        print('❌ Image too small: ${imageBytes.length} bytes');
        return false;
      }
      
      // Check for common image headers
      if (!_isValidImageHeader(imageBytes)) {
        print('❌ Invalid image header');
        return false;
      }
      
      print('✅ Image validation passed: ${imageBytes.length} bytes');
      return true;
    } catch (e) {
      print('❌ Error validating image: $e');
      return false;
    }
  }

  /// Check if bytes start with valid image header
  static bool _isValidImageHeader(Uint8List bytes) {
    if (bytes.length < 4) return false;
    
    // Check for common image formats
    // JPEG: FF D8 FF
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return true;
    }
    
    // PNG: 89 50 4E 47
    if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) {
      return true;
    }
    
    // GIF: 47 49 46 38
    if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x38) {
      return true;
    }
    
    // WebP: 52 49 46 46 (RIFF)
    if (bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x46) {
      return true;
    }
    
    return false;
  }

  /// Compress multiple images
  /// Returns list of compressed images, skipping invalid ones
  static Future<List<Uint8List>> compressImages(List<Uint8List> images) async {
    final compressedImages = <Uint8List>[];
    
    for (var i = 0; i < images.length; i++) {
      print('🗜️ Compressing image ${i + 1}/${images.length}');
      
      final compressed = await compressImage(images[i]);
      if (compressed != null) {
        compressedImages.add(compressed);
        print('✅ Image ${i + 1} compressed successfully');
      } else {
        print('❌ Failed to compress image ${i + 1}, skipping');
      }
    }
    
    print('🗜️ Compression complete: ${images.length} -> ${compressedImages.length} images');
    return compressedImages;
  }

  /// Validate multiple images
  /// Returns list of valid images
  static List<Uint8List> validateImages(List<Uint8List> images) {
    final validImages = <Uint8List>[];
    
    for (var i = 0; i < images.length; i++) {
      print('🔍 Validating image ${i + 1}/${images.length}');
      
      if (validateImage(images[i])) {
        validImages.add(images[i]);
        print('✅ Image ${i + 1} is valid');
      } else {
        print('❌ Image ${i + 1} is invalid, skipping');
      }
    }
    
    print('🔍 Validation complete: ${images.length} -> ${validImages.length} valid images');
    return validImages;
  }
}
