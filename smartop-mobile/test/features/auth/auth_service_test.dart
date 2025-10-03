import 'package:flutter_test/flutter_test.dart';
import 'package:smartop_mobile/core/services/auth_service.dart';
import 'package:smartop_mobile/core/constants/app_constants.dart';
import 'package:smartop_mobile/core/error/app_exception.dart';

void main() {
  group('AuthService Tests', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
    });

    group('User Model Tests', () {
      test('should create User from JSON', () {
        // Arrange
        final json = {
          'id': 1,
          'name': 'Test User',
          'email': 'test@smartop.com',
          'role': 'operator',
          'company': 'Test Company',
          'created_at': '2024-01-15T10:30:00Z',
          'updated_at': '2024-01-15T10:30:00Z',
        };

        // Act
        final user = User.fromJson(json);

        // Assert
        expect(user.id, 1);
        expect(user.name, 'Test User');
        expect(user.email, 'test@smartop.com');
        expect(user.role, 'operator');
        expect(user.company, 'Test Company');
        expect(user.isOperator, true);
        expect(user.isAdmin, false);
        expect(user.isManager, false);
      });

      test('should create User toJson', () {
        // Arrange
        final user = User(
          id: 1,
          name: 'Test User',
          email: 'test@smartop.com',
          role: 'admin',
          company: 'Test Company',
          createdAt: DateTime(2024, 1, 15),
          updatedAt: DateTime(2024, 1, 15),
        );

        // Act
        final json = user.toJson();

        // Assert
        expect(json['id'], 1);
        expect(json['name'], 'Test User');
        expect(json['email'], 'test@smartop.com');
        expect(json['role'], 'admin');
        expect(json['company'], 'Test Company');
      });

      test('should check user roles correctly', () {
        // Arrange
        final adminUser = User(
          id: 1,
          name: 'Admin User',
          email: 'admin@smartop.com',
          role: AppConstants.adminRole,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final managerUser = User(
          id: 2,
          name: 'Manager User',
          email: 'manager@smartop.com',
          role: AppConstants.managerRole,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final operatorUser = User(
          id: 3,
          name: 'Operator User',
          email: 'operator@smartop.com',
          role: AppConstants.operatorRole,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Assert
        expect(adminUser.isAdmin, true);
        expect(adminUser.canManageMachines, true);
        expect(adminUser.canViewReports, true);
        expect(adminUser.canApproveControls, true);

        expect(managerUser.isManager, true);
        expect(managerUser.canManageMachines, true);
        expect(managerUser.canViewReports, true);
        expect(managerUser.canApproveControls, true);

        expect(operatorUser.isOperator, true);
        expect(operatorUser.canManageMachines, false);
        expect(operatorUser.canViewReports, false);
        expect(operatorUser.canApproveControls, false);
      });
    });

    group('AuthService Instance Tests', () {
      test('should return same instance (singleton)', () {
        // Arrange
        final instance1 = AuthService();
        final instance2 = AuthService();

        // Assert
        expect(instance1, same(instance2));
      });

      test('should initialize without errors', () {
        // Act & Assert
        expect(authService, isNotNull);
      });
    });

    group('Authentication State Tests', () {
      test('should start with no logged in user', () {
        // Assert
        expect(authService.currentUser, isNull);
        expect(authService.currentToken, isNull);
        expect(authService.isLoggedIn, false);
      });
    });

    group('Error Handling Tests', () {
      test('should handle ApiException properly', () {
        // Arrange
        const message = 'Authentication failed';
        const statusCode = 401;
        final exception = ApiException(
          message: message,
          statusCode: statusCode,
        );

        // Assert
        expect(exception.message, message);
        expect(exception.statusCode, statusCode);
        expect(exception.toString(), contains(message));
      });

      test('should handle ApiException with errors', () {
        // Arrange
        const message = 'Validation failed';
        const statusCode = 422;
        final errors = {
          'email': ['Email is required'],
          'password': ['Password must be at least 6 characters']
        };
        final exception = ApiException(
          message: message,
          statusCode: statusCode,
          errors: errors,
        );

        // Assert
        expect(exception.message, message);
        expect(exception.statusCode, statusCode);
        expect(exception.errors, errors);
        expect(exception.errors?['email'], contains('Email is required'));
      });
    });

    group('Constants Tests', () {
      test('should have correct role constants', () {
        // Assert
        expect(AppConstants.adminRole, 'admin');
        expect(AppConstants.managerRole, 'manager');
        expect(AppConstants.operatorRole, 'operator');
      });

      test('should have correct storage keys', () {
        // Assert
        expect(AppConstants.tokenKey, 'auth_token');
        expect(AppConstants.userKey, 'user_data');
      });
    });
  });
}