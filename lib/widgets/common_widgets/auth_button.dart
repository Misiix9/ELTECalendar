// File: lib/widgets/common_widgets/auth_button.dart
// Purpose: Custom button widget for authentication screens
// Step: 2.2 - Common Widgets for Authentication

import 'package:flutter/material.dart';
import '../../config/theme_config.dart';

/// Custom authentication button with consistent styling and loading states
class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;
  final bool hasBorder;
  final double? width;
  final double height;

  const AuthButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor = ThemeConfig.primaryDarkBlue,
    this.textColor = ThemeConfig.lightBackground,
    this.icon,
    this.hasBorder = false,
    this.width,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          disabledBackgroundColor: backgroundColor.withOpacity(0.6),
          disabledForegroundColor: textColor.withOpacity(0.6),
          elevation: hasBorder ? 0 : 2,
          shadowColor: backgroundColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: hasBorder
                ? BorderSide(
                    color: ThemeConfig.primaryDarkBlue.withOpacity(0.2),
                    width: 1.5,
                  )
                : BorderSide.none,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon!,
                      size: 20,
                      color: textColor,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Outline button variant for secondary actions
class AuthOutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color borderColor;
  final Color textColor;
  final IconData? icon;
  final double? width;
  final double height;

  const AuthOutlineButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.borderColor = ThemeConfig.primaryDarkBlue,
    this.textColor = ThemeConfig.primaryDarkBlue,
    this.icon,
    this.width,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor,
          disabledForegroundColor: textColor.withOpacity(0.6),
          side: BorderSide(
            color: isLoading ? borderColor.withOpacity(0.6) : borderColor,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon!,
                      size: 20,
                      color: textColor,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Text button variant for tertiary actions
class AuthTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color textColor;
  final bool isUnderlined;

  const AuthTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.textColor = ThemeConfig.primaryDarkBlue,
    this.isUnderlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor,
          decoration: isUnderlined ? TextDecoration.underline : null,
        ),
      ),
    );
  }
}

/// Floating action button variant for main actions
class AuthFloatingButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color backgroundColor;
  final Color iconColor;

  const AuthFloatingButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.backgroundColor = ThemeConfig.goldAccent,
    this.iconColor = ThemeConfig.darkTextElements,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: backgroundColor,
      foregroundColor: iconColor,
      elevation: 4,
      shape: const CircleBorder(),
      child: Icon(
        icon,
        size: 24,
      ),
    );
  }
}