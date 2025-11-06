import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../balloon_twist_game.dart';
import 'dart:math' as math;

/// Visual effect component for screen shake
class ScreenShakeEffect extends Component with HasGameRef<AviaRollHighGame> {
  double _shakeIntensity = 0;
  double _shakeDuration = 0;
  double _shakeTimer = 0;
  Vector2 _shakeOffset = Vector2.zero();
  
  @override
  void update(double dt) {
    super.update(dt);
    
    if (_shakeDuration > 0) {
      _shakeTimer += dt;
      
      if (_shakeTimer < _shakeDuration) {
        // Apply shake offset
        final progress = _shakeTimer / _shakeDuration;
        final intensity = _shakeIntensity * (1 - progress); // Decay over time
        
        _shakeOffset = Vector2(
          (math.Random().nextDouble() - 0.5) * intensity * 2,
          (math.Random().nextDouble() - 0.5) * intensity * 2,
        );
        
        // Apply to camera
        gameRef.camera.viewfinder.position = _shakeOffset;
      } else {
        // Reset
        _shakeDuration = 0;
        _shakeTimer = 0;
        _shakeOffset = Vector2.zero();
        gameRef.camera.viewfinder.position = Vector2.zero();
      }
    }
  }
  
  /// Trigger screen shake
  void shake({required double intensity, required double duration}) {
    _shakeIntensity = intensity;
    _shakeDuration = duration;
    _shakeTimer = 0;
  }
  
  /// Quick shake presets
  void lightShake() => shake(intensity: 5, duration: 0.2);
  void mediumShake() => shake(intensity: 10, duration: 0.3);
  void heavyShake() => shake(intensity: 20, duration: 0.5);
}

/// Particle effect for burst/explosion
class BurstParticle extends PositionComponent {
  final Color color;
  final Vector2 velocity;
  final double lifetime;
  
  double _life = 0;
  
  BurstParticle({
    required Vector2 position,
    required this.color,
    required this.velocity,
    this.lifetime = 1.0,
  }) : super(position: position, size: Vector2.all(4));
  
  @override
  void update(double dt) {
    super.update(dt);
    
    _life += dt;
    
    if (_life >= lifetime) {
      removeFromParent();
      return;
    }
    
    // Update position
    position.add(velocity * dt);
    
    // Apply gravity
    velocity.y += 200 * dt;
  }
  
  @override
  void render(Canvas canvas) {
    final alpha = (1 - (_life / lifetime)).clamp(0.0, 1.0);
    final paint = Paint()
      ..color = color.withOpacity(alpha)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset.zero, 3, paint);
  }
}

/// Particle spawner for creating burst effects
class ParticleSpawner extends Component with HasGameRef<AviaRollHighGame> {
  
  /// Spawn burst particles at position
  void spawnBurst(Vector2 position, {Color? color, int particleCount = 20}) {
    final effectColor = color ?? Colors.red;
    
    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * math.pi * 2;
      final speed = 100 + math.Random().nextDouble() * 100;
      
      final velocity = Vector2(
        math.cos(angle) * speed,
        math.sin(angle) * speed,
      );
      
      final particle = BurstParticle(
        position: position.clone(),
        color: effectColor,
        velocity: velocity,
        lifetime: 0.5 + math.Random().nextDouble() * 0.5,
      );
      
      gameRef.world.add(particle);
    }
  }
  
  /// Spawn trail particles behind balloon
  void spawnTrail(Vector2 position, {Color? color}) {
    final trailColor = color ?? Colors.white.withOpacity(0.5);
    
    final particle = BurstParticle(
      position: position.clone(),
      color: trailColor,
      velocity: Vector2(0, 50), // Slow downward drift
      lifetime: 0.3,
    );
    
    gameRef.world.add(particle);
  }
  
  /// Spawn air leak particles
  void spawnAirLeak(Vector2 position) {
    for (int i = 0; i < 3; i++) {
      final angle = math.pi / 2 + (math.Random().nextDouble() - 0.5) * 0.5;
      final speed = 150 + math.Random().nextDouble() * 50;
      
      final velocity = Vector2(
        math.cos(angle) * speed,
        math.sin(angle) * speed,
      );
      
      final particle = BurstParticle(
        position: position.clone(),
        color: Colors.lightBlueAccent.withOpacity(0.6),
        velocity: velocity,
        lifetime: 0.4,
      );
      
      gameRef.world.add(particle);
    }
  }
}

/// Speed indicator component
class SpeedIndicator extends PositionComponent with HasGameRef<AviaRollHighGame> {
  SpeedIndicator() : super(size: Vector2(100, 60));
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Position at top-right corner
    position = Vector2(gameRef.size.x - 120, 100);
  }
  
  @override
  void render(Canvas canvas) {
    final speed = gameRef.gameSpeed;
    final maxSpeed = 400.0;
    final speedPercent = (speed / maxSpeed).clamp(0.0, 1.0);
    
    // Background
    final bgPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, 100, 60),
        const Radius.circular(8),
      ),
      bgPaint,
    );
    
    // Speed bar
    final barColor = speedPercent < 0.5
        ? Colors.green
        : speedPercent < 0.8
            ? Colors.orange
            : Colors.red;
    
    final barPaint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(10, 35, 80 * speedPercent, 15),
        const Radius.circular(4),
      ),
      barPaint,
    );
    
    // Text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${speed.toInt()} m/s',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(canvas, const Offset(10, 10));
  }
}

/// Motion blur effect component
class MotionBlurEffect extends Component with HasGameRef<AviaRollHighGame> {
  final List<Vector2> _trailPositions = [];
  static const int maxTrailLength = 5;
  double _updateTimer = 0;
  static const double updateInterval = 0.05; // 20 times per second
  
  @override
  void update(double dt) {
    super.update(dt);
    
    _updateTimer += dt;
    
    if (_updateTimer >= updateInterval && gameRef.gameSpeed > 200) {
      _updateTimer = 0;
      
      // Record balloon position
      _trailPositions.add(gameRef.balloonPosition.clone());
      
      // Keep only recent positions
      if (_trailPositions.length > maxTrailLength) {
        _trailPositions.removeAt(0);
      }
    }
  }
  
  @override
  void render(Canvas canvas) {
    if (_trailPositions.length < 2) return;
    
    // Draw fading trail behind balloon
    for (int i = 0; i < _trailPositions.length - 1; i++) {
      final alpha = (i / _trailPositions.length) * 0.3;
      final paint = Paint()
        ..color = Colors.white.withOpacity(alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5)
        ..style = PaintingStyle.fill;
      
      final pos = _trailPositions[i];
      canvas.drawCircle(
        Offset(pos.x, pos.y),
        20,
        paint,
      );
    }
  }
}
