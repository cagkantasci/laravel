import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/control_list.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/constants/app_constants.dart';

class ControlListService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = _authService.currentToken;
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Operatöre atanmış kontrol listelerini getir
  Future<List<ControlList>> getMyControlLists({String? status}) async {
    try {
      final headers = await _getHeaders();
      String url = '${AppConstants.apiBaseUrl}/control-lists/my-lists';
      if (status != null && status.isNotEmpty) {
        url += '?status=$status';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> listsJson = data['data'] ?? [];
        return listsJson.map((json) => ControlList.fromJson(json)).toList();
      } else {
        debugPrint('Error getting control lists: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error getting control lists: $e');
      return [];
    }
  }

  /// Belirli bir kontrol listesinin detayını getir
  Future<ControlList?> getControlListDetail(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/control-lists/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ControlList.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting control list detail: $e');
      return null;
    }
  }

  /// Kontrol listesini başlat
  Future<Map<String, dynamic>> startControlList(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/control-lists/$id/start'),
        headers: headers,
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Kontrol listesi başlatıldı',
          'data': ControlList.fromJson(data['data']),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Kontrol listesi başlatılamadı',
        };
      }
    } catch (e) {
      debugPrint('Error starting control list: $e');
      return {
        'success': false,
        'message': 'Hata: $e',
      };
    }
  }

  /// Kontrol item'ı güncelle
  Future<Map<String, dynamic>> updateControlItem(
    String listId,
    String itemId,
    Map<String, dynamic> data,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${AppConstants.apiBaseUrl}/control-lists/$listId/items/$itemId'),
        headers: headers,
        body: json.encode(data),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Kontrol item güncellendi',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Kontrol item güncellenemedi',
        };
      }
    } catch (e) {
      debugPrint('Error updating control item: $e');
      return {
        'success': false,
        'message': 'Hata: $e',
      };
    }
  }

  /// Kontrol listesini tamamla
  Future<Map<String, dynamic>> completeControlList(
    String id, {
    String? notes,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/control-lists/$id/complete'),
        headers: headers,
        body: json.encode({'notes': notes}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Kontrol listesi tamamlandı',
          'data': ControlList.fromJson(data['data']),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Kontrol listesi tamamlanamadı',
        };
      }
    } catch (e) {
      debugPrint('Error completing control list: $e');
      return {
        'success': false,
        'message': 'Hata: $e',
      };
    }
  }

  /// Makineye ait kontrol listelerini getir
  Future<List<ControlList>> getMachineControlLists(String machineId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/control-lists?machine_id=$machineId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> listsJson = data['data']['data'] ?? data['data'] ?? [];
        return listsJson.map((json) => ControlList.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting machine control lists: $e');
      return [];
    }
  }

  /// Kontrol listesi istatistiklerini getir
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/dashboard'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? {};
      }
      return {};
    } catch (e) {
      debugPrint('Error getting statistics: $e');
      return {};
    }
  }

  /// Kontrol listesi onay/red işlemini geri al
  Future<Map<String, dynamic>> revertControlList(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/control-lists/$id/revert'),
        headers: headers,
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Geri alma işlemi başarılı',
          'data': ControlList.fromJson(data['data']),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Geri alma işlemi başarısız',
        };
      }
    } catch (e) {
      debugPrint('Error reverting control list: $e');
      return {
        'success': false,
        'message': 'Hata: $e',
      };
    }
  }

  /// Tüm kontrol listelerini getir
  Future<List<ControlList>> getAllControlLists({
    String? status,
    String? search,
  }) async {
    try {
      final headers = await _getHeaders();
      var url = '${AppConstants.apiBaseUrl}/control-lists';

      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;
      if (search != null) queryParams['search'] = search;

      if (queryParams.isNotEmpty) {
        url += '?${Uri(queryParameters: queryParams).query}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> listsJson = data['data']['data'] ?? data['data'] ?? [];
        return listsJson.map((json) => ControlList.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting all control lists: $e');
      return [];
    }
  }
}
