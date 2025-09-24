import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/constants/app_constants.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = true;
  bool _hasPermission = false;
  String? _lastScannedCode;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status == PermissionStatus.granted) {
      setState(() {
        _hasPermission = true;
      });
    } else {
      setState(() {
        _hasPermission = false;
      });
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Kamera İzni Gerekli'),
          content: const Text(
            'QR kod taramak için kamera iznine ihtiyaç var. '
            'Lütfen ayarlardan kamera iznini etkinleştirin.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // QR scanner sayfasından çık
              },
              child: const Text('Vazgeç'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Ayarlara Git'),
            ),
          ],
        );
      },
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() {
          _isScanning = false;
          _lastScannedCode = barcode.rawValue;
        });
        _showResultDialog(barcode.rawValue!);
        break;
      }
    }
  }

  void _showResultDialog(String code) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.qr_code_2, color: Color(AppColors.successGreen)),
              const SizedBox(width: AppSizes.paddingSmall),
              const Text('QR Kod Tarandı'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Taranan Kod:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppSizes.textMedium,
                ),
              ),
              const SizedBox(height: AppSizes.paddingSmall),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                decoration: BoxDecoration(
                  color: const Color(AppColors.grey100),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
                child: Text(
                  code,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: AppSizes.textMedium,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              _buildCodeTypeInfo(code),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _continueScan();
              },
              child: const Text('Tekrar Tara'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(code); // Sonucu geri döndür
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(AppColors.primaryBlue),
                foregroundColor: Colors.white,
              ),
              child: const Text('Kullan'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCodeTypeInfo(String code) {
    String codeType = 'Genel QR Kod';
    Color typeColor = const Color(AppColors.infoBlue);
    IconData typeIcon = Icons.qr_code;

    // Makine kodu pattern kontrolü (örnek: M001, M002 gibi)
    if (RegExp(r'^M\d{3}$').hasMatch(code)) {
      codeType = 'Makine Kodu';
      typeColor = const Color(AppColors.primaryBlue);
      typeIcon = Icons.precision_manufacturing;
    }
    // Kontrol listesi pattern (örnek: CL001, CL002)
    else if (RegExp(r'^CL\d{3}$').hasMatch(code)) {
      codeType = 'Kontrol Listesi';
      typeColor = const Color(AppColors.successGreen);
      typeIcon = Icons.checklist;
    }
    // URL pattern
    else if (code.startsWith('http://') || code.startsWith('https://')) {
      codeType = 'Web Adresi';
      typeColor = const Color(AppColors.warningOrange);
      typeIcon = Icons.link;
    }

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingSmall),
      decoration: BoxDecoration(
        color: typeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: typeColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(typeIcon, color: typeColor, size: AppSizes.iconMedium),
          const SizedBox(width: AppSizes.paddingSmall),
          Text(
            codeType,
            style: TextStyle(
              color: typeColor,
              fontWeight: FontWeight.w600,
              fontSize: AppSizes.textSmall,
            ),
          ),
        ],
      ),
    );
  }

  void _continueScan() {
    setState(() {
      _isScanning = true;
      _lastScannedCode = null;
    });
  }

  void _toggleFlash() async {
    await cameraController.toggleTorch();
  }

  void _switchCamera() async {
    await cameraController.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Kod Tarayıcı'),
        backgroundColor: const Color(AppColors.primaryBlue),
        foregroundColor: Colors.white,
        actions: [
          if (_hasPermission) ...[
            IconButton(
              onPressed: _toggleFlash,
              icon: const Icon(Icons.flash_on),
              tooltip: 'Flaş Aç/Kapat',
            ),
            IconButton(
              onPressed: _switchCamera,
              icon: const Icon(Icons.flip_camera_android),
              tooltip: 'Kamera Değiştir',
            ),
          ],
        ],
      ),
      body: _hasPermission ? _buildScannerBody() : _buildPermissionDeniedBody(),
    );
  }

  Widget _buildScannerBody() {
    return Stack(
      children: [
        // Kamera preview
        MobileScanner(controller: cameraController, onDetect: _onDetect),

        // Overlay
        _buildScannerOverlay(),

        // Alt panel
        _buildBottomPanel(),
      ],
    );
  }

  Widget _buildScannerOverlay() {
    return Container(
      decoration: ShapeDecoration(
        shape: QrScannerOverlayShape(
          borderColor: const Color(AppColors.primaryBlue),
          borderRadius: 20,
          borderLength: 40,
          borderWidth: 5,
          cutOutSize: 250,
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        decoration: const BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSizes.radiusLarge),
            topRight: Radius.circular(AppSizes.radiusLarge),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'QR kodu kare içine alın',
              style: TextStyle(
                color: Colors.white,
                fontSize: AppSizes.textLarge,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            const Text(
              'Makine kodları, kontrol listeleri ve diğer QR kodları taranabilir',
              style: TextStyle(
                color: Colors.white70,
                fontSize: AppSizes.textMedium,
              ),
              textAlign: TextAlign.center,
            ),
            if (_lastScannedCode != null) ...[
              const SizedBox(height: AppSizes.paddingMedium),
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingSmall),
                decoration: BoxDecoration(
                  color: const Color(AppColors.successGreen),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                child: Text(
                  'Son taranan: $_lastScannedCode',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AppSizes.textSmall,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionDeniedBody() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              size: 80,
              color: Color(AppColors.grey300),
            ),
            const SizedBox(height: AppSizes.paddingLarge),
            const Text(
              'Kamera İzni Gerekli',
              style: TextStyle(
                fontSize: AppSizes.textXLarge,
                fontWeight: FontWeight.bold,
                color: Color(AppColors.grey700),
              ),
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            const Text(
              'QR kod taramak için kamera iznine ihtiyaç var.',
              style: TextStyle(
                fontSize: AppSizes.textMedium,
                color: Color(AppColors.grey500),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.paddingLarge),
            ElevatedButton.icon(
              onPressed: _requestCameraPermission,
              icon: const Icon(Icons.camera_alt),
              label: const Text('İzin Ver'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(AppColors.primaryBlue),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingLarge,
                  vertical: AppSizes.paddingMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// QR Scanner overlay shape
class QrScannerOverlayShape extends ShapeBorder {
  const QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    double? cutOutSize,
  }) : cutOutSize = cutOutSize ?? 250;

  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path path = Path()..addRect(rect);
    Path cutOutPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: rect.center,
            width: cutOutSize,
            height: cutOutSize,
          ),
          Radius.circular(borderRadius),
        ),
      );
    return Path.combine(PathOperation.difference, path, cutOutPath);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final borderWidthSize = width / 2;
    final borderOffset = borderWidth / 2;
    final borderLength = this.borderLength > cutOutSize / 2 + borderWidth * 2
        ? borderWidthSize / 2
        : this.borderLength;
    final cutOutRect = Rect.fromCenter(
      center: rect.center,
      width: cutOutSize,
      height: cutOutSize,
    );

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(rect)
      ..addRRect(
        RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)),
      );

    canvas.drawPath(path, backgroundPaint);

    // Draw corner borders
    final leftTop = cutOutRect.topLeft.translate(0, borderOffset);
    final leftBottom = cutOutRect.bottomLeft.translate(0, -borderOffset);
    final rightTop = cutOutRect.topRight.translate(0, borderOffset);
    final rightBottom = cutOutRect.bottomRight.translate(0, -borderOffset);

    // Top left corner
    canvas.drawLine(leftTop, leftTop.translate(borderLength, 0), borderPaint);
    canvas.drawLine(leftTop, leftTop.translate(0, borderLength), borderPaint);

    // Top right corner
    canvas.drawLine(
      rightTop,
      rightTop.translate(-borderLength, 0),
      borderPaint,
    );
    canvas.drawLine(rightTop, rightTop.translate(0, borderLength), borderPaint);

    // Bottom left corner
    canvas.drawLine(
      leftBottom,
      leftBottom.translate(borderLength, 0),
      borderPaint,
    );
    canvas.drawLine(
      leftBottom,
      leftBottom.translate(0, -borderLength),
      borderPaint,
    );

    // Bottom right corner
    canvas.drawLine(
      rightBottom,
      rightBottom.translate(-borderLength, 0),
      borderPaint,
    );
    canvas.drawLine(
      rightBottom,
      rightBottom.translate(0, -borderLength),
      borderPaint,
    );
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}
