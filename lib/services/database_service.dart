import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/trip.dart';
import '../models/activity.dart';
import '../models/expense.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'travel_tracker.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT,
        phone TEXT,
        name TEXT NOT NULL,
        homeCity TEXT NOT NULL,
        preferredCurrency TEXT DEFAULT 'USD',
        isGuest INTEGER DEFAULT 0,
        createdAt INTEGER NOT NULL,
        lastSyncAt INTEGER
      )
    ''');

    // Create trips table
    await db.execute('''
      CREATE TABLE trips (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        name TEXT NOT NULL,
        destination TEXT NOT NULL,
        startDate INTEGER NOT NULL,
        endDate INTEGER NOT NULL,
        description TEXT,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL,
        isSynced INTEGER DEFAULT 0,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Create activities table
    await db.execute('''
      CREATE TABLE activities (
        id TEXT PRIMARY KEY,
        tripId TEXT NOT NULL,
        userId TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        date INTEGER NOT NULL,
        location TEXT,
        latitude REAL,
        longitude REAL,
        photos TEXT,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL,
        isSynced INTEGER DEFAULT 0,
        FOREIGN KEY (tripId) REFERENCES trips (id) ON DELETE CASCADE,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Create expenses table
    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        tripId TEXT NOT NULL,
        userId TEXT NOT NULL,
        activityId TEXT,
        amount REAL NOT NULL,
        currency TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT,
        date INTEGER NOT NULL,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL,
        isSynced INTEGER DEFAULT 0,
        FOREIGN KEY (tripId) REFERENCES trips (id) ON DELETE CASCADE,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (activityId) REFERENCES activities (id) ON DELETE CASCADE
      )
    ''');

    // Create memories table
    await db.execute('''
      CREATE TABLE memories (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        locationName TEXT NOT NULL,
        dateCreated INTEGER NOT NULL,
        imageUrls TEXT,
        tripId TEXT,
        tags TEXT,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (tripId) REFERENCES trips (id) ON DELETE SET NULL
      )
    ''');

    // Create points entries table
    await db.execute('''
      CREATE TABLE points_entries (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        type INTEGER NOT NULL,
        points INTEGER NOT NULL,
        description TEXT NOT NULL,
        dateEarned INTEGER NOT NULL,
        relatedId TEXT,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_trips_userId ON trips (userId)');
    await db.execute(
      'CREATE INDEX idx_activities_tripId ON activities (tripId)',
    );
    await db.execute('CREATE INDEX idx_activities_date ON activities (date)');
    await db.execute('CREATE INDEX idx_expenses_tripId ON expenses (tripId)');
    await db.execute('CREATE INDEX idx_expenses_date ON expenses (date)');
    await db.execute('CREATE INDEX idx_memories_userId ON memories (userId)');
    await db.execute('CREATE INDEX idx_memories_tripId ON memories (tripId)');
    await db.execute(
      'CREATE INDEX idx_memories_location ON memories (latitude, longitude)',
    );
    await db.execute(
      'CREATE INDEX idx_points_userId ON points_entries (userId)',
    );
    await db.execute(
      'CREATE INDEX idx_points_dateEarned ON points_entries (dateEarned)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add memories table
      await db.execute('''
        CREATE TABLE memories (
          id TEXT PRIMARY KEY,
          userId TEXT NOT NULL,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          latitude REAL NOT NULL,
          longitude REAL NOT NULL,
          locationName TEXT NOT NULL,
          dateCreated INTEGER NOT NULL,
          imageUrls TEXT,
          tripId TEXT,
          tags TEXT,
          FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
          FOREIGN KEY (tripId) REFERENCES trips (id) ON DELETE SET NULL
        )
      ''');

      // Add points entries table
      await db.execute('''
        CREATE TABLE points_entries (
          id TEXT PRIMARY KEY,
          userId TEXT NOT NULL,
          type INTEGER NOT NULL,
          points INTEGER NOT NULL,
          description TEXT NOT NULL,
          dateEarned INTEGER NOT NULL,
          relatedId TEXT,
          FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');

      // Add new indexes
      await db.execute('CREATE INDEX idx_memories_userId ON memories (userId)');
      await db.execute('CREATE INDEX idx_memories_tripId ON memories (tripId)');
      await db.execute(
        'CREATE INDEX idx_memories_location ON memories (latitude, longitude)',
      );
      await db.execute(
        'CREATE INDEX idx_points_userId ON points_entries (userId)',
      );
      await db.execute(
        'CREATE INDEX idx_points_dateEarned ON points_entries (dateEarned)',
      );
    }
  }

  // User operations
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toJson());
  }

  Future<User?> getUser(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    }
    return null;
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toJson(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Trip operations
  Future<int> insertTrip(Trip trip) async {
    final db = await database;
    return await db.insert('trips', trip.toJson());
  }

  Future<List<Trip>> getTripsForUser(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'trips',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'startDate DESC',
    );

    return List.generate(maps.length, (i) => Trip.fromJson(maps[i]));
  }

  Future<Trip?> getTrip(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'trips',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Trip.fromJson(maps.first);
    }
    return null;
  }

  Future<int> updateTrip(Trip trip) async {
    final db = await database;
    return await db.update(
      'trips',
      trip.toJson(),
      where: 'id = ?',
      whereArgs: [trip.id],
    );
  }

  Future<int> deleteTrip(String id) async {
    final db = await database;
    return await db.delete('trips', where: 'id = ?', whereArgs: [id]);
  }

  // Activity operations
  Future<int> insertActivity(Activity activity) async {
    final db = await database;
    return await db.insert('activities', activity.toJson());
  }

  Future<List<Activity>> getActivitiesForTrip(String tripId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'activities',
      where: 'tripId = ?',
      whereArgs: [tripId],
      orderBy: 'date ASC',
    );

    return List.generate(maps.length, (i) => Activity.fromJson(maps[i]));
  }

  Future<Activity?> getActivity(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'activities',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Activity.fromJson(maps.first);
    }
    return null;
  }

  Future<int> updateActivity(Activity activity) async {
    final db = await database;
    return await db.update(
      'activities',
      activity.toJson(),
      where: 'id = ?',
      whereArgs: [activity.id],
    );
  }

  Future<int> deleteActivity(String id) async {
    final db = await database;
    return await db.delete('activities', where: 'id = ?', whereArgs: [id]);
  }

  // Expense operations
  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    return await db.insert('expenses', expense.toJson());
  }

  Future<List<Expense>> getExpensesForTrip(String tripId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'tripId = ?',
      whereArgs: [tripId],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) => Expense.fromJson(maps[i]));
  }

  Future<List<Expense>> getExpensesForActivity(String activityId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'activityId = ?',
      whereArgs: [activityId],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) => Expense.fromJson(maps[i]));
  }

  Future<double> getTotalExpensesForTrip(String tripId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE tripId = ?',
      [tripId],
    );

    return result.first['total'] as double? ?? 0.0;
  }

  Future<int> updateExpense(Expense expense) async {
    final db = await database;
    return await db.update(
      'expenses',
      expense.toJson(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(String id) async {
    final db = await database;
    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  // Sync operations
  Future<List<Trip>> getUnsyncedTrips() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'trips',
      where: 'isSynced = ?',
      whereArgs: [0],
    );

    return List.generate(maps.length, (i) => Trip.fromJson(maps[i]));
  }

  Future<List<Activity>> getUnsyncedActivities() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'activities',
      where: 'isSynced = ?',
      whereArgs: [0],
    );

    return List.generate(maps.length, (i) => Activity.fromJson(maps[i]));
  }

  Future<List<Expense>> getUnsyncedExpenses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'isSynced = ?',
      whereArgs: [0],
    );

    return List.generate(maps.length, (i) => Expense.fromJson(maps[i]));
  }

  Future<int> deleteUser(String id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
