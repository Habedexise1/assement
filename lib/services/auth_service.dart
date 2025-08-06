import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'user_management_service.dart';

class AuthService {
  static const String _baseUrl = 'https://api.taskmaster.com';
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  final UserManagementService _userManagementService = UserManagementService();

  // Mock API delay
  static const int _apiDelay = 1000;

  Future<User> login(String email, String password) async {
    try {
      // Simulate API delay
      await Future.delayed(Duration(milliseconds: _apiDelay));

      // Mock validation
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email and password are required');
      }

      if (!_isValidEmail(email)) {
        throw Exception('Please enter a valid email address');
      }

      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      // Check if user exists in the system
      final allUsers = await _userManagementService.getAllUsers();
      final existingUser = allUsers.firstWhere(
        (user) => user.email == email,
        orElse: () => User(
          id: 'user_${DateTime.now().millisecondsSinceEpoch}',
          email: email,
          name: email.split('@')[0],
          createdAt: DateTime.now(),
          role: 'user',
        ),
      );

      final token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';

      // Save to local storage
      await _saveAuthData(token, existingUser);

      return existingUser;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<User> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    try {
      // Simulate API delay
      await Future.delayed(Duration(milliseconds: _apiDelay));

      // Mock validation
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        throw Exception('All fields are required');
      }

      if (!_isValidEmail(email)) {
        throw Exception('Please enter a valid email address');
      }

      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      // Mock successful registration
      final user = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: name,
        createdAt: DateTime.now(),
        role: role,
      );

      final token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';

      // Save to local storage
      await _saveAuthData(token, user);

      // Save to user management service for admin dashboard
      await _userManagementService.addUser(user);

      return user;
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      if (userJson != null) {
        final userMap = json.decode(userJson);
        return User.fromJson(userMap);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      return null;
    }
  }

  Future<bool> isAuthenticated() async {
    final token = await getAuthToken();
    return token != null;
  }

  Future<void> _saveAuthData(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, json.encode(user.toJson()));
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
