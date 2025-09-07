// File: lib/widgets/common/accessible_widgets.dart
// Purpose: Accessibility-enhanced widgets for better user experience
// Step: 12.7 - Final UI Polish and Accessibility Improvements

import 'package:flutter/material.dart';
import '../../services/accessibility_service.dart';

/// An accessible button with enhanced touch targets and feedback
class AccessibleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final String? tooltip;
  final bool autofocus;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? minHeight;
  final double? minWidth;
  final BorderRadius? borderRadius;

  const AccessibleButton({
    super.key,
    required this.child,
    this.onPressed,
    this.semanticLabel,
    this.tooltip,
    this.autofocus = false,
    this.padding,
    this.backgroundColor,
    this.foregroundColor,
    this.minHeight,
    this.minWidth,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final accessibilityService = AccessibilityService();
    
    // Ensure minimum touch target size (44x44 logical pixels)
    const double minTouchTarget = 44.0;
    final double effectiveMinHeight = minHeight ?? minTouchTarget;
    final double effectiveMinWidth = minWidth ?? minTouchTarget;
    
    Widget button = ElevatedButton(
      onPressed: onPressed != null
          ? () {
              // Provide haptic feedback
              accessibilityService.provideFeedback(HapticFeedbackType.selectionClick);
              onPressed!();
            }
          : null,
      autofocus: autofocus,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: padding ?? const EdgeInsets.all(12),
        minimumSize: Size(effectiveMinWidth, effectiveMinHeight),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
      child: child,
    );

    // Add semantic information
    if (semanticLabel != null) {
      button = Semantics(
        label: semanticLabel,
        button: true,
        enabled: onPressed != null,
        child: button,
      );
    }

    // Add tooltip if provided
    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}

/// An accessible text input with enhanced focus management
class AccessibleTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final String? semanticLabel;
  final bool autofocus;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLines;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool required;

  const AccessibleTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.semanticLabel,
    this.autofocus = false,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    final accessibilityService = AccessibilityService();
    final theme = Theme.of(context);
    
    // Build semantic label
    String effectiveSemanticLabel = semanticLabel ?? '';
    if (effectiveSemanticLabel.isEmpty) {
      effectiveSemanticLabel = labelText ?? hintText ?? 'Text input';
    }
    if (required) {
      effectiveSemanticLabel += ', required';
    }
    if (errorText != null) {
      effectiveSemanticLabel += ', error: $errorText';
    }
    if (helperText != null) {
      effectiveSemanticLabel += ', $helperText';
    }

    return Semantics(
      label: effectiveSemanticLabel,
      textField: true,
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        keyboardType: keyboardType,
        obscureText: obscureText,
        maxLines: maxLines,
        onTap: onTap != null
            ? () {
                accessibilityService.provideFeedback(HapticFeedbackType.selectionClick);
                onTap!();
              }
            : null,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        style: TextStyle(
          fontSize: accessibilityService.largeTextEnabled ? 18 : 16,
          fontWeight: accessibilityService.screenReaderOptimized 
              ? FontWeight.w600 
              : FontWeight.normal,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          helperText: helperText,
          errorText: errorText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              width: accessibilityService.highContrastEnabled ? 2.0 : 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: theme.primaryColor,
              width: accessibilityService.highContrastEnabled ? 3.0 : 2.0,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: theme.colorScheme.error,
              width: accessibilityService.highContrastEnabled ? 3.0 : 2.0,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}

/// An accessible card with proper semantic information
class AccessibleCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final bool selected;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const AccessibleCard({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.selected = false,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final accessibilityService = AccessibilityService();
    final theme = Theme.of(context);
    
    Widget card = Card(
      margin: margin ?? const EdgeInsets.all(8),
      elevation: accessibilityService.reducedMotionEnabled ? 2 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: selected || accessibilityService.highContrastEnabled
            ? BorderSide(
                color: selected 
                    ? theme.primaryColor
                    : theme.dividerColor,
                width: selected ? 2.0 : 1.0,
              )
            : BorderSide.none,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );

    if (onTap != null) {
      card = InkWell(
        onTap: () {
          accessibilityService.provideFeedback(HapticFeedbackType.lightImpact);
          onTap!();
        },
        borderRadius: BorderRadius.circular(8),
        child: card,
      );
    }

    if (semanticLabel != null) {
      card = Semantics(
        label: semanticLabel,
        button: onTap != null,
        selected: selected,
        child: card,
      );
    }

    return card;
  }
}

/// An accessible list tile with enhanced touch targets
class AccessibleListTile extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final bool selected;
  final bool enabled;

  const AccessibleListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.semanticLabel,
    this.selected = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final accessibilityService = AccessibilityService();
    
    Widget listTile = ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      selected: selected,
      enabled: enabled,
      minVerticalPadding: 16, // Ensure adequate touch target
      onTap: onTap != null && enabled
          ? () {
              accessibilityService.provideFeedback(HapticFeedbackType.selectionClick);
              onTap!();
            }
          : null,
    );

    if (semanticLabel != null) {
      listTile = Semantics(
        label: semanticLabel,
        button: onTap != null,
        selected: selected,
        enabled: enabled,
        child: listTile,
      );
    }

    return listTile;
  }
}

