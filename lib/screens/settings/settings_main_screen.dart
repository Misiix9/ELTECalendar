// File: lib/screens/settings/settings_main_screen.dart
// Purpose: Main settings screen with theme controls and other app preferences
// Step: Settings Screen Implementation

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/localization_config.dart';
import '../../services/theme_service.dart';
import '../../services/language_service.dart';
import '../../services/auth_service.dart';
import 'semester_management_screen.dart';
import 'notification_settings_screen.dart';
import 'sync_settings_screen.dart';

/// Main settings screen with all app preferences and controls
class SettingsMainScreen extends StatelessWidget {
  const SettingsMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.getString('settings') ?? 'Settings'),
      ),
      body: Consumer3<ThemeService, LanguageService, AuthService>(
        builder: (context, themeService, languageService, authService, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Theme Settings Section
              _buildSectionHeader(
                context, 
                localizations?.getString('themeSettings') ?? 'Theme Settings',
                Icons.palette,
              ),
              const SizedBox(height: 8),
              _buildThemeSelector(context, themeService),
              
              const SizedBox(height: 24),
              
              // Language Settings Section
              _buildSectionHeader(
                context,
                localizations?.getString('language') ?? 'Language',
                Icons.language,
              ),
              const SizedBox(height: 8),
              _buildLanguageSelector(context, languageService, localizations),
              
              const SizedBox(height: 32),
              
              // Academic Settings Section
              _buildSectionHeader(
                context,
                localizations?.getString('academicSettings') ?? 'Academic Settings',
                Icons.school,
              ),
              const SizedBox(height: 8),
              _buildSettingsTile(
                context,
                title: localizations?.getString('manageSemesters') ?? 'Manage Semesters',
                subtitle: localizations?.getString('manageSemestersDesc') ?? 'Add, edit, and organize your academic semesters',
                icon: Icons.calendar_today,
                onTap: () => _navigateToSemesterManagement(context),
              ),
              
              const SizedBox(height: 16),
              
              // Notification Settings Section
              _buildSectionHeader(
                context,
                localizations?.getString('notifications') ?? 'Notifications',
                Icons.notifications,
              ),
              const SizedBox(height: 8),
              _buildSettingsTile(
                context,
                title: localizations?.getString('notificationSettings') ?? 'Notification Settings',
                subtitle: localizations?.getString('notificationSettingsDesc') ?? 'Manage your notification preferences',
                icon: Icons.notification_important,
                onTap: () => _navigateToNotificationSettings(context),
              ),
              
              const SizedBox(height: 16),
              
              // Sync Settings Section
              _buildSectionHeader(
                context,
                localizations?.getString('syncSettings') ?? 'Sync & Data',
                Icons.sync,
              ),
              const SizedBox(height: 8),
              _buildSettingsTile(
                context,
                title: localizations?.getString('syncSettings') ?? 'Sync Settings',
                subtitle: localizations?.getString('syncSettingsDesc') ?? 'Manage data synchronization and backup',
                icon: Icons.cloud_sync,
                onTap: () => _navigateToSyncSettings(context),
              ),
              
              const SizedBox(height: 32),
              
              // Account Section
              _buildSectionHeader(
                context,
                localizations?.getString('account') ?? 'Account',
                Icons.person,
              ),
              const SizedBox(height: 8),
              _buildSettingsTile(
                context,
                title: localizations?.getString('signOut') ?? 'Sign Out',
                subtitle: '${authService.currentUser?.email ?? 'Unknown'}',
                icon: Icons.logout,
                onTap: () => _signOut(context, authService),
                isDestructive: true,
              ),
            ],
          );
        },
      ),
    );
  }
  
  /// Build section header
  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
  
  /// Build theme selector widget
  Widget _buildThemeSelector(BuildContext context, ThemeService themeService) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'App Theme',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            // Light Theme Option
            _buildThemeOption(
              context,
              title: 'Light',
              subtitle: 'Clean, bright interface',
              icon: Icons.light_mode,
              isSelected: themeService.themeMode == ThemeMode.light,
              onTap: () => themeService.setLightTheme(),
            ),
            
            const SizedBox(height: 8),
            
            // Dark Theme Option
            _buildThemeOption(
              context,
              title: 'Dark',
              subtitle: 'Easy on the eyes',
              icon: Icons.dark_mode,
              isSelected: themeService.themeMode == ThemeMode.dark,
              onTap: () => themeService.setDarkTheme(),
            ),
            
            const SizedBox(height: 8),
            
            // System Theme Option
            _buildThemeOption(
              context,
              title: 'System',
              subtitle: 'Follow device setting',
              icon: Icons.auto_mode,
              isSelected: themeService.themeMode == ThemeMode.system,
              onTap: () => themeService.setSystemTheme(),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build language selector widget
  Widget _buildLanguageSelector(BuildContext context, LanguageService languageService, AppLocalizations? localizations) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations?.getString('language') ?? 'App Language',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            ...languageService.getAvailableLanguages().map((languageOption) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildLanguageOption(
                  context,
                  languageOption: languageOption,
                  isSelected: languageService.currentLanguageCode == languageOption.code,
                  onTap: () => languageService.setLanguage(languageOption.code),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
  
  /// Build individual language option
  Widget _buildLanguageOption(
    BuildContext context, {
    required LanguageOption languageOption,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          color: isSelected 
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : null,
        ),
        child: Row(
          children: [
            Text(
              languageOption.flag,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    languageOption.nativeName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    languageOption.englishName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
  
  /// Build individual theme option
  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          color: isSelected 
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
  
  /// Build settings tile
  Widget _buildSettingsTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive 
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive 
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        ),
        onTap: onTap,
      ),
    );
  }
  
  /// Navigate to semester management
  void _navigateToSemesterManagement(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SemesterManagementScreen(),
      ),
    );
  }
  
  /// Navigate to notification settings
  void _navigateToNotificationSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NotificationSettingsScreen(),
      ),
    );
  }
  
  /// Navigate to sync settings
  void _navigateToSyncSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SyncSettingsScreen(),
      ),
    );
  }
  
  /// Sign out user
  void _signOut(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              authService.signOut();
            },
            child: Text(
              'Sign Out',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
