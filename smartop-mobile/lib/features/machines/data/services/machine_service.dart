import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/auth_service.dart';
import '../models/machine.dart';

class MachineService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = _authService.currentToken;
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Get all machines
  Future<List<Machine>> getMachines({
    String? status,
    String? type,
    String? search,
  }) async {
    try {
      final headers = await _getHeaders();
      var url = '${AppConstants.apiBaseUrl}/machines';

      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;
      if (type != null) queryParams['type'] = type;
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
        final List<dynamic> machinesJson = data['data']['data'] ?? data['data'] ?? [];
        return machinesJson.map((json) => Machine.fromJson(json)).toList();
      } else {
        debugPrint('Error getting machines: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error getting machines: $e');
      return [];
    }
  }

  /// Get single machine by ID
  Future<Machine?> getMachine(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/machines/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Machine.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting machine: $e');
      return null;
    }
  }

  /// Get machine by QR code
  Future<Machine?> getMachineByQrCode(String qrCode) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/machines?qr_code=$qrCode'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> machines = data['data']['data'] ?? [];
        if (machines.isNotEmpty) {
          return Machine.fromJson(machines.first);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting machine by QR code: $e');
      return null;
    }
  }

  /// Create new machine
  Future<Map<String, dynamic>> createMachine({
    required String name,
    required String code,
    required String type,
    String? description,
    String? location,
    String? model,
    String? manufacturer,
    String? serialNumber,
    String? installationDate,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = {
        'name': name,
        'code': code,
        'type': type,
        if (description != null) 'description': description,
        if (location != null) 'location': location,
        if (model != null) 'model': model,
        if (manufacturer != null) 'manufacturer': manufacturer,
        if (serialNumber != null) 'serial_number': serialNumber,
        if (installationDate != null) 'installation_date': installationDate,
        'status': 'active',
      };

      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/machines'),
        headers: headers,
        body: json.encode(body),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Machine created successfully',
          'machine': Machine.fromJson(data['data']),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create machine',
        };
      }
    } catch (e) {
      debugPrint('Error creating machine: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Update machine
  Future<Map<String, dynamic>> updateMachine({
    required String id,
    String? name,
    String? code,
    String? type,
    String? description,
    String? location,
    String? status,
    String? model,
    String? manufacturer,
    String? serialNumber,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = <String, dynamic>{};

      if (name != null) body['name'] = name;
      if (code != null) body['code'] = code;
      if (type != null) body['type'] = type;
      if (description != null) body['description'] = description;
      if (location != null) body['location'] = location;
      if (status != null) body['status'] = status;
      if (model != null) body['model'] = model;
      if (manufacturer != null) body['manufacturer'] = manufacturer;
      if (serialNumber != null) body['serial_number'] = serialNumber;

      final response = await http.put(
        Uri.parse('${AppConstants.apiBaseUrl}/machines/$id'),
        headers: headers,
        body: json.encode(body),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Machine updated successfully',
          'machine': Machine.fromJson(data['data']),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update machine',
        };
      }
    } catch (e) {
      debugPrint('Error updating machine: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Delete machine
  Future<Map<String, dynamic>> deleteMachine(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${AppConstants.apiBaseUrl}/machines/$id'),
        headers: headers,
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Machine deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to delete machine',
        };
      }
    } catch (e) {
      debugPrint('Error deleting machine: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Generate QR code for machine
  Future<Map<String, dynamic>> generateQrCode(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/machines/$id/qr-code'),
        headers: headers,
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'QR code generated successfully',
          'qr_code': data['data']['qr_code'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to generate QR code',
        };
      }
    } catch (e) {
      debugPrint('Error generating QR code: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get active machines
  Future<List<Machine>> getActiveMachines() async {
    return getMachines(status: 'active');
  }

  /// Get maintenance machines
  Future<List<Machine>> getMaintenanceMachines() async {
    return getMachines(status: 'maintenance');
  }

  /// Get inactive machines
  Future<List<Machine>> getInactiveMachines() async {
    return getMachines(status: 'inactive');
  }

  /// Get machines by type
  Future<List<Machine>> getMachinesByType(String type) async {
    return getMachines(type: type);
  }

  /// Search machines
  Future<List<Machine>> searchMachines(String query) async {
    return getMachines(search: query);
  }
}
