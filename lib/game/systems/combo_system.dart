import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../balloon_twist_game.dart';
import '../../core/constants/game_constants.dart';

/// Manages combo multiplier for near-miss bonuses
class ComboSystem extends Component with HasGameRef<AviaRollHighGame> {
  int _comboCount = 0;
  double _comboTimer = 0;
  static const double comboTimeout = 3.0; // Seconds before combo resets

  int get comboCount => _comboCount;
  double get multiplier => _comboCount > 0 ? GameConstants.comboMultiplier : 1.0;

  @override
  void update(double dt) {
    super.update(dt);
    
    if (_comboCount > 0) {
      _comboTimer += dt;
      
      if (_comboTimer >= comboTimeout) {
        resetCombo();
      }
    }
  }

  void addNearMiss() {
    _comboCount++;
    _comboTimer = 0;
    
    final bonus = (GameConstants.nearMissBonus * multiplier).toInt();
    gameRef.addScore(bonus.toDouble());
    
    debugPrint('🎯 Near miss! Combo: ${_comboCount}x, Bonus: $bonus');
  }

  void resetCombo() {
    if (_comboCount > 0) {
      debugPrint('💔 Combo lost: ${_comboCount}x');
    }
    _comboCount = 0;
    _comboTimer = 0;
  }
}
