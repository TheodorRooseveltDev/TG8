import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

import '../balloon_twist_game.dart';
import '../../core/constants/game_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/audio/audio_manager.dart';
import 'plane_player.dart';

typedef BalloonPlayer = PlanePlayer;

/// Checkpoint that refills air and resets pressure
class Checkpoint extends PositionComponent with HasGameRef<AviaRollHighGame>, CollisionCallbacks {
  Checkpoint({
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2.all(80),
          anchor: Anchor.center,
        );

  bool _isCollected = false;
  double _rotationAngle = 0;
  double _pulseAnimation = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Add collision detection
    add(CircleHitbox(radius: 40));
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (_isCollected) return;
    
    // Rotate checkpoint
    _rotationAngle += dt * 2;
    
    // Pulse animation
    _pulseAnimation += dt * 3;
    
    // Move checkpoint down (relative to game speed)
    position.y += gameRef.gameSpeed * dt;
    
    // Remove if off-screen
    if (position.y > gameRef.size.y + 100) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    if (_isCollected) return;
    
    final pulse = 1.0 + math.sin(_pulseAnimation * math.pi) * 0.1;
    
    // Draw outer glow
    final glowPaint = Paint()
      ..color = AppColors.airRing.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    
    canvas.drawCircle(Offset.zero, 45 * pulse, glowPaint);
    
    // Draw main circle
    final mainPaint = Paint()
      ..color = AppColors.airRing
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    
    canvas.drawCircle(Offset.zero, 35 * pulse, mainPaint);
    
    // Draw rotating fan blades
    canvas.save();
    canvas.rotate(_rotationAngle);
    
    final bladePaint = Paint()
      ..color = AppColors.accentAmber
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    
    for (int i = 0; i < 4; i++) {
      final angle = (i * 90) * math.pi / 180;
      canvas.drawLine(
        Offset.zero,
        Offset(math.cos(angle) * 30, math.sin(angle) * 30),
        bladePaint,
      );
    }
    
    canvas.restore();
    
    // Draw center icon
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset.zero, 8, centerPaint);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    
    if (_isCollected) return;
    
    _isCollected = true;
    
    // Award bonus points
    gameRef.addScore(GameConstants.checkpointBonus.toDouble());
    
    // Refill aircraft fuel
    if (other is BalloonPlayer) {
      other.resetPressure();
      debugPrint('✨ Checkpoint collected! Fuel restored, +${GameConstants.checkpointBonus} points');
    }
    
    // Visual and audio feedback
    gameRef.spawnBurstEffect(position, color: AppColors.airRing, particleCount: 15);
    gameRef.playSoundEffect(SoundEffect.checkpoint);
    gameRef.triggerScreenShake(intensity: 5, duration: 0.2);
    
    removeFromParent();
  }
}
