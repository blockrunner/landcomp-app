/// Specialized agent for image generation
///
/// This agent executes generation requests based on AI-provided execution
/// plans.
/// It handles image generation through Gemini API with smart image selection
/// and fallback mechanisms.
library;

import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:landcomp_app/core/agents/base/agent.dart';
import 'package:landcomp_app/core/network/ai_service.dart';
import 'package:landcomp_app/features/chat/domain/entities/attachment.dart';
import 'package:landcomp_app/features/chat/domain/entities/message.dart';
import 'package:landcomp_app/shared/models/agent_request.dart';
import 'package:landcomp_app/shared/models/agent_response.dart';
import 'package:landcomp_app/shared/models/context.dart';
import 'package:landcomp_app/shared/models/intent.dart';

/// Specialized agent for image generation
/// Executes generation requests based on AI-provided execution plans
class GenerationAgent implements Agent {
  GenerationAgent._();

  static final GenerationAgent _instance = GenerationAgent._();
  
  /// Get the singleton instance of GenerationAgent
  static GenerationAgent get instance => _instance;

  final AIService _aiService = AIService.instance;

  @override
  String get id => 'generation_agent';

  @override
  String get name => 'Image Generation Agent';

  @override
  List<String> get capabilities => [
    AgentCapabilities.imageGeneration,
    AgentCapabilities.textGeneration,
  ];

  @override
  Future<bool> canHandle(Intent intent, RequestContext context) async {
    developer.log(
      'GenerationAgent.canHandle called for intent: ${intent.type.name}',
      name: 'GenerationAgent',
    );

    // Check if this is a generation request via execution plan
    if (intent.executionPlan?.action == ExecutionAction.generateImage) {
      developer.log(
        'GenerationAgent: Can handle via execution plan',
        name: 'GenerationAgent',
      );
      return true;
    }

    // Fallback checks for legacy compatibility
    if (intent.type == IntentType.generation &&
        intent.subtype == IntentSubtype.imageGeneration) {
      developer.log(
        'GenerationAgent: Can handle via legacy generation intent',
        name: 'GenerationAgent',
      );
      return true;
    }

    if (intent.imageIntent == ImageIntent.generateBased) {
      developer.log(
        'GenerationAgent: Can handle via image intent generateBased',
        name: 'GenerationAgent',
      );
      return true;
    }

    developer.log(
      'GenerationAgent: Cannot handle this intent',
      name: 'GenerationAgent',
    );
    return false;
  }

  @override
  Future<AgentResponse> execute(AgentRequest request) async {
    developer.log(
      'GenerationAgent.execute called for request: ${request.requestId}',
      name: 'GenerationAgent',
    );

    try {
      // 1. Extract execution plan or create default
      final plan = request.intent.executionPlan ?? _createDefaultPlan(request);

      // 2. Validate plan and apply smart defaults
      final validatedPlan = _validateAndFixPlan(plan, request);

      developer.log(
        'GenerationAgent: Validated plan - action: '
        '${validatedPlan.action.name}, imageCount: '
        '${validatedPlan.expectedOutputs.imageCount}',
        name: 'GenerationAgent',
      );

      // 3. Select images according to plan
      final selectedImages = await _selectImagesFromPlan(
        validatedPlan.imageSelection,
        request.context,
      );

      developer.log(
        'GenerationAgent: Selected ${selectedImages.length} images for '
        'generation',
        name: 'GenerationAgent',
      );

      // 4. Execute generation via Gemini
      try {
        final result = await _executeGeneration(
          prompt: validatedPlan.enhancedPrompt,
          images: selectedImages,
          expectedOutputs: validatedPlan.expectedOutputs,
          request: request,
        );

        return AgentResponse.success(
          requestId: request.requestId,
          message: result.textResponse,
          generatedAttachments: result.images,
          metadata: {
            'execution_plan': validatedPlan.toJson(),
            'images_used': selectedImages.length,
            'images_generated': result.images.length,
            'agent_id': id,
            'agent_name': name,
          },
        );
      } catch (e) {
        developer.log(
          'GenerationAgent: Primary generation failed: $e',
          name: 'GenerationAgent',
        );
        // Fallback: try different model/API
        return await _executeFallback(validatedPlan, selectedImages, request);
      }
    } catch (e) {
      developer.log(
        'GenerationAgent: Execution failed: $e',
        name: 'GenerationAgent',
      );
      return AgentResponse.error(
        requestId: request.requestId,
        error: 'Generation failed: $e',
        metadata: {
          'agent_id': id,
          'agent_name': name,
          'error_type': e.runtimeType.toString(),
        },
      );
    }
  }

