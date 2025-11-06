import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import '../balloon_twist_game.dart';
import '../../core/constants/game_constants.dart';
import '../components/obstacles.dart';

/// Spawns obstacles procedurally based on game progression
class ObstacleSpawner extends Component with HasGameRef<AviaRollHighGame> {
  ObstacleSpawner();

  double _timeSinceLastSpawn = 0;
  double _spawnInterval = 2.0; // Start with 2 seconds between obstacles
  final math.Random _random = math.Random();

  @override
  void update(double dt) {
    super.update(dt);

    _timeSinceLastSpawn += dt;

    // Adjust spawn rate based on game speed
    final speedMultiplier = gameRef.gameSpeed / GameConstants.baseScrollSpeed;
    final adjustedInterval = _spawnInterval / speedMultiplier;

    if (_timeSinceLastSpawn >= adjustedInterval) {
      _spawnObstacle();
      _timeSinceLastSpawn = 0;
      
      // Gradually decrease interval (increase difficulty)
      _spawnInterval = math.max(0.8, _spawnInterval - 0.01);
    }
  }

  void _spawnObstacle() {
    final screenWidth = gameRef.size.x;
    
    // Random horizontal position - adjusted based on obstacle type
    final obstacleType = _chooseObstacleType();
    final xPos = _getSpawnPositionForType(obstacleType, screenWidth);
    final yPos = -50.0; // Start above screen

    final obstacle = SharpObstacle(
      position: Vector2(xPos, yPos),
      obstacleType: obstacleType,
    );

    gameRef.world.add(obstacle);
    debugPrint('✈️ Spawned: ${obstacleType.name} at x:$xPos');
  }

  /// Choose obstacle type based on game progression
  SharpObstacleType _chooseObstacleType() {
    final distance = gameRef.distanceTraveled;
    
    // Early game (0-1000m): Mostly birds and drones
    if (distance < 1000) {
      final rand = _random.nextDouble();
      if (rand < 0.5) return SharpObstacleType.birds;
      if (rand < 0.8) return SharpObstacleType.drone;
      return SharpObstacleType.blimp;
    }
    
    // Mid game (1000-3000m): Add Cessna
    if (distance < 3000) {
      final rand = _random.nextDouble();
      if (rand < 0.3) return SharpObstacleType.birds;
      if (rand < 0.5) return SharpObstacleType.drone;
      if (rand < 0.7) return SharpObstacleType.cessna;
      if (rand < 0.9) return SharpObstacleType.blimp;
      return SharpObstacleType.missile;
    }
    
    // Late game (3000m+): All obstacles including Boeing
    final rand = _random.nextDouble();
    if (rand < 0.15) return SharpObstacleType.birds;
    if (rand < 0.3) return SharpObstacleType.drone;
    if (rand < 0.5) return SharpObstacleType.cessna;
    if (rand < 0.65) return SharpObstacleType.boeing;
    if (rand < 0.8) return SharpObstacleType.missile;
    return SharpObstacleType.blimp;
  }

  /// Get spawn position based on obstacle type
  double _getSpawnPositionForType(SharpObstacleType type, double screenWidth) {
    switch (type) {
      case SharpObstacleType.birds:
      case SharpObstacleType.cessna:
      case SharpObstacleType.boeing:
        // Flying obstacles can spawn from sides (for horizontal movement)
        if (_random.nextBool()) {
          return _random.nextBool() ? -50.0 : screenWidth + 50.0;
        }
        return _random.nextDouble() * (screenWidth - 100) + 50;
      
      case SharpObstacleType.drone:
      case SharpObstacleType.blimp:
        // Drones and blimps spawn anywhere
        return _random.nextDouble() * (screenWidth - 100) + 50;
      
      case SharpObstacleType.missile:
        // Missiles spawn directly above player more often
        if (_random.nextDouble() < 0.4) {
          // Target player position
          return gameRef.size.x / 2 + (_random.nextDouble() - 0.5) * 100;
        }
        return _random.nextDouble() * (screenWidth - 100) + 50;
    }
  }
}
