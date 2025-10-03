import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/qr_scanner/data/models/scan_history_item.dart';

class ScanHistoryService {
  static final ScanHistoryService _instance = ScanHistoryService._internal();
  factory ScanHistoryService() => _instance;
  ScanHistoryService._internal();

  final List<ScanHistoryItem> _history = [];
  final StreamController<List<ScanHistoryItem>> _historyController =
      StreamController<List<ScanHistoryItem>>.broadcast();

  List<ScanHistoryItem> get history => List.unmodifiable(_history);
  Stream<List<ScanHistoryItem>> get historyStream => _historyController.stream;

  static const String _storageKey = 'scan_history';
  static const int _maxHistoryItems = 100;

  Future<void> initialize() async {
    await _loadHistory();
  }

  Future<void> addScanResult({
    required String scannedCode,
    required String codeType,
    required String result,
    required bool isSuccessful,
    Map<String, dynamic>? metadata,
  }) async {
    final historyItem = ScanHistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      scannedCode: scannedCode,
      codeType: codeType,
      scanTime: DateTime.now(),
      result: result,
      isSuccessful: isSuccessful,
      metadata: metadata,
    );

    _history.insert(0, historyItem); // Add to beginning

    // Keep only the latest items
    if (_history.length > _maxHistoryItems) {
      _history.removeRange(_maxHistoryItems, _history.length);
    }

    _historyController.add(_history);
    await _saveHistory();
  }

  Future<void> clearHistory() async {
    _history.clear();
    _historyController.add(_history);
    await _saveHistory();
  }

  Future<void> removeScanItem(String id) async {
    _history.removeWhere((item) => item.id == id);
    _historyController.add(_history);
    await _saveHistory();
  }

  List<ScanHistoryItem> getHistoryByType(String codeType) {
    return _history.where((item) => item.codeType == codeType).toList();
  }

  List<ScanHistoryItem> getSuccessfulScans() {
    return _history.where((item) => item.isSuccessful).toList();
  }

  List<ScanHistoryItem> getFailedScans() {
    return _history.where((item) => !item.isSuccessful).toList();
  }

  int get totalScans => _history.length;
  int get successfulScans => _history.where((item) => item.isSuccessful).length;
  int get failedScans => _history.where((item) => !item.isSuccessful).length;

  double get successRate {
    if (_history.isEmpty) return 0.0;
    return (successfulScans / totalScans) * 100;
  }

  Map<String, int> get scansByType {
    final Map<String, int> typeCount = {};
    for (final item in _history) {
      typeCount[item.codeType] = (typeCount[item.codeType] ?? 0) + 1;
    }
    return typeCount;
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_storageKey);

      if (historyJson != null) {
        final List<dynamic> historyList = json.decode(historyJson);
        _history.clear();
        _history.addAll(
          historyList.map((item) => ScanHistoryItem.fromJson(item)).toList(),
        );
        _historyController.add(_history);
      }
    } catch (e) {
      print('Failed to load scan history: $e');
    }
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = json.encode(
        _history.map((item) => item.toJson()).toList(),
      );
      await prefs.setString(_storageKey, historyJson);
    } catch (e) {
      print('Failed to save scan history: $e');
    }
  }

  void dispose() {
    _historyController.close();
  }
}
