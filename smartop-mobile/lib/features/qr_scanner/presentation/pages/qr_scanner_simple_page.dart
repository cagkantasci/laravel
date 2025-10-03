import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../machines/presentation/pages/machine_detail_page.dart';
import '../../../machines/data/models/machine.dart';

class QrCodeScannerPage extends StatefulWidget {
  const QrCodeScannerPage({super.key});

  @override
  State<QrCodeScannerPage> createState() => _QrCodeScannerPageState();
}

class _QrCodeScannerPageState extends State<QrCodeScannerPage> {
  bool isFlashOn = false;
  bool isScanning = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Kod Okutun'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _toggleFlash,
            icon: Icon(isFlashOn ? Icons.flash_on : Icons.flash_off),
          ),
          IconButton(
            onPressed: _showManualEntryDialog,
            icon: const Icon(Icons.keyboard),
            tooltip: 'Manuel Giriş',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Mock Camera View
          Container(
            color: Colors.black,
            child: Stack(
              children: [
                // Camera overlay with cutout
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                  ),
                  child: CustomPaint(
                    painter: QrScannerOverlayPainter(
                      borderColor: Theme.of(context).colorScheme.primary,
                      borderWidth: 3,
                      borderLength: 30,
                      cutOutSize: 250,
                    ),
                    child: Container(),
                  ),
                ),

                // Scanning line animation
                _buildScanningLine(),
              ],
            ),
          ),

          // Instructions overlay
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.qr_code_scanner, color: Colors.white, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'Makine üzerindeki QR kodu \nkameraya doğru tutun',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline, color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'QR kod bulunamıyorsa klavye butonunu kullanın',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Demo scan button
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: _simulateQRScan,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('QR Kodu Simüle Et'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanningLine() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 2),
      builder: (context, value, child) {
        return Positioned(
          top: 150 + (200 * value),
          left: (MediaQuery.of(context).size.width - 250) / 2,
          child: Container(
            width: 250,
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Theme.of(context).colorScheme.primary,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
      onEnd: () {
        if (mounted) {
          setState(() {}); // Restart animation
        }
      },
    );
  }

  void _simulateQRScan() {
    if (!isScanning) return;

    // Simulate scanning different QR codes
    final codes = ['M001', 'M002', 'M003', 'M004'];
    final randomCode = codes[DateTime.now().millisecond % codes.length];
    _handleQRCodeScanned(randomCode);
  }

  void _handleQRCodeScanned(String? code) {
    if (code == null || code.isEmpty) return;

    setState(() {
      isScanning = false;
    });

    // Vibrate to indicate successful scan
    HapticFeedback.mediumImpact();

    // Mock machine data based on QR code
    final machineData = _getMachineDataFromQRCode(code);

    if (machineData != null) {
      // Navigate to machine detail page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MachineDetailPage(machine: machineData),
        ),
      );
    } else {
      // Show error dialog for invalid QR code
      _showInvalidQRDialog(code);
    }
  }

  Machine? _getMachineDataFromQRCode(String qrCode) {
    // Mock implementation - in real app, this would validate QR code format
    // and fetch machine data from API

    // Expected QR format: "SMARTOP-MACHINE-{ID}" or just machine ID
    String machineId;

    if (qrCode.startsWith('SMARTOP-MACHINE-')) {
      machineId = qrCode.replaceFirst('SMARTOP-MACHINE-', '');
    } else if (RegExp(r'^[A-Z0-9\-]+$').hasMatch(qrCode)) {
      machineId = qrCode;
    } else {
      return null; // Invalid format
    }

    // Mock machine database
    final machines = {
      'M001': Machine(
        id: 'M001',
        code: 'M001',
        name: 'CNC Tezgah #1',
        description: 'Yüksek hassasiyetli CNC tornalama tezgahı',
        status: 'Çalışıyor',
        location: 'Atölye A-1',
        type: 'CNC',
        lastMaintenanceDate: DateTime.now().subtract(Duration(days: 15)),
        nextMaintenanceDate: DateTime.now().add(Duration(days: 15)),
        efficiency: 85.3,
        imageUrl: 'assets/images/machines/cnc.jpg',
        controlItems: [],
        controlCompletionRate: 85.0,
      ),
      'M002': Machine(
        id: 'M002',
        code: 'M002',
        name: 'Hadde Makinesi #2',
        description: 'Endüstriyel hadde makinesi',
        status: 'Bakım',
        location: 'Atölye B-2',
        type: 'Hadde',
        lastMaintenanceDate: DateTime.now().subtract(Duration(days: 2)),
        nextMaintenanceDate: DateTime.now().add(Duration(days: 28)),
        efficiency: 0.0,
        imageUrl: 'assets/images/machines/hadde.jpg',
        controlItems: [],
        controlCompletionRate: 60.0,
      ),
      'M003': Machine(
        id: 'M003',
        code: 'M003',
        name: 'Pres Makinesi #3',
        description: 'Yüksek basınçlı pres makinesi',
        status: 'Arızalı',
        location: 'Atölye C-1',
        type: 'Pres',
        lastMaintenanceDate: DateTime.now().subtract(Duration(days: 45)),
        nextMaintenanceDate: DateTime.now().subtract(Duration(days: 5)),
        efficiency: 0.0,
        imageUrl: 'assets/images/machines/pres.jpg',
        controlItems: [],
        controlCompletionRate: 20.0,
      ),
      'M004': Machine(
        id: 'M004',
        code: 'M004',
        name: 'Tornalama Tezgahı #4',
        description: 'Hassas tornalama tezgahı',
        status: 'Çalışıyor',
        location: 'Atölye A-3',
        type: 'Torna',
        lastMaintenanceDate: DateTime.now().subtract(Duration(days: 10)),
        nextMaintenanceDate: DateTime.now().add(Duration(days: 20)),
        efficiency: 92.7,
        imageUrl: 'assets/images/machines/torna.jpg',
        controlItems: [],
        controlCompletionRate: 95.0,
      ),
    };

    return machines[machineId.toUpperCase()];
  }

  void _showInvalidQRDialog(String code) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Geçersiz QR Kod'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Okutulan QR kod SmartOp sisteminde kayıtlı değil.'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Okutulan kod: $code',
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Lütfen makinenin üzerindeki doğru QR kodu okutun veya sistem yöneticinize başvurun.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                isScanning = true;
              });
            },
            child: const Text('Tekrar Dene'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showManualEntryDialog() {
    final TextEditingController codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manuel Makine Kodu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Makine kodunu manuel olarak girebilirsiniz:'),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: 'Makine Kodu',
                hintText: 'Örn: M001, M002',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.precision_manufacturing),
              ),
              textCapitalization: TextCapitalization.characters,
              autofocus: true,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Geçerli kodlar: M001, M002, M003, M004',
                      style: TextStyle(color: Colors.blue[700], fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () {
              final code = codeController.text.trim().toUpperCase();
              Navigator.pop(context);
              if (code.isNotEmpty) {
                _handleQRCodeScanned(code);
              }
            },
            child: const Text('Git'),
          ),
        ],
      ),
    );
  }

  void _toggleFlash() {
    setState(() {
      isFlashOn = !isFlashOn;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isFlashOn ? 'Flaş açıldı' : 'Flaş kapandı'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

// Custom painter for QR scanner overlay
class QrScannerOverlayPainter extends CustomPainter {
  final Color borderColor;
  final double borderWidth;
  final double borderLength;
  final double cutOutSize;

  QrScannerOverlayPainter({
    required this.borderColor,
    required this.borderWidth,
    required this.borderLength,
    required this.cutOutSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Calculate cutout rectangle
    final cutOutRect = Rect.fromCenter(
      center: Offset(width / 2, height / 2),
      width: cutOutSize,
      height: cutOutSize,
    );

    // Draw dark overlay with cutout
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final cutOutPaint = Paint()
      ..color = Colors.transparent
      ..blendMode = BlendMode.clear;

    // Draw overlay
    canvas.saveLayer(Rect.fromLTWH(0, 0, width, height), overlayPaint);
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), overlayPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(cutOutRect, const Radius.circular(12)),
      cutOutPaint,
    );
    canvas.restore();

    // Draw corner borders
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    // Top left
    canvas.drawLine(
      Offset(cutOutRect.left, cutOutRect.top + borderLength),
      Offset(cutOutRect.left, cutOutRect.top),
      borderPaint,
    );
    canvas.drawLine(
      Offset(cutOutRect.left, cutOutRect.top),
      Offset(cutOutRect.left + borderLength, cutOutRect.top),
      borderPaint,
    );

    // Top right
    canvas.drawLine(
      Offset(cutOutRect.right - borderLength, cutOutRect.top),
      Offset(cutOutRect.right, cutOutRect.top),
      borderPaint,
    );
    canvas.drawLine(
      Offset(cutOutRect.right, cutOutRect.top),
      Offset(cutOutRect.right, cutOutRect.top + borderLength),
      borderPaint,
    );

    // Bottom left
    canvas.drawLine(
      Offset(cutOutRect.left, cutOutRect.bottom - borderLength),
      Offset(cutOutRect.left, cutOutRect.bottom),
      borderPaint,
    );
    canvas.drawLine(
      Offset(cutOutRect.left, cutOutRect.bottom),
      Offset(cutOutRect.left + borderLength, cutOutRect.bottom),
      borderPaint,
    );

    // Bottom right
    canvas.drawLine(
      Offset(cutOutRect.right - borderLength, cutOutRect.bottom),
      Offset(cutOutRect.right, cutOutRect.bottom),
      borderPaint,
    );
    canvas.drawLine(
      Offset(cutOutRect.right, cutOutRect.bottom),
      Offset(cutOutRect.right, cutOutRect.bottom - borderLength),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
