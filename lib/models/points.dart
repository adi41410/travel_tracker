enum PointType {
  tripCreated,
  tripCompleted,
  memoryAdded,
  placeVisited,
  photosUploaded,
  milestoneReached,
  dailyLogin,
  profileCompleted,
}

class PointsEntry {
  final String id;
  final String userId;
  final PointType type;
  final int points;
  final String description;
  final DateTime dateEarned;
  final String? relatedId; // Trip ID, Memory ID, etc.

  PointsEntry({
    required this.id,
    required this.userId,
    required this.type,
    required this.points,
    required this.description,
    required this.dateEarned,
    this.relatedId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type.index,
      'points': points,
      'description': description,
      'dateEarned': dateEarned.millisecondsSinceEpoch,
      'relatedId': relatedId,
    };
  }

  factory PointsEntry.fromMap(Map<String, dynamic> map) {
    return PointsEntry(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      type: PointType.values[map['type'] ?? 0],
      points: map['points'] ?? 0,
      description: map['description'] ?? '',
      dateEarned: DateTime.fromMillisecondsSinceEpoch(map['dateEarned'] ?? 0),
      relatedId: map['relatedId'],
    );
  }
}

class UserPoints {
  final String userId;
  final int totalPoints;
  final int level;
  final List<PointsEntry> recentEntries;
  final Map<PointType, int> pointsByType;

  UserPoints({
    required this.userId,
    required this.totalPoints,
    required this.level,
    this.recentEntries = const [],
    this.pointsByType = const {},
  });

  int get pointsToNextLevel {
    final nextLevelPoints = (level + 1) * 1000;
    return nextLevelPoints - totalPoints;
  }

  double get levelProgress {
    final currentLevelPoints = level * 1000;
    final nextLevelPoints = (level + 1) * 1000;
    final progressPoints = totalPoints - currentLevelPoints;
    return progressPoints / (nextLevelPoints - currentLevelPoints);
  }

  String get levelTitle {
    if (level < 5) return "Explorer";
    if (level < 10) return "Adventurer";
    if (level < 20) return "Wanderer";
    if (level < 35) return "Globetrotter";
    if (level < 50) return "Travel Master";
    return "Legendary Traveler";
  }

  UserPoints copyWith({
    String? userId,
    int? totalPoints,
    int? level,
    List<PointsEntry>? recentEntries,
    Map<PointType, int>? pointsByType,
  }) {
    return UserPoints(
      userId: userId ?? this.userId,
      totalPoints: totalPoints ?? this.totalPoints,
      level: level ?? this.level,
      recentEntries: recentEntries ?? this.recentEntries,
      pointsByType: pointsByType ?? this.pointsByType,
    );
  }
}

class PointsConfig {
  static const Map<PointType, int> pointsMap = {
    PointType.tripCreated: 100,
    PointType.tripCompleted: 500,
    PointType.memoryAdded: 50,
    PointType.placeVisited: 25,
    PointType.photosUploaded: 10,
    PointType.milestoneReached: 1000,
    PointType.dailyLogin: 5,
    PointType.profileCompleted: 200,
  };

  static const Map<PointType, String> descriptions = {
    PointType.tripCreated: "Created a new trip",
    PointType.tripCompleted: "Completed a trip",
    PointType.memoryAdded: "Added a travel memory",
    PointType.placeVisited: "Visited a new place",
    PointType.photosUploaded: "Uploaded photos",
    PointType.milestoneReached: "Reached a milestone",
    PointType.dailyLogin: "Daily login bonus",
    PointType.profileCompleted: "Completed profile setup",
  };
}