  /// Create default execution plan if AI didn't provide one
  ExecutionPlan _createDefaultPlan(AgentRequest request) {
    developer.log(
      'GenerationAgent: Creating default execution plan',
      name: 'GenerationAgent',
    );

    return ExecutionPlan(
      action: ExecutionAction.generateImage,
      targetAPI: 'gemini',
      imageSelection: const ImageSelectionPlan(
        sources: [ImageSource.userCurrent],
        allFromUserMessage: true,
        explanation: 'Default plan: use all images from current message',
      ),
      enhancedPrompt: request.context.userMessage,
      expectedOutputs: const ExpectedOutputs(
        imageCount: 1,
        includeText: true,
      ),
    );
  }

  /// Validate plan and apply smart defaults (strategy d)
  ExecutionPlan _validateAndFixPlan(
    ExecutionPlan plan,
    AgentRequest request,
  ) {
    developer.log(
      'GenerationAgent: Validating and fixing execution plan',
      name: 'GenerationAgent',
    );

    // Apply smart defaults:
    // - If action = generateImage → targetAPI = 'gemini'
    final targetAPI = plan.targetAPI.isEmpty ? 'gemini' : plan.targetAPI;

    // - If no prompt → use original user message
    final enhancedPrompt = plan.enhancedPrompt.isEmpty
        ? request.context.userMessage
        : plan.enhancedPrompt;

    // - If allFromUserMessage and has images → use all current
    final imageSelection = plan.imageSelection;
    final hasCurrentImages = request.context.attachments
        ?.any((a) => a.isImage) ?? false;

    final enhancedImageSelection = ImageSelectionPlan(
      sources: imageSelection.sources.isEmpty
          ? [ImageSource.userCurrent]
          : imageSelection.sources,
      allFromUserMessage: hasCurrentImages
          ? imageSelection.allFromUserMessage
          : false,
      indices: imageSelection.indices,
      explanation: imageSelection.explanation ?? 'Smart defaults applied',
    );

    // - If expectedOutputs.imageCount = 0 → set to 1
    final expectedOutputs = ExpectedOutputs(
      imageCount: plan.expectedOutputs.imageCount == 0
          ? 1
          : plan.expectedOutputs.imageCount,
      includeText: plan.expectedOutputs.includeText,
    );

    return ExecutionPlan(
      action: plan.action,
      targetAPI: targetAPI,
      imageSelection: enhancedImageSelection,
      enhancedPrompt: enhancedPrompt,
      expectedOutputs: expectedOutputs,
    );
  }

