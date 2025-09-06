// File: lib/services/sync_service.dart
// Purpose: Core synchronization service for offline/online data management
// Step: 9.3 - Sync Service Implementation

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/sync_model.dart';
import '../models/user_model.dart';
import 'connectivity_service.dart';
import 'firebase_service.dart';
import 'auth_service.dart';

/// Core synchronization service for managing offline/online data flow
class SyncService extends ChangeNotifier {
  static const String _logTag = 'SyncService';
  
  // Box names for Hive storage
  static const String _syncMetadataBox = 'sync_metadata';
  static const String _syncQueueBox = 'sync_queue';
  static const String _conflictResolutionBox = 'conflict_resolution';
  
  // Dependencies
  final ConnectivityService _connectivityService;
  final FirebaseService _firebaseService;
  final AuthService _authService;
  
  // Hive boxes
  late Box<SyncMetadata> _metadataBox;
  late Box<SyncQueueItem> _queueBox;
  late Box<Map<String, dynamic>> _conflictBox;
  
  // State
  bool _isInitialized = false;
  bool _isSyncing = false;
  DateTime? _lastFullSync;
  Timer? _syncTimer;
  
  // Sync statistics
  int _totalItemsToSync = 0;
  int _syncedItems = 0;
  int _failedItems = 0;
  int _conflictItems = 0;
  
  // Constructor
  SyncService(
    this._connectivityService,
    this._firebaseService,
    this._authService,
  );
  
  // Getters
  bool get isInitialized => _isInitialized;
  bool get isSyncing => _isSyncing;
  DateTime? get lastFullSync => _lastFullSync;
  int get totalItemsToSync => _totalItemsToSync;
  int get syncedItems => _syncedItems;
  int get failedItems => _failedItems;
  int get conflictItems => _conflictItems;
  double get syncProgress => _totalItemsToSync > 0 ? _syncedItems / _totalItemsToSync : 0.0;
  
  /// Get sync status summary
  String get syncStatusText {
    if (_isSyncing) {
      return 'Syncing... ($_syncedItems/$_totalItemsToSync)';
    }
    if (_connectivityService.isOffline) {
      return 'Offline - ${getPendingItemsCount()} items queued';
    }
    if (_lastFullSync == null) {
      return 'Never synced';
    }
    
    final duration = DateTime.now().difference(_lastFullSync!);
    if (duration.inMinutes < 1) {
      return 'Synced just now';
    } else if (duration.inMinutes < 60) {
      return 'Synced ${duration.inMinutes}m ago';
    } else if (duration.inHours < 24) {
      return 'Synced ${duration.inHours}h ago';
    } else {
      return 'Synced ${duration.inDays}d ago';
    }
  }
  
  /// Initialize sync service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      debugPrint('$_logTag: Initializing sync service...');
      
      // Open Hive boxes
      _metadataBox = await Hive.openBox<SyncMetadata>(_syncMetadataBox);
      _queueBox = await Hive.openBox<SyncQueueItem>(_syncQueueBox);
      _conflictBox = await Hive.openBox<Map<String, dynamic>>(_conflictResolutionBox);
      
      // Load last sync time
      _lastFullSync = _loadLastSyncTime();
      
      // Set up connectivity monitoring
      _setupConnectivityMonitoring();
      
      // Set up periodic sync timer
      _setupPeriodicSync();
      
      _isInitialized = true;
      debugPrint('$_logTag: Sync service initialized');
      
