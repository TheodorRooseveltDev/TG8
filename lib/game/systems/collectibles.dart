import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/game_constants.dart';
import '../balloon_twist_game.dart';
import 'dart:math' as math;

/// Base collectible class
abstract class Collectible extends PositionComponent with HasGameRef<AviaRollHighGame>, CollisionCallbacks {
  Collectible({
    required Vector2 position,
    required this.value,
  }) : super(
          position: position,
          anchor: Anchor.center,
        );

  final int value;
  bool _isCollected = false;
  double _floatAnimation = 0.0;

  @override
  void update(double dt) {
    super.update(dt);
    
    // Move down relative to world
    position.y += gameRef.gameSpeed * dt;
    
    // Floating animation
    _floatAnimation += dt * 2;
    
    // Remove if off screen
    if (position.y > gameRef.size.y + 100) {
      removeFromParent();
    }
  }

  bool get isCollected => _isCollected;

  void collect() {
    if (_isCollected) return;
    _isCollected = true;
    onCollected();
    removeFromParent();
  }

  void onCollected();
}

/// Air ring collectible (gives tokens)
class AirRing extends Collectible {
  AirRing({
    required Vector2 position,
  }) : super(
          position: position,
          value: GameConstants.airRingTokenValue,
        ) {
    size = Vector2.all(50);
  }

  SpriteComponent? _sprite;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    try {
      final sprite = await gameRef.loadSprite('collectibles/air_ring.png');
      _sprite = SpriteComponent(
        sprite: sprite,
        size: size,
        anchor: Anchor.center,
      );
      add(_sprite!);
    } catch (e) {
      debugPrint('⚠️ Failed to load air ring sprite: $e');
    }

    add(CircleHitbox(radius: size.x / 2));
  }

  @override
  void onCollected() {
    gameRef.addScore(value.toDouble());
    debugPrint('💍 Collected Air Ring! +$value tokens');
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Apply floating offset
    final floatOffset = math.sin(_floatAnimation) * 5;
    canvas.save();
    canvas.translate(0, floatOffset);
    
    if (_sprite == null) {
      // Draw ring
      final paint = Paint()
        ..color = AppColors.airRing
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6;
      
      canvas.drawCircle(Offset.zero, size.x / 2, paint);
    }
    
    canvas.restore();
  }
}

/// Fuel booster collectible (increases aircraft fuel temporarily)
class PressureBooster extends Collectible {
  PressureBooster({
    required Vector2 position,
  }) : super(
          position: position,
          value: 20,
        ) {
    size = Vector2.all(45);
  }

  SpriteComponent? _sprite;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    try {
      final sprite = await gameRef.loadSprite('collectibles/pressure_booster.png');
      _sprite = SpriteComponent(
        sprite: sprite,
        size: size,
        anchor: Anchor.center,
      );
      add(_sprite!);
    } catch (e) {
      debugPrint('⚠️ Failed to load fuel booster sprite: $e');
    }

    add(CircleHitbox(radius: size.x / 2));
  }

  @override
  void onCollected() {
    gameRef.addScore(value.toDouble());
    debugPrint('⚡ Collected Fuel Booster!');
    // TODO: Apply booster effect to aircraft
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final floatOffset = math.sin(_floatAnimation) * 5;
    canvas.save();
    canvas.translate(0, floatOffset);
    
    if (_sprite == null) {
      final paint = Paint()
        ..color = AppColors.pressureBooster
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset.zero, size.x / 2, paint);
      
      // Draw + symbol
      final plusPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      
      canvas.drawLine(const Offset(-10, 0), const Offset(10, 0), plusPaint);
      canvas.drawLine(const Offset(0, -10), const Offset(0, 10), plusPaint);
    }
    
    canvas.restore();
  }
}

/// Time slower collectible (slows game temporarily)
class TimeSlower extends Collectible {
  TimeSlower({
    required Vector2 position,
  }) : super(
          position: position,
          value: 15,
        ) {
    size = Vector2.all(40);
  }

  SpriteComponent? _sprite;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    try {
      final sprite = await gameRef.loadSprite('collectibles/time_slower.png');
      _sprite = SpriteComponent(
        sprite: sprite,
        size: size,
        anchor: Anchor.center,
      );
      add(_sprite!);
    } catch (e) {
      debugPrint('⚠️ Failed to load time slower sprite: $e');
    }

    add(CircleHitbox(radius: size.x / 2));
  }

  @override
  void onCollected() {
    gameRef.addScore(value.toDouble());
    debugPrint('⏰ Collected Time Slower!');
    // TODO: Apply slow-mo effect
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final floatOffset = math.sin(_floatAnimation) * 5;
    canvas.save();
    canvas.translate(0, floatOffset);
    
    if (_sprite == null) {
      final paint = Paint()
        ..color = AppColors.timeSlower
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset.zero, size.x / 2, paint);
      
      // Draw clock symbol
      final clockPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      
      canvas.drawCircle(Offset.zero, 12, clockPaint);
      canvas.drawLine(Offset.zero, const Offset(0, -8), clockPaint);
      canvas.drawLine(Offset.zero, const Offset(6, 0), clockPaint);
    }
    
    canvas.restore();
  }
}
