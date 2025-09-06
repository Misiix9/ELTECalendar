// File: lib/models/sync_model.dart
// Purpose: Synchronization models for offline support and data sync management
// Step: 9.1 - Sync Model Implementation

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

part 'sync_model.g.dart';

/// Synchronization status for data items
@HiveType(typeId: 10)
enum SyncStatus {
  @HiveField(0)
  synced, // Data is synchronized with server
  
  @HiveField(1)
  pending, // Needs to be synchronized
  
  @HiveField(2)
  conflict, // Conflict detected, needs resolution
  
  @HiveField(3)
  error, // Sync failed, needs retry
  
  @HiveField(4)
  local, // Local-only data, no sync needed
}

/// Extension methods for SyncStatus
extension SyncStatusExtension on SyncStatus {
  /// Get display name for sync status
  String get displayName {
    switch (this) {
      case SyncStatus.synced:
        return 'Synced';
      case SyncStatus.pending:
        return 'Pending';
      case SyncStatus.conflict:
        return 'Conflict';
      case SyncStatus.error:
        return 'Error';
      case SyncStatus.local:
        return 'Local';
    }
  }
  
  /// Get description for sync status
  String get description {
    switch (this) {
      case SyncStatus.synced:
        return 'Data is up to date with server';
      case SyncStatus.pending:
        return 'Waiting to sync with server';
      case SyncStatus.conflict:
        return 'Conflict detected, needs resolution';
      case SyncStatus.error:
        return 'Sync failed, will retry';
      case SyncStatus.local:
        return 'Local data only';
    }
  }
  
  /// Check if status requires attention
  bool get needsAttention {
    return this == SyncStatus.conflict || this == SyncStatus.error;
  }
  
  /// Check if sync is in progress or pending
  bool get isActive {
    return this == SyncStatus.pending;
  }
}

/// Synchronization metadata for tracking data sync state
@HiveType(typeId: 11)
class SyncMetadata {
  @HiveField(0)
  final String id; // Unique identifier for the data item
  
  @HiveField(1)
  final String dataType; // Type of data (course, semester, user, etc.)
  
  @HiveField(2)
  final SyncStatus status;
  
  @HiveField(3)
  final DateTime lastModified; // When the data was last modified locally
  
  @HiveField(4)
  final DateTime? lastSyncAttempt; // When sync was last attempted
  
  @HiveField(5)
  final DateTime? lastSuccessfulSync; // When sync last succeeded
  
  @HiveField(6)
  final String? serverVersion; // Server version identifier (timestamp or version number)
  
  @HiveField(7)
  final int retryCount; // Number of sync retry attempts
  
  @HiveField(8)
  final String? errorMessage; // Last error message if sync failed
  
  @HiveField(9)
  final Map<String, dynamic>? conflictData; // Data from server for conflict resolution
  
  @HiveField(10)
  final bool isDirty; // Whether local data differs from last sync

  const SyncMetadata({
    required this.id,
    required this.dataType,
    this.status = SyncStatus.pending,
    required this.lastModified,
    this.lastSyncAttempt,
    this.lastSuccessfulSync,
    this.serverVersion,
    this.retryCount = 0,
    this.errorMessage,
    this.conflictData,
    this.isDirty = true,
  });

  /// Create initial sync metadata for new data
  factory SyncMetadata.create({
    required String id,
    required String dataType,
    DateTime? timestamp,
  }) {
    return SyncMetadata(
      id: id,
      dataType: dataType,
      lastModified: timestamp ?? DateTime.now(),
      status: SyncStatus.pending,
      isDirty: true,
    );
  }

  /// Create metadata for local-only data
  factory SyncMetadata.localOnly({
    required String id,
    required String dataType,
    DateTime? timestamp,
  }) {
    return SyncMetadata(
      id: id,
      dataType: dataType,
      lastModified: timestamp ?? DateTime.now(),
      status: SyncStatus.local,
      isDirty: false,
    );
  }

  /// Create metadata for synced data
  factory SyncMetadata.synced({
    required String id,
    required String dataType,
    required String serverVersion,
    DateTime? timestamp,
  }) {
    final now = DateTime.now();
    return SyncMetadata(
      id: id,
      dataType: dataType,
      lastModified: timestamp ?? now,
      lastSyncAttempt: now,
      lastSuccessfulSync: now,
      serverVersion: serverVersion,
      status: SyncStatus.synced,
      isDirty: false,
    );
  }

