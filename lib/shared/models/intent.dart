import 'package:equatable/equatable.dart';

/// Represents a classified user intent
enum IntentType {
  consultation,    // User asking question/advice
  generation,      // User wants image generated
  modification,    // User wants to modify existing
  analysis,        // User wants analysis of situation/image
  unclear,         // Intent is unclear
}

/// Subtypes for more detailed intent classification
enum IntentSubtype {
  // Consultation subtypes
  landscapePlanning,    // Planning and design consultation
  plantSelection,       // Plant and garden advice
  constructionAdvice,   // Building and construction help
  maintenanceAdvice,    // Care and maintenance tips
  generalQuestion,      // General questions
  
  // Generation subtypes
  imageGeneration,      // Generate new images
  textGeneration,       // Generate text content
  planGeneration,       // Generate plans or layouts
  
  // Analysis subtypes
  imageAnalysis,        // Analyze uploaded images
  siteAnalysis,         // Analyze site conditions
  problemDiagnosis,     // Diagnose problems
  
  // Modification subtypes
  designModification,   // Modify existing designs
  planAdjustment,       // Adjust existing plans
  contentUpdate,        // Update existing content
  
  // Unclear
  ambiguous,            // Intent is ambiguous
  incomplete,           // Intent is incomplete
}


/// Represents a classified user intent with detailed information
class Intent extends Equatable {
  const Intent({
    required this.type,
    required this.confidence,
    required this.reasoning,
    this.subtype,
    this.metadata = const {},
    this.extractedEntities = const [],
  });

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
      extractedEntities: List<String>.from(json['extracted_entities'] as List? ?? []),
    );
  }

  final IntentType type;
  final double confidence;
  final String reasoning;
  final IntentSubtype? subtype;
  final Map<String, dynamic> metadata;
  final List<String> extractedEntities;

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

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'confidence': confidence,
      'reasoning': reasoning,
      'subtype': subtype?.name,
      'metadata': metadata,
      'extractedEntities': extractedEntities,
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
      ];
}