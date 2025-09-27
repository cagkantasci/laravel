import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

class ControlListDetailPage extends StatefulWidget {
  final Map<String, dynamic> controlList;

  const ControlListDetailPage({super.key, required this.controlList});

  @override
  State<ControlListDetailPage> createState() => _ControlListDetailPageState();
}

class _ControlListDetailPageState extends State<ControlListDetailPage> {
  final List<Map<String, dynamic>> _controlItems = [];
  bool _isStarted = false;
  bool _isCompleted = false;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _initializeControlItems();
  }

  void _initializeControlItems() {
    // Mock control items based on control list type
    switch (widget.controlList['category']) {
      case 'Güvenlik':
        _controlItems.addAll([
          {
            'id': '1',
            'title': 'Acil Durdurma Butonu Kontrolü',
            'description':
                'Acil durdurma butonunun çalışır durumda olduğunu kontrol edin',
            'type': 'checkbox',
            'required': true,
            'status': 'pending',
            'notes': '',
            'photo': null,
          },
          {
            'id': '2',
            'title': 'Güvenlik Kapısı Kontrolü',
            'description':
                'Güvenlik kapılarının düzgün kapandığını ve kilitlendiğini kontrol edin',
            'type': 'checkbox',
            'required': true,
            'status': 'pending',
            'notes': '',
            'photo': null,
          },
          {
            'id': '3',
            'title': 'Koruyucu Donanım Kontrolü',
            'description':
                'Güvenlik gözlüğü, eldiven ve diğer koruyucu ekipmanları kontrol edin',
            'type': 'checkbox',
            'required': true,
            'status': 'pending',
            'notes': '',
            'photo': null,
          },
          {
            'id': '4',
            'title': 'İşaretleme ve Etiketleme',
            'description':
                'Güvenlik işaretlerinin görünür ve okunabilir olduğunu kontrol edin',
            'type': 'checkbox',
            'required': true,
            'status': 'pending',
            'notes': '',
            'photo': null,
          },
          {
            'id': '5',
            'title': 'İlk Yardım Malzemeleri',
            'description':
                'İlk yardım çantası ve malzemelerinin eksiksiz olduğunu kontrol edin',
            'type': 'checkbox',
            'required': true,
            'status': 'pending',
            'notes': '',
            'photo': null,
          },
          {
            'id': '6',
            'title': 'Yangın Söndürücü Kontrolü',
            'description':
                'Yangın söndürücülerin konumu ve son kontrol tarihini kontrol edin',
            'type': 'checkbox',
            'required': true,
            'status': 'pending',
            'notes': '',
            'photo': null,
          },
          {
            'id': '7',
            'title': 'Çalışma Alanı Temizliği',
            'description':
                'Çalışma alanının temiz ve düzenli olduğunu kontrol edin',
            'type': 'checkbox',
            'required': false,
            'status': 'pending',
            'notes': '',
            'photo': null,
          },
          {
            'id': '8',
            'title': 'Güvenlik Fotoğrafı',
            'description': 'Güvenlik kontrollerinin fotoğrafını çekin',
            'type': 'photo',
            'required': false,
            'status': 'pending',
            'photo': null,
          },
        ]);
        break;
      case 'Bakım':
        _controlItems.addAll([
          {
            'id': '9',
            'title': 'Motor Yağ Seviyesi',
            'description':
                'Motor yağ seviyesini dipstick ile kontrol edin (50-100ml arası)',
            'type': 'numeric',
            'required': true,
            'status': 'pending',
            'value': '',
            'unit': 'ml',
            'minValue': 50,
            'maxValue': 100,
          },
          {
            'id': '10',
            'title': 'Hidrolik Yağ Basıncı',
            'description': 'Hidrolik sistem yağ basıncını ölçün (150-200 bar)',
            'type': 'numeric',
            'required': true,
            'status': 'pending',
            'value': '',
            'unit': 'bar',
            'minValue': 150,
            'maxValue': 200,
          },
          {
            'id': '11',
            'title': 'Titreşim Seviyesi',
            'description':
                'Makine çalışırken titreşim seviyesini ölçün (0-10 Hz)',
            'type': 'numeric',
            'required': true,
            'status': 'pending',
            'value': '',
            'unit': 'Hz',
            'minValue': 0,
            'maxValue': 10,
          },
          {
            'id': '12',
            'title': 'Kayış Gerginliği',
            'description': 'V-kayışların gerginliğini kontrol edin',
            'type': 'radio',
            'required': true,
            'status': 'pending',
            'options': ['Çok Gergin', 'Uygun', 'Gevşek', 'Değişmeli'],
            'selectedOption': '',
          },
          {
            'id': '13',
            'title': 'Filtre Durumu',
            'description': 'Hava ve yağ filtrelerinin durumunu kontrol edin',
            'type': 'radio',
            'required': true,
            'status': 'pending',
            'options': ['Temiz', 'Hafif Kirli', 'Kirli', 'Değişmeli'],
            'selectedOption': '',
          },
          {
            'id': '14',
            'title': 'Rulman Sıcaklığı',
            'description':
                'Ana rulmanların sıcaklığını ölçün (normal: 40-60°C)',
            'type': 'numeric',
            'required': true,
            'status': 'pending',
            'value': '',
            'unit': '°C',
            'minValue': 30,
            'maxValue': 70,
          },
          {
            'id': '15',
            'title': 'Elektriksel Bağlantılar',
            'description':
                'Elektrik bağlantılarında gevşeklik, ısınma kontrol edin',
            'type': 'checkbox',
            'required': true,
            'status': 'pending',
            'notes': '',
            'photo': null,
          },
          {
            'id': '16',
            'title': 'Genel Temizlik',
            'description': 'Makinenin genel temizliğini kontrol edin',
            'type': 'checkbox',
            'required': false,
            'status': 'pending',
            'notes': '',
            'photo': null,
          },
          {
            'id': '17',
            'title': 'Bakım Fotoğrafı',
            'description': 'Genel makine durumunun fotoğrafını çekin',
            'type': 'photo',
            'required': false,
            'status': 'pending',
            'photo': null,
          },
        ]);
        break;
      case 'Kalite':
        _controlItems.addAll([
          {
            'id': '18',
            'title': 'Ürün Boyut Kontrolü - Genişlik',
            'description':
                'Üretilen ürün genişliğini kumpas ile ölçün (98-102mm)',
            'type': 'numeric',
            'required': true,
            'status': 'pending',
            'value': '',
            'unit': 'mm',
            'minValue': 98,
            'maxValue': 102,
          },
          {
            'id': '19',
            'title': 'Ürün Boyut Kontrolü - Yükseklik',
            'description': 'Üretilen ürün yüksekliğini ölçün (45-55mm)',
            'type': 'numeric',
            'required': true,
            'status': 'pending',
            'value': '',
            'unit': 'mm',
            'minValue': 45,
            'maxValue': 55,
          },
          {
            'id': '20',
            'title': 'Ürün Ağırlığı',
            'description': 'Ürün ağırlığını hassas terazi ile ölçün (190-210g)',
            'type': 'numeric',
            'required': true,
            'status': 'pending',
            'value': '',
            'unit': 'g',
            'minValue': 190,
            'maxValue': 210,
          },
          {
            'id': '21',
            'title': 'Yüzey Pürüzlülüğü',
            'description': 'Ürün yüzey pürüzlülük değerini ölçün (Ra < 3.2)',
            'type': 'numeric',
            'required': true,
            'status': 'pending',
            'value': '',
            'unit': 'Ra',
            'minValue': 0,
            'maxValue': 3.2,
          },
          {
            'id': '22',
            'title': 'Renk Kalitesi',
            'description': 'Ürün renk kalitesini değerlendirin',
            'type': 'radio',
            'required': true,
            'status': 'pending',
            'options': ['Mükemmel', 'İyi', 'Kabul Edilebilir', 'Ret'],
            'selectedOption': '',
          },
          {
            'id': '23',
            'title': 'Yüzey Hataları',
            'description':
                'Çizik, çukur, kabarcık vb. yüzey hatalarını kontrol edin',
            'type': 'radio',
            'required': true,
            'status': 'pending',
            'options': [
              'Hata Yok',
              'Küçük Hatalar',
              'Orta Hatalar',
              'Büyük Hatalar',
            ],
            'selectedOption': '',
          },
          {
            'id': '24',
            'title': 'Malzeme Sertliği',
            'description': 'Ürün malzeme sertliğini kontrol edin (HRC 45-55)',
            'type': 'numeric',
            'required': false,
            'status': 'pending',
            'value': '',
            'unit': 'HRC',
            'minValue': 45,
            'maxValue': 55,
          },
          {
            'id': '25',
            'title': 'Kalite Kontrol Fotoğrafı',
            'description': 'Kalite kontrol edilen ürünlerin fotoğrafını çekin',
            'type': 'photo',
            'required': true,
            'status': 'pending',
            'photo': null,
          },
        ]);
        break;
      case 'Performans':
        _controlItems.addAll([
          {
            'id': '26',
            'title': 'Üretim Hızı',
            'description':
                'Dakika başına üretim miktarını ölçün (80-120 adet/dk)',
            'type': 'numeric',
            'required': true,
            'status': 'pending',
            'value': '',
            'unit': 'adet/dk',
            'minValue': 80,
            'maxValue': 120,
          },
          {
            'id': '27',
            'title': 'Enerji Tüketimi',
            'description': 'Saatlik enerji tüketimini kontrol edin (15-25 kWh)',
            'type': 'numeric',
            'required': true,
            'status': 'pending',
            'value': '',
            'unit': 'kWh',
            'minValue': 15,
            'maxValue': 25,
          },
          {
            'id': '28',
            'title': 'Verimlilik Oranı',
            'description': 'Makine verimlilik oranını değerlendirin',
            'type': 'radio',
            'required': true,
            'status': 'pending',
            'options': [
              'Çok İyi (>95%)',
              'İyi (85-95%)',
              'Orta (75-85%)',
              'Düşük (<75%)',
            ],
            'selectedOption': '',
          },
          {
            'id': '29',
            'title': 'Duruş Süreleri',
            'description': 'Vardiya içindeki duruş sürelerini kaydedin',
            'type': 'checkbox',
            'required': false,
            'status': 'pending',
            'notes': '',
            'photo': null,
          },
        ]);
        break;

      case 'Çevre':
        _controlItems.addAll([
          {
            'id': '30',
            'title': 'Gürültü Seviyesi',
            'description': 'Çalışma ortamı gürültü seviyesini ölçün (<85 dB)',
            'type': 'numeric',
            'required': true,
            'status': 'pending',
            'value': '',
            'unit': 'dB',
            'minValue': 0,
            'maxValue': 90,
          },
          {
            'id': '31',
            'title': 'Hava Kalitesi',
            'description': 'Çalışma alanı hava kalitesini kontrol edin',
            'type': 'radio',
            'required': true,
            'status': 'pending',
            'options': ['Çok İyi', 'İyi', 'Orta', 'Kötü'],
            'selectedOption': '',
          },
          {
            'id': '32',
            'title': 'Atık Yönetimi',
            'description':
                'Atık toplama ve ayrıştırma sistemlerini kontrol edin',
            'type': 'checkbox',
            'required': true,
            'status': 'pending',
            'notes': '',
            'photo': null,
          },
          {
            'id': '33',
            'title': 'Sıcaklık ve Nem',
            'description':
                'Çalışma ortamı sıcaklık ve nem değerlerini kaydedin',
            'type': 'checkbox',
            'required': false,
            'status': 'pending',
            'notes': '',
            'photo': null,
          },
        ]);
        break;

      default:
        _controlItems.addAll([
          {
            'id': '34',
            'title': 'Genel Makine Durumu',
            'description': 'Makinenin genel çalışma durumunu kontrol edin',
            'type': 'radio',
            'required': true,
            'status': 'pending',
            'options': ['Mükemmel', 'İyi', 'Orta', 'Kötü'],
            'selectedOption': '',
          },
          {
            'id': '35',
            'title': 'Operatör Güvenliği',
            'description':
                'Operatörün güvenli çalışma koşullarını kontrol edin',
            'type': 'checkbox',
            'required': true,
            'status': 'pending',
            'notes': '',
            'photo': null,
          },
          {
            'id': '36',
            'title': 'Dokümantasyon',
            'description':
                'Makine kullanım kılavuzu ve dokümantasyonun yerinde olduğunu kontrol edin',
            'type': 'checkbox',
            'required': false,
            'status': 'pending',
            'notes': '',
            'photo': null,
          },
          {
            'id': '37',
            'title': 'Genel Kontrol Fotoğrafı',
            'description': 'Genel durum kontrolü fotoğrafını çekin',
            'type': 'photo',
            'required': false,
            'status': 'pending',
            'photo': null,
          },
        ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedItems = _controlItems
        .where((item) => item['status'] == 'completed')
        .length;
    final totalItems = _controlItems.length;
    final progress = totalItems > 0 ? completedItems / totalItems : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.controlList['title']),
        backgroundColor: const Color(AppColors.primaryBlue),
        foregroundColor: Colors.white,
        actions: [
          if (_isStarted && !_isCompleted)
            IconButton(
              onPressed: _showCompleteDialog,
              icon: const Icon(Icons.check_circle),
              tooltip: 'Kontrolü Tamamla',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Progress Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.controlList['title'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${widget.controlList['machine']} • ${widget.controlList['category']}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            widget.controlList['status'],
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _getStatusColor(
                              widget.controlList['status'],
                            ),
                          ),
                        ),
                        child: Text(
                          _getStatusText(widget.controlList['status']),
                          style: TextStyle(
                            color: _getStatusColor(
                              widget.controlList['status'],
                            ),
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Progress Bar
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress == 1.0
                                ? Colors.green
                                : const Color(AppColors.primaryBlue),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$completedItems/$totalItems',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    progress == 1.0
                        ? 'Tüm kontroller tamamlandı'
                        : _isStarted
                        ? 'Kontrol devam ediyor...'
                        : 'Kontrole başlamak için START butonuna basın',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),

                  if (_startTime != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Başlangıç: ${_formatTime(_startTime!)}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),

            // Control Items List
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: List.generate(_controlItems.length, (index) {
                  final item = _controlItems[index];
                  return _buildControlItem(item, index);
                }),
              ),
            ),

            // Bottom padding for the button
            const SizedBox(height: 100),
          ],
        ),
      ),

      // Start/Complete Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isCompleted
                  ? null
                  : (_isStarted ? _showCompleteDialog : _startControl),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isCompleted
                    ? Colors.green
                    : _isStarted
                    ? const Color(AppColors.warningOrange)
                    : const Color(AppColors.primaryBlue),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                _isCompleted
                    ? 'Kontrol Tamamlandı ✓'
                    : _isStarted
                    ? 'Kontrolü Tamamla'
                    : 'Kontrole Başla',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlItem(Map<String, dynamic> item, int index) {
    final isCompleted = item['status'] == 'completed';
    final isFailed = item['status'] == 'failed';
    final isRequired = item['required'] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.green
                        : isFailed
                        ? Colors.red
                        : _isStarted
                        ? const Color(AppColors.primaryBlue)
                        : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item['title'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (isRequired)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Zorunlu',
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['description'],
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (_isStarted && !isCompleted) ...[
              const SizedBox(height: 16),
              _buildControlInput(item),
            ],

            if (isCompleted || isFailed) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isCompleted ? Colors.green : Colors.red).withOpacity(
                    0.1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCompleted ? Colors.green : Colors.red,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isCompleted ? Icons.check_circle : Icons.error,
                          color: isCompleted ? Colors.green : Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isCompleted ? 'Tamamlandı' : 'Başarısız',
                          style: TextStyle(
                            color: isCompleted ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (item['value'] != null &&
                            item['value'].toString().isNotEmpty) ...[
                          const Spacer(),
                          Text(
                            '${item['value']} ${item['unit'] ?? ''}',
                            style: TextStyle(
                              color: isCompleted ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        if (item['selectedOption'] != null &&
                            item['selectedOption'].toString().isNotEmpty) ...[
                          const Spacer(),
                          Text(
                            item['selectedOption'],
                            style: TextStyle(
                              color: isCompleted ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (item['notes'] != null &&
                        item['notes'].toString().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.note,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Not:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600],
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['notes'],
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildControlInput(Map<String, dynamic> item) {
    switch (item['type']) {
      case 'checkbox':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _completeItem(item, 'completed'),
                  icon: const Icon(Icons.check, size: 14),
                  label: const Text('Tamam', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    minimumSize: const Size(0, 32),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showNotesDialog(item, 'failed'),
                  icon: const Icon(Icons.close, size: 14),
                  label: const Text('Sorunlu', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    minimumSize: const Size(0, 32),
                  ),
                ),
                IconButton(
                  onPressed: () => _showNotesDialog(item, null),
                  icon: const Icon(Icons.note_add, size: 16),
                  tooltip: 'Not Ekle',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    minimumSize: const Size(32, 32),
                  ),
                ),
              ],
            ),
            if (item['notes'] != null && item['notes'].isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.note, size: 16, color: Colors.blue[700]),
                        const SizedBox(width: 4),
                        Text(
                          'Not:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['notes'],
                      style: TextStyle(color: Colors.blue[700], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );

      case 'numeric':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Değer (${item['unit']})',
                      border: const OutlineInputBorder(),
                      hintText: '${item['minValue']}-${item['maxValue']}',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      item['value'] = value;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _validateAndCompleteNumeric(item),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    minimumSize: const Size(0, 40),
                  ),
                  child: const Text('Kaydet', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        );

      case 'radio':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seçenek:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: (item['options'] as List<String>).map((option) {
                return FilterChip(
                  label: Text(option),
                  selected: item['selectedOption'] == option,
                  onSelected: (selected) {
                    setState(() {
                      item['selectedOption'] = selected ? option : '';
                      if (selected) {
                        _completeItem(item, 'completed');
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        );

      case 'photo':
        return ElevatedButton.icon(
          onPressed: () => _takePhoto(item),
          icon: const Icon(Icons.camera_alt, size: 16),
          label: const Text('Fotoğraf Çek', style: TextStyle(fontSize: 12)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(AppColors.primaryBlue),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            minimumSize: const Size(0, 36),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  void _startControl() {
    setState(() {
      _isStarted = true;
      _startTime = DateTime.now();
    });
  }

  void _completeItem(Map<String, dynamic> item, String status) {
    setState(() {
      item['status'] = status;
    });
  }

  void _validateAndCompleteNumeric(Map<String, dynamic> item) {
    final value = double.tryParse(item['value']);
    if (value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen geçerli bir sayı girin')),
      );
      return;
    }

    final min = item['minValue'];
    final max = item['maxValue'];

    if (value >= min && value <= max) {
      _completeItem(item, 'completed');
    } else {
      _completeItem(item, 'failed');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Değer $min-$max aralığında olmalı. Kontrol başarısız olarak işaretlendi.',
          ),
        ),
      );
    }
  }

  void _takePhoto(Map<String, dynamic> item) {
    // Mock photo taking
    setState(() {
      item['photo'] = 'mock_photo_${item['id']}.jpg';
      _completeItem(item, 'completed');
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Fotoğraf çekildi')));
  }

  void _showNotesDialog(Map<String, dynamic> item, String? status) {
    final TextEditingController notesController = TextEditingController();
    notesController.text = item['notes'] ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${item['title']} - Not Ekle'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['description'],
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notlarınız',
                    hintText: 'Kontrol ile ilgili notlarınızı buraya yazın...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          if (status != null)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  item['notes'] = notesController.text;
                });
                _completeItem(item, status);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: status == 'completed'
                    ? Colors.green
                    : Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(status == 'completed' ? 'Tamam' : 'Sorunlu'),
            ),
          if (status == null)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  item['notes'] = notesController.text;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Not kaydedildi')));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(AppColors.primaryBlue),
                foregroundColor: Colors.white,
              ),
              child: const Text('Kaydet'),
            ),
        ],
      ),
    );
  }

  void _showCompleteDialog() {
    final requiredItems = _controlItems.where(
      (item) => item['required'] == true,
    );
    final completedRequired = requiredItems.where(
      (item) => item['status'] == 'completed',
    );

    if (completedRequired.length < requiredItems.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tüm zorunlu kontroller tamamlanmadan kontrol sonlandırılamaz',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final failedItems = _controlItems
        .where((item) => item['status'] == 'failed')
        .length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kontrolü Tamamla'),
        content: Text(
          'Kontrol tamamlanacak. ${failedItems > 0 ? '$failedItems kontrolde sorun tespit edildi.' : 'Tüm kontroller başarılı.'}\n\nKontrolü sonlandırmak istiyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _completeControl();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppColors.primaryBlue),
              foregroundColor: Colors.white,
            ),
            child: const Text('Tamamla'),
          ),
        ],
      ),
    );
  }

  void _completeControl() {
    setState(() {
      _isCompleted = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kontrol başarıyla tamamlandı'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return const Color(AppColors.warningOrange);
      case 'pending':
        return Colors.grey;
      case 'overdue':
        return const Color(AppColors.errorRed);
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'Tamamlandı';
      case 'in_progress':
        return 'Devam Ediyor';
      case 'pending':
        return 'Bekliyor';
      case 'overdue':
        return 'Gecikmiş';
      default:
        return 'Bilinmeyen';
    }
  }

  String _formatTime(DateTime time) {
    return '${time.day.toString().padLeft(2, '0')}.${time.month.toString().padLeft(2, '0')}.${time.year} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
