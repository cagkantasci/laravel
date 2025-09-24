import '../network/api_client.dart';
import '../error/app_exception.dart';

class DashboardService {
  static final DashboardService _instance = DashboardService._internal();
  factory DashboardService() => _instance;
  DashboardService._internal();

  final ApiClient _apiClient = ApiClient();

  // Get dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _apiClient.get('/dashboard/stats');
      return response['data'] ?? {};
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Failed to fetch dashboard stats: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Get recent activities
  Future<List<Map<String, dynamic>>> getRecentActivities({
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        '/dashboard/activities',
        queryParams: {'limit': limit},
      );
      final activitiesData = response['data'] as List<dynamic>? ?? [];

      return activitiesData
          .map((json) => json as Map<String, dynamic>)
          .toList();
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Failed to fetch recent activities: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Get machine status overview
  Future<Map<String, dynamic>> getMachineStatusOverview() async {
    try {
      final response = await _apiClient.get('/dashboard/machines/status');
      return response['data'] ?? {};
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Failed to fetch machine status overview: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Get control completion overview
  Future<Map<String, dynamic>> getControlCompletionOverview() async {
    try {
      final response = await _apiClient.get('/dashboard/controls/completion');
      return response['data'] ?? {};
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Failed to fetch control completion overview: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Get maintenance alerts
  Future<List<Map<String, dynamic>>> getMaintenanceAlerts() async {
    try {
      final response = await _apiClient.get('/dashboard/maintenance/alerts');
      final alertsData = response['data'] as List<dynamic>? ?? [];

      return alertsData.map((json) => json as Map<String, dynamic>).toList();
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Failed to fetch maintenance alerts: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Get efficiency trends
  Future<List<Map<String, dynamic>>> getEfficiencyTrends({
    int days = 30,
  }) async {
    try {
      final response = await _apiClient.get(
        '/dashboard/efficiency/trends',
        queryParams: {'days': days},
      );
      final trendsData = response['data'] as List<dynamic>? ?? [];

      return trendsData.map((json) => json as Map<String, dynamic>).toList();
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Failed to fetch efficiency trends: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Get critical alerts
  Future<List<Map<String, dynamic>>> getCriticalAlerts() async {
    try {
      final response = await _apiClient.get('/dashboard/alerts/critical');
      final alertsData = response['data'] as List<dynamic>? ?? [];

      return alertsData.map((json) => json as Map<String, dynamic>).toList();
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Failed to fetch critical alerts: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Get performance metrics
  Future<Map<String, dynamic>> getPerformanceMetrics({
    String period = 'week', // 'day', 'week', 'month', 'year'
  }) async {
    try {
      final response = await _apiClient.get(
        '/dashboard/performance',
        queryParams: {'period': period},
      );
      return response['data'] ?? {};
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Failed to fetch performance metrics: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Get user activity summary
  Future<Map<String, dynamic>> getUserActivitySummary() async {
    try {
      final response = await _apiClient.get('/dashboard/user/activity');
      return response['data'] ?? {};
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Failed to fetch user activity summary: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Mark alert as read
  Future<void> markAlertAsRead(int alertId) async {
    try {
      await _apiClient.patch('/dashboard/alerts/$alertId/read');
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Failed to mark alert as read: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Dismiss alert
  Future<void> dismissAlert(int alertId) async {
    try {
      await _apiClient.delete('/dashboard/alerts/$alertId');
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Failed to dismiss alert: ${e.toString()}',
        statusCode: 0,
      );
    }
  }
}
