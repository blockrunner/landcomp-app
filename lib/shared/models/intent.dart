import 'package:equatable/equatable.dart';

/// Represents a classified user intent
enum IntentType {
  /// User asking question/advice
  consultation,
  /// User wants image generated
  generation,
  /// User wants to modify existing
  modification,
  /// User wants analysis of situation/image
  analysis,
  /// Intent is unclear
  unclear,
}

/// Subtypes for more detailed intent classification
enum IntentSubtype {
  /// Planning and design consultation
  landscapePlanning,
  /// Plant and garden advice
  plantSelection,
  /// Building and construction help
  constructionAdvice,
  /// Care and maintenance tips
  maintenanceAdvice,
  /// General questions
  generalQuestion,
  /// Generate new images
  imageGeneration,
  /// Generate text content
  textGeneration,
  /// Generate plans or layouts
  planGeneration,
  /// Analyze uploaded images
  imageAnalysis,
  /// Analyze site conditions
  siteAnalysis,
  /// Diagnose problems
  problemDiagnosis,
  /// Modify existing designs
  designModification,
  /// Adjust existing plans
  planAdjustment,
  /// Update existing content
  contentUpdate,
  /// Intent is ambiguous
  ambiguous,
  /// Intent is incomplete
  incomplete,
}

/// Image intent classification - what user wants to do with images
enum ImageIntent {
  /// Анализировать новое загруженное изображение
  analyzeNew,
  /// Анализировать недавнее изображение из истории
  analyzeRecent,
  /// Сравнить несколько изображений
  compareMultiple,
  /// Ссылка на конкретное изображение (первое, второе, предыдущее)
  referenceSpecific,
  /// Генерировать на основе изображения
  generateBased,
  /// Изображения не нужны для ответа
  noImageNeeded,
  /// Неясно, нужны ли изображения
  unclear,
}

/// Represents a classified user intent with detailed information
class Intent extends Equatable {
  /// Creates a new Intent instance
  const Intent({
    required this.type,
    required this.confidence,
    required this.reasoning,
    this.subtype,
    this.metadata = const {},
    this.extractedEntities = const [],
    this.imageIntent,
    this.referencedImageIndices,
    this.imagesNeeded,
  });

  /// Creates an Intent instance from JSON data
  factory Intent.fromJson(Map<String, dynamic> json) {
    return Intent(
      type: IntentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => IntentType.unclear,
      ),
      confidence: (json['confidence'] as num).toDouble(),
      reasoning: json['reasoning'] as String,
      subtype: json['subtype'] != null
          ? IntentSubtype.values.firstWhere(
              (e) => e.name == json['subtype'],
              orElse: () => IntentSubtype.generalQuestion,
            )
          : null,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
      extractedEntities: List<String>.from(
        json['extracted_entities'] as List? ?? [],
      ),
      imageIntent: json['imageIntent'] != null
          ? ImageIntent.values.firstWhere(
              (e) => e.name == json['imageIntent'],
              orElse: () => ImageIntent.unclear,
            )
          : null,
      referencedImageIndices: json['referencedImageIndices'] != null
          ? List<int>.from(json['referencedImageIndices'] as List)
          : null,
      imagesNeeded: json['imagesNeeded'] as int?,
    );
  }

  /// The primary intent type
  final IntentType type;
  /// Confidence level of the intent classification (0.0 to 1.0)
  final double confidence;
  /// Reasoning behind the intent classification
  final String reasoning;
  /// Optional subtype for more detailed classification
  final IntentSubtype? subtype;
  /// Additional metadata about the intent
  final Map<String, dynamic> metadata;
  /// Entities extracted from the user input
  final List<String> extractedEntities;

  /// Image-related intent classification
  final ImageIntent? imageIntent;

  /// Referenced image indices (if referenceSpecific)
  final List<int>? referencedImageIndices;

  /// Number of images needed for the request
  final int? imagesNeeded;

  /// Check if intent is consultation type
  bool get isConsultation => type == IntentType.consultation;

  /// Check if intent is generation type
  bool get isGeneration => type == IntentType.generation;

  /// Check if intent is analysis type
  bool get isAnalysis => type == IntentType.analysis;

  /// Check if intent is modification type
  bool get isModification => type == IntentType.modification;

  /// Check if intent is unclear type
  bool get isUnclear => type == IntentType.unclear;

  /// Check if intent has high confidence (>= 0.8)
  bool get isHighConfidence => confidence >= 0.8;

  /// Check if intent has medium confidence (>= 0.5)
  bool get isMediumConfidence => confidence >= 0.5;

  /// Check if intent has low confidence (< 0.5)
  bool get isLowConfidence => confidence < 0.5;

  /// Converts the Intent to JSON format
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'confidence': confidence,
      'reasoning': reasoning,
      'subtype': subtype?.name,
      'metadata': metadata,
      'extractedEntities': extractedEntities,
      'imageIntent': imageIntent?.name,
      'referencedImageIndices': referencedImageIndices,
      'imagesNeeded': imagesNeeded,
    };
  }

  @override
  List<Object?> get props => [
    type,
    confidence,
    reasoning,
    subtype,
    metadata,
    extractedEntities,
    imageIntent,
    referencedImageIndices,
    imagesNeeded,
  ];
}
