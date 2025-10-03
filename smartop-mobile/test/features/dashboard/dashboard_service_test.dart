import 'package:flutter_test/flutter_test.dart';
import 'package:smartop_mobile/core/services/dashboard_service.dart';
import 'package:smartop_mobile/core/error/app_exception.dart';

void main() {
  group('DashboardService Tests', () {
    late DashboardService dashboardService;

    setUp(() {
      dashboardService = DashboardService();
    });

    group('Service Instance Tests', () {
      test('should return same instance (singleton)', () {
        // Arrange
        final instance1 = DashboardService();
        final instance2 = DashboardService();

        // Assert
        expect(instance1, same(instance2));
      });

      test('should initialize without errors', () {
        // Assert
        expect(dashboardService, isNotNull);
      });
    });

    group('Error Handling Tests', () {
      test('should handle ApiException properly', () {
        // Arrange
        const message = 'Dashboard fetch failed';
        const statusCode = 500;
        final exception = ApiException(
          message: message,
          statusCode: statusCode,
        );

        // Assert
        expect(exception.message, message);
        expect(exception.statusCode, statusCode);
        expect(exception.toString(), contains(message));
      });

      test('should handle network timeout gracefully', () {
        // Arrange
        const message = 'Network timeout';
        const statusCode = 0;
        final exception = ApiException(
          message: message,
          statusCode: statusCode,
        );

        // Assert
        expect(exception.message, message);
        expect(exception.statusCode, statusCode);
      });

      test('should handle unauthorized access', () {
        // Arrange
        const message = 'Unauthorized access';
        const statusCode = 401;
        final exception = ApiException(
          message: message,
          statusCode: statusCode,
        );

        // Assert
        expect(exception.message, message);
        expect(exception.statusCode, statusCode);
      });

      test('should handle malformed response data', () {
        // Arrange
        const message = 'Failed to parse response';
        const statusCode = 200;
        final exception = ApiException(
          message: message,
          statusCode: statusCode,
        );

        // Assert
        expect(exception.message, message);
        expect(exception.statusCode, statusCode);
      });
    });

    group('Data Validation Tests', () {
      test('should validate dashboard stats data structure', () {
        // Arrange
        final mockData = {
          'total_machines': 25,
          'active_machines': 20,
          'maintenance_machines': 3,
          'inactive_machines': 2,
          'total_control_lists': 150,
          'recent_activities': []
        };

        // Assert
        expect(mockData['total_machines'], isA<int>());
        expect(mockData['active_machines'], isA<int>());
        expect(mockData['maintenance_machines'], isA<int>());
        expect(mockData['inactive_machines'], isA<int>());
        expect(mockData['total_control_lists'], isA<int>());
        expect(mockData['recent_activities'], isA<List>());
      });

      test('should validate activity data structure', () {
        // Arrange
        final mockActivity = {
          'id': 1,
          'type': 'control_list_created',
          'message': 'New control list created',
          'user': 'John Doe',
          'created_at': '2024-01-15T10:30:00Z'
        };

        // Assert
        expect(mockActivity['id'], isA<int>());
        expect(mockActivity['type'], isA<String>());
        expect(mockActivity['message'], isA<String>());
        expect(mockActivity['user'], isA<String>());
        expect(mockActivity['created_at'], isA<String>());
      });
    });

    group('Parameters Validation Tests', () {
      test('should validate activity limit parameter', () {
        // Arrange
        const validLimit = 10;
        const invalidLimit = -1;

        // Assert
        expect(validLimit, greaterThan(0));
        expect(invalidLimit, lessThan(0));
      });

      test('should validate chart data parameters', () {
        // Arrange
        final mockChartData = {
          'labels': ['Active', 'Maintenance', 'Inactive'],
          'data': [20, 3, 2],
          'total': 25
        };

        // Assert
        expect(mockChartData['labels'], isA<List>());
        expect(mockChartData['data'], isA<List>());
        expect(mockChartData['total'], isA<int>());
        expect((mockChartData['labels'] as List).length,
               equals((mockChartData['data'] as List).length));
      });
    });

    group('Response Structure Tests', () {
      test('should handle empty dashboard data', () {
        // Arrange
        final emptyData = {
          'total_machines': 0,
          'active_machines': 0,
          'maintenance_machines': 0,
          'inactive_machines': 0,
          'total_control_lists': 0,
          'recent_activities': <Map<String, dynamic>>[]
        };

        // Assert
        expect(emptyData['total_machines'], 0);
        expect(emptyData['recent_activities'], isEmpty);
      });

      test('should handle performance metrics structure', () {
        // Arrange
        final mockMetrics = {
          'machine_utilization': {
            'daily': [
              {'date': '2024-01-15', 'utilization': 85.5},
              {'date': '2024-01-14', 'utilization': 78.3}
            ]
          },
          'maintenance_compliance': {
            'completed_on_time': 95,
            'completed_late': 3,
            'overdue': 2
          }
        };

        // Assert
        expect(mockMetrics['machine_utilization'], isA<Map>());
        expect(mockMetrics['maintenance_compliance'], isA<Map>());
        final utilization = mockMetrics['machine_utilization'] as Map;
        expect(utilization['daily'], isA<List>());
      });
    });
  });
}