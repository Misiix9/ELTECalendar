// File: lib/services/connectivity_service.dart
// Purpose: Network connectivity monitoring for offline support
// Step: 9.2 - Connectivity Service Implementation

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Network connectivity service for monitoring online/offline status
class ConnectivityService extends ChangeNotifier {
  static const String _logTag = 'ConnectivityService';
  
  // Private members
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  
  // State
  bool _isOnline = true;
  ConnectivityResult _connectionType = ConnectivityResult.wifi;
  DateTime _lastConnectedTime = DateTime.now();
  DateTime? _lastDisconnectedTime;
  
  // Connection quality metrics
  int _connectionQuality = 100; // 0-100 percentage
  bool _isSlowConnection = false;
  
  // Getters
  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;
  ConnectivityResult get connectionType => _connectionType;
  DateTime get lastConnectedTime => _lastConnectedTime;
  DateTime? get lastDisconnectedTime => _lastDisconnectedTime;
  int get connectionQuality => _connectionQuality;
  bool get isSlowConnection => _isSlowConnection;
  
  /// Get connection type display name
  String get connectionTypeDisplayName {
    switch (_connectionType) {
      case ConnectivityResult.wifi:
        return 'Wi-Fi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.other:
        return 'Other';
      case ConnectivityResult.none:
        return 'No Connection';
    }
  }
  
  /// Get connection quality description
  String get connectionQualityDescription {
    if (!_isOnline) return 'Offline';
    if (_connectionQuality >= 80) return 'Excellent';
    if (_connectionQuality >= 60) return 'Good';
    if (_connectionQuality >= 40) return 'Fair';
    if (_connectionQuality >= 20) return 'Poor';
    return 'Very Poor';
  }
  
  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    try {
      debugPrint('$_logTag: Initializing connectivity service...');
      
      // Get initial connectivity state
      final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
      _updateConnectionState(results);
      
      // Listen for connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _updateConnectionState,
        onError: (error) {
          debugPrint('$_logTag: Connectivity stream error: $error');
        },
      );
      
