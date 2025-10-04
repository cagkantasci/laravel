import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/auth_service.dart';
import '../models/approval.dart';

class ApprovalService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = _authService.currentToken;
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Get all pending approvals
  Future<List<Approval>> getPendingApprovals({
    String? type,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final headers = await _getHeaders();
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (type != null) 'type': type,
      };

      final uri = Uri.parse('${AppConstants.apiBaseUrl}/approvals')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final approvals = (data['data'] as List)
            .map((json) => Approval.fromJson(json))
            .toList();
        return approvals;
      } else {
        throw Exception('Failed to load approvals: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading approvals: $e');
    }
  }

  // Get approval statistics
  Future<ApprovalStatistics> getStatistics() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/approvals/statistics'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApprovalStatistics.fromJson(data['data']);
      } else {
        throw Exception('Failed to load statistics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading statistics: $e');
    }
  }

  // Approve an item
  Future<void> approve(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/approvals/$id/approve'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to approve: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error approving: $e');
    }
  }

  // Reject an item
  Future<void> reject(int id, String reason) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({'reason': reason});

      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/approvals/$id/reject'),
        headers: headers,
        body: body,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to reject: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error rejecting: $e');
    }
  }
}
