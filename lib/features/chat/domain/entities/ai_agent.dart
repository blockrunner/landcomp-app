/// AI Agent entity for specialized landscape design assistance
///
/// This entity represents different AI agents with their specific
/// expertise areas and configurations.
library;

import 'package:flutter/material.dart';

/// AI Agent entity
class AIAgent {
  /// Creates an AI agent
  const AIAgent({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.primaryColor,
    required this.systemPrompt,
    required this.quickStartSuggestions,
    required this.expertiseAreas,
    this.isActive = true,
  });

  /// Unique identifier for the agent
  final String id;

  /// Display name of the agent
  final String name;

  /// Description of the agent's expertise
  final String description;

  /// Icon for the agent
  final IconData icon;

  /// Primary color for the agent's theme
  final Color primaryColor;

  /// System prompt for the AI model
  final String systemPrompt;

  /// Quick start suggestions for users
  final List<String> quickStartSuggestions;

  /// Areas of expertise
  final List<String> expertiseAreas;

  /// Whether the agent is currently active
  final bool isActive;

  /// Get localized name based on language
  String getLocalizedName(String languageCode) {
    switch (languageCode) {
      case 'ru':
        return _getRussianName();
      case 'en':
      default:
        return name;
    }
  }

  /// Get localized description based on language
  String getLocalizedDescription(String languageCode) {
    switch (languageCode) {
      case 'ru':
        return _getRussianDescription();
      case 'en':
      default:
        return description;
    }
  }

  /// Get localized system prompt based on language
  String getLocalizedSystemPrompt(String languageCode) {
    switch (languageCode) {
      case 'ru':
        return _getRussianSystemPrompt();
      case 'en':
      default:
        return systemPrompt;
    }
  }

  /// Get localized quick start suggestions based on language
  List<String> getLocalizedQuickStartSuggestions(String languageCode) {
    switch (languageCode) {
      case 'ru':
        return _getRussianQuickStartSuggestions();
      case 'en':
      default:
        return quickStartSuggestions;
    }
  }

  /// Get Russian name
  String _getRussianName() {
    switch (id) {
      case 'gardener':
        return 'Садовод';
      case 'landscape_designer':
        return 'Ландшафтный дизайнер';
      case 'builder':
        return 'Строитель';
      case 'ecologist':
        return 'Эколог';
      default:
        return name;
    }
  }

  /// Get Russian description
  String _getRussianDescription() {
    switch (id) {
      case 'gardener':
        return 'Эксперт по растениям, уходу и сезонным работам';
      case 'landscape_designer':
        return 'Специалист по планированию участков и зонированию';
      case 'builder':
        return 'Эксперт по строительству и материалам';
      case 'ecologist':
        return 'Специалист по экологичным решениям';
      default:
        return description;
    }
  }

  /// Get Russian system prompt
  String _getRussianSystemPrompt() {
    switch (id) {
      case 'gardener':
        return '''
Ты - опытный садовод с 20-летним стажем. Твоя специализация:
- Выбор растений для разных климатических зон
- Уход за садом и огородом
- Сезонные работы и планирование
- Борьба с вредителями и болезнями
- Органическое земледелие

Отвечай на русском языке, давай практические советы с учетом российского климата.
''';
      case 'landscape_designer':
        return '''
Ты - профессиональный ландшафтный дизайнер. Твоя экспертиза:
- Планирование участков любой сложности
- Зонирование и функциональное разделение
- Создание садовых дорожек и зон отдыха
- Подбор материалов для ландшафта
- Создание проектов с учетом рельефа

Дай практические советы по созданию красивого и функционального сада.
''';
      case 'builder':
        return '''
Ты - опытный строитель с глубокими знаниями в области:
- Строительство домов и хозяйственных построек
- Выбор строительных материалов
- Технологии строительства
- Расчет смет и планирование работ
- Соблюдение строительных норм

Консультируй по практическим вопросам строительства с учетом российских стандартов.
''';
      case 'ecologist':
        return '''
Ты - эколог, специализирующийся на:
- Экологичные строительные материалы
- Устойчивое развитие участка
- Энергосберегающие технологии
- Переработка отходов
- Создание экосистемы на участке

Помогай создавать экологически чистые и устойчивые решения.
''';
      default:
        return systemPrompt;
    }
  }

  /// Get Russian quick start suggestions
  List<String> _getRussianQuickStartSuggestions() {
    switch (id) {
      case 'gardener':
        return [
          '🌱 Какие растения посадить в тенистом уголке сада?',
          '🌿 Как ухаживать за розами зимой?',
          '🥕 Когда сажать овощи в открытый грунт?',
          '🌳 Как обрезать плодовые деревья?',
        ];
      case 'landscape_designer':
        return [
          '🏡 Как спланировать участок 6 соток?',
          '🛤️ Где разместить садовые дорожки?',
          '🌳 Как создать зону отдыха в саду?',
          '💧 Где установить систему полива?',
        ];
      case 'builder':
        return [
          '🏠 Как выбрать фундамент для дома?',
          '🧱 Какие материалы лучше для стен?',
          '📐 Как рассчитать количество материалов?',
          '⚡ Как провести коммуникации?',
        ];
      case 'ecologist':
        return [
          '🌱 Как создать экологичный сад?',
          '♻️ Как перерабатывать органические отходы?',
          '💧 Как использовать дождевую воду?',
          '🌿 Какие растения улучшают экологию?',
        ];
      default:
        return quickStartSuggestions;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AIAgent && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'AIAgent(id: $id, name: $name)';
}
