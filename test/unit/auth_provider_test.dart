import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:assesment/providers/auth_provider.dart';

void main() {
  group('AuthProvider Tests', () {
    late AuthProvider authProvider;

    setUpAll(() async {
      // Initialize shared preferences for testing
      SharedPreferences.setMockInitialValues({});
    });

    setUp(() async {
      // Clear shared preferences before each test
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      authProvider = AuthProvider();
      // Wait for initialization to complete
      await Future.delayed(const Duration(milliseconds: 100));
    });

    test('should initialize with no authenticated user', () {
      expect(authProvider.currentUser, isNull);
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.isLoading, isFalse);
      expect(authProvider.error, isNull);
    });

    test('should register user with role successfully', () async {
      // Act
      final result = await authProvider.register(
        'John Doe',
        'john@example.com',
        'password123',
        'manager',
      );

      // Assert
      expect(result, isTrue);
      expect(authProvider.currentUser, isNotNull);
      expect(authProvider.currentUser!.name, 'John Doe');
      expect(authProvider.currentUser!.email, 'john@example.com');
      expect(authProvider.currentUser!.role, 'manager');
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.error, isNull);
    });

    test('should register user with default role when not specified', () async {
      // Act
      final result = await authProvider.register(
        'Jane Smith',
        'jane@example.com',
        'password123',
        'user',
      );

      // Assert
      expect(result, isTrue);
      expect(authProvider.currentUser, isNotNull);
      expect(authProvider.currentUser!.role, 'user');
    });

    test('should register admin user successfully', () async {
      // Act
      final result = await authProvider.register(
        'Admin User',
        'admin@example.com',
        'password123',
        'admin',
      );

      // Assert
      expect(result, isTrue);
      expect(authProvider.currentUser, isNotNull);
      expect(authProvider.currentUser!.role, 'admin');
    });

    test('should fail registration with invalid email', () async {
      // Act
      final result = await authProvider.register(
        'Test User',
        'invalid-email',
        'password123',
        'user',
      );

      // Assert
      expect(result, isFalse);
      expect(authProvider.currentUser, isNull);
      expect(authProvider.error, isNotNull);
      expect(authProvider.error!.contains('valid email'), isTrue);
    });

    test('should fail registration with short password', () async {
      // Act
      final result = await authProvider.register(
        'Test User',
        'test@example.com',
        '123',
        'user',
      );

      // Assert
      expect(result, isFalse);
      expect(authProvider.currentUser, isNull);
      expect(authProvider.error, isNotNull);
      expect(authProvider.error!.contains('6 characters'), isTrue);
    });

    test('should login user successfully', () async {
      // Act
      final result = await authProvider.login(
        'test@example.com',
        'password123',
      );

      // Assert
      expect(result, isTrue);
      expect(authProvider.currentUser, isNotNull);
      expect(authProvider.currentUser!.email, 'test@example.com');
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.error, isNull);
    });

    test('should fail login with invalid credentials', () async {
      // Act
      final result = await authProvider.login(
        'test@example.com',
        'wrongpassword',
      );

      // Assert
      expect(result, isFalse);
      expect(authProvider.currentUser, isNull);
      expect(authProvider.error, isNotNull);
    });

    test('should logout user successfully', () async {
      // Arrange - Login first
      await authProvider.login('test@example.com', 'password123');
      expect(authProvider.isAuthenticated, isTrue);

      // Act
      await authProvider.logout();

      // Assert
      expect(authProvider.currentUser, isNull);
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.error, isNull);
    });

    test('should clear error when clearError is called', () async {
      // Arrange - Trigger an error
      await authProvider.login('test@example.com', 'wrongpassword');
      expect(authProvider.error, isNotNull);

      // Act
      authProvider.clearError();

      // Assert
      expect(authProvider.error, isNull);
    });

    test('should handle role-based user creation correctly', () async {
      // Test different roles
      final roles = ['user', 'manager', 'admin'];

      for (final role in roles) {
        // Act
        final result = await authProvider.register(
          'Test User',
          'test@example.com',
          'password123',
          role,
        );

        // Assert
        expect(result, isTrue);
        expect(authProvider.currentUser!.role, role);

        // Clean up for next iteration
        await authProvider.logout();
      }
    });
  });
}
