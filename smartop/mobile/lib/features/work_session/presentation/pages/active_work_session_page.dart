import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../data/models/work_session.dart';
import '../../data/services/work_session_service.dart';
import 'end_work_session_page.dart';

class ActiveWorkSessionPage extends StatefulWidget {
  const ActiveWorkSessionPage({super.key});

  @override
  State<ActiveWorkSessionPage> createState() => _ActiveWorkSessionPageState();
}

class _ActiveWorkSessionPageState extends State<ActiveWorkSessionPage> {
  final WorkSessionService _workSessionService = WorkSessionService();
  WorkSession? _activeSession;
  bool _isLoading = true;
  Timer? _timer;
  Duration? _elapsedTime;

  @override
  void initState() {
    super.initState();
    _loadActiveSession();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_activeSession != null) {
        setState(() {
          _elapsedTime = DateTime.now().difference(_activeSession!.startTime);
        });
      }
    });
  }

  Future<void> _loadActiveSession() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final session = await _workSessionService.getActiveSession();
      if (mounted) {
        setState(() {
          _activeSession = session;
          _isLoading = false;
          if (session != null) {
            _elapsedTime = DateTime.now().difference(session.startTime);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '00:00:00';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  Future<void> _navigateToEndSession() async {
    if (_activeSession == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EndWorkSessionPage(session: _activeSession!),
      ),
    );

    if (result == true) {
      // Session ended successfully, reload
      _loadActiveSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Aktif Çalışma'),
          backgroundColor: Colors.blue,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_activeSession == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Aktif Çalışma'),
          backgroundColor: Colors.blue,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.work_off_outlined,
                size: 100,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 24),
              Text(
                'Aktif çalışma bulunamadı',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bir makine seçip çalışma başlatabilirsiniz',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aktif Çalışma'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadActiveSession,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timer Card
            Card(
              color: Colors.green.shade50,
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.timer,
                      size: 64,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Çalışma Süresi',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDuration(_elapsedTime),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Machine Info
            _buildInfoCard(
              icon: Icons.precision_manufacturing,
              title: 'Makine',
              value: _activeSession!.machine?.name ?? 'Bilinmiyor',
              color: Colors.blue,
            ),
            const SizedBox(height: 16),

            // Start Time
            _buildInfoCard(
              icon: Icons.play_arrow,
              title: 'Başlangıç Zamanı',
              value: DateFormat('dd.MM.yyyy HH:mm').format(_activeSession!.startTime),
              color: Colors.green,
            ),
            const SizedBox(height: 16),

            // Location
            if (_activeSession!.location != null)
              _buildInfoCard(
                icon: Icons.location_on,
                title: 'Lokasyon',
                value: _activeSession!.location!,
                color: Colors.orange,
              ),
            if (_activeSession!.location != null) const SizedBox(height: 16),

            // Start Notes
            if (_activeSession!.startNotes != null && _activeSession!.startNotes!.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.note, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Başlangıç Notları',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _activeSession!.startNotes!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 32),

            // End Session Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _navigateToEndSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.stop, size: 28),
                    SizedBox(width: 8),
                    Text(
                      'Çalışmayı Bitir',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
