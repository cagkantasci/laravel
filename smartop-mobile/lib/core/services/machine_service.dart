import 'dart:io';
import '../network/api_client.dart';
import '../error/app_exception.dart';
import '../../features/machines/data/models/machine.dart';
import '../../features/machines/data/models/control_item.dart';

class MachineService {
  static final MachineService _instance = MachineService._internal();
  factory MachineService() => _instance;
  MachineService._internal();

  final ApiClient _apiClient = ApiClient();

  // Get all machines
  Future<List<Machine>> getMachines({
    String? search,
    String? status,
    String? type,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }

      final response = await _apiClient.get(
        '/machines',
        queryParams: queryParams,
      );
      final machinesData = response['data'] as List<dynamic>? ?? [];

      return machinesData
          .map((json) => Machine.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Failed to fetch machines: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Get machine by ID
  Future<Machine> getMachineById(int id) async {
    try {
      final response = await _apiClient.get('/machines/$id');
      final machineData = response['data'];

      if (machineData == null) {
        throw ApiException(message: 'Machine not found', statusCode: 404);
      }

      return Machine.fromJson(machineData);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Failed to fetch machine: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Get machine by QR code
  Future<Machine> getMachineByQrCode(String qrCode) async {
    try {
      final response = await _apiClient.get('/machines/qr/$qrCode');
      final machineData = response['data'];

      if (machineData == null) {
        throw ApiException(
          message: 'Machine not found for QR code',
          statusCode: 404,
        );
      }

      return Machine.fromJson(machineData);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Failed to fetch machine by QR code: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Create new machine
  Future<Machine> createMachine({
    required String name,
    required String code,
    required String type,
    required String location,
    String? description,
    String? manufacturer,
    String? model,
    String? serialNumber,
    DateTime? installationDate,
    DateTime? lastMaintenanceDate,
    DateTime? nextMaintenanceDate,
    String status = 'active',
  }) async {
    try {
      final body = <String, dynamic>{
        'name': name,
        'code': code,
        'type': type,
        'location': location,
        'status': status,
      };

      if (description != null) body['description'] = description;
      if (manufacturer != null) body['manufacturer'] = manufacturer;
      if (model != null) body['model'] = model;
      if (serialNumber != null) body['serial_number'] = serialNumber;
      if (installationDate != null) {
        body['installation_date'] = installationDate.toIso8601String();
      }
      if (lastMaintenanceDate != null) {
        body['last_maintenance_date'] = lastMaintenanceDate.toIso8601String();
      }
      if (nextMaintenanceDate != null) {
        body['next_maintenance_date'] = nextMaintenanceDate.toIso8601String();
      }

      final response = await _apiClient.post('/machines', body: body);
      final machineData = response['data'];

      if (machineData == null) {
        throw ApiException(
          message: 'Invalid create machine response',
          statusCode: 500,
        );
      }

      return Machine.fromJson(machineData);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Failed to create machine: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Update machine
  Future<Machine> updateMachine(
    int id, {
    String? name,
    String? code,
    String? type,
    String? location,
    String? description,
    String? manufacturer,
    String? model,
    String? serialNumber,
    DateTime? installationDate,
    DateTime? lastMaintenanceDate,
    DateTime? nextMaintenanceDate,
    String? status,
  }) async {
    try {
      final body = <String, dynamic>{};

      if (name != null) body['name'] = name;
      if (code != null) body['code'] = code;
      if (type != null) body['type'] = type;
      if (location != null) body['location'] = location;
      if (description != null) body['description'] = description;
      if (manufacturer != null) body['manufacturer'] = manufacturer;
      if (model != null) body['model'] = model;
      if (serialNumber != null) body['serial_number'] = serialNumber;
      if (status != null) body['status'] = status;
      if (installationDate != null) {
        body['installation_date'] = installationDate.toIso8601String();
      }
      if (lastMaintenanceDate != null) {
        body['last_maintenance_date'] = lastMaintenanceDate.toIso8601String();
      }
      if (nextMaintenanceDate != null) {
        body['next_maintenance_date'] = nextMaintenanceDate.toIso8601String();
      }

      final response = await _apiClient.put('/machines/$id', body: body);
      final machineData = response['data'];

      if (machineData == null) {
        throw ApiException(
          message: 'Invalid update machine response',
          statusCode: 500,
        );
      }

      return Machine.fromJson(machineData);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Failed to update machine: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Delete machine
  Future<void> deleteMachine(int id) async {
    try {
      await _apiClient.delete('/machines/$id');
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Failed to delete machine: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Get control items for machine
  Future<List<ControlItem>> getMachineControlItems(int machineId) async {
    try {
      final response = await _apiClient.get('/machines/$machineId/controls');
      final controlsData = response['data'] as List<dynamic>? ?? [];

      return controlsData
          .map((json) => ControlItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Failed to fetch machine controls: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Submit control results
  Future<void> submitControlResults(
    int machineId,
    List<Map<String, dynamic>> results,
  ) async {
    try {
      await _apiClient.post(
        '/machines/$machineId/controls/submit',
        body: {'results': results},
      );
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Failed to submit control results: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Upload control photo
  Future<String> uploadControlPhoto(
    int machineId,
    int controlId,
    String photoPath,
  ) async {
    try {
      final response = await _apiClient.uploadFile(
        '/machines/$machineId/controls/$controlId/photo',
        File(photoPath),
        fieldName: 'photo',
      );

      final photoUrl = response['data']['url'];
      if (photoUrl == null) {
        throw ApiException(
          message: 'Invalid photo upload response',
          statusCode: 500,
        );
      }

      return photoUrl;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Failed to upload photo: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Get machine statistics
  Future<Map<String, dynamic>> getMachineStatistics() async {
    try {
      final response = await _apiClient.get('/machines/statistics');
      return response['data'] ?? {};
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Failed to fetch machine statistics: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Get machine maintenance history
  Future<List<Map<String, dynamic>>> getMachineMaintenanceHistory(
    int machineId,
  ) async {
    try {
      final response = await _apiClient.get('/machines/$machineId/maintenance');
      final historyData = response['data'] as List<dynamic>? ?? [];

      return historyData.map((json) => json as Map<String, dynamic>).toList();
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Failed to fetch maintenance history: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Schedule maintenance
  Future<void> scheduleMaintenance({
    required int machineId,
    required DateTime scheduledDate,
    required String type,
    String? description,
    String? assignedTo,
  }) async {
    try {
      final body = <String, dynamic>{
        'scheduled_date': scheduledDate.toIso8601String(),
        'type': type,
      };

      if (description != null) body['description'] = description;
      if (assignedTo != null) body['assigned_to'] = assignedTo;

      await _apiClient.post('/machines/$machineId/maintenance', body: body);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Failed to schedule maintenance: ${e.toString()}',
        statusCode: 0,
      );
    }
  }
}
