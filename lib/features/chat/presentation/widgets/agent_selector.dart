/// Agent selector widget for choosing AI agents
///
/// This widget displays available AI agents and allows
/// users to switch between them.
library;

import 'package:flutter/material.dart';
import 'package:landcomp_app/core/localization/language_provider.dart';
import 'package:landcomp_app/features/chat/data/config/ai_agents_config.dart';
import 'package:landcomp_app/features/chat/domain/entities/ai_agent.dart';

/// Agent selector widget
class AgentSelector extends StatelessWidget {
  /// Creates an agent selector
  const AgentSelector({
    required this.currentAgent,
    required this.onAgentSelected,
    super.key,
    this.languageProvider,
    this.showAsGrid = true,
  });

  /// Currently selected agent
  final AIAgent currentAgent;

  /// Callback when an agent is selected
  final ValueChanged<AIAgent> onAgentSelected;

  /// Language provider for localization
  final LanguageProvider? languageProvider;

  /// Whether to show agents as a grid or list
  final bool showAsGrid;

  @override
  Widget build(BuildContext context) {
    final agents = AIAgentsConfig.getAllAgents();

    if (showAsGrid) {
      return _buildGridLayout(context, agents);
    } else {
      return _buildListLayout(context, agents);
    }
  }

  /// Build grid layout
  Widget _buildGridLayout(BuildContext context, List<AIAgent> agents) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: agents.length,
      itemBuilder: (context, index) {
        final agent = agents[index];
        return _buildAgentCard(context, agent);
      },
    );
  }

  /// Build list layout
  Widget _buildListLayout(BuildContext context, List<AIAgent> agents) {
    return Column(
      children: agents.map((agent) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildAgentListItem(context, agent),
        );
      }).toList(),
    );
  }

  /// Build agent card for grid layout
  Widget _buildAgentCard(BuildContext context, AIAgent agent) {
    final isSelected = agent.id == currentAgent.id;
    final theme = Theme.of(context);

    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected
          ? agent.primaryColor.withOpacity(0.1)
          : theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: agent.primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => onAgentSelected(agent),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAgentIcon(context, agent, isSelected),
              const SizedBox(height: 12),
              _buildAgentName(context, agent),
              const SizedBox(height: 4),
              _buildAgentDescription(context, agent),
            ],
          ),
        ),
      ),
    );
  }

  /// Build agent list item
  Widget _buildAgentListItem(BuildContext context, AIAgent agent) {
    final isSelected = agent.id == currentAgent.id;
    final theme = Theme.of(context);

    return Card(
      elevation: isSelected ? 2 : 1,
      color: isSelected
          ? agent.primaryColor.withOpacity(0.1)
          : theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: isSelected
            ? BorderSide(color: agent.primaryColor)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => onAgentSelected(agent),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildAgentIcon(context, agent, isSelected, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAgentName(context, agent),
                    const SizedBox(height: 2),
                    _buildAgentDescription(context, agent),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: agent.primaryColor, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Build agent icon
  Widget _buildAgentIcon(
    BuildContext context,
    AIAgent agent,
    bool isSelected, {
    double size = 48,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isSelected
            ? agent.primaryColor
            : agent.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(size / 2),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: agent.primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Icon(
        agent.icon,
        size: size * 0.6,
        color: isSelected ? Colors.white : agent.primaryColor,
      ),
    );
  }

  /// Build agent name
  Widget _buildAgentName(BuildContext context, AIAgent agent) {
    final theme = Theme.of(context);
    final name = _getLocalizedAgentName(agent);

    return Text(
      name,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface,
      ),
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Build agent description
  Widget _buildAgentDescription(BuildContext context, AIAgent agent) {
    final theme = Theme.of(context);
    final description = _getLocalizedAgentDescription(agent);

    return Text(
      description,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Get localized agent name
  String _getLocalizedAgentName(AIAgent agent) {
    if (languageProvider != null) {
      return agent.getLocalizedName(
        languageProvider!.currentLocale.languageCode,
      );
    }
    return agent.name;
  }

  /// Get localized agent description
  String _getLocalizedAgentDescription(AIAgent agent) {
    if (languageProvider != null) {
      return agent.getLocalizedDescription(
        languageProvider!.currentLocale.languageCode,
      );
    }
    return agent.description;
  }
}

/// Compact agent selector for app bar
class CompactAgentSelector extends StatelessWidget {
  /// Creates a compact agent selector
  const CompactAgentSelector({
    required this.currentAgent,
    required this.onAgentSelected,
    super.key,
    this.languageProvider,
  });

  /// Currently selected agent
  final AIAgent currentAgent;

  /// Callback when an agent is selected
  final ValueChanged<AIAgent> onAgentSelected;

  /// Language provider for localization
  final LanguageProvider? languageProvider;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AIAgent>(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: currentAgent.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              currentAgent.icon,
              size: 16,
              color: currentAgent.primaryColor,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _getLocalizedAgentName(currentAgent),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down, size: 20),
        ],
      ),
      itemBuilder: (context) {
        final agents = AIAgentsConfig.getAllAgents();
        return agents.map((agent) {
          return PopupMenuItem<AIAgent>(
            value: agent,
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: agent.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(agent.icon, size: 12, color: agent.primaryColor),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(_getLocalizedAgentName(agent))),
                if (agent.id == currentAgent.id)
                  Icon(Icons.check, color: agent.primaryColor, size: 16),
              ],
            ),
          );
        }).toList();
      },
      onSelected: onAgentSelected,
    );
  }

  /// Get localized agent name
  String _getLocalizedAgentName(AIAgent agent) {
    if (languageProvider != null) {
      return agent.getLocalizedName(
        languageProvider!.currentLocale.languageCode,
      );
    }
    return agent.name;
  }
}
