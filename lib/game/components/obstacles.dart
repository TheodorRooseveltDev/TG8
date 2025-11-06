import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../balloon_twist_game.dart';

/// Base class for all obstacles
abstract class Obstacle extends SpriteComponent with HasGameRef<AviaRollHighGame>, CollisionCallbacks {
  Obstacle({
    required Vector2 position,
    required Vector2 size,
    required this.damageAmount,
  }) : super(
          position: position,
          size: size,
          anchor: Anchor.center,
        );

  final double damageAmount;
  bool _hasCollided = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Move down with game speed (balloon goes up, obstacles come down)
    position.y += gameRef.gameSpeed * dt;
    
    // Remove if off screen
    if (position.y > gameRef.size.y + size.y) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    
    // FIXED: Better collision detection
    final otherType = other.runtimeType.toString();
    if (!_hasCollided && otherType.contains('BalloonPlayer')) {
      _hasCollided = true;
      debugPrint('💥 OBSTACLE HIT BALLOON - CALLING onHit()');
      onHit();
    }
  }

  void onHit() {
    // FIXED: Obstacles always kill the player immediately
    debugPrint('💥 OBSTACLE DESTROYED BALLOON!');
    gameRef.endGame();
  }
}

/// Rotating fan obstacle
class RotatingFan extends Obstacle {
  RotatingFan({
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2.all(80),
          damageAmount: 100,
        );

  double _rotation = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    try {
      sprite = await gameRef.loadSprite('obstacles/rotating_fan.png');
    } catch (e) {
      // Fallback rendering
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _rotation += 3.0 * dt;
    angle = _rotation;
  }

  @override
  void render(Canvas canvas) {
    if (sprite == null) {
      // Draw placeholder fan
      final paint = Paint()
        ..color = Colors.grey
        ..style = PaintingStyle.fill;
      
      for (int i = 0; i < 4; i++) {
        canvas.save();
        canvas.rotate((i * math.pi / 2) + angle);
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: size.x * 0.8, height: size.y * 0.2),
          paint,
        );
        canvas.restore();
      }
    } else {
      super.render(canvas);
    }
  }
}

/// Sharp obstacle (birds, aircraft, drones, missiles, blimps)
class SharpObstacle extends Obstacle {
  SharpObstacle({
    required Vector2 position,
    required this.obstacleType,
  }) : super(
          position: position,
          size: _getSizeForType(obstacleType),
          damageAmount: 100,
        );

  final SharpObstacleType obstacleType;
  double _lifetime = 0;
  double _horizontalSpeed = 0;

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
    
    final spritePath = _getSpritePath();
    try {
      sprite = await gameRef.loadSprite(spritePath);
    } catch (e) {
      debugPrint('⚠️ Failed to load obstacle sprite: $spritePath');
      // Fallback rendering
    }
    
    // Set horizontal movement for some obstacles
    final random = math.Random();
    switch (obstacleType) {
      case SharpObstacleType.birds:
        // Birds move horizontally
        _horizontalSpeed = (random.nextBool() ? 1 : -1) * (50 + random.nextDouble() * 50);
        break;
      case SharpObstacleType.drone:
        // Drones hover and move slowly
        _horizontalSpeed = (random.nextBool() ? 1 : -1) * (30 + random.nextDouble() * 30);
        break;
      case SharpObstacleType.cessna:
        // Cessna flies horizontally
        _horizontalSpeed = (random.nextBool() ? 1 : -1) * (80 + random.nextDouble() * 40);
        break;
      case SharpObstacleType.boeing:
        // Boeing flies straight
        _horizontalSpeed = (random.nextBool() ? 1 : -1) * (60 + random.nextDouble() * 30);
        break;
      case SharpObstacleType.missile:
        // Missiles go straight down fast
        _horizontalSpeed = 0;
        break;
      case SharpObstacleType.blimp:
        // Blimps drift slowly
        _horizontalSpeed = (random.nextBool() ? 1 : -1) * (20 + random.nextDouble() * 20);
        break;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _lifetime += dt;
    
    // Add horizontal movement
    position.x += _horizontalSpeed * dt;
    
    // Add slight bobbing motion for flying obstacles
    if (obstacleType == SharpObstacleType.birds || 
        obstacleType == SharpObstacleType.drone ||
        obstacleType == SharpObstacleType.blimp) {
      position.y += math.sin(_lifetime * 2) * 0.5;
    }
    
    // Remove if off screen horizontally
    if (position.x < -size.x || position.x > gameRef.size.x + size.x) {
      removeFromParent();
    }
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
    if (sprite == null) {
      // Draw placeholder based on type
      final paint = Paint()
        ..color = _getColorForType()
        ..style = PaintingStyle.fill;
      
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: size.x * 0.8, height: size.y * 0.8),
        paint,
      );
      
      // Draw type indicator
      final textPainter = TextPainter(
        text: TextSpan(
          text: _getEmojiForType(),
          style: TextStyle(fontSize: 24),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
    } else {
      super.render(canvas);
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

  String _getEmojiForType() {
    switch (obstacleType) {
      case SharpObstacleType.birds:
        return '🦅';
      case SharpObstacleType.drone:
        return '🚁';
      case SharpObstacleType.cessna:
        return '✈️';
      case SharpObstacleType.boeing:
        return '🛩️';
      case SharpObstacleType.missile:
        return '🚀';
      case SharpObstacleType.blimp:
        return '🎈';
    }
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

/// Heat source that increases pressure
class HeatSource extends Obstacle {
  HeatSource({
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2(50, 60),
          damageAmount: 0, // Doesn't destroy, but increases pressure
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    try {
      sprite = await gameRef.loadSprite('obstacles/candle.png');
    } catch (e) {
      // Fallback rendering
    }
  }

  @override
  void onHit() {
    // Instead of ending game, increase balloon pressure
    // This will be handled in balloon collision
  }

  @override
  void render(Canvas canvas) {
    if (sprite == null) {
      // Draw placeholder flame
      final paint = Paint()
        ..color = Colors.orange
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(0, -size.y / 4), size.x / 3, paint);
      
      final basePaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill;
      
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: size.x / 2, height: size.y / 2),
        basePaint,
      );
    } else {
      super.render(canvas);
    }
  }
}
