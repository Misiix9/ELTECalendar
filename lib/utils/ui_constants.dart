// File: lib/utils/ui_constants.dart
// Purpose: UI constants and utilities for consistent design
// Step: 12.7 - Final UI Polish and Accessibility Improvements

import 'package:flutter/material.dart';

/// UI constants for consistent design throughout the app
class UIConstants {
  UIConstants._();

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // Border radius
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXl = 16.0;
  static const double radiusCircular = 50.0;

  // Elevation
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
  static const double elevationXl = 16.0;

  // Animation durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration animationXSlow = Duration(milliseconds: 800);

  // Touch targets (accessibility)
  static const double minTouchTarget = 44.0;
  static const double recommendedTouchTarget = 48.0;

  // Icon sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXl = 48.0;

  // Font sizes
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXl = 18.0;
  static const double fontSizeXxl = 20.0;

  // Line heights
  static const double lineHeightTight = 1.2;
  static const double lineHeightMedium = 1.4;
  static const double lineHeightLoose = 1.6;

  // Container constraints
  static const double maxContentWidth = 1200.0;
  static const double minDialogWidth = 280.0;
  static const double maxDialogWidth = 560.0;
  
  // Breakpoints for responsive design
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;

  // Calendar specific
  static const double calendarCellMinHeight = 40.0;
  static const double calendarHeaderHeight = 56.0;
  static const double calendarEventMinHeight = 24.0;

  // Form elements
  static const double formFieldHeight = 56.0;
  static const double buttonHeight = 48.0;
  static const double buttonMinWidth = 88.0;

  // Loading and progress
  static const double progressIndicatorSize = 24.0;
  static const double progressIndicatorStrokeWidth = 3.0;

  // Shadows
  static List<BoxShadow> get shadowLow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get shadowMedium => [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get shadowHigh => [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  // Common edge insets
  static const EdgeInsets paddingAll4 = EdgeInsets.all(spacingXs);
  static const EdgeInsets paddingAll8 = EdgeInsets.all(spacingSmall);
  static const EdgeInsets paddingAll16 = EdgeInsets.all(spacingMedium);
  static const EdgeInsets paddingAll24 = EdgeInsets.all(spacingLarge);
  static const EdgeInsets paddingAll32 = EdgeInsets.all(spacingXl);

  static const EdgeInsets paddingH8 = EdgeInsets.symmetric(horizontal: spacingSmall);
  static const EdgeInsets paddingH16 = EdgeInsets.symmetric(horizontal: spacingMedium);
  static const EdgeInsets paddingH24 = EdgeInsets.symmetric(horizontal: spacingLarge);

  static const EdgeInsets paddingV8 = EdgeInsets.symmetric(vertical: spacingSmall);
  static const EdgeInsets paddingV16 = EdgeInsets.symmetric(vertical: spacingMedium);
  static const EdgeInsets paddingV24 = EdgeInsets.symmetric(vertical: spacingLarge);

  static const EdgeInsets marginAll8 = EdgeInsets.all(spacingSmall);
  static const EdgeInsets marginAll16 = EdgeInsets.all(spacingMedium);
  static const EdgeInsets marginAll24 = EdgeInsets.all(spacingLarge);

  // Common border radius
  static BorderRadius get borderRadiusSmall => BorderRadius.circular(radiusSmall);
  static BorderRadius get borderRadiusMedium => BorderRadius.circular(radiusMedium);
  static BorderRadius get borderRadiusLarge => BorderRadius.circular(radiusLarge);
  static BorderRadius get borderRadiusXl => BorderRadius.circular(radiusXl);

  // Common button styles
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    minimumSize: const Size(buttonMinWidth, buttonHeight),
    padding: paddingH24,
    shape: RoundedRectangleBorder(borderRadius: borderRadiusMedium),
  );

  static ButtonStyle get secondaryButtonStyle => OutlinedButton.styleFrom(
    minimumSize: const Size(buttonMinWidth, buttonHeight),
    padding: paddingH24,
    shape: RoundedRectangleBorder(borderRadius: borderRadiusMedium),
  );

  static ButtonStyle get textButtonStyle => TextButton.styleFrom(
    minimumSize: const Size(buttonMinWidth, buttonHeight),
    padding: paddingH16,
    shape: RoundedRectangleBorder(borderRadius: borderRadiusMedium),
  );

  // Input decoration
  static InputDecorationTheme get inputDecorationTheme => InputDecorationTheme(
    contentPadding: const EdgeInsets.symmetric(
      horizontal: spacingMedium,
      vertical: spacingMedium,
    ),
    border: OutlineInputBorder(
      borderRadius: borderRadiusMedium,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: borderRadiusMedium,
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: borderRadiusMedium,
      borderSide: const BorderSide(color: Colors.blue, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: borderRadiusMedium,
      borderSide: const BorderSide(color: Colors.red, width: 2),
    ),
  );

  // Card theme
  static CardTheme get cardTheme => CardTheme(
    elevation: elevationMedium,
    shape: RoundedRectangleBorder(borderRadius: borderRadiusLarge),
    margin: marginAll16,
  );

  // App bar theme
  static AppBarTheme get appBarTheme => const AppBarTheme(
    centerTitle: true,
    elevation: elevationLow,
    titleSpacing: spacingMedium,
  );
}

/// Responsive utilities for different screen sizes
class ResponsiveUtils {
  ResponsiveUtils._();

  /// Check if the screen is mobile size
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < UIConstants.mobileBreakpoint;
  }

  /// Check if the screen is tablet size
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= UIConstants.mobileBreakpoint && 
           width < UIConstants.desktopBreakpoint;
  }

