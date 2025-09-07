// File: lib/widgets/error/error_screen.dart
// Purpose: User-friendly error screen component
// Step: 12.3 - Error Boundaries and Crash Recovery

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme_config.dart';
import '../../config/localization_config.dart';
import '../loading/loading_button.dart';

/// A comprehensive error screen with actions and retry functionality
class ErrorScreen extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String message;
  final String? details;
  final VoidCallback? onRetry;
  final VoidCallback? onReport;
  final VoidCallback? onDismiss;
  final List<Widget>? actions;
  final bool canRetry;
  final bool isRetrying;
  final bool showDetails;
  final Color? backgroundColor;

  const ErrorScreen({
    super.key,
    this.icon,
    required this.title,
    required this.message,
    this.details,
    this.onRetry,
    this.onReport,
    this.onDismiss,
    this.actions,
    this.canRetry = true,
    this.isRetrying = false,
    this.showDetails = false,
    this.backgroundColor,
  });

  /// Create an error screen for network issues
  const ErrorScreen.network({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.onDismiss,
    this.actions,
    this.isRetrying = false,
  }) : icon = Icons.wifi_off,
       details = null,
       onReport = null,
       canRetry = true,
       showDetails = false,
       backgroundColor = null;

  /// Create an error screen for authentication issues
  const ErrorScreen.auth({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.onDismiss,
    this.actions,
    this.isRetrying = false,
  }) : icon = Icons.lock_outline,
       details = null,
       onReport = null,
       canRetry = true,
       showDetails = false,
       backgroundColor = null;

  /// Create an error screen for server issues
  const ErrorScreen.server({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.onReport,
    this.actions,
    this.isRetrying = false,
  }) : icon = Icons.cloud_off,
       details = null,
       onDismiss = null,
       canRetry = true,
       showDetails = false,
       backgroundColor = null;

  /// Create an error screen for general application errors
  const ErrorScreen.general({
    super.key,
    required this.title,
    required this.message,
    this.details,
    this.onRetry,
    this.onReport,
    this.onDismiss,
    this.actions,
    this.isRetrying = false,
    this.showDetails = false,
  }) : icon = Icons.error_outline,
       canRetry = true,
       backgroundColor = null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildErrorIcon(theme),
              const SizedBox(height: 32),
              _buildErrorContent(theme, localizations),
              const SizedBox(height: 32),
              _buildActionButtons(context, localizations),
              if (details != null && showDetails) ...[
                const SizedBox(height: 24),
                _buildErrorDetails(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorIcon(ThemeData theme) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon ?? Icons.error_outline,
        size: 64,
        color: theme.colorScheme.error,
      ),
    );
  }

  Widget _buildErrorContent(ThemeData theme, AppLocalizations? localizations) {
    return Column(
      children: [
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          message,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.8),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, AppLocalizations? localizations) {
    final buttons = <Widget>[];

    // Retry button
    if (canRetry && onRetry != null) {
      buttons.add(
        LoadingButton.primary(
          text: localizations?.getString('retry') ?? 'Try Again',
          onPressed: isRetrying ? null : onRetry,
          isLoading: isRetrying,
          loadingText: localizations?.getString('retrying') ?? 'Retrying...',
          icon: Icons.refresh,
          width: double.infinity,
        ),
      );
    }

    // Custom actions
    if (actions != null) {
      for (final action in actions!) {
        buttons.add(action);
      }
    }

    // Report button
    if (onReport != null) {
      buttons.add(
        LoadingButton.outlined(
          text: localizations?.getString('reportError') ?? 'Report Error',
          onPressed: onReport,
          icon: Icons.bug_report,
          width: double.infinity,
        ),
      );
    }

    // Dismiss button
    if (onDismiss != null) {
      buttons.add(
        LoadingButton.text(
          text: localizations?.getString('dismiss') ?? 'Dismiss',
          onPressed: onDismiss,
        ),
      );
    }

    // Show details button
    if (details != null) {
      buttons.add(
        LoadingButton.text(
          text: showDetails 
              ? (localizations?.getString('hideDetails') ?? 'Hide Details')
              : (localizations?.getString('showDetails') ?? 'Show Details'),
          onPressed: () => _toggleDetails(context),
        ),
      );
    }

    return Column(
      children: buttons.map((button) {
        final index = buttons.indexOf(button);
        return Padding(
          padding: EdgeInsets.only(bottom: index < buttons.length - 1 ? 12 : 0),
          child: button,
        );
      }).toList(),
    );
  }

  Widget _buildErrorDetails(BuildContext context) {
    return ExpansionTile(
      title: Text(
        'Error Details',
        style: Theme.of(context).textTheme.titleSmall,
      ),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                details!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: LoadingButton.outlined(
                      text: 'Copy Details',
                      onPressed: () => _copyDetails(context),
                      icon: Icons.copy,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _toggleDetails(BuildContext context) {
    // This would need to be handled by the parent widget
    // For now, we'll just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Details toggle not implemented'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _copyDetails(BuildContext context) {
    if (details != null) {
      Clipboard.setData(ClipboardData(text: details!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error details copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

/// A simple error widget for inline errors
class InlineErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final bool isRetrying;
  final IconData? icon;
  final Color? backgroundColor;

  const InlineErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.isRetrying = false,
    this.icon,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                icon ?? Icons.error_outline,
                color: theme.colorScheme.error,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                LoadingTextButton(
                  text: 'Retry',
                  onPressed: isRetrying ? null : onRetry,
                  isLoading: isRetrying,
                  color: theme.colorScheme.error,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// A minimal error banner for non-intrusive errors
class ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;
  final VoidCallback? onAction;
  final String? actionText;
  final Color? backgroundColor;
  final Duration? autoHideDuration;

  const ErrorBanner({
    super.key,
    required this.message,
    this.onDismiss,
    this.onAction,
    this.actionText,
    this.backgroundColor,
    this.autoHideDuration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.error.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onAction != null && actionText != null) ...[
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              child: Text(actionText!),
            ),
          ],
          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(Icons.close, color: Colors.white, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}