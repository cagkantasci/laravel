import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineDataService {
  static final OfflineDataService _instance = OfflineDataService._internal();
  factory OfflineDataService() => _instance;
  OfflineDataService._internal();

  // Storage keys
  static const String _machinesKey = 'offline_machines';
  static const String _workTasksKey = 'offline_work_tasks';
  static const String _controlListsKey = 'offline_control_lists';
  static const String _notificationsKey = 'offline_notifications';
  static const String _pendingActionsKey = 'pending_actions';
  static const String _lastSyncKey = 'last_sync_time';

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Generic data storage methods
  Future<void> storeData(String key, List<dynamic> data) async {
    if (_prefs == null) await initialize();
    final jsonString = jsonEncode(data);
    await _prefs!.setString(key, jsonString);
  }

  Future<List<dynamic>> getData(String key) async {
    if (_prefs == null) await initialize();
    final jsonString = _prefs!.getString(key);
    if (jsonString == null) return [];
    return jsonDecode(jsonString) as List<dynamic>;
  }

  // Machines data
  Future<void> storeMachines(List<Map<String, dynamic>> machines) async {
    await storeData(_machinesKey, machines);
  }

  Future<List<Map<String, dynamic>>> getMachines() async {
    final data = await getData(_machinesKey);
    return data.cast<Map<String, dynamic>>();
  }

  // Work tasks data
  Future<void> storeWorkTasks(List<Map<String, dynamic>> workTasks) async {
    await storeData(_workTasksKey, workTasks);
  }

  Future<List<Map<String, dynamic>>> getWorkTasks() async {
    final data = await getData(_workTasksKey);
    return data.cast<Map<String, dynamic>>();
  }

  // Control lists data
  Future<void> storeControlLists(
    List<Map<String, dynamic>> controlLists,
  ) async {
    await storeData(_controlListsKey, controlLists);
  }

  Future<List<Map<String, dynamic>>> getControlLists() async {
    final data = await getData(_controlListsKey);
    return data.cast<Map<String, dynamic>>();
  }

  // Notifications data
  Future<void> storeNotifications(
    List<Map<String, dynamic>> notifications,
  ) async {
    await storeData(_notificationsKey, notifications);
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    final data = await getData(_notificationsKey);
    return data.cast<Map<String, dynamic>>();
  }

  // Pending actions (actions taken while offline)
  Future<void> addPendingAction(Map<String, dynamic> action) async {
    final pendingActions = await getPendingActions();
    action['timestamp'] = DateTime.now().toIso8601String();
    action['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    pendingActions.add(action);
    await storeData(_pendingActionsKey, pendingActions);
  }

  Future<List<Map<String, dynamic>>> getPendingActions() async {
    final data = await getData(_pendingActionsKey);
    return data.cast<Map<String, dynamic>>();
  }

  Future<void> removePendingAction(String actionId) async {
    final pendingActions = await getPendingActions();
    pendingActions.removeWhere((action) => action['id'] == actionId);
    await storeData(_pendingActionsKey, pendingActions);
  }

  Future<void> clearPendingActions() async {
    await storeData(_pendingActionsKey, []);
  }

  // Sync timestamp
  Future<void> updateLastSyncTime() async {
    if (_prefs == null) await initialize();
    await _prefs!.setString(_lastSyncKey, DateTime.now().toIso8601String());
  }

  Future<DateTime?> getLastSyncTime() async {
    if (_prefs == null) await initialize();
    final timeString = _prefs!.getString(_lastSyncKey);
    if (timeString == null) return null;
    return DateTime.tryParse(timeString);
  }

  // Clear all offline data
  Future<void> clearAllData() async {
    if (_prefs == null) await initialize();
    await _prefs!.remove(_machinesKey);
    await _prefs!.remove(_workTasksKey);
    await _prefs!.remove(_controlListsKey);
    await _prefs!.remove(_notificationsKey);
    await _prefs!.remove(_pendingActionsKey);
    await _prefs!.remove(_lastSyncKey);
  }

  // Get storage size info
  Future<Map<String, int>> getStorageInfo() async {
    final machines = await getMachines();
    final workTasks = await getWorkTasks();
    final controlLists = await getControlLists();
    final notifications = await getNotifications();
    final pendingActions = await getPendingActions();

    return {
      'machines': machines.length,
      'workTasks': workTasks.length,
      'controlLists': controlLists.length,
      'notifications': notifications.length,
      'pendingActions': pendingActions.length,
    };
  }
}
