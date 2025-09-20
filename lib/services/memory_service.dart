import 'package:sqflite/sqflite.dart';
import 'dart:math' as math;
import '../models/memory.dart';
import 'database_service.dart';

class MemoryService {
  final DatabaseService _databaseService = DatabaseService();

  Future<void> addMemory(Memory memory) async {
    final db = await _databaseService.database;
    await db.insert('memories', memory.toMap());
  }

  Future<List<Memory>> getMemoriesByUser(String userId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'memories',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'dateCreated DESC',
    );

    return List.generate(maps.length, (i) {
      return Memory.fromMap(maps[i]);
    });
  }

  Future<Memory?> getMemoryById(String memoryId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'memories',
      where: 'id = ?',
      whereArgs: [memoryId],
    );

    if (maps.isNotEmpty) {
      return Memory.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Memory>> getMemoriesByTrip(String tripId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'memories',
      where: 'tripId = ?',
      whereArgs: [tripId],
      orderBy: 'dateCreated DESC',
    );

    return List.generate(maps.length, (i) {
      return Memory.fromMap(maps[i]);
    });
  }

  Future<void> updateMemory(Memory memory) async {
    final db = await _databaseService.database;
    await db.update(
      'memories',
      memory.toMap(),
      where: 'id = ?',
      whereArgs: [memory.id],
    );
  }

  Future<void> deleteMemory(String memoryId) async {
    final db = await _databaseService.database;
    await db.delete(
      'memories',
      where: 'id = ?',
      whereArgs: [memoryId],
    );
  }

  Future<List<Memory>> searchMemories(String userId, String searchTerm) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'memories',
      where: 'userId = ? AND (title LIKE ? OR description LIKE ? OR locationName LIKE ? OR tags LIKE ?)',
      whereArgs: [userId, '%$searchTerm%', '%$searchTerm%', '%$searchTerm%', '%$searchTerm%'],
      orderBy: 'dateCreated DESC',
    );

    return List.generate(maps.length, (i) {
      return Memory.fromMap(maps[i]);
    });
  }

  Future<List<Memory>> getMemoriesInArea(String userId, double centerLat, double centerLng, double radiusKm) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'memories',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'dateCreated DESC',
    );

    final List<Memory> allMemories = List.generate(maps.length, (i) {
      return Memory.fromMap(maps[i]);
    });

    // Filter by distance (simple approximation)
    return allMemories.where((memory) {
      final distance = _calculateDistance(centerLat, centerLng, memory.latitude, memory.longitude);
      return distance <= radiusKm;
    }).toList();
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    
    final double a = 
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) * 
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}