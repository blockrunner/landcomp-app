/// Smart agent selection service
/// 
/// This service analyzes user queries and automatically selects
/// the most appropriate AI agent based on the query content.
library;

import 'package:landcomp_app/features/chat/domain/entities/ai_agent.dart';
import 'package:landcomp_app/features/chat/data/config/ai_agents_config.dart';

/// Smart agent selection service
class AgentSelector {
  AgentSelector._();
  
  static final AgentSelector _instance = AgentSelector._();
  static AgentSelector get instance => _instance;
  
  /// Keywords for each agent type
  static const Map<String, List<String>> _agentKeywords = {
    'gardener': [
      // Plants and gardening
      'растение', 'растения', 'цветок', 'цветы', 'дерево', 'деревья', 'куст', 'кусты',
      'сад', 'огород', 'клумба', 'посадка', 'посадить', 'выращивание', 'уход',
      'полив', 'удобрение', 'обрезка', 'пересадка', 'семена', 'рассада',
      'вредители', 'болезни', 'лечение', 'защита', 'сезон', 'весна', 'лето', 'осень', 'зима',
      'plant', 'plants', 'flower', 'flowers', 'tree', 'trees', 'bush', 'bushes',
      'garden', 'vegetable garden', 'flowerbed', 'planting', 'growing', 'care',
      'watering', 'fertilizer', 'pruning', 'transplanting', 'seeds', 'seedlings',
      'pests', 'diseases', 'treatment', 'protection', 'season', 'spring', 'summer', 'autumn', 'winter',
      
      // Specific plants
      'роза', 'розы', 'томат', 'помидоры', 'огурец', 'огурцы', 'картофель', 'морковь',
      'лук', 'чеснок', 'капуста', 'перец', 'баклажан', 'кабачок', 'тыква',
      'яблоня', 'груша', 'вишня', 'слива', 'малина', 'смородина', 'крыжовник',
      'rose', 'roses', 'tomato', 'tomatoes', 'cucumber', 'cucumbers', 'potato', 'carrot',
      'onion', 'garlic', 'cabbage', 'pepper', 'eggplant', 'zucchini', 'pumpkin',
      'apple tree', 'pear', 'cherry', 'plum', 'raspberry', 'currant', 'gooseberry',
    ],
    
    'landscape_designer': [
      // Landscape design
      'ландшафт', 'дизайн', 'планировка', 'участок', 'зонирование', 'зоны',
      'дорожки', 'тропинки', 'беседка', 'патио', 'терраса', 'веранда',
      'газон', 'газоны', 'клумбы', 'альпинарий', 'рокарий', 'водоем', 'пруд',
      'освещение', 'подсветка', 'ирригация', 'полив', 'дренаж',
      'landscape', 'design', 'planning', 'plot', 'zoning', 'zones',
      'paths', 'walkways', 'gazebo', 'patio', 'terrace', 'veranda',
      'lawn', 'lawns', 'flowerbeds', 'rock garden', 'water feature', 'pond',
      'lighting', 'irrigation', 'drainage',
      
      // Materials and elements
      'камень', 'камни', 'дерево', 'металл', 'стекло', 'бетон', 'кирпич',
      'плитка', 'бордюр', 'забор', 'ограждение', 'ворота', 'калитка',
      'stone', 'stones', 'wood', 'metal', 'glass', 'concrete', 'brick',
      'tile', 'border', 'fence', 'fencing', 'gate', 'wicket',
    ],
    
    'builder': [
      // Construction
      'строительство', 'строить', 'дом', 'здание', 'постройка', 'фундамент',
      'стены', 'крыша', 'пол', 'потолок', 'окна', 'двери', 'лестница',
      'материалы', 'кирпич', 'бетон', 'дерево', 'металл', 'утеплитель',
      'электричество', 'сантехника', 'отопление', 'вентиляция', 'канализация',
      'construction', 'build', 'building', 'house', 'foundation',
      'walls', 'roof', 'floor', 'ceiling', 'windows', 'doors', 'stairs',
      'materials', 'brick', 'concrete', 'wood', 'metal', 'insulation',
      'electricity', 'plumbing', 'heating', 'ventilation', 'sewage',
      
      // Tools and equipment
      'инструменты', 'оборудование', 'техника', 'краны', 'леса', 'бетономешалка',
      'tools', 'equipment', 'machinery', 'cranes', 'scaffolding', 'concrete mixer',
    ],
    
    'ecologist': [
      // Ecology and sustainability
      'экология', 'экологичный', 'экологически', 'устойчивый', 'природный',
      'переработка', 'отходы', 'компост', 'био', 'органический', 'натуральный',
      'энергосбережение', 'солнечные панели', 'ветрогенератор', 'тепловой насос',
      'дождевая вода', 'сбор воды', 'фильтрация', 'очистка',
      'ecology', 'ecological', 'sustainable', 'natural', 'green',
      'recycling', 'waste', 'compost', 'bio', 'organic', 'natural',
      'energy saving', 'solar panels', 'wind generator', 'heat pump',
      'rainwater', 'water collection', 'filtration', 'purification',
      
      // Environmental protection
      'защита окружающей среды', 'природоохранный', 'биоразнообразие',
      'environmental protection', 'biodiversity', 'conservation',
    ],
  };
  
