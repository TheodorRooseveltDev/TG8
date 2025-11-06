import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../../core/constants/game_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/audio/audio_manager.dart';
import '../balloon_twist_game.dart';
import 'dart:math' as math;

/// Player-controlled balloon with physics and pressure management
class BalloonPlayer extends PositionComponent with HasGameRef<AviaRollHighGame>, CollisionCallbacks {
  BalloonPlayer({
    required this.balloonType,
    Vector2? position,
  }) : super(
          position: position,
          anchor: Anchor.center,
        );

  final BalloonType balloonType;

  // Balloon state
  double _pressure = 50.0; // Start at 50% pressure
  double _velocity = 0.0;
  double _horizontalVelocity = 0.0;
  bool _isInflating = false;
  bool _isDeflating = false;
  bool _isBurst = false;
  bool _isPunctured = false;
  bool _isStalled = false;

  // Balloon stats (from type)
  late final double maxPressure;
  late final double burstThreshold;
  late final double controlSensitivity;
  late final double autoAscentRate;

  // Visual
  SpriteComponent? _balloonSprite;
  double _currentRadius = GameConstants.balloonBaseRadius;

  // Getters
  double get pressure => _pressure;
  double get pressurePercent => (_pressure / maxPressure) * 100;
  double get horizontalVelocity => _horizontalVelocity; // For parallax effect
  bool get isBurst => _isBurst;
  Color get pressureColor {
    final percent = pressurePercent;
    if (percent < 40) return AppColors.pressureLow;
    if (percent < 70) return AppColors.pressureOptimal;
    if (percent < 85) return AppColors.pressureHigh;
    return AppColors.pressureCritical;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load balloon stats from constants
    final stats = GameConstants.balloonTypes[balloonType]!;
    maxPressure = stats['maxPressure'] as double;
    burstThreshold = stats['burstThreshold'] as double;
    controlSensitivity = stats['controlSensitivity'] as double;
    autoAscentRate = stats['autoAscent'] as double;

    // Set size with center anchor for proper scaling
    size = Vector2.all(_currentRadius * 2);
    anchor = Anchor.center; // THIS IS KEY! Makes balloon scale from center

    // Add collision shape centered at (0,0) relative to anchor
    // Make hitbox slightly smaller (80% of visual size) for fair gameplay
    add(CircleHitbox(
      radius: _currentRadius * 0.8,
      position: Vector2.zero(),
      anchor: Anchor.center,
    ));

    // Load balloon sprite based on type
    final spritePath = _getBalloonSpritePath();
    try {
      final sprite = await gameRef.loadSprite(spritePath);
      
      // CRITICAL: The sprite PNG has asymmetric padding/transparency
      // We need to offset it to visually center the balloon graphic
      // These percentages are relative to the balloon size and scale with it
      final offsetX = _currentRadius * 0.95; // About 95% of radius to the right
      final offsetY = _currentRadius * 0.68; // About 68% of radius down
      
      _balloonSprite = SpriteComponent(
        sprite: sprite,
        size: size,
        anchor: Anchor.center,
        position: Vector2(offsetX, offsetY),
      );
      add(_balloonSprite!);
      debugPrint('🎈 Balloon sprite loaded: $balloonType from $spritePath');
    } catch (e) {
      debugPrint('⚠️ Failed to load balloon sprite: $e');
      // Fallback to colored circle (will be drawn in render method)
      _balloonSprite = null;
    }

    debugPrint('🎈 Balloon loaded: $balloonType at ${position.x}, ${position.y}');
  }

  String _getBalloonSpritePath() {
    // Flame's loadSprite() automatically looks in assets/images/
    // So we just need the filename without assets/images/ prefix
    switch (balloonType) {
      case BalloonType.standard:
        return 'balloons/standart_balloon.png';
      case BalloonType.foil:
      case BalloonType.fighter:
        return 'balloons/foil_balloon.png';
      case BalloonType.hydrogen:
      case BalloonType.jet:
        return 'balloons/hydrogen_balloon.png';
      case BalloonType.cluster:
      case BalloonType.cargo:
        return 'balloons/cluster_balloon.png';
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_isBurst) return;

    // Handle pressure changes
    _updatePressure(dt);

    // Check burst condition
    if (_pressure >= burstThreshold) {
      _burst();
      return;
    }

    // Check stall condition (out of air)
    if (_pressure <= 0) {
      _stall();
      return;
    }

    // Apply physics
    _updatePhysics(dt);

    // Update position
    _updatePosition(dt);

    // Update visual size based on pressure
    _updateVisualSize();
  }

