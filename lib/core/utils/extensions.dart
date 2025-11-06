import 'package:flutter/material.dart';

/// Extension methods for adding helpful functionality to existing types
extension DoubleExtensions on double {
  /// Clamp this value between min and max
  double clamp(double min, double max) {
    return this < min ? min : (this > max ? max : this);
  }

  /// Format this number as a score with commas
  String toScoreString() {
    return toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// Format this number as a distance with units
  String toDistanceString() {
    if (this < 1000) {
      return '${toStringAsFixed(0)}m';
    } else if (this < 10000) {
      return '${(this / 1000).toStringAsFixed(1)}km';
    } else {
      return '${(this / 1000).toStringAsFixed(0)}km';
    }
  }
}

extension IntExtensions on int {
  /// Format this number as a score with commas
  String toScoreString() {
    return toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

extension ColorExtensions on Color {
  /// Lighten this color by a given percentage
  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  /// Darken this color by a given percentage
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  /// Get a complementary color
  Color get complementary {
    final hsl = HSLColor.fromColor(this);
    final hue = (hsl.hue + 180) % 360;
    return hsl.withHue(hue).toColor();
  }
}

extension StringExtensions on String {
  /// Capitalize first letter of each word
  String capitalize() {
    if (isEmpty) return this;
    return split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Capitalize only first letter
  String capitalizeFirst() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

extension DurationExtensions on Duration {
  /// Format duration as MM:SS
  String toMMSS() {
    final minutes = inMinutes.toString().padLeft(2, '0');
    final seconds = (inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Format duration as HH:MM:SS if hours > 0, otherwise MM:SS
  String toTimeString() {
    if (inHours > 0) {
      final hours = inHours.toString().padLeft(2, '0');
      final minutes = (inMinutes % 60).toString().padLeft(2, '0');
      final seconds = (inSeconds % 60).toString().padLeft(2, '0');
      return '$hours:$minutes:$seconds';
    } else {
      return toMMSS();
    }
  }
}
