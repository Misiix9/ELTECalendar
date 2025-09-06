// File: lib/screens/export/export_history_screen.dart
// Purpose: Export history and management interface
// Step: 8.4 - Export History Implementation

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../config/localization_config.dart';
import '../../services/export_service.dart';
import '../../models/export_model.dart';
import '../../widgets/common_widgets/empty_state_widget.dart';

/// Export history screen showing past exports and management options
class ExportHistoryScreen extends StatefulWidget {
  const ExportHistoryScreen({super.key});

  @override
  State<ExportHistoryScreen> createState() => _ExportHistoryScreenState();
}

class _ExportHistoryScreenState extends State<ExportHistoryScreen> {
  String _selectedFilter = 'all';
  
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: _buildAppBar(context, localizations),
      body: Consumer<ExportService>(
        builder: (context, exportService, child) {
          return Column(
            children: [
              _buildFilterBar(context, exportService, localizations),
              Expanded(
                child: _buildHistoryList(context, exportService, localizations),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Build app bar
  AppBar _buildAppBar(BuildContext context, AppLocalizations? localizations) {
    return AppBar(
      title: Text(localizations?.getString('exportHistory') ?? 'Export History'),
      backgroundColor: ThemeConfig.lightBackground,
      foregroundColor: ThemeConfig.primaryDarkBlue,
      elevation: 0,
      actions: [
        Consumer<ExportService>(
          builder: (context, exportService, child) {
            final history = exportService.getExportHistory();
            return PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(value, exportService),
              itemBuilder: (context) => [
                if (history.isNotEmpty)
                  const PopupMenuItem(
                    value: 'clear',
                    child: Row(
                      children: [
                        Icon(Icons.clear_all, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Clear History', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(Icons.add, size: 16),
                      SizedBox(width: 8),
                      Text('New Export'),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  /// Build filter bar
  Widget _buildFilterBar(BuildContext context, ExportService exportService, AppLocalizations? localizations) {
    final history = exportService.getExportHistory();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: ThemeConfig.lightBackground,
      child: Column(
        children: [
          // Statistics row
          if (history.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: ThemeConfig.primaryDarkBlue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildHistoryStat(
                    'Total',
                    '${history.length}',
                    Icons.history,
                  ),
                  _buildHistoryStat(
                    'This Month',
                    '${_getThisMonthCount(history)}',
                    Icons.calendar_month,
                  ),
                  _buildHistoryStat(
                    'Successful',
                    '${history.where((h) => h.success).length}',
                    Icons.check_circle,
                  ),
                ],
              ),
            ),
          
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('all', 'All', Icons.list, history),
                const SizedBox(width: 8),
                _buildFilterChip('ics', 'ICS', Icons.calendar_today, history),
                const SizedBox(width: 8),
                _buildFilterChip('pdf', 'PDF', Icons.picture_as_pdf, history),
                const SizedBox(width: 8),
                _buildFilterChip('excel', 'Excel', Icons.table_chart, history),
                const SizedBox(width: 8),
                _buildFilterChip('failed', 'Failed', Icons.error, history),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build history statistic
  Widget _buildHistoryStat(String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: ThemeConfig.primaryDarkBlue,
        ),
        const SizedBox(width: 4),
        Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ThemeConfig.primaryDarkBlue,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: ThemeConfig.darkTextElements.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build filter chip
  Widget _buildFilterChip(String value, String label, IconData icon, List<ExportHistoryItem> history) {
    final isSelected = _selectedFilter == value;
    final count = _getFilterCount(value, history);
    
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, 
            color: isSelected ? Colors.white : ThemeConfig.primaryDarkBlue),
          const SizedBox(width: 4),
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.3) : ThemeConfig.goldAccent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      selectedColor: ThemeConfig.primaryDarkBlue,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : ThemeConfig.primaryDarkBlue,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  /// Build history list
  Widget _buildHistoryList(BuildContext context, ExportService exportService, AppLocalizations? localizations) {
    final allHistory = exportService.getExportHistory();
    final filteredHistory = _getFilteredHistory(allHistory);
    
    if (allHistory.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.history,
        title: localizations?.getString('noExportHistory') ?? 'No Export History',
        message: localizations?.getString('noExportHistoryMessage') ?? 
          'Your export history will appear here after you create your first export.',
        actionLabel: localizations?.getString('createExport') ?? 'Create Export',
        onActionPressed: () {
          Navigator.of(context).pushNamed('/export');
        },
      );
    }

    if (filteredHistory.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.filter_list_off,
        title: 'No Matching Exports',
        message: 'No exports match the selected filter criteria.',
        actionLabel: 'Clear Filter',
        onActionPressed: () {
          setState(() {
            _selectedFilter = 'all';
          });
        },
      );
    }

    // Group history by date
    final groupedHistory = _groupHistoryByDate(filteredHistory);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedHistory.length,
      itemBuilder: (context, index) {
        final group = groupedHistory[index];
        return _buildHistoryGroup(context, group);
      },
    );
  }

  /// Build history group (day section)
  Widget _buildHistoryGroup(BuildContext context, Map<String, dynamic> group) {
    final title = group['title'] as String;
    final items = group['items'] as List<ExportHistoryItem>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Group header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ThemeConfig.darkTextElements.withOpacity(0.8),
            ),
          ),
        ),
        
        // History items in group
        ...items.map((item) => _buildHistoryItem(context, item)).toList(),
        
        const SizedBox(height: 16),
      ],
    );
  }

  /// Build individual history item
  Widget _buildHistoryItem(BuildContext context, ExportHistoryItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Export type icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: item.success 
                  ? item.exportType.icon == Icons.calendar_today 
                    ? Colors.blue.withOpacity(0.1)
                    : item.exportType.icon == Icons.picture_as_pdf
                      ? Colors.red.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                item.success ? item.exportType.icon : Icons.error,
                color: item.success 
                  ? item.exportType.icon == Icons.calendar_today 
                    ? Colors.blue
                    : item.exportType.icon == Icons.picture_as_pdf
                      ? Colors.red
                      : Colors.green
                  : Colors.red,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // File name and status
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.fileName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: ThemeConfig.darkTextElements,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.success)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Success',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Failed',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // Export details
                  Row(
                    children: [
                      Text(
                        '${item.exportType.displayName} • ${item.itemCount} courses',
                        style: TextStyle(
                          fontSize: 13,
                          color: ThemeConfig.darkTextElements.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• ${item.fileSizeString}',
                        style: TextStyle(
                          fontSize: 13,
                          color: ThemeConfig.darkTextElements.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // Timestamp
                  Text(
                    item.relativeTime,
                    style: TextStyle(
                      fontSize: 12,
                      color: ThemeConfig.darkTextElements.withOpacity(0.5),
                    ),
                  ),
                  
                  // Error message if failed
                  if (!item.success && item.error != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Error: ${item.error}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            
            // Actions menu
            PopupMenuButton<String>(
              onSelected: (value) => _handleItemAction(value, item),
              itemBuilder: (context) => [
                if (item.success) ...[
                  const PopupMenuItem(
                    value: 'redownload',
                    child: Row(
                      children: [
                        Icon(Icons.file_download, size: 16),
                        SizedBox(width: 8),
                        Text('Download Again'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'share',
                    child: Row(
                      children: [
                        Icon(Icons.share, size: 16),
                        SizedBox(width: 8),
                        Text('Share'),
                      ],
                    ),
                  ),
                ],
                const PopupMenuItem(
                  value: 'retry',
                  child: Row(
                    children: [
                      Icon(Icons.refresh, size: 16),
                      SizedBox(width: 8),
                      Text('Export Again'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              child: Icon(
                Icons.more_vert,
                size: 18,
                color: ThemeConfig.darkTextElements.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get filtered history based on selected filter
  List<ExportHistoryItem> _getFilteredHistory(List<ExportHistoryItem> history) {
    switch (_selectedFilter) {
      case 'ics':
        return history.where((item) => item.exportType == ExportType.ics).toList();
      case 'pdf':
        return history.where((item) => item.exportType == ExportType.pdf).toList();
      case 'excel':
        return history.where((item) => item.exportType == ExportType.excel).toList();
      case 'failed':
        return history.where((item) => !item.success).toList();
      default:
        return history;
    }
  }

  /// Get count for filter
  int _getFilterCount(String filter, List<ExportHistoryItem> history) {
    switch (filter) {
      case 'ics':
        return history.where((item) => item.exportType == ExportType.ics).length;
      case 'pdf':
        return history.where((item) => item.exportType == ExportType.pdf).length;
      case 'excel':
        return history.where((item) => item.exportType == ExportType.excel).length;
      case 'failed':
        return history.where((item) => !item.success).length;
      default:
        return history.length;
    }
  }

  /// Get this month count
  int _getThisMonthCount(List<ExportHistoryItem> history) {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month);
    
    return history.where((item) {
      final itemMonth = DateTime(item.timestamp.year, item.timestamp.month);
      return itemMonth.isAtSameMomentAs(thisMonth);
    }).length;
  }

  /// Group history by date
  List<Map<String, dynamic>> _groupHistoryByDate(List<ExportHistoryItem> history) {
    final groups = <DateTime, List<ExportHistoryItem>>{};
    
    for (final item in history) {
      final date = DateTime(
        item.timestamp.year,
        item.timestamp.month,
        item.timestamp.day,
      );
      
      groups.putIfAbsent(date, () => []).add(item);
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    return groups.entries.map((entry) {
      String title;
      if (entry.key.isAtSameMomentAs(today)) {
        title = 'Today';
      } else if (entry.key.isAtSameMomentAs(yesterday)) {
        title = 'Yesterday';
      } else if (now.difference(entry.key).inDays < 7) {
        const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
        title = weekdays[entry.key.weekday - 1];
      } else {
        title = '${entry.key.day}/${entry.key.month}/${entry.key.year}';
      }

      // Sort items within group by timestamp (newest first)
      final sortedItems = entry.value
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return {
        'title': title,
        'items': sortedItems,
        'date': entry.key,
      };
    }).toList()
      ..sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
  }

  /// Handle menu actions
  void _handleMenuAction(String action, ExportService exportService) {
    switch (action) {
      case 'clear':
        _showClearHistoryConfirmation(exportService);
        break;
      case 'export':
        Navigator.of(context).pushNamed('/export');
        break;
    }
  }

  /// Handle item actions
  void _handleItemAction(String action, ExportHistoryItem item) {
    switch (action) {
      case 'redownload':
        // TODO: Implement re-download functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Download functionality coming soon!'),
            duration: Duration(seconds: 2),
          ),
        );
        break;
      case 'share':
        // TODO: Implement share functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Share functionality coming soon!'),
            duration: Duration(seconds: 2),
          ),
        );
        break;
      case 'retry':
        // TODO: Implement retry with same options
        Navigator.of(context).pushNamed('/export');
        break;
      case 'delete':
        // TODO: Implement history item deletion
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted export: ${item.fileName}'),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                // TODO: Implement undo functionality
              },
            ),
          ),
        );
        break;
    }
  }

  /// Show clear history confirmation dialog
  void _showClearHistoryConfirmation(ExportService exportService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Export History'),
        content: const Text('Are you sure you want to clear all export history? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              exportService.clearExportHistory();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Export history cleared'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}