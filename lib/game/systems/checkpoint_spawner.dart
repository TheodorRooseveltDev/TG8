import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../balloon_twist_game.dart';
import '../components/checkpoint.dart';
import '../../core/constants/game_constants.dart';
import 'dart:math' as math;

/// Spawns checkpoints at intervals
class CheckpointSpawner extends Component with HasGameRef<AviaRollHighGame> {
  double _spawnTimer = 0;
  double _spawnInterval = GameConstants.checkpointSpawnInterval / 100; // Convert meters to seconds

  @override
  void update(double dt) {
    super.update(dt);
    
    _spawnTimer += dt;
    
    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0;
      _spawnCheckpoint();
    }
  }

  void _spawnCheckpoint() {
    final random = math.Random();
    final x = random.nextDouble() * gameRef.size.x;
    
    final checkpoint = Checkpoint(
      position: Vector2(x, -50),
    );
    
    gameRef.world.add(checkpoint);
    debugPrint('🎯 Checkpoint spawned at x: $x');
  }
}
