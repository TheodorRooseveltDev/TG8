import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../balloon_twist_game.dart';
import '../components/environmental_effect.dart';
import 'dart:math' as math;

/// Spawns environmental effects based on altitude
class EnvironmentSpawner extends Component with HasGameRef<AviaRollHighGame> {
  double _spawnTimer = 0;
  double _spawnInterval = 5.0; // Base spawn interval in seconds
  final math.Random _random = math.Random();

  @override
  void update(double dt) {
    super.update(dt);
    
    _spawnTimer += dt;
    
    // Adjust spawn rate based on altitude
    final altitude = gameRef.distanceTraveled;
    _spawnInterval = _calculateSpawnInterval(altitude);
    
    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0;
      _spawnEnvironmentalEffect(altitude);
    }
  }

  double _calculateSpawnInterval(double altitude) {
    // More frequent effects at higher altitudes
    if (altitude < 1000) return 8.0;
    if (altitude < 3000) return 6.0;
    if (altitude < 8000) return 4.0;
    return 3.0;
  }

  void _spawnEnvironmentalEffect(double altitude) {
    final x = _random.nextDouble() * gameRef.size.x;
    
    // Different effects based on altitude/biome
    EnvironmentalEffectType type;
    
    if (altitude < 1000) {
      // Tavern zone - thermals from chimneys
      type = EnvironmentalEffectType.thermal;
    } else if (altitude < 3000) {
      // Sky zone - mix of thermals and dust
      type = _random.nextBool() 
          ? EnvironmentalEffectType.thermal 
          : EnvironmentalEffectType.dustCloud;
    } else if (altitude < 8000) {
      // Stratosphere - dust clouds and storms
      final roll = _random.nextDouble();
      if (roll < 0.4) {
        type = EnvironmentalEffectType.dustCloud;
      } else if (roll < 0.7) {
        type = EnvironmentalEffectType.thermal;
      } else {
        type = EnvironmentalEffectType.electricStorm;
      }
    } else {
      // Mesosphere and space - mostly electrical storms
      type = _random.nextDouble() < 0.7
          ? EnvironmentalEffectType.electricStorm
          : EnvironmentalEffectType.thermal;
    }
    
    final effect = EnvironmentalEffect(
      position: Vector2(x, -100),
      type: type,
      effectRadius: 80 + _random.nextDouble() * 40,
    );
    
    gameRef.world.add(effect);
    debugPrint('🌍 Spawned ${type.toString().split('.').last} at altitude ${altitude.toInt()}m');
  }
}
