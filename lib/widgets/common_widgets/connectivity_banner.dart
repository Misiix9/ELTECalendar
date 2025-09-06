// File: lib/widgets/common_widgets/connectivity_banner.dart
// Purpose: UI component showing connectivity and sync status to users
// Step: 9.4 - Offline Mode UI Indicators

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../services/connectivity_service.dart';
import '../../services/sync_service.dart';

/// Banner widget that shows connectivity and sync status
class ConnectivityBanner extends StatelessWidget {
  final bool showWhenOnline;
  final bool showSyncStatus;
  
  const ConnectivityBanner({
    super.key,
    this.showWhenOnline = false,
    this.showSyncStatus = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<ConnectivityService, SyncService>(
      builder: (context, connectivityService, syncService, child) {
        // Don't show banner if online and showWhenOnline is false
        if (connectivityService.isOnline && !showWhenOnline && !syncService.isSyncing) {
          return const SizedBox.shrink();
        }
        
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildBanner(context, connectivityService, syncService),
        );
      },
    );
  }
  
  Widget _buildBanner(
    BuildContext context,
    ConnectivityService connectivityService, 
    SyncService syncService,
  ) {
    // Determine banner type and content
    if (!connectivityService.isOnline) {
      return _buildOfflineBanner(context, connectivityService, syncService);
    } else if (syncService.isSyncing) {
      return _buildSyncingBanner(context, syncService);
    } else if (showWhenOnline && syncService.conflictItems > 0) {
      return _buildConflictBanner(context, syncService);
    } else if (showWhenOnline) {
      return _buildOnlineBanner(context, connectivityService, syncService);
    }
    
    return const SizedBox.shrink();
  }
  