  /// Check if the screen is desktop size
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= UIConstants.desktopBreakpoint;
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return UIConstants.paddingAll16;
    } else if (isTablet(context)) {
      return UIConstants.paddingAll24;
    } else {
      return UIConstants.paddingAll32;
    }
  }

  /// Get responsive content width
  static double getContentWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (isMobile(context)) {
      return screenWidth - UIConstants.spacingMedium * 2;
    } else if (isTablet(context)) {
      return (screenWidth * 0.9).clamp(0, UIConstants.maxContentWidth);
    } else {
      return UIConstants.maxContentWidth;
    }
  }

  /// Get responsive column count for grids
  static int getGridColumns(BuildContext context, {
    double itemWidth = 300,
    int minColumns = 1,
    int maxColumns = 4,
  }) {
    final width = MediaQuery.of(context).size.width;
    final availableWidth = width - UIConstants.spacingMedium * 2;
    final columns = (availableWidth / itemWidth).floor();
    return columns.clamp(minColumns, maxColumns);
  }

  /// Get responsive font size
  static double getResponsiveFontSize(
    BuildContext context,
    double baseFontSize,
  ) {
    if (isMobile(context)) {
      return baseFontSize;
    } else if (isTablet(context)) {
      return baseFontSize * 1.1;
    } else {
      return baseFontSize * 1.2;
    }
  }
}

/// Animation utilities
class AnimationUtils {
  AnimationUtils._();

  /// Create a slide transition from bottom
  static Widget slideFromBottom({
    required Widget child,
    required Animation<double> animation,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      )),
      child: child,
    );
  }

  /// Create a fade and scale transition
  static Widget fadeScale({
    required Widget child,
    required Animation<double> animation,
  }) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        )),
        child: child,
      ),
    );
  }

  /// Create a staggered animation controller
  static AnimationController createStaggeredController({
    required TickerProvider vsync,
    required int itemCount,
    Duration duration = UIConstants.animationMedium,
  }) {
    return AnimationController(
      duration: Duration(
        milliseconds: duration.inMilliseconds + (itemCount * 50),
      ),
      vsync: vsync,
    );
  }
}

/// Color utilities
class ColorUtils {
  ColorUtils._();

  /// Generate a contrasting color
  static Color getContrastingColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Darken a color
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  /// Lighten a color
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  /// Create a material color swatch from a single color
  static MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    
    for (double strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    
    return MaterialColor(color.value, swatch);
  }
}

/// Text style utilities
class TextStyleUtils {
  TextStyleUtils._();

  /// Get text style with responsive font size
  static TextStyle getResponsiveTextStyle(
    BuildContext context,
    TextStyle baseStyle,
  ) {
    final responsiveFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      baseStyle.fontSize ?? UIConstants.fontSizeMedium,
    );
    
    return baseStyle.copyWith(fontSize: responsiveFontSize);
  }

  /// Get heading text styles
  static TextStyle heading1(BuildContext context) {
    return getResponsiveTextStyle(
      context,
      const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        height: UIConstants.lineHeightTight,
      ),
    );
  }

  static TextStyle heading2(BuildContext context) {
    return getResponsiveTextStyle(
      context,
      const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        height: UIConstants.lineHeightTight,
      ),
    );
  }

  static TextStyle heading3(BuildContext context) {
    return getResponsiveTextStyle(
      context,
      const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: UIConstants.lineHeightTight,
      ),
    );
  }

  static TextStyle heading4(BuildContext context) {
    return getResponsiveTextStyle(
      context,
      const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: UIConstants.lineHeightMedium,
      ),
    );
  }

  static TextStyle bodyLarge(BuildContext context) {
    return getResponsiveTextStyle(
      context,
      const TextStyle(
        fontSize: UIConstants.fontSizeLarge,
        height: UIConstants.lineHeightMedium,
      ),
    );
  }

  static TextStyle bodyMedium(BuildContext context) {
    return getResponsiveTextStyle(
      context,
      const TextStyle(
        fontSize: UIConstants.fontSizeMedium,
        height: UIConstants.lineHeightMedium,
      ),
    );
  }

  static TextStyle caption(BuildContext context) {
    return getResponsiveTextStyle(
      context,
      TextStyle(
        fontSize: UIConstants.fontSizeSmall,
        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
        height: UIConstants.lineHeightMedium,
      ),
    );
  }
}