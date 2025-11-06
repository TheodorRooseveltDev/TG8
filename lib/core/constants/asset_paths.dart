/// Asset path constants for easy access throughout the app
class AssetPaths {
  AssetPaths._();

    // Balloons
  static const String balloonsDir = 'assets/images/balloons/';
  static const String balloonStandard = '${balloonsDir}standart_balloon.png';
  static const String balloonFoil = '${balloonsDir}foil_balloon.png';
  static const String balloonHydrogen = '${balloonsDir}hydrogen_balloon.png';
  static const String balloonCluster = '${balloonsDir}cluster_balloon.png';

  // Obstacles
  static const String obstaclesDir = 'assets/images/obstacles/';
  static const String obstacleFan = '${obstaclesDir}rotating_fan.png';
  static const String obstacleCactus = '${obstaclesDir}cactus.png';
  static const String obstacleWire = '${obstaclesDir}barbed_wire.png';
  static const String obstacleSpikes = '${obstaclesDir}spikes.png';
  static const String obstacleCandle = '${obstaclesDir}candle.png';
  static const String obstacleStorm = '${obstaclesDir}storm_cloud.png';

    // Backgrounds
  static const String backgroundsDir = 'assets/images/backgrounds/';
  static const String bgAboveGround = '${backgroundsDir}above_ground.png';
  static const String bgFarGround = '${backgroundsDir}far_ground.png';
  static const String bgSpace = '${backgroundsDir}space.png';
  static const String bgDeepSpace = '${backgroundsDir}deep_space.png';

  // UI Elements
  static const String uiDir = 'assets/images/ui/';
  static const String buttonNormal = '${uiDir}button_normal.png';
  static const String buttonPressed = '${uiDir}button_pressed.png';
  static const String pressureGauge = '${uiDir}pressure_gauge.png';
  static const String checkpointIcon = '${uiDir}checkpoint_icon.png';
  static const String menuBackground = '${uiDir}menu_background.png';
  static const String dialogBox = '${uiDir}dialog_box.png';
  static const String progressBar = '${uiDir}progress_bar.png';
  static const String starIcon = '${uiDir}star_icon.png';
  static const String lockIcon = '${uiDir}lock_icon.png';

  // Collectibles
  static const String collectiblesDir = 'assets/images/collectibles/';
  static const String airRing = '${collectiblesDir}air_ring.png';
  static const String pressureBooster = '${collectiblesDir}pressure_booster.png';
  static const String timeSlower = '${collectiblesDir}time_slower.png';
  static const String airToken = '${collectiblesDir}air_token.png';

  // Music
  static const String musicDir = 'assets/audio/music/';
  static const String menuTheme = '${musicDir}menu_theme.mp3';
  static const String gameTheme = '${musicDir}game_theme.mp3';
  static const String bossTheme = '${musicDir}boss_theme.mp3';

  // Sound Effects
  static const String sfxDir = 'assets/audio/sfx/';
  static const String windAmbience = '${sfxDir}wind_ambience.mp3';
  static const String pressureHiss = '${sfxDir}pressure_hiss.mp3';
  static const String burst = '${sfxDir}burst.mp3';
  static const String puncture = '${sfxDir}puncture.mp3';
  static const String checkpoint = '${sfxDir}checkpoint.mp3';
  static const String collectiblePickup = '${sfxDir}collectible_pickup.mp3';
  static const String tapFeedback = '${sfxDir}tap_feedback.mp3';
  static const String buttonPress = '${sfxDir}button_press.mp3';
  static const String inflate = '${sfxDir}inflate.mp3';
  static const String deflate = '${sfxDir}deflate.mp3';
  static const String collision = '${sfxDir}collision.mp3';
  static const String fanRotate = '${sfxDir}fan_rotate.mp3';
  static const String electricZap = '${sfxDir}electric_zap.mp3';
}
