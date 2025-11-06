import 'dart:math' as math;

/// Math utility functions for game calculations
class MathUtils {
  MathUtils._();

  /// Clamp a value between min and max
  static double clamp(double value, double min, double max) {
    return value < min ? min : (value > max ? max : value);
  }

  /// Linear interpolation between two values
  static double lerp(double a, double b, double t) {
    return a + (b - a) * t;
  }

  /// Map a value from one range to another
  static double mapRange(
    double value,
    double inMin,
    double inMax,
    double outMin,
    double outMax,
  ) {
    return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
  }

  /// Calculate distance between two points
  static double distance(double x1, double y1, double x2, double y2) {
    final dx = x2 - x1;
    final dy = y2 - y1;
    return math.sqrt(dx * dx + dy * dy);
  }

  /// Calculate angle between two points
  static double angleBetween(double x1, double y1, double x2, double y2) {
    return math.atan2(y2 - y1, x2 - x1);
  }

  /// Normalize an angle to be between 0 and 2π
  static double normalizeAngle(double angle) {
    var result = angle % (2 * math.pi);
    if (result < 0) result += 2 * math.pi;
    return result;
  }

  /// Convert degrees to radians
  static double degToRad(double degrees) {
    return degrees * math.pi / 180;
  }

  /// Convert radians to degrees
  static double radToDeg(double radians) {
    return radians * 180 / math.pi;
  }

  /// Ease in cubic
  static double easeInCubic(double t) {
    return t * t * t;
  }

  /// Ease out cubic
  static double easeOutCubic(double t) {
    return 1 - math.pow(1 - t, 3).toDouble();
  }

  /// Ease in out cubic
  static double easeInOutCubic(double t) {
    return t < 0.5 ? 4 * t * t * t : 1 - math.pow(-2 * t + 2, 3).toDouble() / 2;
  }

  /// Ease in elastic
  static double easeInElastic(double t) {
    const c4 = (2 * math.pi) / 3;
    return t == 0
        ? 0
        : t == 1
            ? 1
            : -math.pow(2, 10 * t - 10) * math.sin((t * 10 - 10.75) * c4);
  }

  /// Ease out elastic
  static double easeOutElastic(double t) {
    const c4 = (2 * math.pi) / 3;
    return t == 0
        ? 0
        : t == 1
            ? 1
            : math.pow(2, -10 * t) * math.sin((t * 10 - 0.75) * c4) + 1;
  }

  /// Random double between min and max
  static double randomRange(double min, double max) {
    return min + math.Random().nextDouble() * (max - min);
  }

  /// Random int between min and max (inclusive)
  static int randomInt(int min, int max) {
    return min + math.Random().nextInt(max - min + 1);
  }

  /// Random boolean
  static bool randomBool() {
    return math.Random().nextBool();
  }

  /// Check if two circles collide
  static bool circleCollision(
    double x1,
    double y1,
    double r1,
    double x2,
    double y2,
    double r2,
  ) {
    final dist = distance(x1, y1, x2, y2);
    return dist < r1 + r2;
  }

  /// Check if a point is inside a circle
  static bool pointInCircle(
    double px,
    double py,
    double cx,
    double cy,
    double radius,
  ) {
    final dist = distance(px, py, cx, cy);
    return dist <= radius;
  }

  /// Check if two rectangles collide
  static bool rectCollision(
    double x1,
    double y1,
    double w1,
    double h1,
    double x2,
    double y2,
    double w2,
    double h2,
  ) {
    return x1 < x2 + w2 && x1 + w1 > x2 && y1 < y2 + h2 && y1 + h1 > y2;
  }
}
