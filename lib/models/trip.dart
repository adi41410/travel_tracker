class Trip {
  final String id;
  final String userId;
  final String name;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;

  Trip({
    required this.id,
    required this.userId,
    required this.name,
    required this.destination,
    required this.startDate,
    required this.endDate,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'destination': destination,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'description': description,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isSynced': isSynced ? 1 : 0,
    };
  }

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      destination: json['destination'],
      startDate: DateTime.fromMillisecondsSinceEpoch(json['startDate']),
      endDate: DateTime.fromMillisecondsSinceEpoch(json['endDate']),
      description: json['description'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt']),
      isSynced: json['isSynced'] == 1,
    );
  }

  Trip copyWith({
    String? name,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return Trip(
      id: id,
      userId: userId,
      name: name ?? this.name,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isSynced: isSynced ?? false,
    );
  }

  int get durationInDays {
    return endDate.difference(startDate).inDays + 1;
  }

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate.subtract(Duration(days: 1))) &&
           now.isBefore(endDate.add(Duration(days: 1)));
  }

  bool get isUpcoming {
    return DateTime.now().isBefore(startDate);
  }

  bool get isPast {
    return DateTime.now().isAfter(endDate);
  }
}