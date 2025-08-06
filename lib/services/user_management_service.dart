import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserManagementService {
  static const String _usersKey = 'all_users';

  // Get all users from storage
  Future<List<User>> getAllUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getStringList(_usersKey) ?? [];

      final users = usersJson
          .map((userJson) => User.fromJson(json.decode(userJson)))
          .toList();

      return users;
    } catch (e) {
      return [];
    }
  }

  // Add a new user to storage
  Future<void> addUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final users = await getAllUsers();

      // Check if user already exists
      final existingUserIndex = users.indexWhere((u) => u.email == user.email);
      if (existingUserIndex != -1) {
        users[existingUserIndex] = user;
      } else {
        users.add(user);
      }

      final usersJson = users.map((u) => json.encode(u.toJson())).toList();
      await prefs.setStringList(_usersKey, usersJson);
    } catch (e) {
      throw Exception('Failed to add user: ${e.toString()}');
    }
  }

  // Update an existing user
  Future<void> updateUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final users = await getAllUsers();

      final index = users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        users[index] = user;
        final usersJson = users.map((u) => json.encode(u.toJson())).toList();
        await prefs.setStringList(_usersKey, usersJson);
      }
    } catch (e) {
      throw Exception('Failed to update user: ${e.toString()}');
    }
  }

  // Delete a user
  Future<void> deleteUser(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final users = await getAllUsers();

      users.removeWhere((u) => u.id == userId);
      final usersJson = users.map((u) => json.encode(u.toJson())).toList();
      await prefs.setStringList(_usersKey, usersJson);
    } catch (e) {
      throw Exception('Failed to delete user: ${e.toString()}');
    }
  }

  // Get user by ID
  Future<User?> getUserById(String userId) async {
    try {
      final users = await getAllUsers();
      return users.firstWhere((u) => u.id == userId);
    } catch (e) {
      return null;
    }
  }

  // Get users by role
  Future<List<User>> getUsersByRole(String role) async {
    try {
      final users = await getAllUsers();
      return users.where((u) => u.role == role).toList();
    } catch (e) {
      return [];
    }
  }

  // Get active users (users who have logged in at least once)
  Future<List<User>> getActiveUsers() async {
    try {
      final users = await getAllUsers();
      // For now, consider all users as active since we don't track login status
      return users;
    } catch (e) {
      return [];
    }
  }

  // Get user statistics
  Future<Map<String, int>> getUserStats() async {
    try {
      final users = await getAllUsers();
      final totalUsers = users.length;
      final activeUsers =
          users.length; // All users are considered active for now
      final adminUsers = users.where((u) => u.role == 'admin').length;
      final managerUsers = users.where((u) => u.role == 'manager').length;
      final regularUsers = users.where((u) => u.role == 'user').length;

      return {
        'total': totalUsers,
        'active': activeUsers,
        'admins': adminUsers,
        'managers': managerUsers,
        'users': regularUsers,
      };
    } catch (e) {
      return {'total': 0, 'active': 0, 'admins': 0, 'managers': 0, 'users': 0};
    }
  }
}
