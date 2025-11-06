import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

import '../balloon_twist_game.dart';
import 'plane_player.dart';
import '../../core/constants/game_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/audio/audio_manager.dart';

typedef BalloonPlayer = PlanePlayer;

/// Types of collectibles in the game
enum CollectibleType {
  airRing,          // Awards tokens
  pressureBooster,  // Increases pressure
  timeSlower,       // Slows game temporarily
}

/// Collectible component that awards bonuses when collected
class Collectible extends PositionComponent with HasGameRef<AviaRollHighGame>, CollisionCallbacks {
  final CollectibleType type;
  
  Collectible({
    required Vector2 position,
    required this.type,
  }) : super(
          position: position,
          size: Vector2.all(40),
          anchor: Anchor.center,
        );

  bool _isCollected = false;
  double _floatAnimation = 0;
  double _rotationAngle = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Add collision detection
    add(CircleHitbox(radius: 20));
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (_isCollected) return;
    
    // Floating animation
    _floatAnimation += dt * 2;
    
    // Rotate collectible
    _rotationAngle += dt * 3;
    
    // Move collectible down (relative to game speed)
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
    
    final floatOffset = math.sin(_floatAnimation * math.pi) * 5;
    
    canvas.save();
    canvas.translate(0, floatOffset);
    canvas.rotate(_rotationAngle);
    
    // Draw collectible based on type
    switch (type) {
      case CollectibleType.airRing:
        _drawAirRing(canvas);
        break;
      case CollectibleType.pressureBooster:
        _drawPressureBooster(canvas);
        break;
      case CollectibleType.timeSlower:
        _drawTimeSlower(canvas);
        break;
    }
    
    canvas.restore();
  }

  void _drawAirRing(Canvas canvas) {
    // Outer glow
    final glowPaint = Paint()
      ..color = AppColors.airRing.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    
    canvas.drawCircle(Offset.zero, 25, glowPaint);
    
    // Ring
    final ringPaint = Paint()
      ..color = AppColors.airRing
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    
    canvas.drawCircle(Offset.zero, 18, ringPaint);
    
    // Inner sparkle
    final sparklePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset.zero, 3, sparklePaint);
  }

  void _drawPressureBooster(Canvas canvas) {
    // Outer glow
    final glowPaint = Paint()
      ..color = AppColors.pressureBooster.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    
    canvas.drawCircle(Offset.zero, 25, glowPaint);
    
    // Main circle
    final circlePaint = Paint()
      ..color = AppColors.pressureBooster
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset.zero, 18, circlePaint);
    
    // Plus symbol
    final symbolPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    
    canvas.drawLine(const Offset(0, -10), const Offset(0, 10), symbolPaint);
    canvas.drawLine(const Offset(-10, 0), const Offset(10, 0), symbolPaint);
  }

  void _drawTimeSlower(Canvas canvas) {
    // Outer glow
    final glowPaint = Paint()
      ..color = AppColors.timeSlower.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    
    canvas.drawCircle(Offset.zero, 25, glowPaint);
    
    // Main circle
    final circlePaint = Paint()
      ..color = AppColors.timeSlower
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset.zero, 18, circlePaint);
    
    // Clock hands
    final handPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    
    // Hour hand (short)
    canvas.drawLine(Offset.zero, const Offset(0, -8), handPaint);
    
    // Minute hand (long)
    canvas.drawLine(Offset.zero, const Offset(10, 0), handPaint);
    
    // Center dot
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset.zero, 2, dotPaint);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    
    if (_isCollected || other is! BalloonPlayer) return;
    
    _isCollected = true;
    
    // Apply collectible effect
    switch (type) {
      case CollectibleType.airRing:
        gameRef.addScore(GameConstants.airRingTokenValue.toDouble());
        gameRef.playSoundEffect(SoundEffect.collectRing);
        gameRef.spawnBurstEffect(position, color: AppColors.airRing, particleCount: 10);
        debugPrint('💰 Collected Air Ring! +${GameConstants.airRingTokenValue} tokens');
        break;
        
      case CollectibleType.pressureBooster:
        other.addPressure(20.0);
        gameRef.playSoundEffect(SoundEffect.collectBooster);
        gameRef.spawnBurstEffect(position, color: AppColors.pressureBooster, particleCount: 15);
        debugPrint('⚡ Fuel Booster! +20% fuel');
        break;
        
      case CollectibleType.timeSlower:
        // TODO: Implement time slower effect in game manager
        gameRef.playSoundEffect(SoundEffect.collectSlower);
        gameRef.spawnBurstEffect(position, color: AppColors.timeSlower, particleCount: 12);
        debugPrint('⏰ Time Slower collected!');
        break;
    }
    
    removeFromParent();
  }
}
