import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/points.dart';
import '../services/points_service.dart';

class PointsProvider with ChangeNotifier {
  final PointsService _pointsService = PointsService();
  final Uuid _uuid = const Uuid();

  UserPoints? _userPoints;
  bool _isLoading = false;
  String? _error;

  UserPoints? get userPoints => _userPoints;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserPoints(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _userPoints = await _pointsService.getUserPoints(userId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading user points: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> awardPoints(String userId, PointType pointType, {String? relatedId}) async {
    try {
      final points = PointsConfig.pointsMap[pointType] ?? 0;
      final description = PointsConfig.descriptions[pointType] ?? 'Points earned';

      final pointsEntry = PointsEntry(
        id: _uuid.v4(),
        userId: userId,
        type: pointType,
        points: points,
        description: description,
        dateEarned: DateTime.now(),
        relatedId: relatedId,
      );

      await _pointsService.addPointsEntry(pointsEntry);
      
      // Update local user points
      if (_userPoints != null) {
        final newTotal = _userPoints!.totalPoints + points;
        final newLevel = (newTotal / 1000).floor();
        
        _userPoints = _userPoints!.copyWith(
          totalPoints: newTotal,
          level: newLevel,
          recentEntries: [pointsEntry, ..._userPoints!.recentEntries.take(9).toList()],
        );
        
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error awarding points: $e');
      notifyListeners();
      return false;
    }
  }

  Future<List<PointsEntry>> getPointsHistory(String userId, {int limit = 50}) async {
    try {
      return await _pointsService.getPointsHistory(userId, limit: limit);
    } catch (e) {
      debugPrint('Error loading points history: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getPointsStats(String userId) async {
    try {
      return await _pointsService.getPointsStats(userId);
    } catch (e) {
      debugPrint('Error loading points stats: $e');
      return {};
    }
  }

  String getLevelIcon(int level) {
    if (level < 5) return '🌱'; // Explorer
    if (level < 10) return '⭐'; // Adventurer
    if (level < 20) return '🎯'; // Wanderer
    if (level < 35) return '🌍'; // Globetrotter
    if (level < 50) return '👑'; // Travel Master
    return '🏆'; // Legendary Traveler
  }

  Color getLevelColor(int level) {
    if (level < 5) return Color(0xFF4CAF50); // Green
    if (level < 10) return Color(0xFF2196F3); // Blue
    if (level < 20) return Color(0xFF9C27B0); // Purple
    if (level < 35) return Color(0xFFFF9800); // Orange
    if (level < 50) return Color(0xFFE91E63); // Pink
    return Color(0xFFFFD700); // Gold
  }

  void clearPoints() {
    _userPoints = null;
    _error = null;
    notifyListeners();
  }

  // Helper methods for specific point awards
  Future<void> awardTripCreated(String userId, String tripId) async {
    await awardPoints(userId, PointType.tripCreated, relatedId: tripId);
  }

  Future<void> awardTripCompleted(String userId, String tripId) async {
    await awardPoints(userId, PointType.tripCompleted, relatedId: tripId);
  }

  Future<void> awardMemoryAdded(String userId, String memoryId) async {
    await awardPoints(userId, PointType.memoryAdded, relatedId: memoryId);
  }

  Future<void> awardPlaceVisited(String userId, String locationId) async {
    await awardPoints(userId, PointType.placeVisited, relatedId: locationId);
  }

  Future<void> awardPhotosUploaded(String userId, int photoCount) async {
    for (int i = 0; i < photoCount; i++) {
      await awardPoints(userId, PointType.photosUploaded);
    }
  }

  Future<void> awardDailyLogin(String userId) async {
    await awardPoints(userId, PointType.dailyLogin);
  }

  Future<void> awardProfileCompleted(String userId) async {
    await awardPoints(userId, PointType.profileCompleted);
  }
}