// File: lib/widgets/common/analytics_wrapper.dart
// Purpose: Analytics wrapper widget for automatic screen and event tracking
// Step: 12.6 - Implement App Analytics and Crash Reporting

import 'package:flutter/material.dart';
import '../../services/analytics_service.dart';

/// A wrapper widget that automatically tracks screen views and user interactions
class AnalyticsWrapper extends StatefulWidget {
  final Widget child;
  final String screenName;
  final Map<String, String>? screenProperties;
  final bool trackScreenView;
  final bool trackUserInteractions;

  const AnalyticsWrapper({
    super.key,
    required this.child,
    required this.screenName,
    this.screenProperties,
    this.trackScreenView = true,
    this.trackUserInteractions = false,
  });

  @override
  State<AnalyticsWrapper> createState() => _AnalyticsWrapperState();
}

class _AnalyticsWrapperState extends State<AnalyticsWrapper>
    with WidgetsBindingObserver {
  
  late final AnalyticsService _analyticsService;
  DateTime? _screenEnterTime;

  @override
  void initState() {
    super.initState();
    
    _analyticsService = AnalyticsService();
    
    if (widget.trackScreenView) {
      _trackScreenView();
    }
    
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _trackScreenExit();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        _analyticsService.logEvent(AnalyticsEvents.appOpen);
        break;
      case AppLifecycleState.paused:
        _trackScreenExit();
        break;
      case AppLifecycleState.detached:
        _trackScreenExit();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // No specific action needed
        break;
    }
  }

  void _trackScreenView() {
    _screenEnterTime = DateTime.now();
    
    _analyticsService.setCurrentScreen(widget.screenName);
    
    if (widget.screenProperties != null) {
      _analyticsService.setUserProperties(widget.screenProperties!);
    }
    
    _analyticsService.logEvent(
      'screen_view',
      parameters: {
        'screen_name': widget.screenName,
        'screen_class': widget.screenName,
        if (widget.screenProperties != null)
          ...widget.screenProperties!.map(
            (key, value) => MapEntry('screen_$key', value),
          ),
      },
    );
  }

  void _trackScreenExit() {
    if (_screenEnterTime != null) {
      final timeSpent = DateTime.now().difference(_screenEnterTime!);
      
      _analyticsService.logEvent(
        'screen_exit',
        parameters: {
          'screen_name': widget.screenName,
          'time_spent_seconds': timeSpent.inSeconds,
        },
      );
      
      _screenEnterTime = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.trackUserInteractions) {
      return widget.child;
    }

    // Wrap with GestureDetector to track user interactions
    return GestureDetector(
      onTap: () => _trackInteraction('tap'),
      onLongPress: () => _trackInteraction('long_press'),
      onDoubleTap: () => _trackInteraction('double_tap'),
      child: widget.child,
    );
  }

  void _trackInteraction(String interactionType) {
    _analyticsService.logEvent(
      'user_interaction',
      parameters: {
        'interaction_type': interactionType,
        'screen_name': widget.screenName,
      },
    );
  }
}

/// A widget that tracks button/action interactions
class AnalyticsButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String actionName;
  final String? category;
  final Map<String, Object>? additionalParameters;

  const AnalyticsButton({
    super.key,
    required this.child,
    required this.onPressed,
    required this.actionName,
    this.category,
    this.additionalParameters,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _trackAction();
        onPressed?.call();
      },
      child: child,
    );
  }

  void _trackAction() {
    final analyticsService = AnalyticsService();
    
    analyticsService.logEvent(
      'button_click',
      parameters: {
        'action_name': actionName,
        if (category != null) 'category': category!,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        ...?additionalParameters,
      },
    );
  }
}

/// A mixin for widgets that want to track analytics easily
mixin AnalyticsTrackingMixin<T extends StatefulWidget> on State<T> {
  late final AnalyticsService _analyticsService;
  
  @override
  void initState() {
    super.initState();
    _analyticsService = AnalyticsService();
  }
  
  /// Track a custom event
  void trackEvent(String eventName, {Map<String, Object>? parameters}) {
    _analyticsService.logEvent(eventName, parameters: parameters);
  }
  
  /// Track an error
  void trackError(dynamic error, StackTrace? stackTrace, {String? reason}) {
    _analyticsService.recordError(error, stackTrace, reason: reason);
  }
  
  /// Track a feature usage
  void trackFeatureUsage(String featureName, {Map<String, Object>? parameters}) {
    trackEvent(
      'feature_usage',
      parameters: {
        'feature_name': featureName,
        ...?parameters,
      },
    );
  }
  
  /// Track a user action
  void trackUserAction(String actionName, {Map<String, Object>? parameters}) {
    trackEvent(
      'user_action',
      parameters: {
        'action_name': actionName,
        ...?parameters,
      },
    );
  }
  
  /// Track timing for performance monitoring
  void trackTiming(String category, String variable, Duration duration) {
    trackEvent(
      'timing',
      parameters: {
        'category': category,
        'variable': variable,
        'duration_ms': duration.inMilliseconds,
      },
    );
  }
}

/// A widget that automatically tracks errors within its subtree
class ErrorTrackingWrapper extends StatelessWidget {
  final Widget child;
  final String? context;
  final Map<String, dynamic>? additionalData;

  const ErrorTrackingWrapper({
    super.key,
    required this.child,
    this.context,
    this.additionalData,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      onError: (FlutterErrorDetails errorDetails) {
        final analyticsService = AnalyticsService();
        
        analyticsService.recordError(
          errorDetails.exception,
          errorDetails.stack,
          reason: this.context ?? 'Widget error',
          additionalData: {
            'widget_context': this.context ?? 'unknown',
            'error_library': errorDetails.library ?? 'unknown',
            'error_context': errorDetails.context?.toString() ?? 'unknown',
            ...?additionalData,
          },
        );
      },
      child: child,
    );
  }
}

/// Placeholder ErrorBoundary - implement this based on your error boundary implementation
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Function(FlutterErrorDetails)? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  FlutterErrorDetails? _errorDetails;

  @override
  void initState() {
    super.initState();
    
    // This is a simplified version - use your actual error boundary implementation
    FlutterError.onError = (FlutterErrorDetails details) {
      widget.onError?.call(details);
      
      if (mounted) {
        setState(() {
          _errorDetails = details;
        });
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_errorDetails != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: Text('An error occurred'),
        ),
      );
    }
    
    return widget.child;
  }
}

/// A performance tracking widget
class PerformanceTracker extends StatefulWidget {
  final Widget child;
  final String operationName;
  final bool autoTrack;

  const PerformanceTracker({
    super.key,
    required this.child,
    required this.operationName,
    this.autoTrack = true,
  });

  @override
  State<PerformanceTracker> createState() => _PerformanceTrackerState();
}

class _PerformanceTrackerState extends State<PerformanceTracker> {
  late final Stopwatch _stopwatch;
  late final AnalyticsService _analyticsService;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _analyticsService = AnalyticsService();
    
    if (widget.autoTrack) {
      _stopwatch.start();
    }
  }

  @override
  void dispose() {
    if (widget.autoTrack && _stopwatch.isRunning) {
      _stopwatch.stop();
      _trackPerformance();
    }
    super.dispose();
  }

  void _trackPerformance() {
    _analyticsService.logEvent(
      AnalyticsEvents.serviceInit,
      parameters: {
        AnalyticsParameters.feature: widget.operationName,
        AnalyticsParameters.duration: _stopwatch.elapsedMilliseconds,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}