// File: lib/widgets/loading/loading_button.dart
// Purpose: Reusable button component with loading state
// Step: 12.2 - Loading States and UX Components

import 'package:flutter/material.dart';
import '../../config/theme_config.dart';

/// A button that shows loading state during async operations
class LoadingButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsets? padding;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final String? loadingText;
  final bool disabled;

  const LoadingButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.width,
    this.height,
    this.borderRadius,
    this.loadingText,
    this.disabled = false,
  });

  /// Create a primary button with default styling
  const LoadingButton.primary({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.padding,
    this.width,
    this.height,
    this.borderRadius,
    this.loadingText,
    this.disabled = false,
  }) : backgroundColor = ThemeConfig.primaryDarkBlue,
       foregroundColor = ThemeConfig.lightBackground;

  /// Create a secondary button with default styling
  const LoadingButton.secondary({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.padding,
    this.width,
    this.height,
    this.borderRadius,
    this.loadingText,
    this.disabled = false,
  }) : backgroundColor = ThemeConfig.lightBackground,
       foregroundColor = ThemeConfig.primaryDarkBlue;

  /// Create an outlined button
  const LoadingButton.outlined({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.padding,
    this.width,
    this.height,
    this.borderRadius,
    this.loadingText,
    this.disabled = false,
  }) : backgroundColor = Colors.transparent,
       foregroundColor = ThemeConfig.primaryDarkBlue;

  /// Create a text button
  const LoadingButton.text({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.padding,
    this.width,
    this.height,
    this.borderRadius,
    this.loadingText,
    this.disabled = false,
  }) : backgroundColor = Colors.transparent,
       foregroundColor = ThemeConfig.primaryDarkBlue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = disabled || isLoading || onPressed == null;
    
    final effectiveBackgroundColor = backgroundColor ?? theme.primaryColor;
    final effectiveForegroundColor = foregroundColor ?? 
        (backgroundColor == Colors.transparent 
            ? theme.primaryColor 
            : ThemeConfig.lightBackground);

    return SizedBox(
      width: width,
      height: height ?? 48,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled 
              ? effectiveBackgroundColor.withOpacity(0.5)
              : effectiveBackgroundColor,
          foregroundColor: isDisabled 
              ? effectiveForegroundColor.withOpacity(0.5)
              : effectiveForegroundColor,
          padding: padding ?? const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(8),
            side: backgroundColor == Colors.transparent
                ? BorderSide(
                    color: isDisabled 
                        ? effectiveForegroundColor.withOpacity(0.3)
                        : effectiveForegroundColor,
                    width: 1,
                  )
                : BorderSide.none,
          ),
          elevation: backgroundColor == Colors.transparent ? 0 : 2,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isLoading
              ? _buildLoadingContent(effectiveForegroundColor)
              : _buildNormalContent(),
        ),
      ),
    );
  }

  /// Build the normal button content
  Widget _buildNormalContent() {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// Build the loading content
  Widget _buildLoadingContent(Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        if (loadingText != null) ...[
          const SizedBox(width: 12),
          Text(
            loadingText!,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ] else if (text.isNotEmpty) ...[
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ],
    );
  }
}

/// A floating action button with loading state
class LoadingFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const LoadingFloatingActionButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: isLoading ? null : onPressed,
      tooltip: tooltip,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(icon ?? Icons.add),
      ),
    );
  }
}

/// An icon button with loading state
class LoadingIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData icon;
  final String? tooltip;
  final Color? color;
  final double? size;

  const LoadingIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.isLoading = false,
    this.tooltip,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: isLoading ? null : onPressed,
      tooltip: tooltip,
      color: color,
      iconSize: size,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: isLoading
            ? SizedBox(
                width: (size ?? 24) * 0.8,
                height: (size ?? 24) * 0.8,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    color ?? Theme.of(context).iconTheme.color ?? Colors.grey,
                  ),
                ),
              )
            : Icon(icon),
      ),
    );
  }
}

/// A text button with loading state
class LoadingTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final String? loadingText;
  final Color? color;
  final TextStyle? textStyle;

  const LoadingTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.loadingText,
    this.color,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: isLoading
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        color ?? Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  if (loadingText != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      loadingText!,
                      style: textStyle,
                    ),
                  ],
                ],
              )
            : Text(
                text,
                style: textStyle,
              ),
      ),
    );
  }
}