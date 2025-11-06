import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../balloon_twist_game.dart';
import '../../core/audio/audio_manager.dart';

/// Collectible items (air rings, boosters, time slowers)
abstract class Collectible extends SpriteComponent with HasGameRef<AviaRollHighGame>, CollisionCallbacks {
  Collectible({
    required Vector2 position,
    required Vector2 size,
  }) : super(
          position: position,
          size: size,
          anchor: Anchor.center,
        );

  bool _collected = false;
  double _floatOffset = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Float animation
    _floatOffset += dt * 2;
    final float = math.sin(_floatOffset) * 5;
    
    // Move down with game speed
    position.y += gameRef.gameSpeed * dt + float * dt;
    
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
      onCollect();
      removeFromParent();
    }
  }

  void onCollect();
}

/// Air ring collectible - gives tokens
class AirRing extends Collectible {
  AirRing({
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2.all(40),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    try {
      sprite = await gameRef.loadSprite('collectibles/air_ring.png');
    } catch (e) {
      // Fallback rendering
    }
  }

  @override
  void onCollect() {
    gameRef.addScore(50); // Bonus points
  }

  @override
  void render(Canvas canvas) {
    if (sprite == null) {
      // Draw placeholder ring
      final paint = Paint()
        ..color = Colors.cyan
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      
      canvas.drawCircle(Offset.zero, size.x / 2, paint);
    } else {
      super.render(canvas);
    }
  }
}

/// Pressure booster - expands balloon temporarily
class PressureBooster extends Collectible {
  PressureBooster({
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2.all(35),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    try {
      sprite = await gameRef.loadSprite('collectibles/pressure_booster.png');
    } catch (e) {
      // Fallback rendering
    }
  }

  @override
  void onCollect() {
    debugPrint('⚡ BOOST COLLECTED!');
    gameRef.addScore(100); // Good bonus
    
    // FIXED: Actually apply boost effect
    gameRef.applyBoost();
    gameRef.playSoundEffect(SoundEffect.collectBooster);
  }

  @override
  void render(Canvas canvas) {
    if (sprite == null) {
      // Draw placeholder
      final paint = Paint()
        ..color = Colors.orange
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset.zero, size.x / 2, paint);
      
      final innerPaint = Paint()
        ..color = Colors.yellow
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset.zero, size.x / 3, innerPaint);
    } else {
      super.render(canvas);
    }
  }
}

/// Time slower - slows down game temporarily
class TimeSlower extends Collectible {
  TimeSlower({
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2.all(35),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    try {
      sprite = await gameRef.loadSprite('collectibles/time_slower.png');
    } catch (e) {
      // Fallback rendering
    }
  }

  @override
  void onCollect() {
    gameRef.addScore(40);
    // TODO: Apply time slow effect
  }

  @override
  void render(Canvas canvas) {
    if (sprite == null) {
      // Draw placeholder clock
      final paint = Paint()
        ..color = Colors.purple
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset.zero, size.x / 2, paint);
      
      // Draw clock hands
      final handPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      
      canvas.drawLine(Offset.zero, Offset(0, -size.y / 3), handPaint);
      canvas.drawLine(Offset.zero, Offset(size.x / 4, 0), handPaint);
    } else {
      super.render(canvas);
    }
  }
}
