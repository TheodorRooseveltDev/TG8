/// Upgrade types available in the game
enum UpgradeType {
  elasticity,        // Aircraft maneuverability
  controlSensitivity, // Control response
  windResistance,    // Turbulence handling
  fuelEfficiency,    // Fuel consumption (was pressureEfficiency)
}

/// Data model for upgrades
class UpgradeData {
  final UpgradeType type;
  final int level;
  final int maxLevel;
  final int cost;
  final String name;
  final String description;

  UpgradeData({
    required this.type,
    required this.level,
    required this.maxLevel,
    required this.cost,
    required this.name,
    required this.description,
  });

  bool get isMaxLevel => level >= maxLevel;

  UpgradeData copyWith({
    UpgradeType? type,
    int? level,
    int? maxLevel,
    int? cost,
    String? name,
    String? description,
  }) {
    return UpgradeData(
      type: type ?? this.type,
      level: level ?? this.level,
      maxLevel: maxLevel ?? this.maxLevel,
      cost: cost ?? this.cost,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.index,
      'level': level,
      'maxLevel': maxLevel,
      'cost': cost,
      'name': name,
      'description': description,
    };
  }

  factory UpgradeData.fromJson(Map<String, dynamic> json) {
    return UpgradeData(
      type: UpgradeType.values[json['type'] as int],
      level: json['level'] as int,
      maxLevel: json['maxLevel'] as int,
      cost: json['cost'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }
}