  /// Build offline status banner
  Widget _buildOfflineBanner(
    BuildContext context,
    ConnectivityService connectivityService,
    SyncService syncService,
  ) {
    final pendingItems = syncService.getPendingItemsCount();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        border: Border(
          bottom: BorderSide(color: Colors.orange.shade300),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.cloud_off,
            color: Colors.orange.shade700,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Working Offline',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade800,
                    fontSize: 14,
                  ),
                ),
                if (pendingItems > 0)
                  Text(
                    '$pendingItems items will sync when online',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade700,
                    ),
                  ),
              ],
            ),
          ),
          if (connectivityService.offlineDuration != null)
            Text(
              connectivityService.offlineDuration!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange.shade600,
              ),
            ),
        ],
      ),
    );
  }
  
  /// Build syncing status banner
  Widget _buildSyncingBanner(BuildContext context, SyncService syncService) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: ThemeConfig.primaryDarkBlue.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: ThemeConfig.primaryDarkBlue.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: ThemeConfig.primaryDarkBlue,
              value: syncService.syncProgress > 0 ? syncService.syncProgress : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Syncing...',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: ThemeConfig.primaryDarkBlue,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${syncService.syncedItems}/${syncService.totalItemsToSync} items',
                  style: TextStyle(
                    fontSize: 12,
                    color: ThemeConfig.primaryDarkBlue.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${(syncService.syncProgress * 100).toInt()}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: ThemeConfig.primaryDarkBlue,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build conflict status banner
  Widget _buildConflictBanner(BuildContext context, SyncService syncService) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        border: Border(
          bottom: BorderSide(color: Colors.red.shade300),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning,
            color: Colors.red.shade700,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sync Conflicts Detected',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade800,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${syncService.conflictItems} items need resolution',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _showConflictResolution(context),
            child: Text(
              'Resolve',
              style: TextStyle(color: Colors.red.shade800),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build online status banner (only shown when showWhenOnline is true)
  Widget _buildOnlineBanner(
    BuildContext context,
    ConnectivityService connectivityService,
    SyncService syncService,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        border: Border(
          bottom: BorderSide(color: Colors.green.shade300),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.cloud_done,
            color: Colors.green.shade700,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Online • ${syncService.syncStatusText}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.green.shade800,
              ),
            ),
          ),
          Text(
            connectivityService.connectionTypeDisplayName,
            style: TextStyle(
              fontSize: 12,
              color: Colors.green.shade600,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Show conflict resolution dialog
  void _showConflictResolution(BuildContext context) {
    // TODO: Implement conflict resolution UI
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Conflict resolution UI coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

/// Compact connectivity indicator for app bars
class ConnectivityIndicator extends StatelessWidget {
  const ConnectivityIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ConnectivityService, SyncService>(
      builder: (context, connectivityService, syncService, child) {
        if (connectivityService.isOnline && !syncService.isSyncing) {
          return const SizedBox.shrink();
        }
        
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _buildIndicator(connectivityService, syncService),
        );
      },
    );
  }
  
  Widget _buildIndicator(ConnectivityService connectivityService, SyncService syncService) {
    if (syncService.isSyncing) {
      return SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
          value: syncService.syncProgress > 0 ? syncService.syncProgress : null,
        ),
      );
    } else if (!connectivityService.isOnline) {
      return const Icon(
        Icons.cloud_off,
        size: 20,
        color: Colors.white,
      );
    } else if (syncService.conflictItems > 0) {
      return const Icon(
        Icons.warning,
        size: 20,
        color: Colors.orange,
      );
    }
    
    return const SizedBox.shrink();
  }
}

/// Status card showing detailed connectivity and sync information
class ConnectivityStatusCard extends StatelessWidget {
  const ConnectivityStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ConnectivityService, SyncService>(
      builder: (context, connectivityService, syncService, child) {
        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(connectivityService, syncService),
                const SizedBox(height: 16),
                _buildStats(connectivityService, syncService),
                if (syncService.getPendingItemsCount() > 0 || syncService.conflictItems > 0) ...[
                  const SizedBox(height: 16),
                  _buildActions(context, syncService),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildHeader(ConnectivityService connectivityService, SyncService syncService) {
    final isOnline = connectivityService.isOnline;
    final color = isOnline ? Colors.green : Colors.orange;
    
    return Row(
      children: [
        Icon(
          isOnline ? Icons.cloud_done : Icons.cloud_off,
          color: color,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isOnline ? 'Online' : 'Offline',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                isOnline 
                  ? connectivityService.connectionTypeDisplayName
                  : connectivityService.offlineDuration ?? 'Just disconnected',
                style: TextStyle(
                  fontSize: 14,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
        if (syncService.isSyncing)
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: ThemeConfig.primaryDarkBlue,
              value: syncService.syncProgress > 0 ? syncService.syncProgress : null,
            ),
          ),
      ],
    );
  }
  
  Widget _buildStats(ConnectivityService connectivityService, SyncService syncService) {
    return Column(
      children: [
        _buildStatRow('Connection Quality', connectivityService.connectionQualityDescription),
        _buildStatRow('Last Sync', syncService.lastFullSync?.toString().substring(0, 16) ?? 'Never'),
        _buildStatRow('Pending Items', syncService.getPendingItemsCount().toString()),
        if (syncService.conflictItems > 0)
          _buildStatRow('Conflicts', syncService.conflictItems.toString(), Colors.red),
        if (syncService.isSyncing)
          _buildStatRow('Sync Progress', '${(syncService.syncProgress * 100).toInt()}%'),
      ],
    );
  }
  
  Widget _buildStatRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: valueColor ?? ThemeConfig.darkTextElements,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActions(BuildContext context, SyncService syncService) {
    return Row(
      children: [
        if (syncService.getPendingItemsCount() > 0)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: syncService.isSyncing ? null : () => syncService.performSync(force: true),
              icon: const Icon(Icons.sync),
              label: const Text('Sync Now'),
            ),
          ),
        if (syncService.getPendingItemsCount() > 0 && syncService.conflictItems > 0)
          const SizedBox(width: 8),
        if (syncService.conflictItems > 0)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showConflictResolution(context),
              icon: const Icon(Icons.warning),
              label: const Text('Resolve Conflicts'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
  
  void _showConflictResolution(BuildContext context) {
    // TODO: Implement conflict resolution UI
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Conflict resolution UI coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}