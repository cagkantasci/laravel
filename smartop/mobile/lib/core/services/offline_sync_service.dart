import 'dart:async';
import 'package:flutter/foundation.dart';
import 'connectivity_service.dart';
import 'offline_data_service.dart';
import '../network/api_client.dart';
import '../error/app_exception.dart';

class OfflineSyncService {
  static final OfflineSyncService _instance = OfflineSyncService._internal();
  factory OfflineSyncService() => _instance;
  OfflineSyncService._internal();

  final ConnectivityService _connectivityService = ConnectivityService();
  final OfflineDataService _offlineDataService = OfflineDataService();
  final ApiClient _apiClient = ApiClient();

  final StreamController<SyncStatus> _syncStatusController =
      StreamController<SyncStatus>.broadcast();

  bool _isSyncing = false;
  Timer? _syncTimer;

  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;
  bool get isSyncing => _isSyncing;

  Future<void> initialize() async {
    await _connectivityService.initialize();
    await _offlineDataService.initialize();

    // Listen for connectivity changes
    _connectivityService.connectionStream.listen((isConnected) {
      if (isConnected && !_isSyncing) {
        _scheduleSyncAttempt();
      }
    });

    // Schedule periodic sync when online
    _startPeriodicSync();
  }

  void _startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (_connectivityService.isConnected && !_isSyncing) {
        _performSync();
      }
    });
  }

  void _scheduleSyncAttempt() {
    // Delay sync attempt to allow network to stabilize
    Timer(const Duration(seconds: 2), () {
      if (_connectivityService.isConnected && !_isSyncing) {
        _performSync();
      }
    });
  }

  Future<void> forceSyncNow() async {
    if (!_connectivityService.isConnected) {
      throw const ApiException(
        message: 'İnternet bağlantısı yok',
        statusCode: 0,
      );
    }

    await _performSync();
  }

  Future<void> _performSync() async {
    if (_isSyncing) return;

    _isSyncing = true;
    _syncStatusController.add(SyncStatus.syncing);

    try {
      // 1. Sync pending actions first
      await _syncPendingActions();

      // 2. Download fresh data
      await _downloadFreshData();

      // 3. Update last sync time
      await _offlineDataService.updateLastSyncTime();

      _syncStatusController.add(SyncStatus.success);
    } catch (e) {
      debugPrint('Sync failed: $e');
      _syncStatusController.add(SyncStatus.failed);
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncPendingActions() async {
    final pendingActions = await _offlineDataService.getPendingActions();

    for (final action in pendingActions) {
      try {
        await _processPendingAction(action);
        await _offlineDataService.removePendingAction(action['id']);
      } catch (e) {
        debugPrint('Failed to sync action ${action['id']}: $e');
        // Continue with other actions
      }
    }
  }

  Future<void> _processPendingAction(Map<String, dynamic> action) async {
    final type = action['type'] as String;
    final data = action['data'] as Map<String, dynamic>;

    switch (type) {
      case 'update_work_task':
        await _apiClient.put('/work-tasks/${data['id']}', body: data);
        break;
      case 'create_control_result':
        await _apiClient.post('/control-results', body: data);
        break;
      case 'update_machine_status':
        await _apiClient.put('/machines/${data['id']}/status', body: data);
        break;
      case 'mark_notification_read':
        await _apiClient.put('/notifications/${data['id']}/read');
        break;
      default:
        debugPrint('Unknown pending action type: $type');
    }
  }

  Future<void> _downloadFreshData() async {
    try {
      // Download machines
      final machinesResponse = await _apiClient.get('/machines');
      if (machinesResponse['machines'] != null) {
        await _offlineDataService.storeMachines(
          List<Map<String, dynamic>>.from(machinesResponse['machines']),
        );
      }

      // Download work tasks
      final workTasksResponse = await _apiClient.get('/work-tasks');
      if (workTasksResponse['work_tasks'] != null) {
        await _offlineDataService.storeWorkTasks(
          List<Map<String, dynamic>>.from(workTasksResponse['work_tasks']),
        );
      }

      // Download control lists
      final controlListsResponse = await _apiClient.get('/control-lists');
      if (controlListsResponse['control_lists'] != null) {
        await _offlineDataService.storeControlLists(
          List<Map<String, dynamic>>.from(
            controlListsResponse['control_lists'],
          ),
        );
      }

      // Download notifications
      final notificationsResponse = await _apiClient.get('/notifications');
      if (notificationsResponse['notifications'] != null) {
        await _offlineDataService.storeNotifications(
          List<Map<String, dynamic>>.from(
            notificationsResponse['notifications'],
          ),
        );
      }
    } catch (e) {
      throw ApiException(
        message: 'Data download failed: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Add pending action when offline
  Future<void> addOfflineAction({
    required String type,
    required Map<String, dynamic> data,
  }) async {
    await _offlineDataService.addPendingAction({'type': type, 'data': data});
  }

  // Get cached data methods
  Future<List<Map<String, dynamic>>> getCachedMachines() async {
    return await _offlineDataService.getMachines();
  }

  Future<List<Map<String, dynamic>>> getCachedWorkTasks() async {
    return await _offlineDataService.getWorkTasks();
  }

  Future<List<Map<String, dynamic>>> getCachedControlLists() async {
    return await _offlineDataService.getControlLists();
  }

  Future<List<Map<String, dynamic>>> getCachedNotifications() async {
    return await _offlineDataService.getNotifications();
  }

  // Get sync info
  Future<Map<String, dynamic>> getSyncInfo() async {
    final lastSync = await _offlineDataService.getLastSyncTime();
    final pendingActions = await _offlineDataService.getPendingActions();
    final storageInfo = await _offlineDataService.getStorageInfo();

    return {
      'lastSync': lastSync?.toIso8601String(),
      'pendingActionsCount': pendingActions.length,
      'isConnected': _connectivityService.isConnected,
      'isSyncing': _isSyncing,
      'storageInfo': storageInfo,
    };
  }

  void dispose() {
    _syncTimer?.cancel();
    _syncStatusController.close();
    _connectivityService.dispose();
  }
}

enum SyncStatus { idle, syncing, success, failed }