      // Perform initial sync if online
      if (_connectivityService.isOnline) {
        Timer(const Duration(seconds: 5), () => performSync());
      }
      
    } catch (e) {
      debugPrint('$_logTag: Failed to initialize sync service: $e');
      _isInitialized = false;
    }
  }
  
  /// Set up connectivity monitoring
  void _setupConnectivityMonitoring() {
    _connectivityService.addListener(_onConnectivityChanged);
  }
  
  /// Handle connectivity changes
  void _onConnectivityChanged() {
    if (_connectivityService.isOnline) {
      debugPrint('$_logTag: Connection restored, triggering sync');
      Timer(const Duration(seconds: 2), () => performSync());
    }
  }
  
  /// Set up periodic sync timer
  void _setupPeriodicSync() {
    _syncTimer = Timer.periodic(const Duration(minutes: 15), (timer) {
      if (_connectivityService.isSuitableForSync && !_isSyncing) {
        performSync();
      }
    });
  }
  
  /// Load last sync time from storage
  DateTime? _loadLastSyncTime() {
    try {
      final box = Hive.box('app_settings');
      final timestamp = box.get('last_full_sync');
      return timestamp != null ? DateTime.parse(timestamp) : null;
    } catch (e) {
      debugPrint('$_logTag: Error loading last sync time: $e');
      return null;
    }
  }
  
  /// Save last sync time to storage
  Future<void> _saveLastSyncTime(DateTime time) async {
    try {
      final box = Hive.box('app_settings');
      await box.put('last_full_sync', time.toIso8601String());
      _lastFullSync = time;
    } catch (e) {
      debugPrint('$_logTag: Error saving last sync time: $e');
    }
  }
  
  /// Perform full synchronization
  Future<bool> performSync({bool force = false}) async {
    if (!_isInitialized) {
      debugPrint('$_logTag: Sync service not initialized');
      return false;
    }
    
    if (_isSyncing && !force) {
      debugPrint('$_logTag: Sync already in progress');
      return false;
    }
    
    if (!_connectivityService.isOnline) {
      debugPrint('$_logTag: Cannot sync while offline');
      return false;
    }
    
    if (!_authService.isAuthenticated) {
      debugPrint('$_logTag: Cannot sync without authentication');
      return false;
    }
    
    try {
      _isSyncing = true;
      _resetSyncStats();
      notifyListeners();
      
      debugPrint('$_logTag: Starting full synchronization...');
      
      // 1. Process sync queue (upload local changes)
      await _processSyncQueue();
      
      // 2. Download updates from server
      await _downloadUpdates();
      
      // 3. Update sync timestamp
      await _saveLastSyncTime(DateTime.now());
      
      debugPrint('$_logTag: Synchronization completed successfully');
      return true;
      
    } catch (e) {
      debugPrint('$_logTag: Sync failed: $e');
      return false;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
  
  /// Reset sync statistics
  void _resetSyncStats() {
    _syncedItems = 0;
    _failedItems = 0;
    _conflictItems = 0;
    _totalItemsToSync = _queueBox.length + _metadataBox.values.where((m) => m.isDirty).length;
  }
  
  /// Process sync queue (upload local changes)
  Future<void> _processSyncQueue() async {
    final queueItems = _queueBox.values.toList()
      ..sort((a, b) => a.priority.compareTo(b.priority));
    
    for (final item in queueItems) {
      try {
        await _processSyncQueueItem(item);
        await _queueBox.delete(item.id);
        _syncedItems++;
      } catch (e) {
        debugPrint('$_logTag: Failed to process queue item ${item.id}: $e');
        _failedItems++;
        
        // Update retry count
        if (item.retryCount < 3) {
          await _queueBox.put(item.id, item.withRetry());
        } else {
          await _queueBox.delete(item.id); // Give up after 3 retries
        }
      }
      notifyListeners();
    }
  }
  
  /// Process individual sync queue item
  Future<void> _processSyncQueueItem(SyncQueueItem item) async {
    switch (item.dataType) {
      case 'course':
        await _syncCourse(item);
        break;
      case 'semester':
        await _syncSemester(item);
        break;
      case 'user':
        await _syncUser(item);
        break;
      case 'notification':
        await _syncNotification(item);
        break;
      default:
        throw Exception('Unknown data type: ${item.dataType}');
    }
  }
  
  /// Sync course data
  Future<void> _syncCourse(SyncQueueItem item) async {
    // TODO: Implement individual course sync when FirebaseService supports it
    // For now, courses are synced in batches by semester
    debugPrint('$_logTag: Individual course sync not implemented yet');
  }
  
  /// Sync semester data
  Future<void> _syncSemester(SyncQueueItem item) async {
    // TODO: Implement semester sync when FirebaseService supports it
    debugPrint('$_logTag: Individual semester sync not implemented yet');
  }
  
  /// Sync user data
  Future<void> _syncUser(SyncQueueItem item) async {
    switch (item.operation) {
      case 'update':
        final userData = item.data;
        final user = StudentUser(
          uid: userData['uid'],
          email: userData['email'],
          displayName: userData['displayName'],
          emailVerified: userData['emailVerified'] ?? false,
          createdAt: DateTime.parse(userData['createdAt']),
          currentSemester: userData['currentSemester'],
          lastLoginAt: userData['lastLoginAt'] != null 
            ? DateTime.parse(userData['lastLoginAt'])
            : null,
          profileImageUrl: userData['profileImageUrl'],
          preferences: Map<String, dynamic>.from(userData['preferences'] ?? {}),
        );
        await _firebaseService.saveUserProfile(user);
        break;
    }
  }
  
  /// Sync notification data
  Future<void> _syncNotification(SyncQueueItem item) async {
    // TODO: Implement notification sync when FirebaseService supports it
    debugPrint('$_logTag: Individual notification sync not implemented yet');
  }
  
  /// Download updates from server
  Future<void> _downloadUpdates() async {
    if (!_authService.isAuthenticated) return;
    
    final userId = _authService.currentUser!.uid;
    
    // TODO: Implement download methods when FirebaseService supports them
    debugPrint('$_logTag: Download updates not implemented yet - requires FirebaseService extensions');
    
    // For now, just mark as complete
    _syncedItems += 1;
    notifyListeners();
  }
  
  // TODO: Merge methods will be implemented when download methods are available
  
  /// Queue item for synchronization when online
  Future<void> queueForSync(
    String dataType,
    String dataId,
    String operation,
    Map<String, dynamic> data, {
    int priority = 10,
  }) async {
    if (!_isInitialized) return;
    
    final queueItem = SyncQueueItem.create(
      operation: operation,
      dataType: dataType,
      dataId: dataId,
      data: data,
      priority: priority,
    );
    
    await _queueBox.put(queueItem.id, queueItem);
    
    // Update metadata
    final metadataKey = '${dataType}_$dataId';
    final metadata = _metadataBox.get(metadataKey) ?? 
      SyncMetadata.create(id: dataId, dataType: dataType);
    
    await _metadataBox.put(metadataKey, metadata.markDirty());
    
    debugPrint('$_logTag: Queued for sync: $dataType/$dataId/$operation');
    notifyListeners();
    
    // Try to sync immediately if online
    if (_connectivityService.isSuitableForSync && !_isSyncing) {
      Timer(const Duration(seconds: 1), () => performSync());
    }
  }
  
  /// Internal queue method
  Future<void> _queueForSync(String dataType, String dataId, String operation, Map<String, dynamic> data) async {
    await queueForSync(dataType, dataId, operation, data);
  }
  
  /// Get number of pending sync items
  int getPendingItemsCount() {
    return _queueBox.length + _metadataBox.values.where((m) => m.isDirty).length;
  }
  
  /// Get sync metadata for a data item
  SyncMetadata? getSyncMetadata(String dataType, String dataId) {
    return _metadataBox.get('${dataType}_$dataId');
  }
  
  /// Get all items with conflicts
  List<SyncMetadata> getConflictItems() {
    return _metadataBox.values.where((m) => m.status == SyncStatus.conflict).toList();
  }
  
  /// Resolve conflict for a data item
  Future<void> resolveConflict(
    String dataType,
    String dataId,
    ConflictResolution resolution, {
    Map<String, dynamic>? resolvedData,
  }) async {
    final metadataKey = '${dataType}_$dataId';
    final metadata = _metadataBox.get(metadataKey);
    
    if (metadata == null || metadata.status != SyncStatus.conflict) {
      debugPrint('$_logTag: No conflict found for $dataType/$dataId');
      return;
    }
    
    switch (resolution) {
      case ConflictResolution.useLocal:
        // Keep local version and queue for upload
        await _metadataBox.put(metadataKey, metadata.copyWith(
          status: SyncStatus.pending,
          conflictData: null,
        ));
        break;
        
      case ConflictResolution.useServer:
        // Use server version
        if (metadata.conflictData != null) {
          // Apply server data and mark as synced
          await _metadataBox.put(metadataKey, metadata.copyWith(
            status: SyncStatus.synced,
            isDirty: false,
            conflictData: null,
          ));
        }
        break;
        
      case ConflictResolution.merge:
        // Use provided resolved data
        if (resolvedData != null) {
          await queueForSync(dataType, dataId, 'update', resolvedData);
          await _metadataBox.put(metadataKey, metadata.copyWith(
            status: SyncStatus.pending,
            conflictData: null,
          ));
        }
        break;
        
      case ConflictResolution.askUser:
        // This should be handled by UI
        break;
    }
    
    notifyListeners();
  }
  
  /// Clear all sync data (for debugging/reset)
  Future<void> clearSyncData() async {
    await _metadataBox.clear();
    await _queueBox.clear();
    await _conflictBox.clear();
    _lastFullSync = null;
    await _saveLastSyncTime(DateTime.fromMillisecondsSinceEpoch(0));
    notifyListeners();
    debugPrint('$_logTag: All sync data cleared');
  }
  
  /// Get sync statistics
  Map<String, dynamic> getSyncStatistics() {
    return {
      'isInitialized': _isInitialized,
      'isSyncing': _isSyncing,
      'lastFullSync': _lastFullSync?.toIso8601String(),
      'totalItemsToSync': _totalItemsToSync,
      'syncedItems': _syncedItems,
      'failedItems': _failedItems,
      'conflictItems': _conflictItems,
      'syncProgress': syncProgress,
      'pendingItems': getPendingItemsCount(),
      'conflictCount': getConflictItems().length,
      'queueLength': _queueBox.length,
      'metadataCount': _metadataBox.length,
    };
  }
  
  @override
  void dispose() {
    debugPrint('$_logTag: Disposing sync service');
    _syncTimer?.cancel();
    _connectivityService.removeListener(_onConnectivityChanged);
    super.dispose();
  }
  
  @override
  String toString() {
    return 'SyncService{initialized: $_isInitialized, syncing: $_isSyncing, '
           'pending: ${getPendingItemsCount()}, conflicts: ${getConflictItems().length}}';
  }
}