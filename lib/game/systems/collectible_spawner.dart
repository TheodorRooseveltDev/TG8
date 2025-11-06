import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import '../balloon_twist_game.dart';
import '../components/collectibles.dart';
import '../components/air_token.dart';

/// Spawns collectibles at regular intervals
class CollectibleSpawner extends Component with HasGameRef<AviaRollHighGame> {
  CollectibleSpawner();

  double _timeSinceLastSpawn = 0;
  double _spawnInterval = 4.0; // Every 4 seconds
  final math.Random _random = math.Random();

  @override
  void update(double dt) {
    super.update(dt);

    _timeSinceLastSpawn += dt;

    if (_timeSinceLastSpawn >= _spawnInterval) {
      _spawnCollectible();
      _timeSinceLastSpawn = 0;
    }
  }

  void _spawnCollectible() {
    final screenWidth = gameRef.size.x;
    
    // Random horizontal position
    final xPos = _random.nextDouble() * (screenWidth - 100) + 50;
    final yPos = -50.0; // Start above screen

    // FIXED: Choose random collectible with air tokens as primary currency
    final collectibleType = _random.nextInt(100);
    
    Component collectible;
    String collectibleName;
    
    if (collectibleType < 50) {
      // 50% chance: Air Token (currency - most common!)
      collectible = AirToken(position: Vector2(xPos, yPos));
      collectibleName = 'AIR TOKEN 💰';
    } else if (collectibleType < 75) {
      // 25% chance: Air ring (bonus points)
      collectible = AirRing(position: Vector2(xPos, yPos));
      collectibleName = 'Air Ring';
    } else if (collectibleType < 90) {
      // 15% chance: Fuel booster (speed boost)
      collectible = PressureBooster(position: Vector2(xPos, yPos));
      collectibleName = 'Fuel Booster';
    } else {
      // 10% chance: Time slower (rare)
      collectible = TimeSlower(position: Vector2(xPos, yPos));
      collectibleName = 'Time Slower';
    }

    debugPrint('🎁 SPAWNED: $collectibleName at ($xPos, $yPos)');
    gameRef.world.add(collectible);
  }
}
