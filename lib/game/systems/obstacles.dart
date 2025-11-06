import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../balloon_twist_game.dart';
import 'dart:math' as math;

/// Base obstacle class
abstract class Obstacle extends PositionComponent with HasGameRef<AviaRollHighGame>, CollisionCallbacks {
  Obstacle({
    required Vector2 position,
    required this.damage,
  }) : super(
          position: position,
          anchor: Anchor.center,
        );

  final double damage;
  bool _isOffScreen = false;
  double _rotationSpeed = 0.0;
  double _rotation = 0.0;

  @override
  void update(double dt) {
    super.update(dt);
    
    // Move down (relative to world as balloon goes up)
    position.y += gameRef.gameSpeed * dt;
    
    // Add falling rotation to obstacles
    _rotation += _rotationSpeed * dt;
    angle = _rotation;
    
    // Remove if off screen
    if (position.y > gameRef.size.y + 100) {
      _isOffScreen = true;
      removeFromParent();
    }
  }

  bool get isOffScreen => _isOffScreen;
  
  void setRotationSpeed(double speed) {
    _rotationSpeed = speed;
  }
}

enum SharpObstacleType { 
  birds,
  drone,
  cessna,
  boeing,
  missile,
  blimp,
}

/// Sharp obstacle (birds, aircraft, drones, missiles, blimps)
class SharpObstacle extends Obstacle {
  SharpObstacle({
    required Vector2 position,
    required this.obstacleType,
  }) : super(
          position: position,
          damage: 100.0, // Instant burst
        ) {
    size = _getSizeForType(obstacleType);
  }

  final SharpObstacleType obstacleType;
  SpriteComponent? _sprite;

  static Vector2 _getSizeForType(SharpObstacleType type) {
    switch (type) {
      case SharpObstacleType.birds:
        return Vector2(70, 60);
      case SharpObstacleType.drone:
        return Vector2(80, 80);
      case SharpObstacleType.cessna:
        return Vector2(100, 60);
      case SharpObstacleType.boeing:
        return Vector2(140, 80);
      case SharpObstacleType.missile:
        return Vector2(50, 100);
      case SharpObstacleType.blimp:
        return Vector2(120, 70);
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add random rotation while falling
    final random = math.Random();
    setRotationSpeed((random.nextDouble() - 0.5) * 2.0); // Random rotation -1 to 1 rad/s

    // Load appropriate sprite
    final spritePath = _getSpritePath();
    try {
      final sprite = await gameRef.loadSprite(spritePath);
      _sprite = SpriteComponent(
        sprite: sprite,
        size: size,
        anchor: Anchor.center,
      );
      add(_sprite!);
    } catch (e) {
      debugPrint('⚠️ Failed to load obstacle sprite: $e');
    }

    // FIXED: Much smaller hitbox - only 50% of sprite size for fair gameplay
    // This accounts for transparency/padding in PNGs
    add(RectangleHitbox(
      size: size * 0.5,
      position: Vector2.zero(),
      anchor: Anchor.center,
    ));
  }

  String _getSpritePath() {
    switch (obstacleType) {
      case SharpObstacleType.birds:
        return 'obstacles/birds.png';
      case SharpObstacleType.drone:
        return 'obstacles/drone.png';
      case SharpObstacleType.cessna:
        return 'obstacles/cesna.png';
      case SharpObstacleType.boeing:
        return 'obstacles/boieng.png';
      case SharpObstacleType.missile:
        return 'obstacles/missle.png';
      case SharpObstacleType.blimp:
        return 'obstacles/blimp.png';
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Fallback rendering
    if (_sprite == null) {
      final paint = Paint()
        ..color = _getColorForType()
        ..style = PaintingStyle.fill;
      
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: size.x * 0.5, height: size.y * 0.5), paint);
    }
  }

  Color _getColorForType() {
    switch (obstacleType) {
      case SharpObstacleType.birds:
        return Colors.brown;
      case SharpObstacleType.drone:
        return Colors.grey;
      case SharpObstacleType.cessna:
        return Colors.white;
      case SharpObstacleType.boeing:
        return Colors.blue;
      case SharpObstacleType.missile:
        return Colors.red;
      case SharpObstacleType.blimp:
        return Colors.lightBlue;
    }
  }
}
