import '../models/points.dart';
import 'database_service.dart';

class PointsService {
  final DatabaseService _databaseService = DatabaseService();

  Future<void> addPointsEntry(PointsEntry entry) async {
    final db = await _databaseService.database;
    await db.insert('points_entries', entry.toMap());
  }

  Future<UserPoints> getUserPoints(String userId) async {
    final db = await _databaseService.database;

    // Get total points
    final totalPointsResult = await db.rawQuery(
      'SELECT SUM(points) as total FROM points_entries WHERE userId = ?',
      [userId],
    );

    final totalPoints = totalPointsResult.first['total'] as int? ?? 0;
    final level = (totalPoints / 1000).floor();

    // Get recent entries
    final recentEntriesResult = await db.query(
      'points_entries',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'dateEarned DESC',
      limit: 10,
    );

    final recentEntries = recentEntriesResult
        .map((map) => PointsEntry.fromMap(map))
        .toList();

    // Get points by type
    final pointsByTypeResult = await db.rawQuery(
      '''
      SELECT type, SUM(points) as total 
      FROM points_entries 
      WHERE userId = ? 
      GROUP BY type
    ''',
      [userId],
    );

    final pointsByType = <PointType, int>{};
    for (final row in pointsByTypeResult) {
      final type = PointType.values[row['type'] as int];
      final points = row['total'] as int;
      pointsByType[type] = points;
    }

    return UserPoints(
      userId: userId,
      totalPoints: totalPoints,
      level: level,
      recentEntries: recentEntries,
      pointsByType: pointsByType,
    );
  }

  Future<List<PointsEntry>> getPointsHistory(
    String userId, {
    int limit = 50,
  }) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'points_entries',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'dateEarned DESC',
      limit: limit,
    );

    return maps.map((map) => PointsEntry.fromMap(map)).toList();
  }

  Future<Map<String, dynamic>> getPointsStats(String userId) async {
    final db = await _databaseService.database;

    // Total points
    final totalPointsResult = await db.rawQuery(
      'SELECT SUM(points) as total FROM points_entries WHERE userId = ?',
      [userId],
    );
    final totalPoints = totalPointsResult.first['total'] as int? ?? 0;

    // Points this month
    final thisMonthStart = DateTime.now().subtract(
      Duration(days: DateTime.now().day - 1),
    );
    final thisMonthPointsResult = await db.rawQuery(
      'SELECT SUM(points) as total FROM points_entries WHERE userId = ? AND dateEarned >= ?',
      [userId, thisMonthStart.millisecondsSinceEpoch],
    );
    final thisMonthPoints = thisMonthPointsResult.first['total'] as int? ?? 0;

    // Points this week
    final thisWeekStart = DateTime.now().subtract(
      Duration(days: DateTime.now().weekday - 1),
    );
    final thisWeekPointsResult = await db.rawQuery(
      'SELECT SUM(points) as total FROM points_entries WHERE userId = ? AND dateEarned >= ?',
      [userId, thisWeekStart.millisecondsSinceEpoch],
    );
    final thisWeekPoints = thisWeekPointsResult.first['total'] as int? ?? 0;

    // Total entries
    final totalEntriesResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM points_entries WHERE userId = ?',
      [userId],
    );
    final totalEntries = totalEntriesResult.first['count'] as int? ?? 0;

    // Average points per day (last 30 days)
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final avgPointsResult = await db.rawQuery(
      'SELECT AVG(daily_points) as avg FROM (SELECT SUM(points) as daily_points FROM points_entries WHERE userId = ? AND dateEarned >= ? GROUP BY DATE(dateEarned / 1000, "unixepoch"))',
      [userId, thirtyDaysAgo.millisecondsSinceEpoch],
    );
    final avgPointsPerDay = avgPointsResult.first['avg'] as double? ?? 0.0;

    return {
      'totalPoints': totalPoints,
      'thisMonthPoints': thisMonthPoints,
      'thisWeekPoints': thisWeekPoints,
      'totalEntries': totalEntries,
      'avgPointsPerDay': avgPointsPerDay.round(),
      'level': (totalPoints / 1000).floor(),
    };
  }

  Future<bool> hasEarnedPointsToday(String userId, PointType pointType) async {
    final db = await _databaseService.database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final result = await db.query(
      'points_entries',
      where: 'userId = ? AND type = ? AND dateEarned >= ?',
      whereArgs: [userId, pointType.index, startOfDay.millisecondsSinceEpoch],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  Future<void> deletePointsEntry(String entryId) async {
    final db = await _databaseService.database;
    await db.delete('points_entries', where: 'id = ?', whereArgs: [entryId]);
  }

  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 10}) async {
    final db = await _databaseService.database;

    final result = await db.rawQuery(
      '''
      SELECT 
        pe.userId,
        SUM(pe.points) as totalPoints,
        COUNT(pe.id) as totalEntries,
        MAX(pe.dateEarned) as lastActivity
      FROM points_entries pe
      GROUP BY pe.userId
      ORDER BY totalPoints DESC
      LIMIT ?
    ''',
      [limit],
    );

    return result
        .map(
          (row) => {
            'userId': row['userId'],
            'totalPoints': row['totalPoints'],
            'totalEntries': row['totalEntries'],
            'lastActivity': row['lastActivity'],
            'level': ((row['totalPoints'] as int) / 1000).floor(),
          },
        )
        .toList();
  }
}
