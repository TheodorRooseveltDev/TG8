import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../data/repositories/game_repository.dart';
import '../../data/models/achievement.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final GameRepository _repository = GameRepository();
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final stats = await _repository.getStatistics();
    
    setState(() {
      _stats = stats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full screen background image
          Positioned.fill(
            child: Transform.scale(
              scale: 1.5,
              child: Image.asset(
                'assets/images/ui/menu_background.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/ui/button_normal.png'),
                              fit: BoxFit.fill,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Title
                      Text(
                        'STATISTICS',
                        style: GoogleFonts.russoOne(
                          fontSize: 32,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.8),
                              offset: const Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      
                      const Spacer(),
                      
                      const SizedBox(width: 60), // Balance back button
                    ],
                  ),
                ),
                
                // Statistics Content
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.accentAmber,
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Column(
                            children: [
                              // Main Stats Grid
                              Row(
                                children: [
                                  Expanded(
                                    child: _StatBox(
                                      title: 'HIGH SCORE',
                                      value: _formatNumber(_stats['highScore'] ?? 0),
                                      icon: '🎯',
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _StatBox(
                                      title: 'GAMES',
                                      value: _formatNumber(_stats['gamesPlayed'] ?? 0),
                                      icon: '🎮',
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 12),
                              
                              Row(
                                children: [
                                  Expanded(
                                    child: _StatBox(
                                      title: 'DISTANCE',
                                      value: '${_formatNumber((_stats['totalDistance'] ?? 0.0).toInt())}m',
                                      icon: '📏',
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _StatBox(
                                      title: 'TOKENS',
                                      value: _formatNumber(_stats['airTokens'] ?? 0),
                                      icon: '🪙',
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Performance Card
                              _PerformanceCard(
                                avgDistance: _calculateAverageDistance(),
                                avgScore: _calculateAverageScore(),
                                successRate: _calculateSuccessRate(),
                                tokensPerGame: _calculateTokensPerGame(),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Achievements Summary Card
                              _AchievementsSummaryCard(
                                stats: _stats,
                              ),
                              
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _calculateAverageDistance() {
    final games = _stats['gamesPlayed'] ?? 0;
    if (games == 0) return '0m';
    final avg = ((_stats['totalDistance'] ?? 0.0) / games).toInt();
    return '${_formatNumber(avg)}m';
  }

  String _calculateAverageScore() {
    final games = _stats['gamesPlayed'] ?? 0;
    if (games == 0) return '0';
    final avg = ((_stats['highScore'] ?? 0) / games).toInt();
    return _formatNumber(avg);
  }

  String _calculateTokensPerGame() {
    final games = _stats['gamesPlayed'] ?? 0;
    if (games == 0) return '0';
    final avg = ((_stats['airTokens'] ?? 0) / games).toInt();
    return _formatNumber(avg);
  }

  int _calculateSuccessRate() {
    final games = _stats['gamesPlayed'] ?? 0;
    if (games == 0) return 0;
    // Placeholder calculation - consider games where player reached > 500m as success
    return ((games * 0.6)).toInt(); // Mock value
  }
}

// Small stat box for grid layout
class _StatBox extends StatelessWidget {
  final String title;
  final String value;
  final String icon;

  const _StatBox({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/ui/dialogue_box.png'),
          fit: BoxFit.fill,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.exo2(
              fontSize: 13,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.russoOne(
              fontSize: 32,
              color: AppColors.accentAmber,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.8),
                  offset: const Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Performance metrics card
class _PerformanceCard extends StatelessWidget {
  final String avgDistance;
  final String avgScore;
  final int successRate;
  final String tokensPerGame;

  const _PerformanceCard({
    required this.avgDistance,
    required this.avgScore,
    required this.successRate,
    required this.tokensPerGame,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/ui/dialogue_box.png'),
          fit: BoxFit.fill,
        ),
      ),
      padding: const EdgeInsets.only(left: 50, right: 50, top: 0, bottom: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'PERFORMANCE',
            style: GoogleFonts.russoOne(
              fontSize: 20,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.8),
                  offset: const Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _PerformanceRow(label: 'Avg Distance', value: avgDistance),
          const SizedBox(height: 14),
          _PerformanceRow(label: 'Avg Score', value: avgScore),
          const SizedBox(height: 14),
          _PerformanceRow(label: 'Success Rate', value: '$successRate%'),
        ],
      ),
    );
  }
}

class _PerformanceRow extends StatelessWidget {
  final String label;
  final String value;

  const _PerformanceRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.exo2(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.russoOne(
            fontSize: 16,
            color: AppColors.accentAmber,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.8),
                offset: const Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Achievements summary card
class _AchievementsSummaryCard extends StatelessWidget {
  final Map<String, dynamic> stats;

  const _AchievementsSummaryCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final unlockedCount = GameAchievements.getUnlocked(stats).length;
    final totalCount = GameAchievements.all.length;
    final percentage = GameAchievements.getCompletionPercentage(stats);

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/ui/dialogue_box.png'),
          fit: BoxFit.fill,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 28),
      child: Column(
        children: [
          Text(
            'ACHIEVEMENTS',
            style: GoogleFonts.russoOne(
              fontSize: 18,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.8),
                  offset: const Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '🏆',
                style: TextStyle(fontSize: 48),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$unlockedCount / $totalCount',
                    style: GoogleFonts.russoOne(
                      fontSize: 32,
                      color: AppColors.accentAmber,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.8),
                          offset: const Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Unlocked',
                    style: GoogleFonts.exo2(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentage / 100,
                minHeight: 14,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentAmber),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${percentage.toInt()}% Complete',
            style: GoogleFonts.exo2(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