  void _updatePressure(double dt) {
    final oldPressure = _pressure;
    
    // Get balloon stats for pressure efficiency
    final stats = GameConstants.balloonStats[balloonType.name]!;
    
    // Natural pressure loss (modified by efficiency stat)
    final pressureLossModifier = 1.0 / stats['efficiency']!;
    _pressure -= GameConstants.pressureLossRate * dt * pressureLossModifier;

    // Player input
    if (_isInflating) {
      _pressure += GameConstants.inflationRate * dt;
      
      // Spawn air intake particles occasionally
      if (math.Random().nextDouble() < 0.1) {
        gameRef.spawnAirLeakEffect(position);
      }
      
      // Play inflate sound
      gameRef.playSoundEffect(SoundEffect.inflate);
    } else if (_isDeflating) {
      _pressure -= GameConstants.deflationRate * dt;
      gameRef.playSoundEffect(SoundEffect.deflate);
    }

    // Puncture air leak
    if (_isPunctured) {
      _pressure -= 15.0 * dt; // Gradual leak
      
      // Spawn leak particles
      if (math.Random().nextDouble() < 0.2) {
        gameRef.spawnAirLeakEffect(position);
      }
    }

    // Clamp pressure
    _pressure = _pressure.clamp(0.0, maxPressure);

    // Check failure conditions
    if (_pressure >= burstThreshold) {
      _burst();
    } else if (_pressure <= GameConstants.stallPressure) {
      _stall();
    }
    
    // Pressure warning sounds
    if (_pressure > 85 && oldPressure <= 85) {
      gameRef.playSoundEffect(SoundEffect.pressureHigh);
    } else if (_pressure < 20 && oldPressure >= 20) {
      gameRef.playSoundEffect(SoundEffect.pressureLow);
    }
  }

  void _updatePhysics(double dt) {
    // Get balloon stats for this type
    final stats = GameConstants.balloonStats[balloonType.name]!;
    
    // FIXED: Inflation directly affects upward force
    // More pressure = more lift!
    // Low pressure (0-30%): Barely moves up, might fall
    // Medium pressure (30-70%): Good steady climb
    // High pressure (70-90%): Fast ascent
    // Critical pressure (90-100%): Maximum speed but dangerous!
    
    final pressureRatio = _pressure / maxPressure;
    
    // Base upward force from pressure
    final ascentForce = (pressureRatio * 300.0) * stats['speed']!;
    _velocity = ascentForce * controlSensitivity * stats['control']!;

    // Apply gravity (stronger effect at low pressure)
    final gravityModifier = (2.0 - pressureRatio); // More gravity when low pressure
    _velocity -= GameConstants.gravity * dt * 30 * gravityModifier;

    // Horizontal velocity dampening (modified by control)
    _horizontalVelocity *= math.pow(0.95, dt * 60) * stats['control']!;
  }

  void _updatePosition(double dt) {
    // FIXED: Balloon stays in CENTER of screen vertically
    // Only horizontal movement allowed
    // World moves down instead of balloon moving up!
    
    final gameSize = gameRef.size;
    
    // LOCK vertical position to center-bottom area
    position.y = gameSize.y * 0.65; // Stay at 65% down the screen (center-ish)

    // Horizontal movement only
    position.x += _horizontalVelocity * dt;

    // Keep balloon in screen bounds (horizontally)
    final halfWidth = _currentRadius;
    position.x = position.x.clamp(halfWidth, gameSize.x - halfWidth);
    
    // Balloon NEVER moves vertically - it stays centered!
    // The world scrolls down based on velocity instead
    gameRef.setWorldScrollSpeed(_velocity);
  }

