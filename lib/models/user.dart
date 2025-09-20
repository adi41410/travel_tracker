class User {
  final String id;
  final String? email;
  final String? phone;
  final String name;
  final String homeCity;
  final String preferredCurrency;
  final bool isGuest;
  final DateTime createdAt;
  final DateTime? lastSyncAt;

  User({
    required this.id,
    this.email,
    this.phone,
    required this.name,
    required this.homeCity,
    this.preferredCurrency = 'USD',
    this.isGuest = false,
    required this.createdAt,
    this.lastSyncAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'name': name,
      'homeCity': homeCity,
      'preferredCurrency': preferredCurrency,
      'isGuest': isGuest ? 1 : 0,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastSyncAt': lastSyncAt?.millisecondsSinceEpoch,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      phone: json['phone'],
      name: json['name'],
      homeCity: json['homeCity'],
      preferredCurrency: json['preferredCurrency'] ?? 'USD',
      isGuest: json['isGuest'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      lastSyncAt: json['lastSyncAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastSyncAt'])
          : null,
    );
  }

  User copyWith({
    String? email,
    String? phone,
    String? name,
    String? homeCity,
    String? preferredCurrency,
    DateTime? lastSyncAt,
  }) {
    return User(
      id: id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      homeCity: homeCity ?? this.homeCity,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      isGuest: isGuest,
      createdAt: createdAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }
}