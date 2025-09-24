import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';
import '../constants/app_constants.dart';
import '../error/app_exception.dart';

class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? company;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.company,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      company: json['company'],
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.tryParse(json['email_verified_at'])
          : null,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'company': company,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper methods for role checking
  bool get isAdmin => role == AppConstants.adminRole;
  bool get isManager => role == AppConstants.managerRole;
  bool get isOperator => role == AppConstants.operatorRole;

  bool get canManageMachines => isAdmin || isManager;
  bool get canViewReports => isAdmin || isManager;
  bool get canApproveControls => isAdmin || isManager;
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiClient _apiClient = ApiClient();
  User? _currentUser;
  String? _currentToken;

  User? get currentUser => _currentUser;
  String? get currentToken => _currentToken;
  bool get isLoggedIn => _currentUser != null && _currentToken != null;

  // Initialize service - load saved user data
  Future<void> init() async {
    await _apiClient.init();
    await _loadSavedUserData();
  }

  // Load user data from storage
  Future<void> _loadSavedUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      final userData = prefs.getString(AppConstants.userKey);

      if (token != null && userData != null) {
        _currentToken = token;
        _currentUser = User.fromJson(jsonDecode(userData));
        _apiClient.setToken(token);
      }
    } catch (e) {
      // If there's an error loading data, clear it
      await logout();
    }
  }

  // Save user data to storage
  Future<void> _saveUserData(String token, User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.tokenKey, token);
      await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));

      _currentToken = token;
      _currentUser = user;
      _apiClient.setToken(token);
    } catch (e) {
      throw ApiException(message: 'Failed to save user data', statusCode: 0);
    }
  }

  // Clear user data from storage
  Future<void> _clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.tokenKey);
      await prefs.remove(AppConstants.userKey);

      _currentToken = null;
      _currentUser = null;
      _apiClient.clearToken();
    } catch (e) {
      // Even if clearing fails, set local variables to null
      _currentToken = null;
      _currentUser = null;
      _apiClient.clearToken();
    }
  }

  // Login with email and password
  Future<User> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        '/auth/login',
        body: {'email': email, 'password': password},
        requiresAuth: false,
      );

      final token = response['access_token'];
      final userData = response['user'];

      if (token == null || userData == null) {
        throw ApiException(message: 'Invalid login response', statusCode: 500);
      }

      final user = User.fromJson(userData);
      await _saveUserData(token, user);

      return user;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Login failed: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Register new user
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? company,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/register',
        body: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          if (company != null) 'company': company,
        },
        requiresAuth: false,
      );

      final token = response['access_token'];
      final userData = response['user'];

      if (token == null || userData == null) {
        throw ApiException(
          message: 'Invalid registration response',
          statusCode: 500,
        );
      }

      final user = User.fromJson(userData);
      await _saveUserData(token, user);

      return user;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Registration failed: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      // Try to call logout endpoint if we have a token
      if (_currentToken != null) {
        await _apiClient.post('/auth/logout');
      }
    } catch (e) {
      // Even if logout API call fails, we should clear local data
    } finally {
      await _clearUserData();
    }
  }

  // Refresh token
  Future<void> refreshToken() async {
    try {
      final response = await _apiClient.post('/auth/refresh');

      final token = response['access_token'];
      final userData = response['user'];

      if (token == null || userData == null) {
        throw ApiException(
          message: 'Invalid refresh response',
          statusCode: 500,
        );
      }

      final user = User.fromJson(userData);
      await _saveUserData(token, user);
    } catch (e) {
      // If refresh fails, logout user
      await logout();
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Token refresh failed: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Get current user profile
  Future<User> getProfile() async {
    try {
      final response = await _apiClient.get('/auth/profile');
      final userData = response['user'];

      if (userData == null) {
        throw ApiException(
          message: 'Invalid profile response',
          statusCode: 500,
        );
      }

      final user = User.fromJson(userData);

      // Update stored user data
      if (_currentToken != null) {
        await _saveUserData(_currentToken!, user);
      }

      return user;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Failed to get profile: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Update user profile
  Future<User> updateProfile({
    String? name,
    String? email,
    String? company,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (email != null) body['email'] = email;
      if (company != null) body['company'] = company;

      final response = await _apiClient.put('/auth/profile', body: body);
      final userData = response['user'];

      if (userData == null) {
        throw ApiException(message: 'Invalid update response', statusCode: 500);
      }

      final user = User.fromJson(userData);

      // Update stored user data
      if (_currentToken != null) {
        await _saveUserData(_currentToken!, user);
      }

      return user;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Failed to update profile: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String passwordConfirmation,
  }) async {
    try {
      await _apiClient.put(
        '/auth/change-password',
        body: {
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation': passwordConfirmation,
        },
      );
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Failed to change password: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Verify if token is still valid
  Future<bool> verifyToken() async {
    try {
      await _apiClient.get('/auth/verify');
      return true;
    } catch (e) {
      return false;
    }
  }

  // Auto-refresh token if needed
  Future<void> ensureValidToken() async {
    if (!isLoggedIn) return;

    if (!await verifyToken()) {
      try {
        await refreshToken();
      } catch (e) {
        await logout();
        rethrow;
      }
    }
  }
}
