import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/trip.dart';
import '../models/activity.dart';
import '../models/expense.dart';
import '../services/database_service.dart';

class TripProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final Uuid _uuid = Uuid();

  List<Trip> _trips = [];
  Trip? _selectedTrip;
  List<Activity> _activities = [];
  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _error;

  List<Trip> get trips => _trips;
  Trip? get selectedTrip => _selectedTrip;
  List<Activity> get activities => _activities;
  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTrips(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _trips = await _db.getTripsForUser(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createTrip({
    required String userId,
    required String name,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    String? description,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final trip = Trip(
        id: _uuid.v4(),
        userId: userId,
        name: name,
        destination: destination,
        startDate: startDate,
        endDate: endDate,
        description: description,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _db.insertTrip(trip);
      _trips.insert(0, trip);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTrip(Trip trip) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedTrip = trip.copyWith(updatedAt: DateTime.now());
      await _db.updateTrip(updatedTrip);
      
      final index = _trips.indexWhere((t) => t.id == trip.id);
      if (index != -1) {
        _trips[index] = updatedTrip;
      }
      
      if (_selectedTrip?.id == trip.id) {
        _selectedTrip = updatedTrip;
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTrip(String tripId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _db.deleteTrip(tripId);
      _trips.removeWhere((trip) => trip.id == tripId);
      
      if (_selectedTrip?.id == tripId) {
        _selectedTrip = null;
        _activities.clear();
        _expenses.clear();
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> selectTrip(String tripId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _selectedTrip = await _db.getTrip(tripId);
      if (_selectedTrip != null) {
        await loadActivities(tripId);
        await loadExpenses(tripId);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadActivities(String tripId) async {
    try {
      _activities = await _db.getActivitiesForTrip(tripId);
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> loadExpenses(String tripId) async {
    try {
      _expenses = await _db.getExpensesForTrip(tripId);
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<bool> addActivity({
    required String tripId,
    required String userId,
    required String title,
    String? description,
    required DateTime date,
    String? location,
    double? latitude,
    double? longitude,
    List<String>? photos,
  }) async {
    try {
      final activity = Activity(
        id: _uuid.v4(),
        tripId: tripId,
        userId: userId,
        title: title,
        description: description,
        date: date,
        location: location,
        latitude: latitude,
        longitude: longitude,
        photos: photos ?? [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _db.insertActivity(activity);
      
      // Insert in chronological order
      int insertIndex = 0;
      for (int i = 0; i < _activities.length; i++) {
        if (_activities[i].date.isAfter(date)) {
          insertIndex = i;
          break;
        }
        insertIndex = i + 1;
      }
      
      _activities.insert(insertIndex, activity);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> addExpense({
    required String tripId,
    required String userId,
    String? activityId,
    required double amount,
    required String currency,
    required ExpenseCategory category,
    String? description,
    required DateTime date,
  }) async {
    try {
      final expense = Expense(
        id: _uuid.v4(),
        tripId: tripId,
        userId: userId,
        activityId: activityId,
        amount: amount,
        currency: currency,
        category: category,
        description: description,
        date: date,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _db.insertExpense(expense);
      _expenses.insert(0, expense);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  double getTotalExpenses() {
    return _expenses.fold(0.0, (total, expense) => total + expense.amount);
  }

  Map<ExpenseCategory, double> getExpensesByCategory() {
    final Map<ExpenseCategory, double> categoryTotals = {};
    
    for (final expense in _expenses) {
      categoryTotals[expense.category] = 
          (categoryTotals[expense.category] ?? 0.0) + expense.amount;
    }
    
    return categoryTotals;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSelectedTrip() {
    _selectedTrip = null;
    _activities.clear();
    _expenses.clear();
    notifyListeners();
  }
}