  /// Create copy with updated values
  SyncMetadata copyWith({
    String? id,
    String? dataType,
    SyncStatus? status,
    DateTime? lastModified,
    DateTime? lastSyncAttempt,
    DateTime? lastSuccessfulSync,
    String? serverVersion,
    int? retryCount,
    String? errorMessage,
    Map<String, dynamic>? conflictData,
    bool? isDirty,
  }) {
    return SyncMetadata(
      id: id ?? this.id,
      dataType: dataType ?? this.dataType,
      status: status ?? this.status,
      lastModified: lastModified ?? this.lastModified,
      lastSyncAttempt: lastSyncAttempt ?? this.lastSyncAttempt,
      lastSuccessfulSync: lastSuccessfulSync ?? this.lastSuccessfulSync,
      serverVersion: serverVersion ?? this.serverVersion,
      retryCount: retryCount ?? this.retryCount,
      errorMessage: errorMessage ?? this.errorMessage,
      conflictData: conflictData ?? this.conflictData,
      isDirty: isDirty ?? this.isDirty,
    );
  }

  /// Mark as modified (dirty)
  SyncMetadata markDirty([DateTime? timestamp]) {
    return copyWith(
      lastModified: timestamp ?? DateTime.now(),
      status: SyncStatus.pending,
      isDirty: true,
      errorMessage: null, // Clear previous errors
    );
  }

  /// Mark sync as successful
  SyncMetadata markSynced(String serverVersion, [DateTime? timestamp]) {
    final now = timestamp ?? DateTime.now();
    return copyWith(
      status: SyncStatus.synced,
      lastSyncAttempt: now,
      lastSuccessfulSync: now,
      serverVersion: serverVersion,
      isDirty: false,
      retryCount: 0,
      errorMessage: null,
      conflictData: null,
    );
  }

  /// Mark sync as failed
  SyncMetadata markSyncError(String error, [DateTime? timestamp]) {
    return copyWith(
      status: SyncStatus.error,
      lastSyncAttempt: timestamp ?? DateTime.now(),
      retryCount: retryCount + 1,
      errorMessage: error,
    );
  }

  /// Mark as having conflict
  SyncMetadata markConflict(Map<String, dynamic> serverData, [DateTime? timestamp]) {
    return copyWith(
      status: SyncStatus.conflict,
      lastSyncAttempt: timestamp ?? DateTime.now(),
      conflictData: serverData,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dataType': dataType,
      'status': status.name,
      'lastModified': lastModified.toIso8601String(),
      'lastSyncAttempt': lastSyncAttempt?.toIso8601String(),
      'lastSuccessfulSync': lastSuccessfulSync?.toIso8601String(),
      'serverVersion': serverVersion,
      'retryCount': retryCount,
      'errorMessage': errorMessage,
      'conflictData': conflictData,
      'isDirty': isDirty,
    };
  }

  /// Create from JSON
  factory SyncMetadata.fromJson(Map<String, dynamic> json) {
    return SyncMetadata(
      id: json['id'] ?? '',
      dataType: json['dataType'] ?? '',
      status: SyncStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => SyncStatus.pending,
      ),
      lastModified: DateTime.parse(json['lastModified']),
      lastSyncAttempt: json['lastSyncAttempt'] != null 
        ? DateTime.parse(json['lastSyncAttempt'])
        : null,
      lastSuccessfulSync: json['lastSuccessfulSync'] != null 
        ? DateTime.parse(json['lastSuccessfulSync'])
        : null,
      serverVersion: json['serverVersion'],
      retryCount: json['retryCount'] ?? 0,
      errorMessage: json['errorMessage'],
      conflictData: json['conflictData'] as Map<String, dynamic>?,
      isDirty: json['isDirty'] ?? true,
    );
  }

  /// Get formatted last modified time
  String get formattedLastModified {
    return '${lastModified.day}/${lastModified.month}/${lastModified.year} '
           '${lastModified.hour.toString().padLeft(2, '0')}:'
           '${lastModified.minute.toString().padLeft(2, '0')}';
  }

  /// Get formatted last sync time
  String? get formattedLastSync {
    if (lastSuccessfulSync == null) return null;
    final sync = lastSuccessfulSync!;
    return '${sync.day}/${sync.month}/${sync.year} '
           '${sync.hour.toString().padLeft(2, '0')}:'
           '${sync.minute.toString().padLeft(2, '0')}';
  }

  /// Check if data is stale (hasn't been synced for a while)
  bool get isStale {
    if (lastSuccessfulSync == null) return true;
    final now = DateTime.now();
    final difference = now.difference(lastSuccessfulSync!);
    return difference.inHours > 24; // Consider stale after 24 hours
  }

  /// Check if sync should be retried
  bool get shouldRetry {
    if (status != SyncStatus.error) return false;
    if (retryCount >= 5) return false; // Max 5 retries
    
    // Exponential backoff: wait longer between retries
    if (lastSyncAttempt == null) return true;
    final now = DateTime.now();
    final waitTime = Duration(minutes: (retryCount * retryCount) * 5); // 5, 20, 45, 80, 125 minutes
    return now.difference(lastSyncAttempt!) >= waitTime;
  }

  @override
  String toString() {
    return 'SyncMetadata{id: $id, type: $dataType, status: ${status.name}, '
           'dirty: $isDirty, lastSync: $formattedLastSync}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SyncMetadata &&
           other.id == id &&
           other.dataType == dataType;
  }

  @override
  int get hashCode => id.hashCode ^ dataType.hashCode;
}

