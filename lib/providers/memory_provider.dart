import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'dart:math' as math;
import '../models/memory.dart';
import '../services/memory_service.dart';

class MemoryProvider with ChangeNotifier {
  final MemoryService _memoryService = MemoryService();
  final Uuid _uuid = const Uuid();

  List<Memory> _memories = [];
  bool _isLoading = false;
  String? _error;

  List<Memory> get memories => _memories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMemories(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _memories = await _memoryService.getMemoriesByUser(userId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading memories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addMemory({
    required String userId,
    required String title,
    required String description,
    required double latitude,
    required double longitude,
    required String locationName,
    List<String> imageUrls = const [],
    String? tripId,
    List<String> tags = const [],
  }) async {
    try {
      final memory = Memory(
        id: _uuid.v4(),
        userId: userId,
        title: title,
        description: description,
        latitude: latitude,
        longitude: longitude,
        locationName: locationName,
        dateCreated: DateTime.now(),
        imageUrls: imageUrls,
        tripId: tripId,
        tags: tags,
      );

      await _memoryService.addMemory(memory);
      _memories.add(memory);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error adding memory: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateMemory(Memory memory) async {
    try {
      await _memoryService.updateMemory(memory);
      final index = _memories.indexWhere((m) => m.id == memory.id);
      if (index != -1) {
        _memories[index] = memory;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating memory: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteMemory(String memoryId) async {
    try {
      await _memoryService.deleteMemory(memoryId);
      _memories.removeWhere((memory) => memory.id == memoryId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error deleting memory: $e');
      notifyListeners();
      return false;
    }
  }

  List<Memory> getMemoriesByTrip(String tripId) {
    return _memories.where((memory) => memory.tripId == tripId).toList();
  }

  List<Memory> getMemoriesByLocation(double lat, double lng, double radiusKm) {
    return _memories.where((memory) {
      final distance = _calculateDistance(
        lat,
        lng,
        memory.latitude,
        memory.longitude,
      );
      return distance <= radiusKm;
    }).toList();
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // Simple distance calculation using Haversine formula
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  void clearMemories() {
    _memories.clear();
    _error = null;
    notifyListeners();
  }
}
