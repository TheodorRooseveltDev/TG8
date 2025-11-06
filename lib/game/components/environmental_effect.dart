import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

import '../balloon_twist_game.dart';
import 'plane_player.dart';

typedef BalloonPlayer = PlanePlayer;

/// Types of environmental effects
enum EnvironmentalEffectType {
  thermal,      // Lift balloon vertically
  dustCloud,    // Reduce visibility
  electricStorm, // Physics disruption
}

/// Environmental effect that influences balloon behavior
class EnvironmentalEffect extends PositionComponent 
    with HasGameRef<AviaRollHighGame>, CollisionCallbacks {
  final EnvironmentalEffectType type;
  final double effectRadius;
  
  EnvironmentalEffect({
    required Vector2 position,
    required this.type,
    this.effectRadius = 100.0,
  }) : super(
          position: position,
          size: Vector2.all(effectRadius * 2),
          anchor: Anchor.center,
        );

  double _animationTime = 0;
  bool _isActive = true;
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Add collision detection
    add(CircleHitbox(radius: effectRadius));
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    _animationTime += dt;
    
    // Move effect down with game speed
    position.y += gameRef.gameSpeed * dt;
    
    // Remove if off-screen
    if (position.y > gameRef.size.y + effectRadius) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    if (!_isActive) return;
    
    switch (type) {
      case EnvironmentalEffectType.thermal:
        _renderThermal(canvas);
        break;
      case EnvironmentalEffectType.dustCloud:
        _renderDustCloud(canvas);
        break;
      case EnvironmentalEffectType.electricStorm:
        _renderElectricStorm(canvas);
        break;
    }
  }

  void _renderThermal(Canvas canvas) {
    // Rising air visualization
    final pulse = math.sin(_animationTime * 3) * 0.2 + 0.8;
    
    for (int i = 0; i < 3; i++) {
      final yOffset = ((_animationTime * 50 + i * 30) % 100) - 50;
      final alpha = (1.0 - (yOffset + 50) / 100) * pulse;
      
      final paint = Paint()
        ..color = Colors.orange.withOpacity(alpha * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
      
      canvas.drawCircle(
        Offset(0, yOffset),
        effectRadius * 0.6,
        paint,
      );
    }
    
    // Center indicator
    final centerPaint = Paint()
      ..color = Colors.orange.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    canvas.drawCircle(Offset.zero, effectRadius * 0.8, centerPaint);
  }

  void _renderDustCloud(Canvas canvas) {
    // Swirling dust particles
    final paint = Paint()
      ..color = Colors.brown.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    
    for (int i = 0; i < 5; i++) {
      final angle = _animationTime + i * (math.pi * 2 / 5);
      final radius = effectRadius * 0.7;
      final x = math.cos(angle) * radius;
      final y = math.sin(angle) * radius;
      
      canvas.drawCircle(
        Offset(x, y),
        20,
        paint,
      );
    }
    
    // Center cloud
    canvas.drawCircle(Offset.zero, effectRadius * 0.5, paint);
  }

  void _renderElectricStorm(Canvas canvas) {
    // Electric arcs
    final random = math.Random(_animationTime.toInt());
    
    if (_animationTime % 0.5 < 0.1) {
      // Flash of lightning
      final paint = Paint()
        ..color = Colors.cyan.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;
      
      // Draw jagged lightning bolt
      final path = Path();
      var currentX = 0.0;
      var currentY = -effectRadius;
      
      path.moveTo(currentX, currentY);
      
      for (int i = 0; i < 5; i++) {
        currentX += (random.nextDouble() - 0.5) * 40;
        currentY += effectRadius / 3;
        path.lineTo(currentX, currentY);
      }
      
      canvas.drawPath(path, paint);
      
      // Glow
      final glowPaint = Paint()
        ..color = Colors.cyan.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      
      canvas.drawCircle(Offset.zero, effectRadius, glowPaint);
    }
    
    // Storm cloud outline
    final cloudPaint = Paint()
      ..color = Colors.purple.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    canvas.drawCircle(Offset.zero, effectRadius * 0.9, cloudPaint);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    
    if (other is! BalloonPlayer) return;
    
    // Apply environmental effect to aircraft
    switch (type) {
      case EnvironmentalEffectType.thermal:
        // Lift aircraft upward
        other.applyVerticalForce(-150.0); // Upward force
        debugPrint('🌡️ Thermal updraft! Lifting aircraft');
        break;
        
      case EnvironmentalEffectType.dustCloud:
        // Reduce visibility (handled by game manager)
        debugPrint('💨 Entered dust cloud');
        break;
        
      case EnvironmentalEffectType.electricStorm:
        // Apply random force disruption
        final random = math.Random();
        final forceX = (random.nextDouble() - 0.5) * 300;
        final forceY = (random.nextDouble() - 0.5) * 200;
        other.applyHorizontalForce(forceX);
        other.applyVerticalForce(forceY);
        debugPrint('⚡ Electric storm! Physics disrupted');
        break;
    }
  }
}
