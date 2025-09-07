// File: lib/screens/settings/sync_settings_screen.dart
// Purpose: Sync settings and status management screen
// Step: 9.5 - Sync Settings Interface

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../config/localization_config.dart';
import '../../services/connectivity_service.dart';
import '../../services/sync_service.dart';
import '../../widgets/common_widgets/connectivity_banner.dart';

/// Sync settings and status management screen
class SyncSettingsScreen extends StatefulWidget {
  const SyncSettingsScreen({super.key});

  @override
  State<SyncSettingsScreen> createState() => _SyncSettingsScreenState();
}

class _SyncSettingsScreenState extends State<SyncSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: _buildAppBar(context, localizations),
      body: Column(
        children: [
          const ConnectivityBanner(showWhenOnline: true),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ConnectivityStatusCard(),
                  const SizedBox(height: 16),
                  _buildSyncOptions(context, localizations),
                  const SizedBox(height: 16),
                  _buildAdvancedOptions(context, localizations),
                  const SizedBox(height: 16),
                  _buildDebugInfo(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build app bar
  AppBar _buildAppBar(BuildContext context, AppLocalizations? localizations) {
    return AppBar(
      title: Text(localizations?.getString('syncSettings') ?? 'Sync & Offline'),
      backgroundColor: ThemeConfig.lightBackground,
      foregroundColor: ThemeConfig.primaryDarkBlue,
      elevation: 0,
      actions: [
        Consumer<SyncService>(
          builder: (context, syncService, child) {
            return IconButton(
              onPressed: syncService.isSyncing 
                ? null 
                : () => syncService.performSync(force: true),
              icon: syncService.isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ThemeConfig.primaryDarkBlue,
                    ),
                  )
                : const Icon(Icons.sync),
              tooltip: 'Sync Now',
            );
          },
        ),
      ],
    );
  }

  /// Build sync options section
  Widget _buildSyncOptions(BuildContext context, AppLocalizations? localizations) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations?.getString('syncOptions') ?? 'Sync Options',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ThemeConfig.darkTextElements,
              ),
            ),
            const SizedBox(height: 16),
            
            Consumer<SyncService>(
              builder: (context, syncService, child) {
                return Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.sync, color: ThemeConfig.primaryDarkBlue),
                      title: const Text('Auto-sync'),
                      subtitle: const Text('Automatically sync when online'),
                      trailing: Switch(
                        value: true, // TODO: Add auto-sync preference
                        onChanged: (value) {
                          // TODO: Implement auto-sync toggle
                        },
                        activeThumbColor: ThemeConfig.primaryDarkBlue,
                      ),
                    ),
                    
                    ListTile(
                      leading: const Icon(Icons.wifi, color: ThemeConfig.primaryDarkBlue),
                      title: const Text('Wi-Fi only sync'),
                      subtitle: const Text('Only sync when connected to Wi-Fi'),
                      trailing: Switch(
                        value: false, // TODO: Add Wi-Fi only preference
                        onChanged: (value) {
                          // TODO: Implement Wi-Fi only toggle
                        },
                        activeThumbColor: ThemeConfig.primaryDarkBlue,
                      ),
                    ),
                    
                    ListTile(
                      leading: const Icon(Icons.battery_saver, color: ThemeConfig.primaryDarkBlue),
                      title: const Text('Battery optimization'),
                      subtitle: const Text('Reduce sync frequency on low battery'),
                      trailing: Switch(
                        value: true, // TODO: Add battery optimization preference
                        onChanged: (value) {
                          // TODO: Implement battery optimization toggle
                        },
                        activeThumbColor: ThemeConfig.primaryDarkBlue,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Build advanced options section
  Widget _buildAdvancedOptions(BuildContext context, AppLocalizations? localizations) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations?.getString('advancedOptions') ?? 'Advanced Options',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ThemeConfig.darkTextElements,
              ),
            ),
            const SizedBox(height: 16),
            
            Consumer<SyncService>(
              builder: (context, syncService, child) {
                final stats = syncService.getSyncStatistics();
                
                return Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.storage, color: ThemeConfig.primaryDarkBlue),
                      title: const Text('Local storage usage'),
                      subtitle: Text('${stats['metadataCount']} metadata items'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showStorageDetails(context, stats),
                    ),
                    
                    ListTile(
                      leading: const Icon(Icons.queue, color: ThemeConfig.primaryDarkBlue),
                      title: const Text('Sync queue'),
                      subtitle: Text('${stats['queueLength']} items pending'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showQueueDetails(context, stats),
                    ),
                    
                    if (stats['conflictCount'] > 0)
                      ListTile(
                        leading: const Icon(Icons.warning, color: Colors.orange),
                        title: const Text('Resolve conflicts'),
                        subtitle: Text('${stats['conflictCount']} conflicts need attention'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showConflictResolution(context),
                      ),
                    
                    const Divider(),
                    
                    ListTile(
                      leading: const Icon(Icons.refresh, color: ThemeConfig.primaryDarkBlue),
                      title: const Text('Force full sync'),
                      subtitle: const Text('Re-sync all data from server'),
                      trailing: syncService.isSyncing 
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                      onTap: syncService.isSyncing 
                        ? null 
                        : () => _confirmFullSync(context, syncService),
                    ),
                    
                    ListTile(
                      leading: const Icon(Icons.clear_all, color: Colors.red),
                      title: const Text('Clear sync data'),
                      subtitle: const Text('Reset all sync metadata (advanced)'),
                      onTap: () => _confirmClearSyncData(context, syncService),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Build debug information section
  Widget _buildDebugInfo(BuildContext context) {
    return Consumer2<ConnectivityService, SyncService>(
      builder: (context, connectivityService, syncService, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Debug Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ThemeConfig.darkTextElements,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildDebugRow('Connectivity', connectivityService.isOnline ? 'Online' : 'Offline'),
                _buildDebugRow('Connection Type', connectivityService.connectionTypeDisplayName),
                _buildDebugRow('Connection Quality', connectivityService.connectionQualityDescription),
                _buildDebugRow('Sync Service', syncService.isInitialized ? 'Initialized' : 'Not initialized'),
                _buildDebugRow('Currently Syncing', syncService.isSyncing.toString()),
                _buildDebugRow('Last Sync', syncService.lastFullSync?.toString().substring(0, 19) ?? 'Never'),
                
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _exportDebugInfo(context, connectivityService, syncService),
                        child: const Text('Export Debug Info'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build debug information row
  Widget _buildDebugRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: ThemeConfig.primaryDarkBlue,
            ),
          ),
        ],
      ),
    );
  }

  /// Show storage details dialog
  void _showStorageDetails(BuildContext context, Map<String, dynamic> stats) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Local Storage Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Metadata items: ${stats['metadataCount']}'),
            Text('Queue items: ${stats['queueLength']}'),
            Text('Pending items: ${stats['pendingItems']}'),
            Text('Conflict items: ${stats['conflictCount']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Show sync queue details dialog
  void _showQueueDetails(BuildContext context, Map<String, dynamic> stats) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync Queue Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Items in queue: ${stats['queueLength']}'),
            Text('Total pending: ${stats['pendingItems']}'),
            Text('Sync progress: ${(stats['syncProgress'] * 100).toInt()}%'),
            if (stats['isSyncing'])
              Text('Currently syncing: ${stats['syncedItems']}/${stats['totalItemsToSync']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Show conflict resolution
  void _showConflictResolution(BuildContext context) {
    // TODO: Implement detailed conflict resolution UI
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Detailed conflict resolution UI coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Confirm full sync
  void _confirmFullSync(BuildContext context, SyncService syncService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Force Full Sync'),
        content: const Text('This will re-sync all your data from the server. This may take a few minutes and use mobile data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              syncService.performSync(force: true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Full sync started'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Sync'),
          ),
        ],
      ),
    );
  }

  /// Confirm clear sync data
  void _confirmClearSyncData(BuildContext context, SyncService syncService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Sync Data'),
        content: const Text('This will clear all sync metadata and force a complete re-sync next time you go online. Use this only if you\'re experiencing sync issues.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              syncService.clearSyncData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sync data cleared'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  /// Export debug information
  void _exportDebugInfo(
    BuildContext context,
    ConnectivityService connectivityService,
    SyncService syncService,
  ) {
    final connectivityStats = connectivityService.getConnectionStats();
    final syncStats = syncService.getSyncStatistics();
    
    final debugInfo = {
      'timestamp': DateTime.now().toIso8601String(),
      'connectivity': connectivityStats,
      'sync': syncStats,
    };
    
    // TODO: Implement actual export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Debug info: ${debugInfo.toString().substring(0, 50)}...'),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}