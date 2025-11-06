import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import '../../game/balloon_twist_game.dart';
import '../../core/constants/game_constants.dart';
import '../../data/repositories/game_repository.dart';
import '../widgets/game_over_dialog.dart';
import '../widgets/balloon_info_display.dart';
import '../widgets/tutorial_overlay.dart';
import '../../core/constants/app_colors.dart';

/// Main gameplay screen with Flame game widget and HUD overlay
class GameScreen extends StatefulWidget {
  final PlaneType? selectedPlaneType;
  
  const GameScreen({
    super.key,
    this.selectedPlaneType,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late AviaRollHighGame _game;
  final ValueNotifier<int> _scoreNotifier = ValueNotifier<int>(0);
  final GameRepository _repository = GameRepository();
  bool _isPaused = false;
  bool _showTutorial = false;

  @override
  void initState() {
    super.initState();
    _checkTutorial();
    _initializeGame();
  }
  
  Future<void> _checkTutorial() async {
    final completed = await TutorialOverlay.hasCompletedTutorial();
    if (!completed) {
      setState(() {
        _showTutorial = true;
      });
    }
  }

  void _initializeGame() {
    _game = AviaRollHighGame(
      selectedPlaneType: widget.selectedPlaneType ?? PlaneType.standard,
      onGameOver: _handleGameOver,
      onScoreUpdate: (score) {
        _scoreNotifier.value = score;
      },
    );
  }

  void _handleGameOver() async {
    // Get game stats
    final tokensCollected = _game.airTokensCollected;
    final distance = _game.distanceTraveled.toInt();
    final score = _scoreNotifier.value;
    
    // SAVE ALL STATS TO PERSISTENT STORAGE!
    await _repository.addAirTokens(tokensCollected);
    await _repository.incrementGamesPlayed();
    await _repository.addTotalDistance(distance.toDouble());
    
    // Update high score if needed
    final currentHighScore = await _repository.getHighScore();
    if (score > currentHighScore) {
      await _repository.saveHighScore(score);
      debugPrint('🏆 NEW HIGH SCORE: $score!');
    }
    
    debugPrint('💰 SAVED $tokensCollected tokens to storage!');
    debugPrint('📊 Distance: $distance m, Score: $score');
    
    // Show game over dialog
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameOverDialog(
        score: score,
        distance: distance,
        airTokensEarned: tokensCollected,
        onRestart: () {
          Navigator.of(context).pop();
          _restartGame();
        },
        onMainMenu: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _game.pauseGame();
      } else {
        _game.resumeGame();
      }
    });
  }

  void _restartGame() {
    // Reinitialize game with same balloon type
    setState(() {
      _scoreNotifier.value = 0;
      _isPaused = false;
      _initializeGame();
    });
  }

  @override
  void dispose() {
    _scoreNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTapDown: (_) => _game.startInflatingPlane(),
          onTapUp: (_) => _game.stopInflatingPlane(),
          onTapCancel: () => _game.stopInflatingPlane(),
          onPanUpdate: (details) => _game.applyHorizontalForce(details.delta.dx * 2),
          child: Stack(
            children: [
              // Game widget
              GameWidget(
                game: _game,
              ),
              
              // HUD overlay
              if (!_isPaused && !_showTutorial) _buildFloatingHUD(),
              
              // Pause overlay
              if (_isPaused && !_showTutorial) _buildPauseOverlay(context, _game),
              
              // Tutorial overlay
              if (_showTutorial)
                TutorialOverlay(
                  onComplete: () {
                    setState(() {
                      _showTutorial = false;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingHUD() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Top bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Score
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBrass.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.accentAmber,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: AppColors.accentAmber,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      ValueListenableBuilder<int>(
                        valueListenable: _scoreNotifier,
                        builder: (context, score, child) {
                          return Text(
                            score.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                // FIXED: Centered Pressure Gauge Display
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.3),
                    border: Border.all(
                      color: AppColors.accentAmber,
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${_game.planeFuel.toInt()}%',
                      style: const TextStyle(
                        color: AppColors.accentAmber,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                // Pause button
                IconButton(
                  onPressed: _togglePause,
                  icon: const Icon(Icons.pause),
                  color: AppColors.accentAmber,
                  iconSize: 32,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Balloon type indicator
            BalloonInfoDisplay(
              balloonType: widget.selectedPlaneType ?? PlaneType.standard,
            ),
            
            const SizedBox(height: 16),
            
            // Instructions text (disappears after a few seconds)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'TAP to inflate • SWIPE to move',
                style: TextStyle(
                  color: AppColors.accentAmber,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPauseOverlay(BuildContext context, AviaRollHighGame game) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.secondaryWood,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.accentAmber,
              width: 3,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'PAUSED',
                style: TextStyle(
                  color: AppColors.accentAmber,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              
              // Resume button
              ElevatedButton.icon(
                onPressed: _togglePause,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Resume'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBrass,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Restart button
              ElevatedButton.icon(
                onPressed: () {
                  _togglePause();
                  _restartGame();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Restart'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentAmber,
                  foregroundColor: AppColors.secondaryWood,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Main menu button
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Main Menu',
                  style: TextStyle(
                    color: AppColors.accentAmber,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