  /// Select images according to execution plan
  Future<List<Attachment>> _selectImagesFromPlan(
    ImageSelectionPlan plan,
    RequestContext context,
  ) async {
    developer.log(
      'GenerationAgent: Selecting images from plan',
      name: 'GenerationAgent',
    );

    final selectedImages = <Attachment>[];

    if (plan.allFromUserMessage) {
      // All images from current user message
      if (context.attachments != null) {
        selectedImages.addAll(
          context.attachments!.where((a) => a.isImage),
        );
      }
    } else if (plan.indices != null && plan.indices!.isNotEmpty) {
      // Specific images by indices from history
      selectedImages.addAll(
        _getImagesByIndices(plan.indices!, context.conversationHistory),
      );
    } else {
      // Select by sources
      for (final source in plan.sources) {
        switch (source) {
          case ImageSource.userCurrent:
            if (context.attachments != null) {
              selectedImages.addAll(
                context.attachments!.where((a) => a.isImage),
              );
            }
          case ImageSource.historyRecent:
            selectedImages.addAll(
              _getRecentImages(context.conversationHistory),
            );
          case ImageSource.historySpecific:
            // This would need specific indices, handled above
        }
      }
    }

    // Remove duplicates and limit to reasonable number
    final uniqueImages = selectedImages.toSet().toList();
    final limitedImages = uniqueImages.take(5).toList();

    developer.log(
      'GenerationAgent: Selected ${limitedImages.length} unique images',
      name: 'GenerationAgent',
    );

    return limitedImages;
  }

  /// Get images by specific indices from conversation history
  List<Attachment> _getImagesByIndices(
    List<int> indices,
    List<Message> history,
  ) {
    final allImages = <Attachment>[];
    for (final message in history) {
      if (message.attachments != null) {
        allImages.addAll(
          message.attachments!.where((a) => a.isImage),
        );
      }
    }

    final selectedImages = <Attachment>[];
    for (final index in indices) {
      if (index >= 0 && index < allImages.length) {
        selectedImages.add(allImages[index]);
      }
    }

    return selectedImages;
  }

  /// Get recent images from conversation history
  List<Attachment> _getRecentImages(List<Message> history) {
    final recentImages = <Attachment>[];
    final recentMessages = history.length > 5
        ? history.sublist(history.length - 5)
        : history;

    for (final message in recentMessages.reversed) {
      if (message.attachments != null) {
        for (final attachment in message.attachments!.where((a) => a.isImage)) {
          recentImages.add(attachment);
          if (recentImages.length >= 3) break; // Limit to 3 recent images
        }
      }
      if (recentImages.length >= 3) break;
    }

    return recentImages;
  }

  /// Detect user language from request context
  String _detectUserLanguage(AgentRequest request) {
    // Check current user message for Russian text
    if (_containsRussianText(request.userMessage)) {
      return 'ru';
    }

    // Check conversation history for Russian text
    for (final message in request.context.conversationHistory) {
      if (message.type == MessageType.user && 
          _containsRussianText(message.content)) {
        return 'ru';
      }
    }

    return 'en'; // Default to English
  }

  /// Check if text contains Russian characters
  bool _containsRussianText(String text) {
    // Russian Unicode range: \u0400-\u04FF
    return RegExp(r'[\u0400-\u04FF]').hasMatch(text);
  }

  /// Execute generation via Gemini API
  Future<({String textResponse, List<Attachment> images})> _executeGeneration({
    required String prompt,
    required List<Attachment> images,
    required ExpectedOutputs expectedOutputs,
    required AgentRequest request,
  }) async {
    developer.log(
      'GenerationAgent: Executing generation with ${images.length} images',
      name: 'GenerationAgent',
    );

    try {
      // Convert attachments to Uint8List for Gemini API
      final imageData = <Uint8List>[];
      for (final attachment in images) {
        if (attachment.data != null) {
          imageData.add(attachment.data!);
        }
      }

      // Detect user language from request context
      final userLanguage = _detectUserLanguage(request);
      
      developer.log(
        'GenerationAgent: Requesting ${expectedOutputs.imageCount} '
        'images from Gemini',
        name: 'GenerationAgent',
      );
      
      final response = await _aiService.sendImageGenerationToGemini(
        prompt: prompt,
        images: imageData,
        userLanguage: userLanguage,
        requestedImageCount: expectedOutputs.imageCount,
      );

      if (response.hasGeneratedImages) {
        final generatedAttachments = <Attachment>[];
        for (var i = 0; i < response.generatedImages.length; i++) {
          final imageBytes = response.generatedImages[i];
          final mimeType = i < response.imageMimeTypes.length 
              ? response.imageMimeTypes[i] 
              : 'image/png';
          
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          generatedAttachments.add(
            Attachment.image(
              id: 'generated_${timestamp}_$i',
              name: 'generated_${timestamp}_$i.png',
              data: imageBytes,
              mimeType: mimeType,
            ),
          );
        }

        return (
          textResponse: response.textResponse.isNotEmpty 
              ? response.textResponse 
              : 'Image generated successfully',
          images: generatedAttachments,
        );
      } else {
        throw Exception('Generation failed: ${response.textResponse}');
      }
    } catch (e) {
      developer.log(
        'GenerationAgent: Generation execution failed: $e',
        name: 'GenerationAgent',
      );
      rethrow;
    }
  }