  /// Out-of-scope keywords that indicate the query is not related to our services
  static const List<String> _outOfScopeKeywords = [
    // Technology and programming
    'программирование', 'код', 'разработка', 'сайт', 'приложение', 'компьютер',
    'programming', 'code', 'development', 'website', 'application', 'computer',
    
    // Medical and health
    'лечение', 'болезнь', 'врач', 'больница', 'лекарство', 'симптомы',
    'treatment', 'disease', 'doctor', 'hospital', 'medicine', 'symptoms',
    
    // Finance and business
    'деньги', 'финансы', 'банк', 'кредит', 'инвестиции', 'бизнес',
    'money', 'finance', 'bank', 'credit', 'investments', 'business',
    
    // Legal
    'закон', 'право', 'суд', 'адвокат', 'документы', 'договор',
    'law', 'legal', 'court', 'lawyer', 'documents', 'contract',
    
    // Education
    'учеба', 'школа', 'университет', 'экзамен', 'диплом', 'курсы',
    'study', 'school', 'university', 'exam', 'diploma', 'courses',
  ];
  
  /// Analyze user query and select appropriate agent
  Future<AgentSelectionResult> selectAgent(String userQuery) async {
    final query = userQuery.toLowerCase().trim();
    
    // Check if query is out of scope
    if (_isOutOfScope(query)) {
      return AgentSelectionResult.outOfScope();
    }
    
    // Calculate scores for each agent
    final scores = <String, int>{};
    
    for (final agentId in _agentKeywords.keys) {
      scores[agentId] = _calculateScore(query, _agentKeywords[agentId]!);
    }
    
    // Find the agent with highest score
    String? selectedAgentId;
    var maxScore = 0;
    
    for (final entry in scores.entries) {
      if (entry.value > maxScore) {
        maxScore = entry.value;
        selectedAgentId = entry.key;
      }
    }
    
    // If no agent has a significant score, default to gardener
    if (maxScore < 2) {
      selectedAgentId = 'gardener';
    }
    
    final selectedAgent = AIAgentsConfig.getAgentById(selectedAgentId!);
    if (selectedAgent == null) {
      return AgentSelectionResult.outOfScope();
    }
    
    return AgentSelectionResult.success(
      agent: selectedAgent,
      confidence: _calculateConfidence(maxScore),
      scores: scores,
    );
  }
  
  /// Check if query is out of scope
  bool _isOutOfScope(String query) {
    for (final keyword in _outOfScopeKeywords) {
      if (query.contains(keyword.toLowerCase())) {
        return true;
      }
    }
    return false;
  }
  
  /// Calculate score for an agent based on keyword matches
  int _calculateScore(String query, List<String> keywords) {
    var score = 0;
    
    for (final keyword in keywords) {
      if (query.contains(keyword.toLowerCase())) {
        // Give more weight to exact matches
        if (query == keyword.toLowerCase()) {
          score += 3;
        } else if (query.startsWith(keyword.toLowerCase()) || 
                   query.endsWith(keyword.toLowerCase())) {
          score += 2;
        } else {
          score += 1;
        }
      }
    }
    
    return score;
  }
  
  /// Calculate confidence level based on score
  double _calculateConfidence(int score) {
    if (score >= 5) return 0.9; // High confidence
    if (score >= 3) return 0.7; // Medium confidence
    if (score >= 1) return 0.5; // Low confidence
    return 0.3; // Very low confidence
  }
  
  /// Get all available agents
  List<AIAgent> getAllAgents() {
    return AIAgentsConfig.getAllAgents();
  }
  
  /// Get agent by ID
  AIAgent? getAgentById(String id) {
    return AIAgentsConfig.getAgentById(id);
  }
}

/// Result of agent selection
class AgentSelectionResult {
  const AgentSelectionResult._({
    required this.isSuccess,
    required this.isOutOfScope,
    this.agent,
    this.confidence,
    this.scores,
    this.outOfScopeMessage,
  });
  
  /// Create successful selection result
  factory AgentSelectionResult.success({
    required AIAgent agent,
    required double confidence,
    required Map<String, int> scores,
  }) {
    return AgentSelectionResult._(
      isSuccess: true,
      isOutOfScope: false,
      agent: agent,
      confidence: confidence,
      scores: scores,
    );
  }
  
  /// Create out-of-scope result
  factory AgentSelectionResult.outOfScope() {
    return AgentSelectionResult._(
      isSuccess: false,
      isOutOfScope: true,
      outOfScopeMessage: _getOutOfScopeMessage(),
    );
  }
  
  /// Whether the selection was successful
  final bool isSuccess;
  
  /// Whether the query is out of scope
  final bool isOutOfScope;
  
  /// Selected agent (if successful)
  final AIAgent? agent;
  
  /// Confidence level (0.0 to 1.0)
  final double? confidence;
  
  /// Scores for all agents
  final Map<String, int>? scores;
  
  /// Out-of-scope message
  final String? outOfScopeMessage;
  
  /// Get localized out-of-scope message
  static String _getOutOfScopeMessage() {
    // For now, return Russian message
    // TODO: Add localization support
    return '''
Извините, но я специализируюсь только на ландшафтном дизайне, садоводстве и загородном строительстве. 

Я могу помочь вам с:
🌱 Выбором и уходом за растениями
🏡 Планировкой участка и ландшафтным дизайном  
🔨 Строительными вопросами и материалами
🌿 Экологичными решениями для участка

Пожалуйста, задайте вопрос по одной из этих тем.''';
  }
}
