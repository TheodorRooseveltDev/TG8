import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../balloon_twist_game.dart';

/// Static background with beautiful fade transitions and motion lines
class ParallaxBackground extends PositionComponent with HasGameRef<AviaRollHighGame> {
  ParallaxBackground({
    required this.biome,
  });

  String biome;
  
  Sprite? _currentSprite;
  Sprite? _nextSprite;
  
  double _fadeProgress = 1.0; // 0.0 = old sprite, 1.0 = new sprite
  bool _isTransitioning = false;
  static const double _transitionDuration = 2.0; // 2 seconds for smooth fade
  
  // Motion lines for upward movement effect
  final List<_MotionLine> _motionLines = [];
  final math.Random _random = math.Random();
  double _lineSpawnTimer = 0.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    size = gameRef.size;
    position = Vector2.zero();
    priority = -100; // Render behind everything
    
    // Initialize motion lines
    _initializeMotionLines();
    
    await _loadCurrentSprite();
    debugPrint('🌄 Static background loaded: $biome');
  }
  
  void _initializeMotionLines() {
    // Create initial set of motion lines
    for (int i = 0; i < 8; i++) {
      _motionLines.add(_MotionLine(
        x: _random.nextDouble() * size.x,
        y: _random.nextDouble() * size.y,
        speed: 100 + _random.nextDouble() * 100,
        length: 20 + _random.nextDouble() * 30,
        opacity: 0.1 + _random.nextDouble() * 0.2,
      ));
    }
  }

  Future<void> _loadCurrentSprite() async {
    final imagePath = _getBiomeImage(biome);
    
    try {
      _currentSprite = await gameRef.loadSprite(imagePath);
      debugPrint('✅ Background sprite loaded: $imagePath');
    } catch (e) {
      debugPrint('⚠️ Failed to load background: $e');
    }
  }

  String _getBiomeImage(String biomeName) {
    // FIXED: Match exact biome names to correct images!
    switch (biomeName) {
      case 'sky':
        return 'backgrounds/above_ground.png'; // 0-1500m: Start above ground
      case 'clouds':
        return 'backgrounds/far_ground.png'; // 1500-3000m: Far ground view
      case 'stratosphere':
        return 'backgrounds/space.png'; // 3000-4500m: High atmosphere
      case 'space':
        return 'backgrounds/space.png'; // 4500-6000m: Edge of space  
      case 'deep_space':
        return 'backgrounds/deep_space.png'; // 6000m+: Deep space
      default:
        return 'backgrounds/above_ground.png';
    }
  }

  Future<void> changeBiome(String newBiome) async {
    if (biome == newBiome) return;
    if (_isTransitioning) return; // Don't interrupt existing transition
    
    debugPrint('🌄 Starting transition from $biome to $newBiome...');
    
    // Load the new sprite
    final imagePath = _getBiomeImage(newBiome);
    try {
      _nextSprite = await gameRef.loadSprite(imagePath);
      
      // Start transition
      biome = newBiome;
      _isTransitioning = true;
      _fadeProgress = 0.0;
      
      debugPrint('✨ Biome transition started: $biome');
    } catch (e) {
      debugPrint('⚠️ Failed to load new background: $e');
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Update fade transition
    if (_isTransitioning) {
      _fadeProgress += dt / _transitionDuration;
      
      if (_fadeProgress >= 1.0) {
        _fadeProgress = 1.0;
        _isTransitioning = false;
        
        // Transition complete - swap sprites
        _currentSprite = _nextSprite;
        _nextSprite = null;
        
        debugPrint('✅ Biome transition complete: $biome');
      }
    }
    
    // Update motion lines to create upward movement effect
    final gameSpeed = gameRef.gameSpeed;
    for (final line in _motionLines) {
      line.y += gameSpeed * dt * 0.3; // Move down (balloon moving up relative to them)
      
      // Wrap around when off screen
      if (line.y > size.y + line.length) {
        line.y = -line.length;
        line.x = _random.nextDouble() * size.x;
      }
    }
    
    // Spawn new lines periodically
    _lineSpawnTimer += dt;
    if (_lineSpawnTimer > 0.5) {
      _lineSpawnTimer = 0.0;
      // Replace one random line
      final index = _random.nextInt(_motionLines.length);
      _motionLines[index] = _MotionLine(
        x: _random.nextDouble() * size.x,
        y: -50,
        speed: 100 + _random.nextDouble() * 100,
        length: 20 + _random.nextDouble() * 30,
        opacity: 0.1 + _random.nextDouble() * 0.2,
      );
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    
    if (_currentSprite == null && _nextSprite == null) {
      // Fallback solid color
      final paint = Paint()..color = _getBiomeColor(biome);
      canvas.drawRect(rect, paint);
    } else if (_isTransitioning && _nextSprite != null) {
      // Render BOTH sprites with fade effect
      
      // Old sprite fading out
      if (_currentSprite != null) {
        final oldOpacity = 1.0 - _fadeProgress;
        _currentSprite!.render(
          canvas,
          size: size,
          overridePaint: Paint()..color = Color.fromRGBO(255, 255, 255, oldOpacity),
        );
      }
      
      // New sprite fading in
      final newOpacity = _fadeProgress;
      _nextSprite!.render(
        canvas,
        size: size,
        overridePaint: Paint()..color = Color.fromRGBO(255, 255, 255, newOpacity),
      );
    } else {
      // Just render current sprite at full opacity
      if (_currentSprite != null) {
        _currentSprite!.render(
          canvas,
          size: size,
          overridePaint: Paint(),
        );
      } else {
        // Fallback
        final paint = Paint()..color = _getBiomeColor(biome);
        canvas.drawRect(rect, paint);
      }
    }
    
    // Draw motion lines on top of background to show upward movement
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    
    for (final line in _motionLines) {
      canvas.drawLine(
        Offset(line.x, line.y),
        Offset(line.x, line.y + line.length),
        linePaint..color = Colors.white.withOpacity(line.opacity),
      );
    }
  }

  Color _getBiomeColor(String biomeName) {
    switch (biomeName) {
      case 'sky':
        return const Color(0xFF87CEEB); // Sky blue
      case 'clouds':
        return const Color(0xFFB0E2FF); // Light blue
      case 'stratosphere':
        return const Color(0xFF4A5F8C); // Dark blue
      case 'space':
        return const Color(0xFF1A1A2E); // Dark purple-blue
      case 'deep_space':
        return const Color(0xFF000000); // Black
      default:
        return const Color(0xFF87CEEB);
    }
  }
  
  // Remove the old updateParallax method - no longer needed!
  void updateParallax({
    required double worldSpeed,
    required double dt,
  }) {
    // Background is now static - no scrolling!
  }
}

/// Motion line for creating upward movement effect
class _MotionLine {
  double x;
  double y;
  double speed;
  double length;
  double opacity;
  
  _MotionLine({
    required this.x,
    required this.y,
    required this.speed,
    required this.length,
    required this.opacity,
  });
}