  void _updateVisualSize() {
    // FIXED: Much more dramatic size change based on pressure
    // Pressure 0-20%: Deflated (60% size)
    // Pressure 50%: Normal (100% size)
    // Pressure 100%: Overinflated (180% size) - About to burst!
    final pressureScale = 0.6 + (pressurePercent / 100 * 1.2); // 60% to 180% size
    _currentRadius = GameConstants.balloonBaseRadius * pressureScale;
    
    // Update component size
    size = Vector2.all(_currentRadius * 2);
    
    // Update sprite - maintain proportional offset so it stays centered as it scales
    if (_balloonSprite != null) {
      _balloonSprite!.size = size;
      
      // Recalculate offset based on new radius to keep balloon visually centered
      final offsetX = _currentRadius * 0.95;
      final offsetY = _currentRadius * 0.68;
      _balloonSprite!.position = Vector2(offsetX, offsetY);
    }

    // Update hitbox (remove old, add new)
    // Hitbox is smaller than visual size for more forgiving gameplay
    final oldHitbox = children.whereType<CircleHitbox>().firstOrNull;
    if (oldHitbox != null) {
      remove(oldHitbox);
      add(CircleHitbox(
        radius: _currentRadius * 0.8, // 80% of visual radius for fairer collisions
        position: Vector2.zero(),
        anchor: Anchor.center,
      ));
    }
  }

  // Control methods
  void startInflating() {
    _isInflating = true;
    _isDeflating = false;
  }

  void stopInflating() {
    _isInflating = false;
  }

  void startDeflating() {
    _isDeflating = true;
    _isInflating = false;
  }

  void stopDeflating() {
    _isDeflating = false;
  }

  void applyHorizontalForce(double force) {
    _horizontalVelocity += force;
    // Clamp horizontal velocity
    _horizontalVelocity = _horizontalVelocity.clamp(-200.0, 200.0);
  }

  void applyVerticalForce(double force) {
    _velocity += force;
    // Clamp vertical velocity
    _velocity = _velocity.clamp(-300.0, 300.0);
  }

  /// Reset pressure to optimal level (called at checkpoints)
  void resetPressure() {
    // Reset to middle of optimal range
    _pressure = (GameConstants.optimalPressureMin + GameConstants.optimalPressureMax) / 2;
    debugPrint('🔄 Pressure reset to ${_pressure.toStringAsFixed(0)}%');
  }

  void _burst() {
    if (_isBurst) return;
    
    _isBurst = true;
    debugPrint('💥 Balloon burst at ${pressurePercent.toStringAsFixed(1)}% pressure!');
    
    // Trigger visual effects
    gameRef.spawnBurstEffect(position, color: Colors.red, particleCount: 30);
    gameRef.triggerScreenShake(intensity: 15, duration: 0.4);
    gameRef.playSoundEffect(SoundEffect.burst);
    
    gameRef.endGame();
  }

  void _stall() {
    if (_isStalled) return;
    
    _isStalled = true;
    debugPrint('🪂 Balloon stalled! Out of air...');
    
    // Light shake
    gameRef.triggerScreenShake(intensity: 5, duration: 0.2);
    gameRef.playSoundEffect(SoundEffect.pressureLow);
    
    gameRef.endGame();
  }

  void addPressure(double amount) {
    _pressure = (_pressure + amount).clamp(0.0, maxPressure);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    
    // FIXED: Proper collision detection for obstacles
    final otherType = other.runtimeType.toString();
    
    if (otherType.contains('Obstacle') || 
        otherType.contains('RotatingFan') || 
        otherType.contains('SharpObstacle') ||
        otherType.contains('HeatSource')) {
      debugPrint('💥 HIT OBSTACLE: $otherType - BURSTING BALLOON!');
      _burst(); // Instant game over on obstacle hit
      return;
    }
    
    // Handle collectible collisions
    if (otherType.contains('Collectible') || otherType.contains('AirToken')) {
      debugPrint('✨ Collected item: $otherType');
      try {
        (other as dynamic).collect();
      } catch (e) {
        debugPrint('⚠️ Failed to collect: $e');
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Only draw placeholder if sprite didn't load
    if (_balloonSprite == null) {
      // Draw balloon as colored circle (placeholder)
      final paint = Paint()
        ..color = pressureColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(_currentRadius, _currentRadius),
        _currentRadius,
        paint,
      );

      // Draw outline
      final outlinePaint = Paint()
        ..color = AppColors.accentAmber
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawCircle(
        Offset(_currentRadius, _currentRadius),
        _currentRadius,
        outlinePaint,
      );
    }
  }
}
