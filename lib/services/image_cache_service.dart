// File: lib/services/image_cache_service.dart
// Purpose: Optimized image loading and caching service
// Step: 12.4 - Optimize Image Loading and Caching

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Service for optimized image loading with disk and memory caching
class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  factory ImageCacheService() => _instance;
  ImageCacheService._internal();

  // Memory cache for recently used images
  final Map<String, Uint8List> _memoryCache = {};
  
  // Track cache sizes
  int _memoryCacheSize = 0;
  
  // Configuration
  static const int maxMemoryCacheSize = 50 * 1024 * 1024; // 50MB
  static const int maxDiskCacheSize = 200 * 1024 * 1024; // 200MB
  static const Duration cacheExpiry = Duration(days: 7);
  
  // Directory for disk cache
  Directory? _cacheDirectory;
  
  /// Initialize the cache service
  Future<void> initialize() async {
    try {
      final tempDir = await getTemporaryDirectory();
      _cacheDirectory = Directory('${tempDir.path}/image_cache');
      
      if (!await _cacheDirectory!.exists()) {
        await _cacheDirectory!.create(recursive: true);
      }
      
      // Clean up expired cache files
      await _cleanupExpiredFiles();
      
      debugPrint('ImageCacheService initialized');
    } catch (e) {
      debugPrint('Failed to initialize ImageCacheService: $e');
    }
  }
  
  /// Load image with caching (memory -> disk -> network)
  Future<Uint8List?> loadImage(String url, {
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    if (url.isEmpty) return null;
    
    final cacheKey = _generateCacheKey(url);
    
    try {
      // 1. Check memory cache first
      if (_memoryCache.containsKey(cacheKey)) {
        debugPrint('Loading image from memory cache: $url');
        return _memoryCache[cacheKey];
      }
      
      // 2. Check disk cache
      final diskCachedImage = await _loadFromDisk(cacheKey);
      if (diskCachedImage != null) {
        debugPrint('Loading image from disk cache: $url');
        _addToMemoryCache(cacheKey, diskCachedImage);
        return diskCachedImage;
      }
      
      // 3. Load from network
      debugPrint('Loading image from network: $url');
      final networkImage = await _loadFromNetwork(
        url, 
        headers: headers, 
        timeout: timeout ?? const Duration(seconds: 30),
      );
      
      if (networkImage != null) {
        // Cache to disk and memory
        await _saveToDisk(cacheKey, networkImage);
        _addToMemoryCache(cacheKey, networkImage);
        return networkImage;
      }
      
    } catch (e) {
      debugPrint('Error loading image $url: $e');
    }
    
    return null;
  }
  
  /// Preload images for better performance
  Future<void> preloadImages(List<String> urls, {
    Map<String, String>? headers,
    int concurrency = 3,
  }) async {
    if (urls.isEmpty) return;
    
    // Process images in batches to avoid overwhelming the network
    for (int i = 0; i < urls.length; i += concurrency) {
      final batch = urls.skip(i).take(concurrency);
      final futures = batch.map((url) => loadImage(url, headers: headers));
      
      try {
        await Future.wait(futures, eagerError: false);
      } catch (e) {
        debugPrint('Error in preload batch: $e');
      }
      
      // Small delay between batches
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }
  
  /// Clear memory cache
  void clearMemoryCache() {
    _memoryCache.clear();
    _memoryCacheSize = 0;
    debugPrint('Memory cache cleared');
  }
  
  /// Clear disk cache
  Future<void> clearDiskCache() async {
    if (_cacheDirectory == null) return;
    
    try {
      if (await _cacheDirectory!.exists()) {
        await _cacheDirectory!.delete(recursive: true);
        await _cacheDirectory!.create(recursive: true);
      }
      debugPrint('Disk cache cleared');
    } catch (e) {
      debugPrint('Error clearing disk cache: $e');
    }
  }
  
  /// Clear all caches
  Future<void> clearAllCaches() async {
    clearMemoryCache();
    await clearDiskCache();
  }
  
  /// Get cache statistics
  Future<CacheStatistics> getCacheStatistics() async {
    int diskCacheSize = 0;
    int diskCacheFiles = 0;
    
    if (_cacheDirectory != null && await _cacheDirectory!.exists()) {
      try {
        final files = await _cacheDirectory!.list().toList();
        diskCacheFiles = files.length;
        
        for (final file in files) {
          if (file is File) {
            final stat = await file.stat();
            diskCacheSize += stat.size;
          }
        }
      } catch (e) {
        debugPrint('Error calculating disk cache size: $e');
      }
    }
    
    return CacheStatistics(
      memoryCacheSize: _memoryCacheSize,
      memoryCacheItems: _memoryCache.length,
      diskCacheSize: diskCacheSize,
      diskCacheFiles: diskCacheFiles,
    );
  }
  
  /// Generate cache key from URL
  String _generateCacheKey(String url) {
    final bytes = utf8.encode(url);
    final digest = md5.convert(bytes);
    return digest.toString();
  }
  
  /// Load image from disk cache
  Future<Uint8List?> _loadFromDisk(String cacheKey) async {
    if (_cacheDirectory == null) return null;
    
    final file = File('${_cacheDirectory!.path}/$cacheKey');
    
    try {
      if (await file.exists()) {
        final stat = await file.stat();
        final age = DateTime.now().difference(stat.modified);
        
        // Check if cache is expired
        if (age > cacheExpiry) {
          await file.delete();
          return null;
        }
        
        return await file.readAsBytes();
      }
    } catch (e) {
      debugPrint('Error loading from disk cache: $e');
      // Try to delete corrupted file
      try {
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}
    }
    
    return null;
  }
  
  /// Save image to disk cache
  Future<void> _saveToDisk(String cacheKey, Uint8List data) async {
    if (_cacheDirectory == null) return;
    
    try {
      final file = File('${_cacheDirectory!.path}/$cacheKey');
      await file.writeAsBytes(data);
      
      // Clean up disk cache if it gets too large
      await _cleanupDiskCacheIfNeeded();
      
    } catch (e) {
      debugPrint('Error saving to disk cache: $e');
    }
  }
  
  /// Load image from network
  Future<Uint8List?> _loadFromNetwork(
    String url, {
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(timeout);
      
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        debugPrint('HTTP error ${response.statusCode} for image: $url');
      }
    } catch (e) {
      debugPrint('Network error loading image $url: $e');
    }
    
    return null;
  }
  
  /// Add image to memory cache with size management
  void _addToMemoryCache(String cacheKey, Uint8List data) {
    // Remove old entry if exists
    if (_memoryCache.containsKey(cacheKey)) {
      _memoryCacheSize -= _memoryCache[cacheKey]!.length;
    }
    
    // Add new entry
    _memoryCache[cacheKey] = data;
    _memoryCacheSize += data.length;
    
    // Clean up if memory cache is too large
    _cleanupMemoryCacheIfNeeded();
  }
  
  /// Clean up memory cache when it exceeds size limit
  void _cleanupMemoryCacheIfNeeded() {
    if (_memoryCacheSize <= maxMemoryCacheSize) return;
    
    // Remove oldest entries (simple FIFO approach)
    final keys = _memoryCache.keys.toList();
    int removedSize = 0;
    int targetSize = maxMemoryCacheSize ~/ 2; // Remove half when cleaning
    
    for (final key in keys) {
      if (_memoryCacheSize - removedSize <= targetSize) break;
      
      final data = _memoryCache.remove(key);
      if (data != null) {
        removedSize += data.length;
      }
    }
    
    _memoryCacheSize -= removedSize;
    debugPrint('Cleaned up memory cache: removed ${removedSize ~/ 1024}KB');
  }
  
  /// Clean up disk cache when it exceeds size limit
  Future<void> _cleanupDiskCacheIfNeeded() async {
    if (_cacheDirectory == null) return;
    
    try {
      final files = await _cacheDirectory!.list().toList();
      int totalSize = 0;
      final fileStats = <MapEntry<File, int>>[];
      
      // Calculate total size and collect file stats
      for (final entity in files) {
        if (entity is File) {
          final stat = await entity.stat();
          totalSize += stat.size;
          fileStats.add(MapEntry(entity, stat.size));
        }
      }
      
      if (totalSize <= maxDiskCacheSize) return;
      
      // Sort files by modification time (oldest first)
      fileStats.sort((a, b) {
        return a.key.statSync().modified.compareTo(b.key.statSync().modified);
      });
      
      // Remove oldest files until we're under the limit
      int removedSize = 0;
      int targetSize = maxDiskCacheSize ~/ 2; // Remove half when cleaning
      
      for (final entry in fileStats) {
        if (totalSize - removedSize <= targetSize) break;
        
        try {
          await entry.key.delete();
          removedSize += entry.value;
        } catch (e) {
          debugPrint('Error deleting cache file: $e');
        }
      }
      
      debugPrint('Cleaned up disk cache: removed ${removedSize ~/ 1024}KB');
      
    } catch (e) {
      debugPrint('Error cleaning up disk cache: $e');
    }
  }
  
  /// Clean up expired cache files
  Future<void> _cleanupExpiredFiles() async {
    if (_cacheDirectory == null) return;
    
    try {
      final files = await _cacheDirectory!.list().toList();
      int removedCount = 0;
      
      for (final entity in files) {
        if (entity is File) {
          final stat = await entity.stat();
          final age = DateTime.now().difference(stat.modified);
          
          if (age > cacheExpiry) {
            try {
              await entity.delete();
              removedCount++;
            } catch (e) {
              debugPrint('Error deleting expired cache file: $e');
            }
          }
        }
      }
      
      if (removedCount > 0) {
        debugPrint('Cleaned up $removedCount expired cache files');
      }
      
    } catch (e) {
      debugPrint('Error cleaning up expired files: $e');
    }
  }
}

/// Statistics about the image cache
class CacheStatistics {
  final int memoryCacheSize;
  final int memoryCacheItems;
  final int diskCacheSize;
  final int diskCacheFiles;
  
  const CacheStatistics({
    required this.memoryCacheSize,
    required this.memoryCacheItems,
    required this.diskCacheSize,
    required this.diskCacheFiles,
  });
  
  String get formattedMemorySize => _formatBytes(memoryCacheSize);
  String get formattedDiskSize => _formatBytes(diskCacheSize);
  
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
  
  @override
  String toString() {
    return 'CacheStatistics('
        'memory: $formattedMemorySize ($memoryCacheItems items), '
        'disk: $formattedDiskSize ($diskCacheFiles files)'
        ')';
  }
}