/// An accessible icon button with enhanced touch target
class AccessibleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final String? semanticLabel;
  final Color? color;
  final double? size;
  final bool autofocus;

  const AccessibleIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.semanticLabel,
    this.color,
    this.size,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final accessibilityService = AccessibilityService();
    
    Widget button = IconButton(
      icon: Icon(icon),
      onPressed: onPressed != null
          ? () {
              accessibilityService.provideFeedback(HapticFeedbackType.lightImpact);
              onPressed!();
            }
          : null,
      tooltip: tooltip,
      color: color,
      iconSize: size ?? 24,
      autofocus: autofocus,
      constraints: const BoxConstraints(
        minWidth: 44,
        minHeight: 44,
      ),
    );

    if (semanticLabel != null) {
      button = Semantics(
        label: semanticLabel,
        button: true,
        enabled: onPressed != null,
        child: button,
      );
    }

    return button;
  }
}

/// A skip link for keyboard navigation
class SkipLink extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final FocusNode? focusNode;

  const SkipLink({
    super.key,
    required this.text,
    required this.onPressed,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -100, // Hidden by default
      left: 16,
      child: Focus(
        focusNode: focusNode,
        onFocusChange: (hasFocus) {
          // Show when focused for keyboard navigation
        },
        child: ElevatedButton(
          onPressed: onPressed,
          child: Text(text),
        ),
      ),
    );
  }
}

/// A focus trap widget for modal dialogs
class FocusTrap extends StatefulWidget {
  final Widget child;
  final bool active;

  const FocusTrap({
    super.key,
    required this.child,
    this.active = true,
  });

  @override
  State<FocusTrap> createState() => _FocusTrapState();
}

class _FocusTrapState extends State<FocusTrap> {
  late final FocusNode _firstFocusNode;
  late final FocusNode _lastFocusNode;

  @override
  void initState() {
    super.initState();
    _firstFocusNode = FocusNode();
    _lastFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _firstFocusNode.dispose();
    _lastFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) {
      return widget.child;
    }

    return FocusScope(
      child: Column(
        children: [
          Focus(
            focusNode: _firstFocusNode,
            onKey: (node, event) {
              // Trap focus by moving to last element when shift+tab on first
              if (event.isShiftPressed) {
                _lastFocusNode.requestFocus();
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: const SizedBox.shrink(),
          ),
          Expanded(child: widget.child),
          Focus(
            focusNode: _lastFocusNode,
            onKey: (node, event) {
              // Trap focus by moving to first element when tab on last
              if (!event.isShiftPressed) {
                _firstFocusNode.requestFocus();
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

/// An accessible progress indicator with semantic information
class AccessibleProgressIndicator extends StatelessWidget {
  final double? value;
  final String? semanticLabel;
  final String? progressDescription;

  const AccessibleProgressIndicator({
    super.key,
    this.value,
    this.semanticLabel,
    this.progressDescription,
  });

  @override
  Widget build(BuildContext context) {
    final accessibilityService = AccessibilityService();
    
    String effectiveLabel = semanticLabel ?? 'Progress indicator';
    if (value != null) {
      final percentage = (value! * 100).round();
      effectiveLabel += ', $percentage percent complete';
    }
    if (progressDescription != null) {
      effectiveLabel += ', $progressDescription';
    }

    Widget indicator = value != null
        ? LinearProgressIndicator(
            value: value,
            minHeight: accessibilityService.largeTextEnabled ? 8 : 4,
          )
        : LinearProgressIndicator(
            minHeight: accessibilityService.largeTextEnabled ? 8 : 4,
          );

    return Semantics(
      label: effectiveLabel,
      value: value != null ? '${(value! * 100).round()}%' : null,
      child: indicator,
    );
  }
}

/// Mixin to add accessibility helpers to widgets
mixin AccessibilityMixin<T extends StatefulWidget> on State<T> {
  late final AccessibilityService _accessibilityService;
  
  @override
  void initState() {
    super.initState();
    _accessibilityService = AccessibilityService();
  }
  
  /// Provide haptic feedback
  void provideFeedback(HapticFeedbackType type) {
    _accessibilityService.provideFeedback(type);
  }
  
  /// Get animation duration based on accessibility settings
  Duration getAnimationDuration(Duration original) {
    return _accessibilityService.getAnimationDuration(original);
  }
  
  /// Check if reduced motion is enabled
  bool get isReducedMotionEnabled => _accessibilityService.reducedMotionEnabled;
  
  /// Check if high contrast is enabled
  bool get isHighContrastEnabled => _accessibilityService.highContrastEnabled;
  
  /// Check if large text is enabled
  bool get isLargeTextEnabled => _accessibilityService.largeTextEnabled;
  
  /// Check if screen reader optimization is enabled
  bool get isScreenReaderOptimized => _accessibilityService.screenReaderOptimized;
}