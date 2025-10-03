import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';
import '../services/offline_sync_service.dart';
import '../constants/app_constants.dart';

class OfflineAwareWidget extends StatefulWidget {
  final Widget child;
  final Widget? offlineChild;
  final bool showOfflineMessage;
  final VoidCallback? onOnline;
  final VoidCallback? onOffline;

  const OfflineAwareWidget({
    super.key,
    required this.child,
    this.offlineChild,
    this.showOfflineMessage = true,
    this.onOnline,
    this.onOffline,
  });

  @override
  State<OfflineAwareWidget> createState() => _OfflineAwareWidgetState();
}

class _OfflineAwareWidgetState extends State<OfflineAwareWidget> {
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _isConnected = _connectivityService.isConnected;

    _connectivityService.connectionStream.listen((isConnected) {
      if (mounted) {
        setState(() {
          _isConnected = isConnected;
        });

        if (isConnected && widget.onOnline != null) {
          widget.onOnline!();
        } else if (!isConnected && widget.onOffline != null) {
          widget.onOffline!();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isConnected) {
      if (widget.offlineChild != null) {
        return widget.offlineChild!;
      }

      if (widget.showOfflineMessage) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.cloud_off,
                  size: 80,
                  color: Color(AppColors.dangerRed),
                ),
                const SizedBox(height: AppSizes.paddingLarge),
                const Text(
                  'İnternet Bağlantısı Yok',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSizes.paddingMedium),
                const Text(
                  'Bu özellik internet bağlantısı gerektirir.\nLütfen bağlantınızı kontrol edin.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: AppSizes.paddingLarge),
                ElevatedButton.icon(
                  onPressed: () async {
                    // Try to refresh connectivity status
                    await Future.delayed(const Duration(seconds: 1));
                    setState(() {
                      _isConnected = _connectivityService.isConnected;
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tekrar Dene'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(AppColors.primaryBlue),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    return widget.child;
  }
}

// Mixin for pages that need offline handling
mixin OfflineCapableMixin<T extends StatefulWidget> on State<T> {
  final ConnectivityService _connectivityService = ConnectivityService();
  final OfflineSyncService _syncService = OfflineSyncService();

  bool get isConnected => _connectivityService.isConnected;

  Future<List<Map<String, dynamic>>> getCachedMachines() async {
    return await _syncService.getCachedMachines();
  }

  Future<List<Map<String, dynamic>>> getCachedWorkTasks() async {
    return await _syncService.getCachedWorkTasks();
  }

  Future<List<Map<String, dynamic>>> getCachedControlLists() async {
    return await _syncService.getCachedControlLists();
  }

  Future<List<Map<String, dynamic>>> getCachedNotifications() async {
    return await _syncService.getCachedNotifications();
  }

  Future<void> addOfflineAction({
    required String type,
    required Map<String, dynamic> data,
  }) async {
    await _syncService.addOfflineAction(type: type, data: data);
  }

  void showOfflineSnackBar({String? message}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'Bu işlem çevrimdışıyken kullanılamaz'),
        backgroundColor: const Color(AppColors.dangerRed),
        action: SnackBarAction(
          label: 'Tamam',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void showOfflineActionSnackBar({String? message}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message ??
              'İşlem çevrimdışı olarak kaydedildi ve bağlantı kurulduğunda senkronize edilecek',
        ),
        backgroundColor: const Color(AppColors.warningOrange),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Tamam',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
