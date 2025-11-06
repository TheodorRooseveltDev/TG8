/// Game Constants and Configuration Values
class GameConstants {
  GameConstants._();

  // Physics Constants
  static const double gravity = 9.8;
  static const double baseAscensionSpeed = 50.0;
  static const double maxVerticalSpeed = 200.0;
  static const double maxHorizontalSpeed = 150.0;
  static const double airDragCoefficient = 0.47;

  // Plane Properties
  static const double planeBaseRadius = 30.0;
  static const double planeMinRadius = 20.0;
  static const double planeMaxRadius = 50.0;
  static const double optimalFuelMin = 40.0;
  static const double optimalFuelMax = 70.0;
  static const double maxFuel = 100.0;
  static const double stallFuel = 10.0;
  static const double fuelDecayRate = 5.0; // per second
  static const double refuelRate = 20.0; // per second
  static const double fuelDrainRate = 30.0; // per second
  
  // Legacy balloon constants (aliases for compatibility)
  static const double balloonBaseRadius = planeBaseRadius;
  static const double balloonMinRadius = planeMinRadius;
  static const double balloonMaxRadius = planeMaxRadius;
  static const double optimalPressureMin = optimalFuelMin;
  static const double optimalPressureMax = optimalFuelMax;
  static const double burstPressure = maxFuel;
  static const double stallPressure = stallFuel;
  static const double pressureDecayRate = fuelDecayRate;
  static const double inflationRate = refuelRate;
  static const double deflationRate = fuelDrainRate;

  // Game Difficulty
  static const double baseScrollSpeed = 100.0;
  static const double scrollSpeedIncrement = 2.0; // per second
  static const double maxScrollSpeed = 400.0;
  static const double scrollAcceleration = 5.0; // gradual speed increase per second
  static const double difficultyMultiplier = 1.0;
  static const double pressureLossRate = 2.0; // natural pressure loss per second

  // Scoring
  static const int scorePerMeter = 10;
  static const int nearMissBonus = 50;
  static const double nearMissDistance = 5.0;
  static const int fuelMasteryBonus = 5; // per second in optimal
  static const double comboMultiplier = 1.5;
  static const int checkpointBonus = 100;

  // Checkpoints
  static const double checkpointSpawnInterval = 500.0; // meters
  static const double checkpointSafeZoneRadius = 100.0;

  // Collectibles
  static const int airRingTokenValue = 10;
  static const int fuelBoosterDuration = 5; // seconds
  static const double fuelBoosterSizeMultiplier = 1.5;
  static const int timeSlowerDuration = 3; // seconds
  static const double timeSlowerFactor = 0.5;

  // Obstacles
  static const double obstacleSpawnMinDistance = 150.0;
  static const double obstacleSpawnMaxDistance = 300.0;
  static const double fanRotationSpeed = 2.0; // radians per second
  static const double fanTurbulenceRadius = 80.0;
  static const double heatSourceRadius = 60.0;
  static const double heatFuelIncrease = 30.0;

  // Camera
  static const double cameraFollowSpeed = 5.0;
  static const double cameraZoomMin = 0.8;
  static const double cameraZoomMax = 1.2;
  static const double cameraShakeIntensity = 10.0;

  // Upgrades
  static const int upgradeMaxLevel = 10;
  static const int upgradeCostBase = 50;
  static const double upgradeCostMultiplier = 1.5;

