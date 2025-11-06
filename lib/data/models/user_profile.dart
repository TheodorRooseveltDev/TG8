/// User profile data model
class UserProfile {
  final String pilotName;
  final String callSign;
  final DateTime accountCreated;
  final int avatarIndex;
  
  UserProfile({
    required this.pilotName,
    required this.callSign,
    required this.accountCreated,
    this.avatarIndex = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'pilotName': pilotName,
      'callSign': callSign,
      'accountCreated': accountCreated.toIso8601String(),
      'avatarIndex': avatarIndex,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      pilotName: json['pilotName'] as String,
      callSign: json['callSign'] as String,
      accountCreated: DateTime.parse(json['accountCreated'] as String),
      avatarIndex: json['avatarIndex'] as int? ?? 0,
    );
  }

  UserProfile copyWith({
    String? pilotName,
    String? callSign,
    DateTime? accountCreated,
    int? avatarIndex,
  }) {
    return UserProfile(
      pilotName: pilotName ?? this.pilotName,
      callSign: callSign ?? this.callSign,
      accountCreated: accountCreated ?? this.accountCreated,
      avatarIndex: avatarIndex ?? this.avatarIndex,
    );
  }
}
