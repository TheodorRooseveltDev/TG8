import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../balloon_twist_game.dart';
import '../../core/constants/app_colors.dart';

/// Distance counter HUD element
class DistanceCounter extends PositionComponent with HasGameRef<AviaRollHighGame> {
  DistanceCounter({
    required Vector2 position,
  }) : super(
          position: position,
          anchor: Anchor.topLeft,
        );

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final distance = gameRef.distanceTraveled;
    final distanceText = '${distance.toInt()}m';

    // Draw background
    final bgPaint = Paint()
      ..color = AppColors.primaryBrass.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      text: TextSpan(
        text: distanceText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // Draw rounded rect background
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(-8, -8, textPainter.width + 16, textPainter.height + 16),
      const Radius.circular(12),
    );

    canvas.drawRRect(bgRect, bgPaint);

    // Draw border
    final borderPaint = Paint()
      ..color = AppColors.accentAmber
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(bgRect, borderPaint);

    // Draw text
    textPainter.paint(canvas, const Offset(0, 0));

    // Draw altitude icon
    final iconPainter = TextPainter(
      text: const TextSpan(
        text: '↑',
        style: TextStyle(
          color: AppColors.accentAmber,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(-iconPainter.width - 4, 0),
    );
  }
}