  // Plane Types
  static const Map<String, Map<String, double>> planeStats = {
    'standard': {
      'speed': 1.0,
      'control': 1.0,
      'agility': 1.0,
      'durability': 1.0,
      'efficiency': 1.0,
    },
    'fighter': {
      'speed': 0.7,
      'control': 1.5,
      'agility': 1.2,
      'durability': 0.8,
      'efficiency': 1.2,
    },
    'jet': {
      'speed': 1.8,
      'control': 0.6,
      'agility': 0.7,
      'durability': 0.7,
      'efficiency': 0.9,
    },
    'cargo': {
      'speed': 1.2,
      'control': 0.9,
      'agility': 1.3,
      'durability': 1.3,
      'efficiency': 1.1,
    },
    // Legacy names (same stats as new names)
    'foil': {
      'speed': 0.7,
      'control': 1.5,
      'agility': 1.2,
      'durability': 0.8,
      'efficiency': 1.2,
    },
    'hydrogen': {
      'speed': 1.8,
      'control': 0.6,
      'agility': 0.7,
      'durability': 0.7,
      'efficiency': 0.9,
    },
    'cluster': {
      'speed': 1.2,
      'control': 0.9,
      'agility': 1.3,
      'durability': 1.3,
      'efficiency': 1.1,
    },
  };
  
  // Legacy balloon stats (aliases for compatibility)
  static const Map<String, Map<String, double>> balloonStats = planeStats;
  
  // Plane type-specific constants
  static const Map<PlaneType, Map<String, double>> planeTypes = {
    PlaneType.standard: {
      'maxPressure': 100.0,
      'burstThreshold': 95.0,
      'controlSensitivity': 1.0,
      'autoAscent': 50.0,
    },
    PlaneType.fighter: {
      'maxPressure': 120.0,
      'burstThreshold': 110.0,
      'controlSensitivity': 1.5,
      'autoAscent': 35.0,
    },
    PlaneType.jet: {
      'maxPressure': 80.0,
      'burstThreshold': 75.0,
      'controlSensitivity': 0.6,
      'autoAscent': 90.0,
    },
    PlaneType.cargo: {
      'maxPressure': 150.0,
      'burstThreshold': 140.0,
      'controlSensitivity': 0.9,
      'autoAscent': 60.0,
    },
    // Legacy names (same values)
    PlaneType.foil: {
      'maxPressure': 120.0,
      'burstThreshold': 110.0,
      'controlSensitivity': 1.5,
      'autoAscent': 35.0,
    },
    PlaneType.hydrogen: {
      'maxPressure': 80.0,
      'burstThreshold': 75.0,
      'controlSensitivity': 0.6,
      'autoAscent': 90.0,
    },
    PlaneType.cluster: {
      'maxPressure': 150.0,
      'burstThreshold': 140.0,
      'controlSensitivity': 0.9,
      'autoAscent': 60.0,
    },
  };
  
  // Legacy balloon types (aliases for compatibility)
  static const Map<PlaneType, Map<String, double>> balloonTypes = planeTypes;

  // Biome Altitudes (meters)
  static const double biomeTavernEnd = 1000.0;
  static const double biomeSkyEnd = 3000.0;
  static const double biomeStratosphereEnd = 8000.0;
  static const double biomeMesosphereEnd = 15000.0;
  static const double biomeSpaceStart = 15000.0;

  // Audio
  static const double musicVolume = 0.7;
  static const double sfxVolume = 0.8;
  static const double ambienceVolume = 0.5;

  // UI
  static const double buttonHeight = 60.0;
  static const double buttonPressScale = 0.95;
  static const int tapAnimationDuration = 150; // milliseconds
  static const int screenTransitionDuration = 300; // milliseconds
  static const double dialogBlurAmount = 5.0;

  // Performance
  static const int obstaclePoolSize = 50;
  static const double cullingDistance = 100.0; // off-screen distance

  // Daily Challenge
  static const int dailyChallengeReward = 500;
  static const int leaderboardTopCount = 100;

  // Tutorial
  static const int tutorialStepCount = 5;
  static const int tutorialMessageDuration = 3; // seconds
}

/// Plane types enum
enum PlaneType {
  standard,
  fighter,  // was foil
  jet,      // was hydrogen  
  cargo,    // was cluster
  
  // Legacy names (deprecated - use new names above)
  @Deprecated('Use fighter instead')
  foil,
  @Deprecated('Use jet instead')
  hydrogen,
  @Deprecated('Use cargo instead')
  cluster,
}

// Legacy balloon type alias for compatibility
typedef BalloonType = PlaneType;