      debugPrint('$_logTag: Connectivity service initialized. Status: ${_isOnline ? 'Online' : 'Offline'}');
    } catch (e) {
      debugPrint('$_logTag: Failed to initialize connectivity service: $e');
      // Assume online if initialization fails
      _isOnline = true;
    }
  }
  
  /// Update connection state based on connectivity results
  void _updateConnectionState(List<ConnectivityResult> results) {
    final bool wasOnline = _isOnline;
    
    // Determine if we're online based on connectivity results
    _isOnline = results.isNotEmpty && !results.contains(ConnectivityResult.none);
    
    // Get the primary connection type
    if (results.isNotEmpty) {
      _connectionType = results.first;
    } else {
      _connectionType = ConnectivityResult.none;
    }
    
    // Update timestamps
    final now = DateTime.now();
    if (_isOnline && !wasOnline) {
      // Just came back online
      _lastConnectedTime = now;
      debugPrint('$_logTag: Connection restored - ${connectionTypeDisplayName}');
    } else if (!_isOnline && wasOnline) {
      // Just went offline
      _lastDisconnectedTime = now;
      debugPrint('$_logTag: Connection lost');
    }
    
    // Update connection quality based on type
    _updateConnectionQuality();
    
    // Only notify if state actually changed
    if (wasOnline != _isOnline) {
      notifyListeners();
    }
  }
  
  /// Update connection quality metrics based on connection type
  void _updateConnectionQuality() {
    if (!_isOnline) {
      _connectionQuality = 0;
      _isSlowConnection = true;
      return;
    }
    
    // Estimate quality based on connection type
    switch (_connectionType) {
      case ConnectivityResult.wifi:
        _connectionQuality = 90;
        _isSlowConnection = false;
        break;
      case ConnectivityResult.ethernet:
        _connectionQuality = 100;
        _isSlowConnection = false;
        break;
      case ConnectivityResult.mobile:
        _connectionQuality = 70;
        _isSlowConnection = false;
        break;
      case ConnectivityResult.vpn:
        _connectionQuality = 60;
        _isSlowConnection = true;
        break;
      case ConnectivityResult.bluetooth:
        _connectionQuality = 30;
        _isSlowConnection = true;
        break;
      case ConnectivityResult.other:
        _connectionQuality = 50;
        _isSlowConnection = false;
        break;
      case ConnectivityResult.none:
        _connectionQuality = 0;
        _isSlowConnection = true;
        break;
    }
  }
  
  /// Check if connection is suitable for large operations (like sync)
  bool get isSuitableForSync {
    return _isOnline && _connectionQuality >= 40;
  }
  
  /// Check if connection is suitable for heavy uploads/downloads
  bool get isSuitableForHeavyOperations {
    return _isOnline && _connectionQuality >= 70;
  }
  
  /// Get offline duration in a human-readable format
  String? get offlineDuration {
    if (_isOnline || _lastDisconnectedTime == null) return null;
    
    final now = DateTime.now();
    final duration = now.difference(_lastDisconnectedTime!);
    
    if (duration.inMinutes < 1) {
      return 'Just now';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m ago';
    } else if (duration.inHours < 24) {
      return '${duration.inHours}h ago';
    } else {
      return '${duration.inDays}d ago';
    }
  }
  
  /// Wait for connection to be available
  Future<bool> waitForConnection({Duration timeout = const Duration(seconds: 30)}) async {
    if (_isOnline) return true;
    
    final completer = Completer<bool>();
    late VoidCallback listener;
    Timer? timeoutTimer;
    
    // Set up timeout
    timeoutTimer = Timer(timeout, () {
      if (!completer.isCompleted) {
        removeListener(listener);
        completer.complete(false);
      }
    });
    
    // Listen for connection
    listener = () {
      if (_isOnline) {
        timeoutTimer?.cancel();
        removeListener(listener);
        if (!completer.isCompleted) {
          completer.complete(true);
        }
      }
    };
    
    addListener(listener);
    return completer.future;
  }
  
  /// Manually check connectivity (force refresh)
  Future<bool> checkConnectivity() async {
    try {
      final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
      _updateConnectionState(results);
      return _isOnline;
    } catch (e) {
      debugPrint('$_logTag: Error checking connectivity: $e');
      return _isOnline; // Return current state if check fails
    }
  }
  
  /// Get connection statistics
  Map<String, dynamic> getConnectionStats() {
    return {
      'isOnline': _isOnline,
      'connectionType': _connectionType.name,
      'connectionQuality': _connectionQuality,
      'qualityDescription': connectionQualityDescription,
      'isSlowConnection': _isSlowConnection,
      'lastConnectedTime': _lastConnectedTime.toIso8601String(),
      'lastDisconnectedTime': _lastDisconnectedTime?.toIso8601String(),
      'offlineDuration': offlineDuration,
      'isSuitableForSync': isSuitableForSync,
      'isSuitableForHeavyOperations': isSuitableForHeavyOperations,
    };
  }
  
  /// Register callback for connectivity changes
  VoidCallback onConnectivityChanged(VoidCallback callback) {
    addListener(callback);
    return () => removeListener(callback);
  }
  
  /// Register callback for when connection is restored
  VoidCallback onConnectionRestored(VoidCallback callback) {
    VoidCallback listener = () {
      if (_isOnline) {
        callback();
      }
    };
    addListener(listener);
    return () => removeListener(listener);
  }
  
  /// Register callback for when connection is lost
  VoidCallback onConnectionLost(VoidCallback callback) {
    bool wasOnline = _isOnline;
    VoidCallback listener = () {
      if (wasOnline && !_isOnline) {
        callback();
      }
      wasOnline = _isOnline;
    };
    addListener(listener);
    return () => removeListener(listener);
  }
  
  @override
  void dispose() {
    debugPrint('$_logTag: Disposing connectivity service');
    _connectivitySubscription?.cancel();
    super.dispose();
  }
  
  @override
  String toString() {
    return 'ConnectivityService{online: $_isOnline, type: ${_connectionType.name}, quality: $_connectionQuality%}';
  }
}