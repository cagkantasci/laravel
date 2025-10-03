import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/storage_service.dart';
import '../models/work_session.dart';

class WorkSessionService {
  final StorageService _storageService = StorageService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storageService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Get active session for current operator
  Future<WorkSession?> getActiveSession() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${AppConstants.apiUrl}/work-sessions/active'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          return WorkSession.fromJson(data['data']);
        }
        return null;
      }
      return null;
    } catch (e) {
      print('Error getting active session: $e');
      return null;
    }
  }

  // Get my sessions
  Future<List<WorkSession>> getMySessions() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${AppConstants.apiUrl}/work-sessions/my-sessions'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> sessions = data['data']['data'] ?? [];
        return sessions.map((json) => WorkSession.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting my sessions: $e');
      return [];
    }
  }

  // Start work session
  Future<Map<String, dynamic>> startSession({
    required int machineId,
    required DateTime startTime,
    String? location,
    String? startNotes,
    int? controlListId,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = {
        'machine_id': machineId,
        'start_time': startTime.toIso8601String(),
        if (location != null) 'location': location,
        if (startNotes != null) 'start_notes': startNotes,
        if (controlListId != null) 'control_list_id': controlListId,
      };

      final response = await http.post(
        Uri.parse('${AppConstants.apiUrl}/work-sessions/start'),
        headers: headers,
        body: json.encode(body),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Çalışma seansı başlatıldı',
          'session': WorkSession.fromJson(data['data']),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Çalışma seansı başlatılamadı',
        };
      }
    } catch (e) {
      print('Error starting session: $e');
      return {
        'success': false,
        'message': 'Bir hata oluştu: $e',
      };
    }
  }

  // End work session
  Future<Map<String, dynamic>> endSession({
    required int sessionId,
    required DateTime endTime,
    String? endNotes,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = {
        'end_time': endTime.toIso8601String(),
        if (endNotes != null) 'end_notes': endNotes,
      };

      final response = await http.post(
        Uri.parse('${AppConstants.apiUrl}/work-sessions/$sessionId/end'),
        headers: headers,
        body: json.encode(body),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Çalışma seansı sonlandırıldı',
          'session': WorkSession.fromJson(data['data']),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Çalışma seansı sonlandırılamadı',
        };
      }
    } catch (e) {
      print('Error ending session: $e');
      return {
        'success': false,
        'message': 'Bir hata oluştu: $e',
      };
    }
  }

  // Get statistics
  Future<Map<String, dynamic>> getStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final headers = await _getHeaders();
      var url = '${AppConstants.apiUrl}/work-sessions/statistics';

      final queryParams = <String, String>{};
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String().split('T')[0];
      }

      if (queryParams.isNotEmpty) {
        url += '?${Uri(queryParameters: queryParams).query}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      }
      return {};
    } catch (e) {
      print('Error getting statistics: $e');
      return {};
    }
  }
}
