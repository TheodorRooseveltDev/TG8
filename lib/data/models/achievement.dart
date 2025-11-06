/// Achievement definitions for the game
class Achievement {
  final String id;
  final String name;
  final String description;
  final String iconEmoji;
  final AchievementTier tier;
  final bool Function(Map<String, dynamic> stats) isUnlocked;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.iconEmoji,
    required this.tier,
    required this.isUnlocked,
  });
}

enum AchievementTier {
  bronze,
  silver,
  gold,
  platinum,
}

class GameAchievements {
  static final List<Achievement> all = [
    // Distance achievements
    Achievement(
      id: 'first_flight',
      name: 'First Flight',
      description: 'Complete your first flight',
      iconEmoji: '✈️',
      tier: AchievementTier.bronze,
      isUnlocked: (stats) => (stats['gamesPlayed'] ?? 0) >= 1,
    ),
    Achievement(
      id: 'sky_explorer',
      name: 'Sky Explorer',
      description: 'Reach 500m altitude',
      iconEmoji: '☁️',
      tier: AchievementTier.bronze,
      isUnlocked: (stats) => (stats['totalDistance'] ?? 0.0) >= 500,
    ),
    Achievement(
      id: 'stratosphere_pilot',
      name: 'Stratosphere Ace',
      description: 'Reach 3000m altitude',
      iconEmoji: '🌤️',
      tier: AchievementTier.silver,
      isUnlocked: (stats) => (stats['totalDistance'] ?? 0.0) >= 3000,
    ),
    Achievement(
      id: 'space_pioneer',
      name: 'Space Pioneer',
      description: 'Reach 15000m altitude',
      iconEmoji: '🚀',
      tier: AchievementTier.gold,
      isUnlocked: (stats) => (stats['totalDistance'] ?? 0.0) >= 15000,
    ),
    
    // Score achievements
    Achievement(
      id: 'novice_scorer',
      name: 'Novice Aviator',
      description: 'Score 5,000 points',
      iconEmoji: '⭐',
      tier: AchievementTier.bronze,
      isUnlocked: (stats) => (stats['highScore'] ?? 0) >= 5000,
    ),
    Achievement(
      id: 'skilled_pilot',
      name: 'Skilled Aviator',
      description: 'Score 25,000 points',
      iconEmoji: '🌟',
      tier: AchievementTier.silver,
      isUnlocked: (stats) => (stats['highScore'] ?? 0) >= 25000,
    ),
    Achievement(
      id: 'master_pilot',
      name: 'Master Aviator',
      description: 'Score 100,000 points',
      iconEmoji: '💫',
      tier: AchievementTier.gold,
      isUnlocked: (stats) => (stats['highScore'] ?? 0) >= 100000,
    ),
    Achievement(
      id: 'legend',
      name: 'Aviation Legend',
      description: 'Score 500,000 points',
      iconEmoji: '👑',
      tier: AchievementTier.platinum,
      isUnlocked: (stats) => (stats['highScore'] ?? 0) >= 500000,
    ),
    
    // Token achievements
    Achievement(
      id: 'token_collector',
      name: 'Sky Token Collector',
      description: 'Collect 1,000 Air Tokens',
      iconEmoji: '🪙',
      tier: AchievementTier.bronze,
      isUnlocked: (stats) => (stats['airTokens'] ?? 0) >= 1000,
    ),
    Achievement(
      id: 'token_hoarder',
      name: 'Aviation Hoarder',
      description: 'Collect 10,000 Air Tokens',
      iconEmoji: '💰',
      tier: AchievementTier.silver,
      isUnlocked: (stats) => (stats['airTokens'] ?? 0) >= 10000,
    ),
    Achievement(
      id: 'token_tycoon',
      name: 'Flight Tycoon',
      description: 'Collect 100,000 Air Tokens',
      iconEmoji: '💎',
      tier: AchievementTier.gold,
      isUnlocked: (stats) => (stats['airTokens'] ?? 0) >= 100000,
    ),
    
    // Experience achievements
    Achievement(
      id: 'rookie',
      name: 'Rookie Pilot',
      description: 'Complete 10 flights',
      iconEmoji: '🛩️',
      tier: AchievementTier.bronze,
      isUnlocked: (stats) => (stats['gamesPlayed'] ?? 0) >= 10,
    ),
    Achievement(
      id: 'veteran',
      name: 'Veteran Aviator',
      description: 'Complete 50 flights',
      iconEmoji: '🛫',
      tier: AchievementTier.silver,
      isUnlocked: (stats) => (stats['gamesPlayed'] ?? 0) >= 50,
    ),
    Achievement(
      id: 'dedicated',
      name: 'Ace Pilot',
      description: 'Complete 100 flights',
      iconEmoji: '🏆',
      tier: AchievementTier.gold,
      isUnlocked: (stats) => (stats['gamesPlayed'] ?? 0) >= 100,
    ),
    Achievement(
      id: 'obsessed',
      name: 'Sky Master',
      description: 'Complete 500 flights',
      iconEmoji: '🎖️',
      tier: AchievementTier.platinum,
      isUnlocked: (stats) => (stats['gamesPlayed'] ?? 0) >= 500,
    ),
  ];

  /// Get all unlocked achievements
  static List<Achievement> getUnlocked(Map<String, dynamic> stats) {
    return all.where((achievement) => achievement.isUnlocked(stats)).toList();
  }

  /// Get locked achievements
  static List<Achievement> getLocked(Map<String, dynamic> stats) {
    return all.where((achievement) => !achievement.isUnlocked(stats)).toList();
  }

  /// Get achievement unlock percentage
  static double getCompletionPercentage(Map<String, dynamic> stats) {
    final unlocked = getUnlocked(stats).length;
    return (unlocked / all.length) * 100;
  }
}
