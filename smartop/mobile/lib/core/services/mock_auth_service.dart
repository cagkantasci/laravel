import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../services/auth_service.dart';

class MockAuthService {
  static final MockAuthService _instance = MockAuthService._internal();
  factory MockAuthService() => _instance;
  MockAuthService._internal();

  // Mock users database
  final List<Map<String, dynamic>> _mockUsers = [
    {
      'id': 1,
      'name': 'Admin User',
      'email': 'admin@smartop.com',
      'password': '123456',
      'role': 'admin',
      'company': 'SmartOp Teknoloji',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    },
    {
      'id': 2,
      'name': 'Operator User',
      'email': 'operator@smartop.com',
      'password': '123456',
      'role': 'operator',
      'company': 'SmartOp Teknoloji',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    },
    {
      'id': 3,
      'name': 'Manager User',
      'email': 'manager@smartop.com',
      'password': '123456',
      'role': 'manager',
      'company': 'SmartOp Teknoloji',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    },
  ];

  Future<User> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1500));

    // Find user in mock database
    final userData = _mockUsers.firstWhere(
      (user) => user['email'] == email && user['password'] == password,
      orElse: () => {},
    );

    if (userData.isEmpty) {
      throw Exception('Invalid credentials');
    }

    // Generate mock token
    final token =
        'mock_token_${userData['id']}_${DateTime.now().millisecondsSinceEpoch}';

    final user = User.fromJson(userData);
    await _saveUserData(token, user);

    return user;
  }

  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? company,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1500));

    if (password != passwordConfirmation) {
      throw Exception('Passwords do not match');
    }

    // Check if user already exists
    final existingUser = _mockUsers.any((user) => user['email'] == email);
    if (existingUser) {
      throw Exception('User already exists');
    }

    // Create new user
    final newUser = {
      'id': _mockUsers.length + 1,
      'name': name,
      'email': email,
      'password': password,
      'role': 'operator', // Default role
      'company': company ?? 'Default Company',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    _mockUsers.add(newUser);

    // Generate mock token
    final token =
        'mock_token_${newUser['id']}_${DateTime.now().millisecondsSinceEpoch}';

    final user = User.fromJson(newUser);
    await _saveUserData(token, user);

    return user;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _clearUserData();
  }

  Future<void> refreshToken() async {
    await Future.delayed(const Duration(milliseconds: 1000));

    if (currentUser == null) {
      throw Exception('No user logged in');
    }

    // Generate new mock token
    final token =
        'mock_token_${currentUser!.id}_${DateTime.now().millisecondsSinceEpoch}';
    await _saveUserData(token, currentUser!);
  }

  Future<User> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (currentUser == null) {
      throw Exception('No user logged in');
    }

    return currentUser!;
  }

  Future<User> updateProfile({
    String? name,
    String? email,
    String? company,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    if (currentUser == null) {
      throw Exception('No user logged in');
    }

    // Update mock user data
    final updatedUserData = {
      'id': currentUser!.id,
      'name': name ?? currentUser!.name,
      'email': email ?? currentUser!.email,
      'role': currentUser!.role,
      'company': company ?? currentUser!.company,
      'created_at': currentUser!.createdAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    final updatedUser = User.fromJson(updatedUserData);
    await _saveUserData(currentToken!, updatedUser);

    return updatedUser;
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String passwordConfirmation,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    if (currentUser == null) {
      throw Exception('No user logged in');
    }

    if (newPassword != passwordConfirmation) {
      throw Exception('Passwords do not match');
    }

    // Find user in mock database and verify current password
    final userIndex = _mockUsers.indexWhere(
      (user) => user['id'] == currentUser!.id,
    );
    if (userIndex == -1 ||
        _mockUsers[userIndex]['password'] != currentPassword) {
      throw Exception('Current password is incorrect');
    }

    // Update password in mock database
    _mockUsers[userIndex]['password'] = newPassword;
  }

  Future<bool> verifyToken() async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock token verification - always return true if user is logged in
    return isLoggedIn;
  }

  // Helper methods (private - only accessible within this class)
  Future<void> _saveUserData(String token, User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.tokenKey, token);
      await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));

      _currentToken = token;
      _currentUser = user;
    } catch (e) {
      throw Exception('Failed to save user data');
    }
  }

  Future<void> _clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.tokenKey);
      await prefs.remove(AppConstants.userKey);

      _currentToken = null;
      _currentUser = null;
    } catch (e) {
      // Even if clearing fails, set local variables to null
      _currentToken = null;
      _currentUser = null;
    }
  }

  // Access to private fields from parent class
  User? _currentUser;
  String? _currentToken;

  User? get currentUser => _currentUser;

  String? get currentToken => _currentToken;

  bool get isLoggedIn => _currentUser != null && _currentToken != null;

  // Initialize method
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    final userData = prefs.getString(AppConstants.userKey);

    if (token != null && userData != null) {
      _currentToken = token;
      _currentUser = User.fromJson(jsonDecode(userData));
    }
  }
}