/// Queue item for operations that need to be synced when online
@HiveType(typeId: 12)
class SyncQueueItem {
  @HiveField(0)
  final String id; // Unique identifier for the queue item
  
  @HiveField(1)
  final String operation; // Type of operation (create, update, delete)
  
  @HiveField(2)
  final String dataType; // Type of data being synchronized
  
  @HiveField(3)
  final String dataId; // ID of the data item
  
  @HiveField(4)
  final Map<String, dynamic> data; // The data to sync
  
  @HiveField(5)
  final DateTime createdAt; // When the queue item was created
  
  @HiveField(6)
  final int priority; // Sync priority (0 = highest)
  
  @HiveField(7)
  final int retryCount; // Number of retry attempts
  
  @HiveField(8)
  final DateTime? lastAttempt; // Last sync attempt time

  const SyncQueueItem({
    required this.id,
    required this.operation,
    required this.dataType,
    required this.dataId,
    required this.data,
    required this.createdAt,
    this.priority = 10,
    this.retryCount = 0,
    this.lastAttempt,
  });

  /// Create new queue item
  factory SyncQueueItem.create({
    required String operation,
    required String dataType,
    required String dataId,
    required Map<String, dynamic> data,
    int priority = 10,
  }) {
    return SyncQueueItem(
      id: '${dataType}_${dataId}_${operation}_${DateTime.now().millisecondsSinceEpoch}',
      operation: operation,
      dataType: dataType,
      dataId: dataId,
      data: data,
      createdAt: DateTime.now(),
      priority: priority,
    );
  }

  /// Copy with updated retry information
  SyncQueueItem withRetry() {
    return SyncQueueItem(
      id: id,
      operation: operation,
      dataType: dataType,
      dataId: dataId,
      data: data,
      createdAt: createdAt,
      priority: priority,
      retryCount: retryCount + 1,
      lastAttempt: DateTime.now(),
    );
  }

  /// Check if item should be retried
  bool get shouldRetry {
    if (retryCount >= 3) return false; // Max 3 retries
    if (lastAttempt == null) return true;
    
    final now = DateTime.now();
    final waitTime = Duration(minutes: retryCount * 5); // 5, 10, 15 minutes
    return now.difference(lastAttempt!) >= waitTime;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'operation': operation,
      'dataType': dataType,
      'dataId': dataId,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'priority': priority,
      'retryCount': retryCount,
      'lastAttempt': lastAttempt?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory SyncQueueItem.fromJson(Map<String, dynamic> json) {
    return SyncQueueItem(
      id: json['id'],
      operation: json['operation'],
      dataType: json['dataType'],
      dataId: json['dataId'],
      data: Map<String, dynamic>.from(json['data']),
      createdAt: DateTime.parse(json['createdAt']),
      priority: json['priority'] ?? 10,
      retryCount: json['retryCount'] ?? 0,
      lastAttempt: json['lastAttempt'] != null 
        ? DateTime.parse(json['lastAttempt'])
        : null,
    );
  }

  @override
  String toString() {
    return 'SyncQueueItem{id: $id, operation: $operation, dataType: $dataType, retries: $retryCount}';
  }
}

/// Conflict resolution strategies
enum ConflictResolution {
  useLocal, // Keep local version
  useServer, // Use server version
  merge, // Merge both versions
  askUser, // Let user decide
}

/// Conflict resolution result
class ConflictResolutionResult {
  final ConflictResolution resolution;
  final Map<String, dynamic>? resolvedData;
  final String? userComment;

  const ConflictResolutionResult({
    required this.resolution,
    this.resolvedData,
    this.userComment,
  });
}