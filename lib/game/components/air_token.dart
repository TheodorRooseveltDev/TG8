import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../balloon_twist_game.dart';
import '../../core/audio/audio_manager.dart';

/// FIXED: Air Token collectible - actual currency that can be spent
class AirToken extends SpriteComponent with HasGameRef<AviaRollHighGame>, CollisionCallbacks {
  AirToken({
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2.all(30),
          anchor: Anchor.center,
        );

  bool _collected = false;
  double _floatOffset = 0;
  final int tokenValue = 10; // Each token worth 10 air tokens

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox());
    
    try {
      sprite = await gameRef.loadSprite('collectibles/air_token.png');
    } catch (e) {
      // Will use fallback rendering
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Float animation
    _floatOffset += dt * 3;
    final float = math.sin(_floatOffset) * 8;
    
    // Move down with game speed
    position.y += gameRef.gameSpeed * dt;
    
    // Apply float offset
    position.y += float * dt;
    
    // Gentle rotation
    angle = math.sin(_floatOffset) * 0.3;
    
    // Remove if off screen
    if (position.y > gameRef.size.y + size.y) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    
    if (!_collected && other.toString().contains('BalloonPlayer')) {
      _collected = true;
      collect();
    }
  }

  void collect() {
    debugPrint('💰 Collected Air Token! +$tokenValue tokens');
    
    // Add tokens to game
    gameRef.addAirTokens(tokenValue);
    
    // Add small score bonus
    gameRef.addScore(25);
    
    // Play sound
    gameRef.playSoundEffect(SoundEffect.collectRing);
    
    // Spawn particles
    gameRef.spawnBurstEffect(position, color: Colors.amber, particleCount: 10);
    
    // Remove from game
    removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    if (sprite == null) {
      // Draw golden coin placeholder
      final paint = Paint()
        ..color = const Color(0xFFFFD700) // Gold
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset.zero, size.x / 2, paint);
      
      // Inner circle
      final innerPaint = Paint()
        ..color = const Color(0xFFFFEB3B) // Brighter gold
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset.zero, size.x / 3, innerPaint);
      
      // Outline
      final outlinePaint = Paint()
        ..color = const Color(0xFFFF8F00) // Orange gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      
      canvas.drawCircle(Offset.zero, size.x / 2, outlinePaint);
    } else {
      super.render(canvas);
    }
  }
}
