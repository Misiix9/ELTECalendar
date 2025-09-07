// File: lib/widgets/error/error_boundary.dart
// Purpose: Error boundary widget for graceful error handling
// Step: 12.3 - Error Boundaries and Crash Recovery

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme_config.dart';
import '../../config/localization_config.dart';
import 'error_screen.dart';

/// A widget that catches and handles errors in its child widget tree
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(BuildContext context, FlutterErrorDetails error)? errorBuilder;
  final void Function(FlutterErrorDetails error)? onError;
  final String? fallbackTitle;
  final String? fallbackMessage;
  final bool showErrorDetails;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
    this.fallbackTitle,
    this.fallbackMessage,
    this.showErrorDetails = false,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  FlutterErrorDetails? _errorDetails;

  @override
  void initState() {
    super.initState();
    
    // Set up global error handler
    FlutterError.onError = (FlutterErrorDetails details) {
      // Call the original handler first
      FlutterError.presentError(details);
      
      // Call custom error handler if provided
      widget.onError?.call(details);
      
      // Update state to show error UI
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
      return widget.errorBuilder?.call(context, _errorDetails!) ??
          _buildDefaultErrorWidget(context, _errorDetails!);
    }

    return widget.child;
  }

  Widget _buildDefaultErrorWidget(BuildContext context, FlutterErrorDetails error) {
    final localizations = AppLocalizations.of(context);
    
    return ErrorScreen(
      title: widget.fallbackTitle ?? localizations?.getString('errorTitle') ?? 'Something went wrong',
      message: widget.fallbackMessage ?? localizations?.getString('errorMessage') ?? 
          'An unexpected error occurred. Please try again.',
      details: widget.showErrorDetails ? error.toString() : null,
      onRetry: () {
        setState(() {
          _errorDetails = null;
        });
      },
      onReport: () => _reportError(error),
    );
  }

  void _reportError(FlutterErrorDetails error) {
    // TODO: Implement error reporting to Firebase Crashlytics
    debugPrint('Error reported: ${error.toString()}');
    
    // For now, copy error to clipboard
    Clipboard.setData(ClipboardData(text: error.toString()));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error details copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

/// A specialized error boundary for async operations
class AsyncErrorBoundary extends StatefulWidget {
  final Widget child;
  final Future<void> Function()? onRetry;
  final String? title;
  final String? message;
  final bool canRetry;

  const AsyncErrorBoundary({
    super.key,
    required this.child,
    this.onRetry,
    this.title,
    this.message,
    this.canRetry = true,
  });

  @override
  State<AsyncErrorBoundary> createState() => _AsyncErrorBoundaryState();
}

class _AsyncErrorBoundaryState extends State<AsyncErrorBoundary> {
  Object? _error;
  bool _isRetrying = false;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return ErrorScreen(
        title: widget.title ?? 'Operation Failed',
        message: widget.message ?? 'The operation could not be completed.',
        details: _error.toString(),
        canRetry: widget.canRetry,
        isRetrying: _isRetrying,
        onRetry: widget.canRetry ? _handleRetry : null,
        onDismiss: () {
          setState(() {
            _error = null;
          });
        },
      );
    }

    return widget.child;
  }

  Future<void> _handleRetry() async {
    if (widget.onRetry == null) return;

    setState(() {
      _isRetrying = true;
      _error = null;
    });

    try {
      await widget.onRetry!();
    } catch (error) {
      setState(() {
        _error = error;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isRetrying = false;
        });
      }
    }
  }

  void setError(Object error) {
    setState(() {
      _error = error;
    });
  }
}

/// A wrapper for handling network errors specifically
class NetworkErrorBoundary extends StatefulWidget {
  final Widget child;
  final Future<void> Function()? onRetry;
  final bool showOfflineMessage;

  const NetworkErrorBoundary({
    super.key,
    required this.child,
    this.onRetry,
    this.showOfflineMessage = true,
  });

  @override
  State<NetworkErrorBoundary> createState() => _NetworkErrorBoundaryState();
}

class _NetworkErrorBoundaryState extends State<NetworkErrorBoundary> {
  Object? _networkError;
  bool _isRetrying = false;

  @override
  Widget build(BuildContext context) {
    if (_networkError != null) {
      return ErrorScreen(
        icon: Icons.wifi_off,
        title: 'Connection Problem',
        message: widget.showOfflineMessage 
            ? 'Please check your internet connection and try again.'
            : 'Unable to connect to the server.',
        canRetry: true,
        isRetrying: _isRetrying,
        onRetry: _handleRetry,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _networkError = null;
              });
            },
            child: const Text('Work Offline'),
          ),
        ],
      );
    }

    return widget.child;
  }

  Future<void> _handleRetry() async {
    setState(() {
      _isRetrying = true;
    });

    try {
      if (widget.onRetry != null) {
        await widget.onRetry!();
      }
      
      setState(() {
        _networkError = null;
      });
    } catch (error) {
      setState(() {
        _networkError = error;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isRetrying = false;
        });
      }
    }
  }

  void setNetworkError(Object error) {
    setState(() {
      _networkError = error;
    });
  }
}

/// A helper function to wrap widgets with error boundaries
Widget withErrorBoundary(
  Widget child, {
  String? title,
  String? message,
  bool showErrorDetails = false,
  void Function(FlutterErrorDetails)? onError,
}) {
  return ErrorBoundary(
    fallbackTitle: title,
    fallbackMessage: message,
    showErrorDetails: showErrorDetails,
    onError: onError,
    child: child,
  );
}

/// A helper function to wrap async operations with error handling
Widget withAsyncErrorBoundary(
  Widget child, {
  Future<void> Function()? onRetry,
  String? title,
  String? message,
}) {
  return AsyncErrorBoundary(
    onRetry: onRetry,
    title: title,
    message: message,
    child: child,
  );
}

/// A helper function for network operations
Widget withNetworkErrorBoundary(
  Widget child, {
  Future<void> Function()? onRetry,
  bool showOfflineMessage = true,
}) {
  return NetworkErrorBoundary(
    onRetry: onRetry,
    showOfflineMessage: showOfflineMessage,
    child: child,
  );
}