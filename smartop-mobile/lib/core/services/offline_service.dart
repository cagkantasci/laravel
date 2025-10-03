import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';

class OfflineService {
  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  OfflineService._internal();

  static const String _offlineDataKey = 'offline_data';
  static const String _pendingSyncKey = 'pending_sync';
  static const String _lastSyncKey = 'last_sync';

  Future<bool> get isOnline async {
    try {
      // Try to reach a reliable server to confirm internet access
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> saveOfflineData(String key, dynamic data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final offlineData = await _getOfflineData();

      offlineData[key] = {
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
        'synced': false,
      };

      await prefs.setString(_offlineDataKey, jsonEncode(offlineData));
    } catch (e) {
      print('Error saving offline data: $e');
    }
  }

  Future<dynamic> getOfflineData(String key) async {
    try {
      final offlineData = await _getOfflineData();
      return offlineData[key]?['data'];
    } catch (e) {
      print('Error getting offline data: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> _getOfflineData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataString = prefs.getString(_offlineDataKey);
      if (dataString != null) {
        return Map<String, dynamic>.from(jsonDecode(dataString));
      }
      return {};
    } catch (e) {
      print('Error reading offline data: $e');
      return {};
    }
  }

  Future<void> addPendingSync(String action, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingSync = await _getPendingSync();

      pendingSync.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'action': action,
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      });

      await prefs.setString(_pendingSyncKey, jsonEncode(pendingSync));
    } catch (e) {
      print('Error adding pending sync: $e');
    }
  }

  Future<List<dynamic>> _getPendingSync() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final syncString = prefs.getString(_pendingSyncKey);
      if (syncString != null) {
        return List<dynamic>.from(jsonDecode(syncString));
      }
      return [];
    } catch (e) {
      print('Error reading pending sync: $e');
      return [];
    }
  }

  Future<List<dynamic>> getPendingSyncItems() async {
    return await _getPendingSync();
  }

  Future<void> syncPendingData() async {
    if (!await isOnline) {
      print('No internet connection for sync');
      return;
    }

    try {
      final pendingItems = await _getPendingSync();
      if (pendingItems.isEmpty) {
        print('No pending sync items');
        return;
      }

      print('Syncing ${pendingItems.length} pending items...');

      // Mock sync process - in real app, this would send data to server
      for (final item in pendingItems) {
        await _mockSyncItem(item);
      }

      // Clear pending sync after successful sync
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pendingSyncKey);
      await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());

      print('Sync completed successfully');
    } catch (e) {
      print('Error during sync: $e');
    }
  }

  Future<void> _mockSyncItem(Map<String, dynamic> item) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock different sync actions
    switch (item['action']) {
      case 'control_completed':
        print('Synced control completion: ${item['data']['controlId']}');
        break;
      case 'machine_status_update':
        print('Synced machine status: ${item['data']['machineId']}');
        break;
      case 'maintenance_logged':
        print('Synced maintenance log: ${item['data']['maintenanceId']}');
        break;
      default:
        print('Synced generic action: ${item['action']}');
    }
  }

  Future<DateTime?> getLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSyncString = prefs.getString(_lastSyncKey);
      if (lastSyncString != null) {
        return DateTime.parse(lastSyncString);
      }
      return null;
    } catch (e) {
      print('Error getting last sync time: $e');
      return null;
    }
  }

  Future<void> clearOfflineData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_offlineDataKey);
      await prefs.remove(_pendingSyncKey);
      await prefs.remove(_lastSyncKey);
      print('Offline data cleared');
    } catch (e) {
      print('Error clearing offline data: $e');
    }
  }

  // Auto sync when connection is restored
  void startAutoSync() {
    // Periodically check for internet connection and sync
    Timer.periodic(const Duration(minutes: 5), (_) async {
      if (await isOnline) {
        await syncPendingData();
      }
    });
  }

  // Mock data for offline testing
  Future<void> loadMockOfflineData() async {
    // Load some mock data for offline usage
    await saveOfflineData('machines', [
      {
        'id': 'M001',
        'name': 'CNC Tezgah #1',
        'status': 'Çalışıyor',
        'efficiency': 85.3,
      },
      {
        'id': 'M002',
        'name': 'Hadde Makinesi #2',
        'status': 'Bakım',
        'efficiency': 0.0,
      },
    ]);

    await saveOfflineData('control_lists', [
      {
        'id': 'CL001',
        'title': 'Günlük Güvenlik Kontrolü',
        'items': ['Acil durdurma butonu', 'Güvenlik kapıları', 'Alarm sistemi'],
      },
      {
        'id': 'CL002',
        'title': 'Haftalık Bakım Kontrolü',
        'items': ['Yağlama seviyeleri', 'Titreşim kontrolü', 'Sıcaklık ölçümü'],
      },
    ]);

    print('Mock offline data loaded');
  }

  // Utility methods
  Future<bool> hasOfflineData(String key) async {
    final data = await getOfflineData(key);
    return data != null;
  }

  Future<int> getPendingSyncCount() async {
    final pendingItems = await _getPendingSync();
    return pendingItems.length;
  }

  Future<Map<String, dynamic>> getOfflineStatus() async {
    final lastSync = await getLastSyncTime();
    final pendingCount = await getPendingSyncCount();
    final online = await isOnline;

    return {
      'isOnline': online,
      'lastSyncTime': lastSync?.toIso8601String(),
      'pendingSyncCount': pendingCount,
      'hasOfflineData': (await _getOfflineData()).isNotEmpty,
    };
  }
}
