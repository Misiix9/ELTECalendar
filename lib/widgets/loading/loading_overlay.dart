// File: lib/widgets/loading/loading_overlay.dart
// Purpose: Full-screen loading overlay component
// Step: 12.2 - Loading States and UX Components

import 'package:flutter/material.dart';
import '../../config/theme_config.dart';

/// A full-screen loading overlay with customizable content
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final double? progress;
  final Color? backgroundColor;
  final Color? indicatorColor;
  final bool canDismiss;
  final VoidCallback? onDismiss;
  final Duration animationDuration;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.progress,
    this.backgroundColor,
    this.indicatorColor,
    this.canDismiss = false,
    this.onDismiss,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        AnimatedOpacity(
          opacity: isLoading ? 1.0 : 0.0,
          duration: animationDuration,
          child: isLoading
              ? _buildOverlay(context)
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Positioned.fill(
      child: GestureDetector(
        onTap: canDismiss ? onDismiss : null,
        child: Container(
          color: backgroundColor ?? 
              (isDarkMode 
                  ? Colors.black.withOpacity(0.7)
                  : Colors.white.withOpacity(0.8)),
          child: Center(
            child: _buildLoadingContent(context, isDarkMode),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingContent(BuildContext context, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDarkMode ? ThemeConfig.darkTextElements : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildProgressIndicator(context),
          if (message != null) ...[
            const SizedBox(height: 24),
            Text(
              message!,
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.white : ThemeConfig.darkTextElements,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (canDismiss) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: onDismiss,
              child: Text(
                'Dismiss',
                style: TextStyle(
                  color: indicatorColor ?? ThemeConfig.primaryDarkBlue,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    final color = indicatorColor ?? ThemeConfig.primaryDarkBlue;
    
    if (progress != null) {
      return Column(
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              backgroundColor: color.withOpacity(0.2),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${(progress! * 100).round()}%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      );
    }

    return SizedBox(
      width: 60,
      height: 60,
      child: CircularProgressIndicator(
        strokeWidth: 4,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}

/// A simple loading overlay with just a spinner
class SimpleLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final Color? overlayColor;
  final Color? indicatorColor;

  const SimpleLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.overlayColor,
    this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: overlayColor ?? Colors.black.withOpacity(0.3),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    indicatorColor ?? ThemeConfig.primaryDarkBlue,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// A loading overlay specifically for screens/pages
class PageLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final List<Widget>? actions;

  const PageLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.title,
    this.subtitle,
    this.icon,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 64,
                color: ThemeConfig.primaryDarkBlue.withOpacity(0.7),
              ),
              const SizedBox(height: 24),
            ],
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(ThemeConfig.primaryDarkBlue),
            ),
            const SizedBox(height: 24),
            if (title != null)
              Text(
                title!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: ThemeConfig.darkTextElements,
                ),
                textAlign: TextAlign.center,
              ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 14,
                  color: ThemeConfig.darkTextElements.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actions != null) ...[
              const SizedBox(height: 32),
              ...actions!,
            ],
          ],
        ),
      ),
    );
  }
}

/// A loading state for list items
class ListLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final int itemCount;
  final double itemHeight;

  const ListLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.itemCount = 3,
    this.itemHeight = 60,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) => Container(
        height: itemHeight,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: _buildShimmerItem(context),
      ),
    );
  }

  Widget _buildShimmerItem(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 16,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}