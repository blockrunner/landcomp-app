/// Profile page for user information
///
/// This page displays user profile information and allows
/// users to manage their account settings.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:landcomp_app/core/localization/language_provider.dart';
import '../../../projects/presentation/widgets/projects_sidebar.dart';

/// Profile page widget
class ProfilePage extends StatelessWidget {
  /// Creates a profile page
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) => Scaffold(
        appBar: AppBar(
          title: Text(languageProvider.getString('profileTitle')),
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
        ),
        drawer: const ProjectsSidebar(),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      languageProvider.getString('landcompUser'),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      languageProvider.getString('userEmail'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Statistics Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageProvider.getString('usageStatistics'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          context,
                          languageProvider.getString('messages'),
                          '0',
                          Icons.chat,
                        ),
                        _buildStatItem(
                          context,
                          languageProvider.getString('sessions'),
                          '0',
                          Icons.schedule,
                        ),
                        _buildStatItem(
                          context,
                          languageProvider.getString('daysActive'),
                          '0',
                          Icons.calendar_today,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Account Section
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: Text(languageProvider.getString('editProfile')),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // TODO: Navigate to edit profile
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.security),
                    title: Text(languageProvider.getString('privacySecurity')),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // TODO: Navigate to privacy settings
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.download),
                    title: Text(languageProvider.getString('exportData')),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // TODO: Export user data
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Support Section
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.help),
                    title: Text(languageProvider.getString('helpSupport')),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // TODO: Open help center
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.feedback),
                    title: Text(languageProvider.getString('sendFeedback')),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // TODO: Open feedback form
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.star),
                    title: Text(languageProvider.getString('rateApp')),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // TODO: Open app store rating
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Danger Zone
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.logout,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    title: Text(
                      languageProvider.getString('signOut'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                    onTap: () {
                      _showSignOutDialog(context);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.delete_forever,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    title: Text(
                      languageProvider.getString('deleteAccount'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                    onTap: () {
                      _showDeleteAccountDialog(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a statistics item
  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  /// Shows sign out confirmation dialog
  void _showSignOutDialog(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(languageProvider.getString('signOut')),
        content: Text(languageProvider.getString('signOutConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(languageProvider.getString('cancel')),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement sign out
              Navigator.of(context).pop();
            },
            child: Text(languageProvider.getString('signOut')),
          ),
        ],
      ),
    );
  }

  /// Shows delete account confirmation dialog
  void _showDeleteAccountDialog(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(languageProvider.getString('deleteAccount')),
        content: Text(languageProvider.getString('deleteAccountConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(languageProvider.getString('cancel')),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement account deletion
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(languageProvider.getString('delete')),
          ),
        ],
      ),
    );
  }
}
