import 'package:uuid/uuid.dart';
import '../models/user.dart';
import 'database_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  static const String _guestUserKey = 'guest_user_id';
  
  factory AuthService() => _instance;
  AuthService._internal();

  final DatabaseService _db = DatabaseService();
  final Uuid _uuid = Uuid();
  
  User? _currentUser;
  
  User? get currentUser => _currentUser;
  
  bool get isAuthenticated => _currentUser != null;
  
  bool get isGuest => _currentUser?.isGuest ?? false;

  Future<User?> signUpWithEmail(String email, String name, String homeCity, {String preferredCurrency = 'USD'}) async {
    try {
      final userId = _uuid.v4();
      final user = User(
        id: userId,
        email: email,
        name: name,
        homeCity: homeCity,
        preferredCurrency: preferredCurrency,
        isGuest: false,
        createdAt: DateTime.now(),
      );
      
      await _db.insertUser(user);
      _currentUser = user;
      return user;
    } catch (e) {
      print('Error signing up with email: $e');
      return null;
    }
  }

  Future<User?> signUpWithPhone(String phone, String name, String homeCity, {String preferredCurrency = 'USD'}) async {
    try {
      final userId = _uuid.v4();
      final user = User(
        id: userId,
        phone: phone,
        name: name,
        homeCity: homeCity,
        preferredCurrency: preferredCurrency,
        isGuest: false,
        createdAt: DateTime.now(),
      );
      
      await _db.insertUser(user);
      _currentUser = user;
      return user;
    } catch (e) {
      print('Error signing up with phone: $e');
      return null;
    }
  }

  Future<User?> continueAsGuest(String name, String homeCity, {String preferredCurrency = 'USD'}) async {
    try {
      final userId = _uuid.v4();
      final user = User(
        id: userId,
        name: name,
        homeCity: homeCity,
        preferredCurrency: preferredCurrency,
        isGuest: true,
        createdAt: DateTime.now(),
      );
      
      await _db.insertUser(user);
      _currentUser = user;
      return user;
    } catch (e) {
      print('Error creating guest user: $e');
      return null;
    }
  }

  Future<User?> signIn(String emailOrPhone) async {
    try {
      // For MVP, we'll do simple email/phone lookup
      // In production, you'd implement proper authentication
      
      // This is a simplified version - you'd need proper password verification
      print('Sign in functionality would be implemented here');
      return null;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  Future<User?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;
    
    // Try to load user from storage
    // For now, we'll keep it simple and require authentication each time
    return null;
  }

  Future<void> signOut() async {
    _currentUser = null;
    // Clear any stored credentials
  }

  Future<User?> updateProfile({
    String? name,
    String? homeCity,
    String? preferredCurrency,
    String? email,
    String? phone,
  }) async {
    if (_currentUser == null) return null;

    try {
      final updatedUser = _currentUser!.copyWith(
        name: name,
        homeCity: homeCity,
        preferredCurrency: preferredCurrency,
        email: email,
        phone: phone,
      );

      await _db.updateUser(updatedUser);
      _currentUser = updatedUser;
      return updatedUser;
    } catch (e) {
      print('Error updating profile: $e');
      return null;
    }
  }

  Future<bool> deleteAccount() async {
    if (_currentUser == null) return false;

    try {
      // In a real app, you'd need to handle data deletion properly
      _currentUser = null;
      return true;
    } catch (e) {
      print('Error deleting account: $e');
      return false;
    }
  }
}