class Activity {
  final String id;
  final String tripId;
  final String userId;
  final String title;
  final String? description;
  final DateTime date;
  final String? location;
  final double? latitude;
  final double? longitude;
  final List<String> photos;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;

  Activity({
    required this.id,
    required this.tripId,
    required this.userId,
    required this.title,
    this.description,
    required this.date,
    this.location,
    this.latitude,
    this.longitude,
    this.photos = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'userId': userId,
      'title': title,
      'description': description,
      'date': date.millisecondsSinceEpoch,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'photos': photos.join(','), // Store as comma-separated string
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isSynced': isSynced ? 1 : 0,
    };
  }

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      tripId: json['tripId'],
      userId: json['userId'],
      title: json['title'],
      description: json['description'],
      date: DateTime.fromMillisecondsSinceEpoch(json['date']),
      location: json['location'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      photos: json['photos'] != null && json['photos'].isNotEmpty
          ? json['photos'].split(',')
          : [],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt']),
      isSynced: json['isSynced'] == 1,
    );
  }

  Activity copyWith({
    String? title,
    String? description,
    DateTime? date,
    String? location,
    double? latitude,
    double? longitude,
    List<String>? photos,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return Activity(
      id: id,
      tripId: tripId,
      userId: userId,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      photos: photos ?? this.photos,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isSynced: isSynced ?? false,
    );
  }

  bool get hasLocation {
    return latitude != null && longitude != null;
  }

  bool get hasPhotos {
    return photos.isNotEmpty;
  }
}