// File: lib/widgets/common/cached_image.dart
// Purpose: Optimized image loading widget with caching and placeholders
// Step: 12.4 - Optimize Image Loading and Caching

import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../services/image_cache_service.dart';
import '../loading/skeleton_loader.dart';

/// A widget that loads and displays images with advanced caching
class CachedImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Map<String, String>? headers;
  final Duration? cacheTimeout;
  final bool showLoadingProgress;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final AlignmentGeometry alignment;
  final Duration fadeDuration;

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.headers,
    this.cacheTimeout,
    this.showLoadingProgress = true,
    this.borderRadius,
    this.backgroundColor,
    this.alignment = Alignment.center,
    this.fadeDuration = const Duration(milliseconds: 300),
  });

  @override
  State<CachedImage> createState() => _CachedImageState();
}

class _CachedImageState extends State<CachedImage>
    with SingleTickerProviderStateMixin {
  
  late final ImageCacheService _cacheService;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  
  Uint8List? _imageData;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    
    _cacheService = ImageCacheService();
    
    _fadeController = AnimationController(
      duration: widget.fadeDuration,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _loadImage();
  }

  @override
  void didUpdateWidget(CachedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.headers != widget.headers) {
      _loadImage();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadImage() async {
    if (widget.imageUrl.isEmpty) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Empty image URL';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
      _imageData = null;
    });

    try {
      final imageData = await _cacheService.loadImage(
        widget.imageUrl,
        headers: widget.headers,
        timeout: widget.cacheTimeout,
      );

      if (mounted) {
        if (imageData != null) {
          setState(() {
            _imageData = imageData;
            _isLoading = false;
          });
          _fadeController.forward();
        } else {
          setState(() {
            _hasError = true;
            _errorMessage = 'Failed to load image';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (_hasError) {
      child = _buildErrorWidget();
    } else if (_isLoading) {
      child = _buildLoadingWidget();
    } else if (_imageData != null) {
      child = _buildImageWidget();
    } else {
      child = _buildLoadingWidget();
    }

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: widget.borderRadius,
      ),
      clipBehavior: widget.borderRadius != null 
          ? Clip.antiAlias 
          : Clip.none,
      child: child,
    );
  }

  Widget _buildImageWidget() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Image.memory(
        _imageData!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        alignment: widget.alignment,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
      ),
    );
  }

  Widget _buildLoadingWidget() {
    if (widget.placeholder != null) {
      return widget.placeholder!;
    }

    if (widget.showLoadingProgress) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey.withOpacity(0.1),
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    // Use skeleton loader for better UX
    return ShimmerWidget(
      child: SkeletonBox(
        width: widget.width,
        height: widget.height,
      ),
    );
  }

  Widget _buildErrorWidget() {
    if (widget.errorWidget != null) {
      return widget.errorWidget!;
    }

    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey.withOpacity(0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            size: (widget.height != null && widget.height! < 100) ? 24 : 48,
            color: Colors.grey,
          ),
          if (widget.height == null || widget.height! > 60) ...[
            const SizedBox(height: 8),
            Text(
              'Image failed to load',
              style: TextStyle(
                color: Colors.grey,
                fontSize: (widget.height != null && widget.height! < 100) ? 10 : 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// A circular cached image widget (commonly used for avatars)
class CachedCircularImage extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Map<String, String>? headers;
  final Color? backgroundColor;

  const CachedCircularImage({
    super.key,
    required this.imageUrl,
    required this.radius,
    this.placeholder,
    this.errorWidget,
    this.headers,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: CachedImage(
        imageUrl: imageUrl,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        headers: headers,
        backgroundColor: backgroundColor,
        placeholder: placeholder ?? _buildDefaultPlaceholder(),
        errorWidget: errorWidget ?? _buildDefaultError(),
      ),
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: radius * 2,
      height: radius * 2,
      color: Colors.grey.withOpacity(0.1),
      child: Icon(
        Icons.person_outline,
        size: radius * 0.8,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildDefaultError() {
    return Container(
      width: radius * 2,
      height: radius * 2,
      color: Colors.grey.withOpacity(0.1),
      child: Icon(
        Icons.person_off_outlined,
        size: radius * 0.8,
        color: Colors.grey,
      ),
    );
  }
}

/// A cached image that maintains aspect ratio
class CachedAspectRatioImage extends StatelessWidget {
  final String imageUrl;
  final double aspectRatio;
  final double? maxWidth;
  final double? maxHeight;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Map<String, String>? headers;
  final BorderRadius? borderRadius;

  const CachedAspectRatioImage({
    super.key,
    required this.imageUrl,
    required this.aspectRatio,
    this.maxWidth,
    this.maxHeight,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.headers,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? double.infinity,
          maxHeight: maxHeight ?? double.infinity,
        ),
        child: CachedImage(
          imageUrl: imageUrl,
          fit: fit,
          headers: headers,
          borderRadius: borderRadius,
          placeholder: placeholder,
          errorWidget: errorWidget,
        ),
      ),
    );
  }
}

/// A list of cached images with optimized loading
class CachedImageList extends StatefulWidget {
  final List<String> imageUrls;
  final double itemHeight;
  final EdgeInsets? padding;
  final Axis scrollDirection;
  final Map<String, String>? headers;
  final Widget Function(String imageUrl, int index)? itemBuilder;
  final bool preloadImages;

  const CachedImageList({
    super.key,
    required this.imageUrls,
    this.itemHeight = 200,
    this.padding,
    this.scrollDirection = Axis.horizontal,
    this.headers,
    this.itemBuilder,
    this.preloadImages = true,
  });

  @override
  State<CachedImageList> createState() => _CachedImageListState();
}

class _CachedImageListState extends State<CachedImageList> {
  late final ImageCacheService _cacheService;

  @override
  void initState() {
    super.initState();
    _cacheService = ImageCacheService();
    
    if (widget.preloadImages) {
      _preloadImages();
    }
  }

  Future<void> _preloadImages() async {
    // Preload first few images for immediate display
    final priorityUrls = widget.imageUrls.take(5).toList();
    final remainingUrls = widget.imageUrls.skip(5).toList();
    
    // Load priority images first
    if (priorityUrls.isNotEmpty) {
      await _cacheService.preloadImages(
        priorityUrls, 
        headers: widget.headers,
        concurrency: 2,
      );
    }
    
    // Load remaining images in background
    if (remainingUrls.isNotEmpty) {
      _cacheService.preloadImages(
        remainingUrls, 
        headers: widget.headers,
        concurrency: 1,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: widget.scrollDirection == Axis.horizontal ? widget.itemHeight : null,
      child: ListView.builder(
        scrollDirection: widget.scrollDirection,
        padding: widget.padding,
        itemCount: widget.imageUrls.length,
        itemBuilder: (context, index) {
          final imageUrl = widget.imageUrls[index];
          
          if (widget.itemBuilder != null) {
            return widget.itemBuilder!(imageUrl, index);
          }
          
          return Container(
            width: widget.scrollDirection == Axis.horizontal 
                ? widget.itemHeight 
                : null,
            height: widget.scrollDirection == Axis.vertical 
                ? widget.itemHeight 
                : null,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: CachedImage(
              imageUrl: imageUrl,
              headers: widget.headers,
              borderRadius: BorderRadius.circular(8),
            ),
          );
        },
      ),
    );
  }
}