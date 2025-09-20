enum ExpenseCategory {
  transportation,
  accommodation,
  food,
  activities,
  shopping,
  miscellaneous,
}

class Expense {
  final String id;
  final String tripId;
  final String userId;
  final String? activityId;
  final double amount;
  final String currency;
  final ExpenseCategory category;
  final String? description;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;

  Expense({
    required this.id,
    required this.tripId,
    required this.userId,
    this.activityId,
    required this.amount,
    required this.currency,
    required this.category,
    this.description,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'userId': userId,
      'activityId': activityId,
      'amount': amount,
      'currency': currency,
      'category': category.name,
      'description': description,
      'date': date.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isSynced': isSynced ? 1 : 0,
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      tripId: json['tripId'],
      userId: json['userId'],
      activityId: json['activityId'],
      amount: json['amount'].toDouble(),
      currency: json['currency'],
      category: ExpenseCategory.values
          .firstWhere((e) => e.name == json['category']),
      description: json['description'],
      date: DateTime.fromMillisecondsSinceEpoch(json['date']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt']),
      isSynced: json['isSynced'] == 1,
    );
  }

  Expense copyWith({
    double? amount,
    String? currency,
    ExpenseCategory? category,
    String? description,
    DateTime? date,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return Expense(
      id: id,
      tripId: tripId,
      userId: userId,
      activityId: activityId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      description: description ?? this.description,
      date: date ?? this.date,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isSynced: isSynced ?? false,
    );
  }

  String get categoryDisplayName {
    switch (category) {
      case ExpenseCategory.transportation:
        return 'Transportation';
      case ExpenseCategory.accommodation:
        return 'Accommodation';
      case ExpenseCategory.food:
        return 'Food & Drink';
      case ExpenseCategory.activities:
        return 'Activities';
      case ExpenseCategory.shopping:
        return 'Shopping';
      case ExpenseCategory.miscellaneous:
        return 'Miscellaneous';
    }
  }

  String get formattedAmount {
    return '\$${amount.toStringAsFixed(2)}';
  }
}