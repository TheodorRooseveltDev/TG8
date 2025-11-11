import 'package:flutter/material.dart';

/// Utility class for responsive design across different screen sizes
/// Especially optimized for iPad and tablet devices
class ResponsiveUtils {
  /// Get responsive font size based on screen width
  /// Base size is for phones, scales appropriately for tablets
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    
    // iPad and tablets (typically > 600px width)
    if (width > 900) {
      // Large tablets (iPad Pro, etc.)
      return baseSize * 0.7; // Reduce to 70% for large screens
    } else if (width > 600) {
      // Standard tablets/iPad
      return baseSize * 0.75; // Reduce to 75% for medium screens
    }
    
    // Phone size - return base size
    return baseSize;
  }

  /// Get responsive button width
  static double getResponsiveButtonWidth(BuildContext context, double baseWidth) {
    final width = MediaQuery.of(context).size.width;
    
    if (width > 900) {
      return baseWidth * 1.2; // Slightly larger for big tablets
    } else if (width > 600) {
      return baseWidth * 1.1; // Slightly larger for tablets
    } else if (width < 375) {
      // Small phones - make buttons smaller to fit
      return baseWidth * 0.85;
    }
    
    return baseWidth;
  }

  /// Get responsive button height
  static double getResponsiveButtonHeight(BuildContext context, double baseHeight) {
    final width = MediaQuery.of(context).size.width;
    
    if (width > 900) {
      return baseHeight * 0.9; // Slightly smaller height for big tablets
    } else if (width > 600) {
      return baseHeight * 0.95; // Slightly smaller height for tablets
    } else if (width < 375) {
      // Small phones - make buttons smaller to fit
      return baseHeight * 0.85;
    }
    
    return baseHeight;
  }

  /// Get responsive spacing
  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    final width = MediaQuery.of(context).size.width;
    
    if (width > 900) {
      return baseSpacing * 0.8; // Tighter spacing on large screens
    } else if (width > 600) {
      return baseSpacing * 0.85; // Slightly tighter on tablets
    }
    
    return baseSpacing;
  }

  /// Get responsive icon size
  static double getResponsiveIconSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    
    if (width > 900) {
      return baseSize * 0.8;
    } else if (width > 600) {
      return baseSize * 0.85;
    }
    
    return baseSize;
  }

  /// Check if device is tablet-sized
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width > 600;
  }

  /// Check if device is large tablet (iPad Pro, etc.)
  static bool isLargeTablet(BuildContext context) {
    return MediaQuery.of(context).size.width > 900;
  }

  /// Get safe horizontal padding to prevent edge overflow
  static double getSafeHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width > 900) {
      return 48.0; // More padding on large screens
    } else if (width > 600) {
      return 32.0; // Medium padding on tablets
    }
    
    return 16.0; // Standard padding on phones
  }

  /// Get safe vertical padding
  static double getSafeVerticalPadding(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    
    if (height > 1000) {
      return 32.0;
    } else if (height > 800) {
      return 24.0;
    }
    
    return 16.0;
  }

  /// Get responsive container constraints
  static BoxConstraints getResponsiveConstraints(BuildContext context, {
    double? maxWidth,
    double? minWidth,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return BoxConstraints(
      maxWidth: maxWidth ?? screenWidth * 0.9,
      minWidth: minWidth ?? 0,
    );
  }
}
