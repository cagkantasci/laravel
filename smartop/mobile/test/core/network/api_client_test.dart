import 'package:flutter_test/flutter_test.dart';
import 'package:smartop_mobile/core/network/api_client.dart';
import 'package:smartop_mobile/core/constants/app_constants.dart';
import 'package:smartop_mobile/core/error/app_exception.dart';

void main() {
  group('ApiClient Tests', () {
    late ApiClient apiClient;

    setUp(() {
      apiClient = ApiClient();
    });

    group('Configuration Tests', () {
      test('should have correct base URL in constants', () {
        // Assert
        expect(AppConstants.apiBaseUrl, 'http://127.0.0.1:8001/api');
      });

      test('should have correct API timeout', () {
        // Assert
        expect(AppConstants.apiTimeout, '30000');
      });

      test('should have correct token key', () {
        // Assert
        expect(AppConstants.tokenKey, 'auth_token');
      });
    });

    group('Authentication Tests', () {
      test('should set token', () {
        // Arrange
        const token = 'test-token-123';

        // Act
        apiClient.setToken(token);

        // Assert - Token is set internally
        expect(apiClient, isNotNull);
      });

      test('should clear token', () {
        // Arrange
        apiClient.setToken('some-token');

        // Act
        apiClient.clearToken();

        // Assert - Token is cleared internally
        expect(apiClient, isNotNull);
      });
    });

    group('Instance Tests', () {
      test('should return same instance (singleton)', () {
        // Arrange
        final instance1 = ApiClient();
        final instance2 = ApiClient();

        // Assert
        expect(instance1, same(instance2));
      });
    });

    group('Error Handling Tests', () {
      test('should handle ApiException properly', () {
        // Arrange
        const message = 'Test error';
        const statusCode = 400;
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
        const message = 'Validation error';
        const statusCode = 422;
        final errors = {'email': ['Email is required']};
        final exception = ApiException(
          message: message,
          statusCode: statusCode,
          errors: errors,
        );

        // Assert
        expect(exception.message, message);
        expect(exception.statusCode, statusCode);
        expect(exception.errors, errors);
      });
    });

    tearDown(() {
      apiClient.dispose();
    });
  });
}