import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/upgrade_data.dart';
import '../models/user_profile.dart';
import '../../core/constants/game_constants.dart';

/// Repository for managing game data persistence
class GameRepository {
  static const String _keyHighScore = 'high_score';
  static const String _keyAirTokens = 'air_tokens';
  static const String _keyUpgrades = 'upgrades';
  static const String _keyUnlockedBalloons = 'unlocked_balloons';
  static const String _keyTotalDistance = 'total_distance';
  static const String _keyGamesPlayed = 'games_played';
  static const String _keyUserProfile = 'user_profile';
  static const String _keyFirstLaunch = 'first_launch';
  static const String _keyAchievements = 'achievements';
  static const String _keyBestStreak = 'best_streak';
  static const String _keyTotalFlightTime = 'total_flight_time';

  Future<void> saveHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyHighScore, score);
  }

  Future<int> getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyHighScore) ?? 0;
  }

  Future<void> saveAirTokens(int tokens) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyAirTokens, tokens);
  }

  Future<int> getAirTokens() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyAirTokens) ?? 0;
  }

  Future<void> addAirTokens(int amount) async {
    final current = await getAirTokens();
    await saveAirTokens(current + amount);
  }

  Future<void> saveUpgrades(List<UpgradeData> upgrades) async {
    final prefs = await SharedPreferences.getInstance();
    final json = upgrades.map((u) => u.toJson()).toList();
    await prefs.setString(_keyUpgrades, jsonEncode(json));
  }

  Future<List<UpgradeData>> getUpgrades() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyUpgrades);
    
    if (jsonString == null) {
      return _getDefaultUpgrades();
    }
    
    try {
      final List<dynamic> json = jsonDecode(jsonString);
      final upgrades = json.map((j) => UpgradeData.fromJson(j)).toList();
      
      // Check if old data has "Elasticity" name and reset if found
      if (upgrades.any((u) => u.name == 'Elasticity' || u.description.contains('balloon'))) {
        await resetUpgrades();
        return _getDefaultUpgrades();
      }
      
      return upgrades;
    } catch (e) {
      // If parsing fails, reset to defaults
      await resetUpgrades();
      return _getDefaultUpgrades();
    }
  }

  /// Clear old upgrade data and reload with new defaults
  Future<void> resetUpgrades() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUpgrades);
  }

  List<UpgradeData> _getDefaultUpgrades() {
    return [
      UpgradeData(
        type: UpgradeType.elasticity,
        level: 0,
        maxLevel: GameConstants.upgradeMaxLevel,
        cost: GameConstants.upgradeCostBase,
        name: 'Maneuverability',
        description: 'Increase aircraft agility and responsiveness',
      ),
      UpgradeData(
        type: UpgradeType.controlSensitivity,
        level: 0,
        maxLevel: GameConstants.upgradeMaxLevel,
        cost: GameConstants.upgradeCostBase,
        name: 'Precision Control',
        description: 'Improve flight control precision',
      ),
      UpgradeData(
        type: UpgradeType.windResistance,
        level: 0,
        maxLevel: GameConstants.upgradeMaxLevel,
        cost: GameConstants.upgradeCostBase,
        name: 'Turbulence Handling',
        description: 'Resist wind and environmental turbulence',
      ),
      UpgradeData(
        type: UpgradeType.fuelEfficiency,
        level: 0,
        maxLevel: GameConstants.upgradeMaxLevel,
        cost: GameConstants.upgradeCostBase,
        name: 'Fuel Efficiency',
        description: 'Reduce fuel consumption rate',
      ),
    ];
  }

  Future<void> saveUnlockedBalloons(List<BalloonType> balloons) async {
    final prefs = await SharedPreferences.getInstance();
    final indices = balloons.map((b) => b.index).toList();
    await prefs.setString(_keyUnlockedBalloons, jsonEncode(indices));
  }

  Future<List<BalloonType>> getUnlockedBalloons() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyUnlockedBalloons);
    
    if (jsonString == null) {
      return [BalloonType.standard]; // Default unlocked
    }
    
    final List<dynamic> json = jsonDecode(jsonString);
    return json.map((i) => BalloonType.values[i as int]).toList();
  }

  // Aliases for plane methods (same implementation)
  Future<void> saveUnlockedPlanes(List<PlaneType> planes) => saveUnlockedBalloons(planes);
  Future<List<PlaneType>> getUnlockedPlanes() => getUnlockedBalloons();

  Future<void> incrementGamesPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_keyGamesPlayed) ?? 0;
    await prefs.setInt(_keyGamesPlayed, current + 1);
  }

  Future<void> addTotalDistance(double distance) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getDouble(_keyTotalDistance) ?? 0.0;
    await prefs.setDouble(_keyTotalDistance, current + distance);
  }

  Future<Map<String, dynamic>> getStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'highScore': prefs.getInt(_keyHighScore) ?? 0,
      'airTokens': prefs.getInt(_keyAirTokens) ?? 0,
      'totalDistance': prefs.getDouble(_keyTotalDistance) ?? 0.0,
      'gamesPlayed': prefs.getInt(_keyGamesPlayed) ?? 0,
      'bestStreak': prefs.getInt(_keyBestStreak) ?? 0,
      'totalFlightTime': prefs.getDouble(_keyTotalFlightTime) ?? 0.0,
    };
  }

  // User Profile methods
  Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserProfile, jsonEncode(profile.toJson()));
  }

  Future<UserProfile?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyUserProfile);
    
    if (jsonString == null) return null;
    
    try {
      final json = jsonDecode(jsonString);
      return UserProfile.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFirstLaunch) ?? true;
  }

  Future<void> setFirstLaunchComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFirstLaunch, false);
  }

  // Achievement tracking
  Future<void> saveAchievementProgress(String achievementId, double progress) async {
    final prefs = await SharedPreferences.getInstance();
    final achievements = prefs.getString(_keyAchievements);
    Map<String, double> achievementMap = {};
    
    if (achievements != null) {
      achievementMap = Map<String, double>.from(jsonDecode(achievements));
    }
    
    achievementMap[achievementId] = progress;
    await prefs.setString(_keyAchievements, jsonEncode(achievementMap));
  }

  Future<Map<String, double>> getAchievementProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final achievements = prefs.getString(_keyAchievements);
    
    if (achievements == null) return {};
    
    try {
      return Map<String, double>.from(jsonDecode(achievements));
    } catch (e) {
      return {};
    }
  }

  // Additional stats tracking
  Future<void> updateBestStreak(int streak) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_keyBestStreak) ?? 0;
    if (streak > current) {
      await prefs.setInt(_keyBestStreak, streak);
    }
  }

  Future<void> addFlightTime(double seconds) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getDouble(_keyTotalFlightTime) ?? 0.0;
    await prefs.setDouble(_keyTotalFlightTime, current + seconds);
  }

  /// Clear ALL data from SharedPreferences (for reset/delete functionality)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
