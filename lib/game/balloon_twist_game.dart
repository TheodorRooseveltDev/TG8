import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../core/constants/game_constants.dart';
import '../core/audio/audio_manager.dart';
import 'components/plane_player.dart';
import 'components/pressure_gauge.dart';
import 'components/parallax_background.dart';
import 'systems/obstacle_spawner.dart';
import 'systems/collectible_spawner.dart';
import 'systems/checkpoint_spawner.dart';
import 'systems/combo_system.dart';
import 'systems/environment_spawner.dart';
import 'systems/visual_effects_system.dart';
import 'systems/performance_monitor.dart';

/// Main game class for AviaRoll High
/// Manages game loop, camera, and component hierarchy
class AviaRollHighGame extends FlameGame with HasCollisionDetection {
  AviaRollHighGame({
    required this.onGameOver,
    required this.onScoreUpdate,
    this.selectedPlaneType = PlaneType.standard,
  }) : super();

  // Callbacks
  final VoidCallback onGameOver;
  final ValueChanged<int> onScoreUpdate;
  final PlaneType selectedPlaneType;

  // Game state
  bool _isPaused = false;
  bool _isGameOver = false;
  double _currentScore = 0;
  double _distanceTraveled = 0;
  double _gameSpeed = GameConstants.baseScrollSpeed;
  int _airTokens = 0; // FIXED: Track air tokens collected in this session
  bool _boostActive = false;
  double _boostTimer = 0;
  static const double _boostDuration = 3.0; // 3 seconds of boost
  double _worldScrollSpeed = 0; // Speed at which world scrolls down (plane stays centered)
  
  // Game components
  PlanePlayer? _plane;
  PressureGauge? _pressureGauge;
  ParallaxBackground? _background; // Keep reference to change biomes
  ObstacleSpawner? _obstacleSpawner;
  CollectibleSpawner? _collectibleSpawner;
  CheckpointSpawner? _checkpointSpawner;
  ComboSystem? _comboSystem;
  EnvironmentSpawner? _environmentSpawner;
  ScreenShakeEffect? _screenShake;
  ParticleSpawner? _particleSpawner;
  SpeedIndicator? _speedIndicator;
  MotionBlurEffect? _motionBlur;
  
  // Audio
  final AudioManager _audioManager = AudioManager.instance;
  
  // Performance monitoring
  final PerformanceMonitor _perfMonitor = PerformanceMonitor.instance;
  double _perfReportTimer = 0;
  static const double _perfReportInterval = 5.0; // Report every 5 seconds

  // Getters
  bool get isPaused => _isPaused;
  bool get isGameOver => _isGameOver;
  double get currentScore => _currentScore;
  double get distanceTraveled => _distanceTraveled;
  double get gameSpeed => _gameSpeed;
  
  // Getters for replay system and legacy code
  Vector2 get planePosition => _plane?.position ?? Vector2.zero();
  double get planeFuel => _plane?.pressurePercent ?? 0;
  
  // Legacy getters (for compatibility)
  Vector2 get balloonPosition => planePosition;
  double get balloonPressure => planeFuel;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Initialize audio
    await _audioManager.initialize();
    
    // Set up camera with world bounds
    camera.viewfinder.anchor = Anchor.topLeft;
    
