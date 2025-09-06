// File: lib/widgets/common_widgets/notification_badge.dart
// Purpose: Notification badge widget for showing unread count
// Step: 7.5 - Notification UI Components

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../services/notification_service.dart';

/// Notification badge widget that shows unread notification count
class NotificationBadge extends StatelessWidget {
  final VoidCallback? onTap;
  final Color? badgeColor;
  final Color? textColor;
  final Color? iconColor;
  final double iconSize;

  const NotificationBadge({
    super.key,
    this.onTap,
    this.badgeColor,
    this.textColor,
    this.iconColor,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationService>(
      builder: (context, notificationService, child) {
        final unreadCount = notificationService.unreadCount;
        
        return InkWell(
          onTap: onTap ?? () => Navigator.of(context).pushNamed('/notifications'),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.notifications,
                  size: iconSize,
                  color: iconColor ?? ThemeConfig.primaryDarkBlue,
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: badgeColor ?? ThemeConfig.goldAccent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        unreadCount > 99 ? '99+' : '$unreadCount',
                        style: TextStyle(
                          color: textColor ?? Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Floating notification badge for persistent display
class FloatingNotificationBadge extends StatefulWidget {
  final Widget child;
  final bool showOnlyWhenUnread;

  const FloatingNotificationBadge({
    super.key,
    required this.child,
    this.showOnlyWhenUnread = true,
  });

  @override
  State<FloatingNotificationBadge> createState() => _FloatingNotificationBadgeState();
}

class _FloatingNotificationBadgeState extends State<FloatingNotificationBadge>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationService>(
      builder: (context, notificationService, child) {
        final unreadCount = notificationService.unreadCount;
        final shouldShow = !widget.showOnlyWhenUnread || unreadCount > 0;

        if (!shouldShow) {
          return widget.child;
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            widget.child,
            if (unreadCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: ThemeConfig.goldAccent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Text(
                                unreadCount > 99 ? '99+' : '$unreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Mini notification widget for quick display
class MiniNotification extends StatefulWidget {
  final String title;
  final String message;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final Duration duration;

  const MiniNotification({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.color,
    this.onTap,
    this.onDismiss,
    this.duration = const Duration(seconds: 4),
  });

  @override
  State<MiniNotification> createState() => _MiniNotificationState();
}

class _MiniNotificationState extends State<MiniNotification>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_fadeController);
    
    // Start animation
    _slideController.forward();
    _fadeController.forward();
    
    // Auto dismiss
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _fadeController.reverse();
    await _slideController.reverse();
    widget.onDismiss?.call();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.color ?? ThemeConfig.primaryDarkBlue,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  if (widget.icon != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (widget.color ?? ThemeConfig.primaryDarkBlue).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.color ?? ThemeConfig.primaryDarkBlue,
                        size: 20,
                      ),
                    ),
                  if (widget.icon != null) const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: widget.color ?? ThemeConfig.primaryDarkBlue,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.message,
                          style: TextStyle(
                            fontSize: 12,
                            color: ThemeConfig.darkTextElements.withOpacity(0.8),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _dismiss,
                    icon: Icon(
                      Icons.close,
                      size: 18,
                      color: ThemeConfig.darkTextElements.withOpacity(0.5),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Notification overlay manager for showing mini notifications
class NotificationOverlay {
  static final List<OverlayEntry> _overlayEntries = [];
  
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    IconData? icon,
    Color? color,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 4),
  }) {
    final overlay = Overlay.of(context);
    
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + kToolbarHeight + 16,
        left: 16,
        right: 16,
        child: MiniNotification(
          title: title,
          message: message,
          icon: icon,
          color: color,
          onTap: onTap,
          duration: duration,
          onDismiss: () {
            overlayEntry.remove();
            _overlayEntries.remove(overlayEntry);
          },
        ),
      ),
    );
    
    overlay.insert(overlayEntry);
    _overlayEntries.add(overlayEntry);
    
    // Limit to 3 notifications on screen
    if (_overlayEntries.length > 3) {
      final oldest = _overlayEntries.removeAt(0);
      oldest.remove();
    }
  }
  
  static void clear() {
    for (final entry in _overlayEntries) {
      entry.remove();
    }
    _overlayEntries.clear();
  }
}