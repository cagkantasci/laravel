import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/control_list.dart';
import '../../../../core/services/mock_auth_service.dart';

class ControlListService {
  static const String baseUrl = 'http://127.0.0.1:8001/api';

  /// Operatöre atanmış kontrol listelerini getir
  Future<List<ControlList>> getMyControlLists({String? status}) async {
    try {
      final token = MockAuthService.getCurrentToken();
      if (token == null) {
        throw Exception('Token bulunamadı');
      }

      String url = '$baseUrl/control-lists/my-lists';
      if (status != null && status.isNotEmpty) {
        url += '?status=$status';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> listsJson = data['data'] ?? [];
        return listsJson.map((json) => ControlList.fromJson(json)).toList();
      } else {
        throw Exception('Kontrol listeleri yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Kontrol listeleri yüklenirken hata: $e');
    }
  }

  /// Belirli bir kontrol listesinin detayını getir
  Future<ControlList> getControlListDetail(String id) async {
    try {
      final token = MockAuthService.getCurrentToken();
      if (token == null) {
        throw Exception('Token bulunamadı');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/control-lists/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ControlList.fromJson(data['data']);
      } else {
        throw Exception('Kontrol listesi detayı yüklenemedi');
      }
    } catch (e) {
      throw Exception('Kontrol listesi detayı yüklenirken hata: $e');
    }
  }

  /// Kontrol listesini başlat
  Future<ControlList> startControlList(String id) async {
    try {
      final token = MockAuthService.getCurrentToken();
      if (token == null) {
        throw Exception('Token bulunamadı');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/control-lists/$id/start'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ControlList.fromJson(data['data']);
      } else {
        throw Exception('Kontrol listesi başlatılamadı');
      }
    } catch (e) {
      throw Exception('Kontrol listesi başlatılırken hata: $e');
    }
  }

  /// Kontrol item'ı güncelle
  Future<void> updateControlItem(
    String listId,
    String itemId,
    Map<String, dynamic> data,
  ) async {
    try {
      final token = MockAuthService.getCurrentToken();
      if (token == null) {
        throw Exception('Token bulunamadı');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/control-lists/$listId/items/$itemId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      if (response.statusCode != 200) {
        throw Exception('Kontrol item güncellenemedi');
      }
    } catch (e) {
      throw Exception('Kontrol item güncellenirken hata: $e');
    }
  }

  /// Kontrol listesini tamamla
  Future<ControlList> completeControlList(
    String id, {
    String? notes,
  }) async {
    try {
      final token = MockAuthService.getCurrentToken();
      if (token == null) {
        throw Exception('Token bulunamadı');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/control-lists/$id/complete'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'notes': notes,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ControlList.fromJson(data['data']);
      } else {
        throw Exception('Kontrol listesi tamamlanamadı');
      }
    } catch (e) {
      throw Exception('Kontrol listesi tamamlanırken hata: $e');
    }
  }

  /// Makineye ait kontrol listelerini getir
  Future<List<ControlList>> getMachineControlLists(String machineId) async {
    try {
      final token = MockAuthService.getCurrentToken();
      if (token == null) {
        throw Exception('Token bulunamadı');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/machines/$machineId/control-lists'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> listsJson = data['data'] ?? [];
        return listsJson.map((json) => ControlList.fromJson(json)).toList();
      } else {
        throw Exception('Makine kontrol listeleri yüklenemedi');
      }
    } catch (e) {
      throw Exception('Makine kontrol listeleri yüklenirken hata: $e');
    }
  }

  /// Kontrol listesi istatistiklerini getir
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final token = MockAuthService.getCurrentToken();
      if (token == null) {
        throw Exception('Token bulunamadı');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/control-lists/statistics'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? {};
      } else {
        throw Exception('İstatistikler yüklenemedi');
      }
    } catch (e) {
      throw Exception('İstatistikler yüklenirken hata: $e');
    }
  }

  /// Kontrol listesi onay/red işlemini geri al
  Future<ControlList> revertControlList(String id) async {
    try {
      final token = MockAuthService.getCurrentToken();
      if (token == null) {
        throw Exception('Token bulunamadı');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/control-lists/$id/revert'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ControlList.fromJson(data['data']);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Geri alma işlemi başarısız');
      }
    } catch (e) {
      throw Exception('Geri alma işlemi sırasında hata: $e');
    }
  }
}
