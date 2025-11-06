import 'package:flutter/material.dart';

/// App Color Scheme - 60:30:10 Steampunk-Saloon Aesthetic
/// Primary (60%): Brass Gold
/// Secondary (30%): Dark Wood
/// Accent (10%): Glowing Amber
class AppColors {
  AppColors._();

  // Primary Color (60% usage) - Brass Gold
  static const Color primary = Color(0xFFB8860B);
  static const Color primaryBrass = Color(0xFFB8860B); // Alias for consistency
  static const Color primaryLight = Color(0xFFDAA520);
  static const Color primaryDark = Color(0xFF8B6914);
  static const Color primaryVeryLight = Color(0xFFFFD700);

  // Secondary Color (30% usage) - Dark Wood
  static const Color secondary = Color(0xFF3E2723);
  static const Color secondaryWood = Color(0xFF3E2723); // Alias for consistency
  static const Color secondaryLight = Color(0xFF6A4F4B);
  static const Color secondaryDark = Color(0xFF1B0000);
  static const Color woodGrain = Color(0xFF5D4037);

  // Accent Color (10% usage) - Glowing Amber
  static const Color accent = Color(0xFFFFA726);
  static const Color accentAmber = Color(0xFFFFA726); // Alias for consistency
  static const Color accentLight = Color(0xFFFFB74D);
  static const Color accentDark = Color(0xFFF57C00);
  static const Color accentGlow = Color(0xFFFFCC80);

  // Fuel Gauge Colors (Aviation Theme)
  static const Color fuelLow = Color(0xFF2196F3); // Blue - low fuel warning
  static const Color fuelOptimal = Color(0xFF4CAF50); // Green - optimal fuel range
  static const Color fuelHigh = Color(0xFFFFEB3B); // Yellow - high speed warning
  static const Color fuelWarning = Color(0xFFFFEB3B); // Yellow - alias
  static const Color fuelDanger = Color(0xFFF44336); // Red - danger zone
  static const Color fuelCritical = Color(0xFFD32F2F); // Dark Red - critical speed
  
  // Legacy pressure color aliases (deprecated - use fuel colors)
  @Deprecated('Use fuelLow instead')
  static const Color pressureLow = fuelLow;
  @Deprecated('Use fuelOptimal instead')
  static const Color pressureOptimal = fuelOptimal;
  @Deprecated('Use fuelHigh instead')
  static const Color pressureHigh = fuelHigh;
  @Deprecated('Use fuelWarning instead')
  static const Color pressureWarning = fuelWarning;
  @Deprecated('Use fuelDanger instead')
  static const Color pressureDanger = fuelDanger;
  @Deprecated('Use fuelCritical instead')
  static const Color pressureCritical = fuelCritical;

  // UI Colors
  static const Color background = Color(0xFF1A1A1A);
  static const Color backgroundLight = Color(0xFF2A2A2A);
  static const Color surface = Color(0xFF2C2C2C);
  static const Color surfaceLight = Color(0xFF3C3C3C);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textDisabled = Color(0xFF6A6A6A);
  static const Color textAccent = accent;

  // Game Colors
  static const Color windCurrent = Color(0x4DBBDEFB); // Translucent blue
  static const Color thermal = Color(0x4DFF9800); // Translucent orange
  static const Color electricArc = Color(0xFFE1BEE7); // Purple
  static const Color dustCloud = Color(0x80A1887F); // Gray translucent

  // Collectible Colors  
  static const Color fuelRing = Color(0xFF81D4FA); // Fuel ring collectible
  static const Color speedBooster = Color(0xFFFF6E40); // Speed boost collectible
  static const Color timeSlower = Color(0xFF9575CD); // Time slower collectible
  static const Color airToken = primaryLight; // Currency token
  
  // Legacy collectible aliases (deprecated)
  @Deprecated('Use fuelRing instead')
  static const Color airRing = fuelRing;
  @Deprecated('Use speedBooster instead')
  static const Color pressureBooster = speedBooster;

  // Biome Colors
  static const Color biomeTavern = Color(0xFF6A4F4B);
  static const Color biomeSky = Color(0xFF42A5F5);
  static const Color biomeStratosphere = Color(0xFF1976D2);
  static const Color biomeMesosphere = Color(0xFF0D47A1);
  static const Color biomeSpace = Color(0xFF0A0E27);

  // Special Effects
  static const Color glow = Color(0xFFFFE082);
  static const Color shadow = Color(0x80000000);
  static const Color highlight = Color(0x40FFFFFF);
  static const Color overlay = Color(0x99000000);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
}
