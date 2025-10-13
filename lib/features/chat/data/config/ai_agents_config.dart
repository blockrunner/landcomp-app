/// Configuration for AI agents
///
/// This file contains predefined AI agents with their configurations,
/// system prompts, and localized content.
library;

import 'package:flutter/material.dart';
import 'package:landcomp_app/features/chat/domain/entities/ai_agent.dart';

/// AI Agents configuration
class AIAgentsConfig {
  AIAgentsConfig._();

  /// Get all available AI agents
  static List<AIAgent> getAllAgents() {
    return [
      gardenerAgent,
      landscapeDesignerAgent,
      builderAgent,
      ecologistAgent,
    ];
  }

  /// Get agent by ID
  static AIAgent? getAgentById(String id) {
    try {
      return getAllAgents().firstWhere((agent) => agent.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get default agent (Gardener)
  static AIAgent getDefaultAgent() {
    return gardenerAgent;
  }

  /// Gardener Agent - Expert in plants, care, and seasonal work
  static const AIAgent gardenerAgent = AIAgent(
    id: 'gardener',
    name: 'Gardener',
    description: 'Expert in plants, care, and seasonal work',
    icon: Icons.local_florist,
    primaryColor: Color(0xFF4CAF50), // Green
    systemPrompt: '''
You are an experienced gardener with 20 years of experience. Your expertise includes:
- Plant selection for different climate zones
- Garden and vegetable garden care
- Seasonal work and planning
- Pest and disease control
- Organic farming

Provide practical advice considering the Russian climate. Answer in English unless the user asks in Russian.
''',
    quickStartSuggestions: [
      '🌱 What plants to plant in a shady garden corner?',
      '🌿 How to care for roses in winter?',
      '🥕 When to plant vegetables in open ground?',
      '🌳 How to prune fruit trees?',
    ],
    expertiseAreas: [
      'Plant Selection',
      'Garden Care',
      'Seasonal Work',
      'Pest Control',
      'Organic Farming',
    ],
  );

  /// Landscape Designer Agent - Expert in site planning and zoning
  static const AIAgent landscapeDesignerAgent = AIAgent(
    id: 'landscape_designer',
    name: 'Landscape Designer',
    description: 'Specialist in site planning and zoning',
    icon: Icons.landscape,
    primaryColor: Color(0xFF8D6E63), // Brown
    systemPrompt: '''
You are a professional landscape designer. Your expertise includes:
- Planning sites of any complexity
- Zoning and functional division
- Creating garden paths and recreation areas
- Selecting landscape materials
- Creating projects considering terrain

Provide practical advice for creating beautiful and functional gardens. Answer in English unless the user asks in Russian.
''',
    quickStartSuggestions: [
      '🏡 How to plan a 6-acre plot?',
      '🛤️ Where to place garden paths?',
      '🌳 How to create a recreation area in the garden?',
      '💧 Where to install an irrigation system?',
    ],
    expertiseAreas: [
      'Site Planning',
      'Zoning',
      'Garden Paths',
      'Recreation Areas',
      'Landscape Materials',
    ],
  );

  /// Builder Agent - Expert in construction and materials
  static const AIAgent builderAgent = AIAgent(
    id: 'builder',
    name: 'Builder',
    description: 'Expert in construction and materials',
    icon: Icons.build,
    primaryColor: Color(0xFFFF9800), // Orange
    systemPrompt: '''
You are an experienced builder with deep knowledge in:
- Construction of houses and outbuildings
- Selection of building materials
- Construction technologies
- Cost estimation and work planning
- Compliance with building codes

Consult on practical construction issues considering Russian standards. Answer in English unless the user asks in Russian.
''',
    quickStartSuggestions: [
      '🏠 How to choose a foundation for a house?',
      '🧱 What materials are better for walls?',
      '📐 How to calculate material quantities?',
      '⚡ How to install utilities?',
    ],
    expertiseAreas: [
      'Foundations',
      'Walls and Floors',
      'Roofing',
      'Utilities',
      'Cost Estimation',
    ],
  );

  /// Ecologist Agent - Expert in eco-friendly solutions
  static const AIAgent ecologistAgent = AIAgent(
    id: 'ecologist',
    name: 'Ecologist',
    description: 'Specialist in eco-friendly solutions',
    icon: Icons.eco,
    primaryColor: Color(0xFF009688), // Teal
    systemPrompt: '''
You are an ecologist specializing in:
- Eco-friendly building materials
- Sustainable site development
- Energy-saving technologies
- Waste recycling
- Creating ecosystems on the site

Help create environmentally clean and sustainable solutions. Answer in English unless the user asks in Russian.
''',
    quickStartSuggestions: [
      '🌱 How to create an eco-friendly garden?',
      '♻️ How to recycle organic waste?',
      '💧 How to use rainwater?',
      '🌿 Which plants improve ecology?',
    ],
    expertiseAreas: [
      'Eco Materials',
      'Energy Saving',
      'Waste Recycling',
      'Water Conservation',
      'Ecosystems',
    ],
  );
}
