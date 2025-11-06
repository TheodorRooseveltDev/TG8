import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'plane_player.dart';
import 'dart:math' as math;

/// Visual pressure gauge that displays as a horizontal progress bar below the balloon
class PressureGauge extends PositionComponent {
  PressureGauge({
    required this.balloon,
  }) : super(
          anchor: Anchor.center,
        );

  final PlanePlayer balloon;

  // Gauge settings - horizontal bar
  static const double barWidth = 100.0;
  static const double barHeight = 8.0;
  static const double barOffsetY = 60.0; // Position below balloon
  static const double warningPulseSpeed = 2.0;

  double _pulseAnimation = 0.0;

  @override
  void update(double dt) {
    super.update(dt);

    // Follow balloon position
    position = balloon.position;

    // Pulse animation when in danger zone
    if (balloon.pressurePercent > 85) {
      _pulseAnimation += warningPulseSpeed * dt;
    } else {
      _pulseAnimation = 0;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final pressure = balloon.pressurePercent;
    final color = balloon.pressureColor;

    // Add pulse effect for critical pressure
    final pulseScale = balloon.pressurePercent > 85 
        ? 1.0 + (math.sin(_pulseAnimation * math.pi * 2) * 0.05)
        : 1.0;

    final effectiveHeight = barHeight * pulseScale;
    final effectiveWidth = barWidth * pulseScale;

    // Bar position (centered below balloon)
    final barX = -effectiveWidth / 2;
    final barY = barOffsetY;

    // Draw background bar (gray)
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(barX, barY, effectiveWidth, effectiveHeight),
      const Radius.circular(4),
    );
    canvas.drawRRect(bgRect, bgPaint);

    // Draw pressure bar (colored)
    final fillWidth = effectiveWidth * (pressure / 100);
    final pressurePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final fillRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(barX, barY, fillWidth, effectiveHeight),
      const Radius.circular(4),
    );
    canvas.drawRRect(fillRect, pressurePaint);

    // Draw border
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawRRect(bgRect, borderPaint);

    // Draw pressure percentage text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${pressure.toInt()}%',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          shadows: const [
            Shadow(
              color: Colors.black,
              offset: Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, barY + effectiveHeight + 5),
    );

    // Draw warning indicators at critical thresholds
    if (pressure > 85) {
      _drawWarningMarker(canvas, barX, barY, effectiveWidth, effectiveHeight, Colors.red);
    } else if (pressure < 15) {
      _drawWarningMarker(canvas, barX, barY, effectiveWidth, effectiveHeight, Colors.blue);
    }
  }

  void _drawWarningMarker(Canvas canvas, double x, double y, double width, double height, Color color) {
    final markerPaint = Paint()
      ..color = color.withOpacity(0.6 + math.sin(_pulseAnimation * math.pi * 4) * 0.4)
      ..style = PaintingStyle.fill;

    // Draw small warning triangles on both sides of the bar
    final leftTriangle = Path();
    leftTriangle.moveTo(x - 8, y + height / 2);
    leftTriangle.lineTo(x - 2, y);
    leftTriangle.lineTo(x - 2, y + height);
    leftTriangle.close();
    canvas.drawPath(leftTriangle, markerPaint);

    final rightTriangle = Path();
    rightTriangle.moveTo(x + width + 8, y + height / 2);
    rightTriangle.lineTo(x + width + 2, y);
    rightTriangle.lineTo(x + width + 2, y + height);
    rightTriangle.close();
    canvas.drawPath(rightTriangle, markerPaint);
  }
}
