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

/// Execution action types for AI-generated plans
enum ExecutionAction {
  /// Generate or modify images
  generateImage,
  /// Analyze existing images
  analyzeImage,
  /// Provide text consultation
  consultText,
}

/// Image source types for selection
enum ImageSource {
  /// Images from current user message
  userCurrent,
  /// Recent images from conversation history
  historyRecent,
  /// Specific images by indices
  historySpecific,
}

/// Expected outputs configuration for execution plans
class ExpectedOutputs extends Equatable {
  /// Creates a new ExpectedOutputs instance
  const ExpectedOutputs({
    required this.imageCount,
    required this.includeText,
  });

  /// Creates an ExpectedOutputs instance from JSON data
  factory ExpectedOutputs.fromJson(Map<String, dynamic> json) {
    return ExpectedOutputs(
      imageCount: json['imageCount'] as int? ?? 1,
      includeText: json['includeText'] as bool? ?? true,
    );
  }

  /// Number of images expected in the output
  final int imageCount;
  
  /// Whether text response should be included
  final bool includeText;

  /// Converts the ExpectedOutputs to JSON format
  Map<String, dynamic> toJson() {
    return {
      'imageCount': imageCount,
      'includeText': includeText,
    };
  }

  @override
  List<Object?> get props => [imageCount, includeText];
}

/// Image selection plan for execution
class ImageSelectionPlan extends Equatable {
  /// Creates a new ImageSelectionPlan instance
  const ImageSelectionPlan({
    required this.sources,
    required this.allFromUserMessage,
    this.indices,
    this.explanation,
  });

  /// Creates an ImageSelectionPlan instance from JSON data
  factory ImageSelectionPlan.fromJson(Map<String, dynamic> json) {
    return ImageSelectionPlan(
      sources: (json['sources'] as List?)
          ?.map((e) => ImageSource.values.firstWhere(
                (source) => source.name == e,
                orElse: () => ImageSource.userCurrent,
              ))
          .toList() ?? [ImageSource.userCurrent],
      allFromUserMessage: json['allFromUserMessage'] as bool? ?? false,
      indices: json['indices'] != null
          ? List<int>.from(json['indices'] as List)
          : null,
      explanation: json['explanation'] as String?,
    );
  }

  /// List of image sources to select from
  final List<ImageSource> sources;
  
  /// Whether to use all images from the current user message
  final bool allFromUserMessage;
  
  /// Specific image indices to select (if applicable)
  final List<int>? indices;
  
  /// Explanation of why these images were selected
  final String? explanation;

  /// Converts the ImageSelectionPlan to JSON format
  Map<String, dynamic> toJson() {
    return {
      'sources': sources.map((e) => e.name).toList(),
      'allFromUserMessage': allFromUserMessage,
      'indices': indices,
      'explanation': explanation,
    };
  }

  @override
  List<Object?> get props => [
        sources,
        allFromUserMessage,
        indices,
        explanation,
      ];
}

/// AI-generated execution plan for request processing
class ExecutionPlan extends Equatable {
  /// Creates a new ExecutionPlan instance
  const ExecutionPlan({
    required this.action,
    required this.targetAPI,
    required this.imageSelection,
    required this.enhancedPrompt,
    required this.expectedOutputs,
  });

  /// Creates an ExecutionPlan instance from JSON data
  factory ExecutionPlan.fromJson(Map<String, dynamic> json) {
    return ExecutionPlan(
      action: ExecutionAction.values.firstWhere(
        (e) => e.name == json['action'],
        orElse: () => ExecutionAction.consultText,
      ),
      targetAPI: json['targetAPI'] as String? ?? 'gemini',
      imageSelection: ImageSelectionPlan.fromJson(
        json['imageSelection'] as Map<String, dynamic>? ?? {},
      ),
      enhancedPrompt: json['enhancedPrompt'] as String? ?? '',
      expectedOutputs: ExpectedOutputs.fromJson(
        json['expectedOutputs'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  /// The action to perform
  final ExecutionAction action;
  
  /// Target API to use (gemini, openai, etc.)
  final String targetAPI;
  
  /// Plan for selecting images
  final ImageSelectionPlan imageSelection;
  
  /// Enhanced prompt for execution
  final String enhancedPrompt;
  
  /// Expected outputs configuration
  final ExpectedOutputs expectedOutputs;

  /// Converts the ExecutionPlan to JSON format
  Map<String, dynamic> toJson() {
    return {
      'action': action.name,
      'targetAPI': targetAPI,
      'imageSelection': imageSelection.toJson(),
      'enhancedPrompt': enhancedPrompt,
      'expectedOutputs': expectedOutputs.toJson(),
    };
  }

  @override
  List<Object?> get props => [
        action,
        targetAPI,
        imageSelection,
        enhancedPrompt,
        expectedOutputs,
      ];
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
    this.executionPlan,
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
      executionPlan: json['executionPlan'] != null
          ? ExecutionPlan.fromJson(
              json['executionPlan'] as Map<String, dynamic>,
            )
          : null,
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

  /// AI-generated execution plan for request processing
  final ExecutionPlan? executionPlan;

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

  /// Creates a copy of this Intent with the given fields replaced
  Intent copyWith({
    IntentType? type,
    double? confidence,
    String? reasoning,
    IntentSubtype? subtype,
    Map<String, dynamic>? metadata,
    List<String>? extractedEntities,
    ImageIntent? imageIntent,
    List<int>? referencedImageIndices,
    int? imagesNeeded,
    ExecutionPlan? executionPlan,
  }) {
    return Intent(
      type: type ?? this.type,
      confidence: confidence ?? this.confidence,
      reasoning: reasoning ?? this.reasoning,
      subtype: subtype ?? this.subtype,
      metadata: metadata ?? this.metadata,
      extractedEntities: extractedEntities ?? this.extractedEntities,
      imageIntent: imageIntent ?? this.imageIntent,
      referencedImageIndices:
          referencedImageIndices ?? this.referencedImageIndices,
      imagesNeeded: imagesNeeded ?? this.imagesNeeded,
      executionPlan: executionPlan ?? this.executionPlan,
    );
  }

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
      'executionPlan': executionPlan?.toJson(),
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
    executionPlan,
  ];
}
