import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';
import '../services/offline_sync_service.dart';
import '../constants/app_constants.dart';

class OfflineIndicator extends StatefulWidget {
  const OfflineIndicator({super.key});

  @override
  State<OfflineIndicator> createState() => _OfflineIndicatorState();
}

class _OfflineIndicatorState extends State<OfflineIndicator>
    with TickerProviderStateMixin {
  final ConnectivityService _connectivityService = ConnectivityService();
  final OfflineSyncService _syncService = OfflineSyncService();

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  bool _isConnected = true;
  bool _isSyncing = false;
  int _pendingActionsCount = 0;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _initializeConnectivity();
    _listenToConnectivity();
    _listenToSyncStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeConnectivity() {
    setState(() {
      _isConnected = _connectivityService.isConnected;
    });
    _updateSyncInfo();
  }

  void _listenToConnectivity() {
    _connectivityService.connectionStream.listen((isConnected) {
      setState(() {
        _isConnected = isConnected;
      });

      if (isConnected) {
        _animationController.forward().then((_) {
          _animationController.reverse();
        });
      }

      _updateSyncInfo();
    });
  }

  void _listenToSyncStatus() {
    _syncService.syncStatusStream.listen((status) {
      setState(() {
        _isSyncing = status == SyncStatus.syncing;
      });

      if (status == SyncStatus.success) {
        _updateSyncInfo();
      }
    });
  }

  Future<void> _updateSyncInfo() async {
    final syncInfo = await _syncService.getSyncInfo();
    setState(() {
      _pendingActionsCount = syncInfo['pendingActionsCount'] ?? 0;
    });
  }

  Future<void> _showSyncDetails() async {
    final syncInfo = await _syncService.getSyncInfo();
    final lastSync = syncInfo['lastSync'] != null
        ? DateTime.tryParse(syncInfo['lastSync'])
        : null;

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Senkronizasyon Durumu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              'Bağlantı:',
              _isConnected ? 'Çevrimiçi' : 'Çevrimdışı',
            ),
            _buildInfoRow(
              'Son Senkronizasyon:',
              lastSync != null
                  ? _formatDateTime(lastSync)
                  : 'Henüz senkronize edilmedi',
            ),
            _buildInfoRow('Bekleyen İşlem:', '$_pendingActionsCount adet'),
            if (syncInfo['storageInfo'] != null) ...[
              const SizedBox(height: AppSizes.paddingMedium),
              const Text(
                'Çevrimdışı Veri:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSizes.paddingSmall),
              _buildInfoRow(
                'Makineler:',
                '${syncInfo['storageInfo']['machines']} adet',
              ),
              _buildInfoRow(
                'İş Emirleri:',
                '${syncInfo['storageInfo']['workTasks']} adet',
              ),
              _buildInfoRow(
                'Kontrol Listeleri:',
                '${syncInfo['storageInfo']['controlLists']} adet',
              ),
              _buildInfoRow(
                'Bildirimler:',
                '${syncInfo['storageInfo']['notifications']} adet',
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
          if (_isConnected && !_isSyncing)
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await _syncService.forceSyncNow();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Senkronizasyon tamamlandı'),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Senkronizasyon hatası: $e')),
                    );
                  }
                }
              },
              child: const Text('Şimdi Senkronize Et'),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Az önce';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} dakika önce';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} saat önce';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isConnected && _pendingActionsCount == 0 && !_isSyncing) {
      return const SizedBox.shrink(); // Don't show indicator when everything is fine
    }

    return GestureDetector(
      onTap: _showSyncDetails,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMedium,
                vertical: AppSizes.paddingSmall,
              ),
              decoration: BoxDecoration(
                color: _getBackgroundColor(),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatusIcon(),
                  const SizedBox(width: AppSizes.paddingSmall),
                  Text(
                    _getStatusText(),
                    style: TextStyle(
                      color: _getTextColor(),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusIcon() {
    if (_isSyncing) {
      return SizedBox(
        width: 12,
        height: 12,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
        ),
      );
    }

    IconData iconData;
    if (!_isConnected) {
      iconData = Icons.cloud_off;
    } else if (_pendingActionsCount > 0) {
      iconData = Icons.sync_problem;
    } else {
      iconData = Icons.cloud_done;
    }

    return Icon(iconData, size: 14, color: _getTextColor());
  }

  Color _getBackgroundColor() {
    if (!_isConnected) {
      return const Color(AppColors.dangerRed);
    } else if (_pendingActionsCount > 0 || _isSyncing) {
      return const Color(AppColors.warningOrange);
    } else {
      return const Color(AppColors.successGreen);
    }
  }

  Color _getTextColor() {
    return Colors.white;
  }

  String _getStatusText() {
    if (_isSyncing) {
      return 'Senkronize ediliyor...';
    } else if (!_isConnected) {
      return 'Çevrimdışı';
    } else if (_pendingActionsCount > 0) {
      return '$_pendingActionsCount bekliyor';
    } else {
      return 'Çevrimiçi';
    }
  }
}
