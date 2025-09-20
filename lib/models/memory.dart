class Memory {
  final String id;
  final String userId;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final String locationName;
  final DateTime dateCreated;
  final List<String> imageUrls;
  final String? tripId;
  final List<String> tags;

  Memory({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.dateCreated,
    this.imageUrls = const [],
    this.tripId,
    this.tags = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
      'dateCreated': dateCreated.millisecondsSinceEpoch,
      'imageUrls': imageUrls.join(','),
      'tripId': tripId,
      'tags': tags.join(','),
    };
  }

  factory Memory.fromMap(Map<String, dynamic> map) {
    return Memory(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      locationName: map['locationName'] ?? '',
      dateCreated: DateTime.fromMillisecondsSinceEpoch(map['dateCreated'] ?? 0),
      imageUrls: map['imageUrls'] != null && map['imageUrls'].isNotEmpty 
          ? map['imageUrls'].split(',') 
          : [],
      tripId: map['tripId'],
      tags: map['tags'] != null && map['tags'].isNotEmpty 
          ? map['tags'].split(',') 
          : [],
    );
  }

  Memory copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    double? latitude,
    double? longitude,
    String? locationName,
    DateTime? dateCreated,
    List<String>? imageUrls,
    String? tripId,
    List<String>? tags,
  }) {
    return Memory(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      dateCreated: dateCreated ?? this.dateCreated,
      imageUrls: imageUrls ?? this.imageUrls,
      tripId: tripId ?? this.tripId,
      tags: tags ?? this.tags,
    );
  }
}