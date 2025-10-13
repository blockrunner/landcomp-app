/// Image generation response entity
///
/// This entity represents the response from Gemini image generation API
/// containing both generated images and text response.
library;

import 'dart:typed_data';
import 'package:equatable/equatable.dart';

/// Response from image generation API
class ImageGenerationResponse extends Equatable {
  /// Create response with only text (no images)
  factory ImageGenerationResponse.textOnly(String text) {
    return ImageGenerationResponse(
      textResponse: text,
      generatedImages: const [],
      imageMimeTypes: const [],
    );
  }

  /// Create response with images and text
  factory ImageGenerationResponse.withImages({
    required String text,
    required List<Uint8List> images,
    List<String>? mimeTypes,
  }) {
    return ImageGenerationResponse(
      textResponse: text,
      generatedImages: images,
      imageMimeTypes: mimeTypes ?? List.filled(images.length, 'image/jpeg'),
    );
  }

  /// Create from OpenAI Vision analysis (text only, no images)
  factory ImageGenerationResponse.fromAnalysis({
    required String imageAnalysis,
    required String userIntent,
    required double intentConfidence,
    required String intentReasoning,
    required String suitability,
    required List<String> recommendations,
    String? textResponse,
  }) {
    return ImageGenerationResponse(
      textResponse: textResponse ?? suitability,
      generatedImages: const [],
      imageMimeTypes: const [],
      imageAnalysis: imageAnalysis,
      userIntent: userIntent,
      intentConfidence: intentConfidence,
      intentReasoning: intentReasoning,
      suitability: suitability,
      recommendations: recommendations,
    );
  }

  /// Create from JSON
  factory ImageGenerationResponse.fromJson(Map<String, dynamic> json) {
    return ImageGenerationResponse(
      textResponse: json['textResponse'] as String,
      generatedImages: (json['generatedImages'] as List)
          .map((img) => Uint8List.fromList((img as List).cast<int>()))
          .toList(),
      imageMimeTypes: (json['imageMimeTypes'] as List).cast<String>(),
      imageAnalysis: json['imageAnalysis'] as String?,
      userIntent: json['userIntent'] as String?,
      intentConfidence: (json['intentConfidence'] as num?)?.toDouble(),
      intentReasoning: json['intentReasoning'] as String?,
      suitability: json['suitability'] as String?,
      recommendations: json['recommendations'] != null
          ? (json['recommendations'] as List).cast<String>()
          : null,
    );
  }

  /// Creates an image generation response
  const ImageGenerationResponse({
    required this.textResponse,
    required this.generatedImages,
    required this.imageMimeTypes,
    this.imageAnalysis,
    this.userIntent,
    this.intentConfidence,
    this.intentReasoning,
    this.suitability,
    this.recommendations,
  });

  /// Text response from the AI
  final String textResponse;

  /// List of generated images as byte data
  final List<Uint8List> generatedImages;

  /// MIME types of generated images
  final List<String> imageMimeTypes;

  /// Analysis of uploaded image
  final String? imageAnalysis;

  /// User intent: 'consultation', 'visualization', or 'unclear'
  final String? userIntent;

  /// Confidence in intent detection (0.0-1.0)
  final double? intentConfidence;

  /// Reasoning for intent choice
  final String? intentReasoning;

  /// Suitability assessment of the area
  final String? suitability;

  /// List of recommendations
  final List<String>? recommendations;

  /// Check if response contains generated images
  bool get hasGeneratedImages => generatedImages.isNotEmpty;

  /// Get count of generated images
  int get imageCount => generatedImages.length;

  /// Check if this is consultation response (no images generated)
  bool get isConsultation => userIntent == 'consultation';

  /// Check if this is visualization response (images generated)
  bool get isVisualization =>
      userIntent == 'visualization' || hasGeneratedImages;

  /// Check if intent is unclear
  bool get isUnclear => userIntent == 'unclear';

  /// Copy response with new values
  ImageGenerationResponse copyWith({
    String? textResponse,
    List<Uint8List>? generatedImages,
    List<String>? imageMimeTypes,
    String? imageAnalysis,
    String? userIntent,
    double? intentConfidence,
    String? intentReasoning,
    String? suitability,
    List<String>? recommendations,
  }) {
    return ImageGenerationResponse(
      textResponse: textResponse ?? this.textResponse,
      generatedImages: generatedImages ?? this.generatedImages,
      imageMimeTypes: imageMimeTypes ?? this.imageMimeTypes,
      imageAnalysis: imageAnalysis ?? this.imageAnalysis,
      userIntent: userIntent ?? this.userIntent,
      intentConfidence: intentConfidence ?? this.intentConfidence,
      intentReasoning: intentReasoning ?? this.intentReasoning,
      suitability: suitability ?? this.suitability,
      recommendations: recommendations ?? this.recommendations,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'textResponse': textResponse,
      'generatedImages': generatedImages.map((img) => img.toList()).toList(),
      'imageMimeTypes': imageMimeTypes,
      'imageAnalysis': imageAnalysis,
      'userIntent': userIntent,
      'intentConfidence': intentConfidence,
      'intentReasoning': intentReasoning,
      'suitability': suitability,
      'recommendations': recommendations,
    };
  }

  @override
  List<Object?> get props => [
    textResponse,
    generatedImages,
    imageMimeTypes,
    imageAnalysis,
    userIntent,
    intentConfidence,
    intentReasoning,
    suitability,
    recommendations,
  ];

  @override
  String toString() {
    return 'ImageGenerationResponse(textResponse: ${textResponse.length} chars, generatedImages: ${generatedImages.length}, imageMimeTypes: ${imageMimeTypes.length})';
  }
}