    // Initialize game components
    await _initializeGame();
  }

  Future<void> _initializeGame() async {
    // FIXED: Always start with 'sky' biome at distance 0
    // This matches the 0-1500m range in _checkBiomeTransition()
    String biome = 'sky'; // Always start above ground!
    
    // Add parallax background
    _background = ParallaxBackground(biome: biome);
    world.add(_background!);
    
    // Create and add plane player with selected type
    // FIXED: Position at center of screen (horizontally and vertically centered)
    _plane = PlanePlayer(
      planeType: selectedPlaneType,
      position: Vector2(size.x / 2, size.y * 0.65), // Center horizontally, 65% down
    );
    world.add(_plane!);
    
    // Add pressure gauge around plane (still uses balloon parameter name for now)
    _pressureGauge = PressureGauge(balloon: _plane!);
    world.add(_pressureGauge!);
    
    // Add spawner systems
    _obstacleSpawner = ObstacleSpawner();
    add(_obstacleSpawner!);
    
    _collectibleSpawner = CollectibleSpawner();
    add(_collectibleSpawner!);
    
    _checkpointSpawner = CheckpointSpawner();
    add(_checkpointSpawner!);
    
    _comboSystem = ComboSystem();
    add(_comboSystem!);
    
    _environmentSpawner = EnvironmentSpawner();
    add(_environmentSpawner!);
    
    // REMOVED: Replay system deleted
    
    // Visual effects
    _screenShake = ScreenShakeEffect();
    add(_screenShake!);
    
    _particleSpawner = ParticleSpawner();
    add(_particleSpawner!);
    
    _speedIndicator = SpeedIndicator();
    add(_speedIndicator!);
    
    _motionBlur = MotionBlurEffect();
    add(_motionBlur!);
    
    // Start ambient wind sound
    _audioManager.playWindAmbience(0.3);
    _audioManager.playMusic('background_theme');
    
    debugPrint('🎮 AviaRoll High Game initialized with plane at ${_plane!.position}');
  }

  @override
  void update(double dt) {
    if (_isPaused || _isGameOver) return;
    
    super.update(dt);
    
    // Update boost timer
    if (_boostActive) {
      _boostTimer -= dt;
      if (_boostTimer <= 0) {
        _boostActive = false;
        debugPrint('⚡ Boost ended');
      }
    }
    
    // Background is now static - no scrolling update needed!
    // Beautiful fade transitions happen automatically in the background component
    
    // Update performance monitoring
    _perfMonitor.recordFrame(dt);
    _updatePerformanceReport(dt);

    // Update game speed over time (gradual acceleration)
    _updateGameSpeed(dt);
    
    // Update distance and score
    _updateScore(dt);
    
    // Check for biome transitions
    _checkBiomeTransition();
    
    // Update wind ambience based on speed
    final speedIntensity = (_gameSpeed / GameConstants.maxScrollSpeed).clamp(0.0, 1.0);
    _audioManager.playWindAmbience(speedIntensity);
    
    // Screen shake at high speeds
    if (_gameSpeed > 300 && math.Random().nextDouble() < 0.05) {
      _screenShake?.lightShake();
    }
  }
  
  void _updatePerformanceReport(double dt) {
    _perfReportTimer += dt;
    
    if (_perfReportTimer >= _perfReportInterval) {
      _perfReportTimer = 0;
      
      // Update component counts
      _perfMonitor.updateCounts(
        components: world.children.length,
        collisions: world.children.whereType<PositionComponent>().length,
        particles: 0, // Particle count would need tracking in ParticleSpawner
      );
      
      // Print report in debug mode
      _perfMonitor.printReport();
      
      // Check for performance issues
      final recommendations = _perfMonitor.getRecommendations();
      if (recommendations.isNotEmpty) {
        debugPrint('⚠️ Performance Recommendations:');
        for (final rec in recommendations) {
          debugPrint('  - $rec');
        }
      }
    }
  }

  void _checkBiomeTransition() {
    // FIXED: Change background every 1500 meters
    String newBiome;
    
    if (_distanceTraveled < 1500) {
      newBiome = 'sky'; // 0-1500m: Start above ground
    } else if (_distanceTraveled < 3000) {
      newBiome = 'clouds'; // 1500-3000m: Far ground view
    } else if (_distanceTraveled < 4500) {
      newBiome = 'stratosphere'; // 3000-4500m: Stratosphere (dark blue)
    } else if (_distanceTraveled < 6000) {
      newBiome = 'space'; // 4500-6000m: Edge of space
    } else {
      newBiome = 'deep_space'; // 6000m+: Deep space (black with stars)
    }
    
    // Log biome transitions for debugging
    if (_background?.biome != newBiome) {
      debugPrint('🌍 BIOME TRANSITION at ${_distanceTraveled.toInt()}m: ${_background?.biome} → $newBiome');
    }
    
    // Change background when crossing threshold
    _background?.changeBiome(newBiome);
  }

  void _updateGameSpeed(double dt) {
    // Gradually increase speed up to max
    if (_gameSpeed < GameConstants.maxScrollSpeed) {
      _gameSpeed += GameConstants.scrollAcceleration * dt;
      _gameSpeed = _gameSpeed.clamp(
        GameConstants.baseScrollSpeed,
        GameConstants.maxScrollSpeed,
      );
    }
  }

  void _updateScore(double dt) {
    // FIXED: Distance based on world scroll speed (balloon's upward velocity)
    // Since balloon stays centered, world scrolling = distance traveled
    final distanceGained = _worldScrollSpeed * dt;
    _distanceTraveled += distanceGained;
    
    // Convert distance to score (MUCH SLOWER)
    // Only get 1 point per 2 meters traveled (was 1 per 0.1m!)
    final scoreGained = distanceGained * 0.5; // 0.5 points per meter
    final oldScore = _currentScore.toInt();
    _currentScore += scoreGained;
    final newScore = _currentScore.toInt();
    
    // Notify UI of score changes only when integer value changes
    if (oldScore != newScore) {
      // Schedule the callback for the next frame to avoid setState during build
      Future.microtask(() => onScoreUpdate(newScore));
    }
  }

  void pauseGame() {
    _isPaused = true;
    pauseEngine();
    _audioManager.pauseAll();
  }

  void resumeGame() {
    _isPaused = false;
    resumeEngine();
    _audioManager.resumeAll();
  }

  void endGame() {
    if (_isGameOver) return;
    
    // Calculate distance bonus: 1 token per 100 meters traveled
    final distanceBonus = (_distanceTraveled / 100).floor();
    _airTokens += distanceBonus;
    
    debugPrint('🎮 GAME OVER!');
    debugPrint('  📏 Distance: ${_distanceTraveled.toInt()}m');
    debugPrint('  💰 Distance bonus: +$distanceBonus tokens (1 per 100m)');
    debugPrint('  💰 Total tokens this session: $_airTokens');
    
    _isGameOver = true;
    pauseEngine();
    
    // Play game over sound
    _audioManager.playSfx(SoundEffect.gameOver);
    _audioManager.stopAmbience();
    
    // Heavy screen shake
    _screenShake?.heavyShake();
    
    // Spawn burst particles at plane position
    if (_plane != null) {
      _particleSpawner?.spawnBurst(_plane!.position, color: Colors.red, particleCount: 30);
    }
    
    // REMOVED: Replay system deleted
    
    // Save game statistics
    _saveGameData();
    
    debugPrint('💰 About to call onGameOver callback with $_airTokens tokens');
    onGameOver();
  }

  Future<void> _saveGameData() async {
    // This will be called when game ends to persist data
    // Repository integration will happen here
    debugPrint('💾 Saving game data: Score ${_currentScore.toInt()}, Distance ${_distanceTraveled.toInt()}m');
  }

  void resetGame() {
    debugPrint('🔄 RESETTING GAME - Previous tokens: $_airTokens');
    
    _isGameOver = false;
    _isPaused = false;
    _currentScore = 0;
    _distanceTraveled = 0;
    _gameSpeed = GameConstants.baseScrollSpeed;
    _airTokens = 0; // Reset token counter for new game
    
    debugPrint('🔄 RESET COMPLETE - Tokens now: $_airTokens');
    
    // REMOVED: Replay system deleted
    
    // Clear all components from world
    for (final component in world.children.toList()) {
      world.remove(component);
    }
    
    // Reinitialize
    _initializeGame();
    resumeEngine();
  }

  void addScore(double points) {
    _currentScore += points;
    onScoreUpdate(_currentScore.toInt());
  }
  
  // FIXED: Add air tokens collected
  void addAirTokens(int amount) {
    _airTokens += amount;
    debugPrint('💰 Air tokens collected: +$amount (Total this session: $_airTokens)');
    debugPrint('💰 Current game state - isGameOver: $_isGameOver, isPaused: $_isPaused');
    // Note: Will be saved to repository on game over
  }
  
  int get airTokensCollected {
    debugPrint('💰 Getting airTokensCollected: $_airTokens');
    return _airTokens;
  }
  
  // FIXED: Boost system
  void applyBoost() {
    _boostActive = true;
    _boostTimer = _boostDuration;
    debugPrint('⚡ BOOST ACTIVATED! 3 seconds of speed and lift!');
    
    // Apply immediate upward force to plane
    _plane?.applyVerticalForce(200.0);
    
    // Add pressure for extra lift
    _plane?.addPressure(15.0);
    
    // Visual feedback
    spawnBurstEffect(_plane?.position ?? Vector2.zero(), 
      color: Colors.yellow, particleCount: 30);
    triggerScreenShake(intensity: 5, duration: 0.3);
  }
  
  bool get isBoostActive => _boostActive;
  
  // FIXED: Plane tells game how fast world should scroll
  void setWorldScrollSpeed(double speed) {
    _worldScrollSpeed = speed;
  }
  
  // Visual effects helpers
  void triggerScreenShake({required double intensity, required double duration}) {
    _screenShake?.shake(intensity: intensity, duration: duration);
  }
  
  void spawnBurstEffect(Vector2 position, {Color? color, int particleCount = 20}) {
    _particleSpawner?.spawnBurst(position, color: color, particleCount: particleCount);
  }
  
  void spawnAirLeakEffect(Vector2 position) {
    _particleSpawner?.spawnAirLeak(position);
  }
  
  // Audio helpers
  void playSoundEffect(SoundEffect effect) {
    _audioManager.playSfx(effect);
  }
  
  // Plane control methods
  void startInflatingPlane() {
    _plane?.startInflating();
  }
  
  void stopInflatingPlane() {
    _plane?.stopInflating();
  }
  
  void applyHorizontalForce(double force) {
    _plane?.applyHorizontalForce(force);
  }
}

// Legacy type alias for compatibility during migration
typedef BalloonTwistGame = AviaRollHighGame;
typedef BalloonPlayer = PlanePlayer;