  /// Fallback strategy (strategy a + 4.d)
  Future<AgentResponse> _executeFallback(
    ExecutionPlan plan,
    List<Attachment> images,
    AgentRequest request,
  ) async {
    developer.log(
      'GenerationAgent: Executing fallback strategy',
      name: 'GenerationAgent',
    );

    // 1. Try different Gemini model (if available)
    try {
      developer.log(
        'GenerationAgent: Trying fallback generation method',
        name: 'GenerationAgent',
      );

      // For now, we only have one Gemini model, so we'll try a simplified
      // prompt
      final simplifiedPrompt = _createSimplifiedPrompt(plan.enhancedPrompt);
      
      final result = await _executeGeneration(
        prompt: simplifiedPrompt,
        images: images.take(1).toList(), // Use only first image for fallback
        expectedOutputs: const ExpectedOutputs(
          imageCount: 1,
          includeText: true,
        ),
        request: request,
      );

      return AgentResponse.success(
        requestId: request.requestId,
        message: '${result.textResponse} (Generated with fallback method)',
        generatedAttachments: result.images,
        metadata: {
          'execution_plan': plan.toJson(),
          'fallback_used': true,
          'images_used': images.length,
          'images_generated': result.images.length,
          'agent_id': id,
          'agent_name': name,
        },
      );
    } catch (e) {
      developer.log(
        'GenerationAgent: Fallback generation failed: $e',
        name: 'GenerationAgent',
      );
    }

    // 2. Apply basic rules fallback (strategy a) - return consultation instead
    developer.log(
      'GenerationAgent: Using basic rules fallback - returning consultation',
      name: 'GenerationAgent',
    );

    return AgentResponse.success(
      requestId: request.requestId,
      message: 'I understand you want to generate images, but I\'m having '
          'trouble with the image generation service right now. '
          'Could you describe what you\'d like to create, and I can provide '
          'detailed guidance on how to achieve it?',
      metadata: {
        'execution_plan': plan.toJson(),
        'fallback_used': true,
        'fallback_type': 'consultation',
        'agent_id': id,
        'agent_name': name,
      },
    );
  }

  /// Create simplified prompt for fallback generation
  String _createSimplifiedPrompt(String originalPrompt) {
    // Remove complex instructions and keep core request
    final simplified = originalPrompt
        .replaceAll(RegExp(r'[^\w\s]'), ' ') // Remove special characters
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
        .trim();

    // Limit length
    if (simplified.length > 100) {
      return '${simplified.substring(0, 100)}...';
    }

    return simplified.isEmpty ? 'Create a landscape design' : simplified;
  }

  @override
  Map<String, dynamic> getMetrics() {
    return {
      'agent_id': id,
      'agent_name': name,
      'capabilities': capabilities,
      'is_specialized': true,
      'generation_type': 'image_generation',
    };
  }

  @override
  Future<void> initialize() async {
    developer.log(
      'GenerationAgent: Initializing',
      name: 'GenerationAgent',
    );
    // No specific initialization needed
  }

  @override
  Future<void> dispose() async {
    developer.log(
      'GenerationAgent: Disposing',
      name: 'GenerationAgent',
    );
    // No specific disposal needed
  }
}
