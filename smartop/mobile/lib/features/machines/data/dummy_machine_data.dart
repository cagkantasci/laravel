import 'models/machine.dart';
import 'models/control_item.dart';

class DummyMachineData {
  static List<Machine> getMachines() {
    final now = DateTime.now();

    return [
      Machine(
        id: '1',
        code: 'M001',
        name: 'CNC Torna Tezgahı',
        description:
            'Hassas tornalama işlemleri için kullanılan CNC torna tezgahı',
        status: 'active',
        location: 'A Blok - 1. Kat',
        type: 'CNC Torna',
        lastMaintenanceDate: now.subtract(const Duration(days: 15)),
        nextMaintenanceDate: now.add(const Duration(days: 75)),
        efficiency: 0.925,
        imageUrl: 'https://via.placeholder.com/300x200?text=CNC+Torna',
        controlItems: _getCNCControlItems(),
        lastControlDate: now.subtract(const Duration(hours: 6)),
        lastControlBy: 'Ahmet Yılmaz',
        controlCompletionRate: 85.0,
        // New fields
        model: 'TC-250',
        manufacturer: 'TAKSAN',
        serialNumber: 'TS2024001',
        installationDate: '15.03.2023',
        operatingHours: 3248.5,
        maxCapacity: 120.0,
        powerConsumption: 15.5,
        assignedOperator: 'Ahmet Yılmaz',
        department: 'Metal İşleme',
        notes:
            'Yüksek hassasiyetli işlemler için optimize edilmiş. Son kalibrasyon: 10.09.2024',
        isAutoMode: true,
      ),
      Machine(
        id: '2',
        code: 'M002',
        name: 'Kaynak Makinası',
        description: 'Endüstriyel kaynak işlemleri için özel kaynak makinası',
        status: 'active',
        location: 'B Blok - Zemin Kat',
        type: 'Kaynak Makinası',
        lastMaintenanceDate: now.subtract(const Duration(days: 8)),
        nextMaintenanceDate: now.add(const Duration(days: 82)),
        efficiency: 0.873,
        imageUrl: 'https://via.placeholder.com/300x200?text=Kaynak+Makinasi',
        controlItems: _getWeldingControlItems(),
        lastControlDate: now.subtract(const Duration(hours: 12)),
        lastControlBy: 'Mehmet Demir',
        controlCompletionRate: 60.0,
        // New fields
        model: 'WM-400',
        manufacturer: 'LINCOLN',
        serialNumber: 'LN2023456',
        installationDate: '22.06.2023',
        operatingHours: 2156.0,
        maxCapacity: 80.0,
        powerConsumption: 25.0,
        assignedOperator: 'Mehmet Demir',
        department: 'Kaynak Atölyesi',
        notes:
            'MIG/MAG kaynak işlemleri için kullanılır. Gaz tüketimi normal seviyede.',
        isAutoMode: false,
      ),
      Machine(
        id: '3',
        code: 'M003',
        name: 'Freze Tezgahı',
        description: 'Metal işleme için kullanılan hassas freze tezgahı',
        status: 'maintenance',
        location: 'A Blok - 2. Kat',
        type: 'CNC Freze',
        lastMaintenanceDate: now.subtract(const Duration(days: 2)),
        nextMaintenanceDate: now.add(const Duration(days: 88)),
        efficiency: 0.0, // Bakımda olduğu için 0
        // New fields
        model: 'FM-600',
        manufacturer: 'HERMLE',
        serialNumber: 'HM2024789',
        installationDate: '08.01.2024',
        operatingHours: 1567.5,
        maxCapacity: 95.0,
        powerConsumption: 18.5,
        assignedOperator: 'Fatma Kaya',
        department: 'Hassas İşleme',
        notes:
            'Bakımda - Spindle değişimi yapılıyor. Tahmini tamamlanma: 3 gün.',
        isAutoMode: true,
        imageUrl: 'https://via.placeholder.com/300x200?text=Freze+Tezgahi',
      ),
      Machine(
        id: '4',
        code: 'M004',
        name: 'Pres Makinası',
        description: 'Metal şekillendirme için hidrolik pres makinası',
        status: 'active',
        location: 'C Blok - 1. Kat',
        type: 'Pres',
        lastMaintenanceDate: now.subtract(const Duration(days: 45)),
        nextMaintenanceDate: now.add(const Duration(days: 5)), // Yakında bakım
        efficiency: 89.7,
        imageUrl: 'https://via.placeholder.com/300x200?text=Pres+Makinasi',
        controlItems: _getPressControlItems(),
        lastControlDate: now.subtract(const Duration(days: 1)),
        lastControlBy: 'Ali Özkan',
        controlCompletionRate: 75.0,
      ),
      Machine(
        id: '5',
        code: 'M005',
        name: 'Kesme Makinası',
        description: 'Plazma kesim makinası - metal levha kesimi',
        status: 'inactive',
        location: 'B Blok - 1. Kat',
        type: 'Kesim',
        lastMaintenanceDate: now.subtract(const Duration(days: 120)),
        nextMaintenanceDate: now.subtract(
          const Duration(days: 30),
        ), // Geçmiş tarih - bakım gerekli
        efficiency: 0.0,
        imageUrl: 'https://via.placeholder.com/300x200?text=Kesme+Makinasi',
      ),
      Machine(
        id: '6',
        code: 'M006',
        name: 'Matkap Tezgahı',
        description: 'Hassas delik delme işlemleri için matkap tezgahı',
        status: 'active',
        location: 'A Blok - Zemin Kat',
        type: 'Matkap',
        lastMaintenanceDate: now.subtract(const Duration(days: 30)),
        nextMaintenanceDate: now.add(const Duration(days: 60)),
        efficiency: 94.2,
        imageUrl: 'https://via.placeholder.com/300x200?text=Matkap+Tezgahi',
        controlItems: _getGeneralControlItems(),
        lastControlDate: now.subtract(const Duration(hours: 24)),
        lastControlBy: 'Zeynep Arslan',
        controlCompletionRate: 100.0,
      ),
      Machine(
        id: '7',
        code: 'M007',
        name: 'Grinding Makinası',
        description: 'Yüzey taşlama için grinding makinası',
        status: 'active',
        location: 'C Blok - 2. Kat',
        type: 'Taşlama',
        lastMaintenanceDate: now.subtract(const Duration(days: 10)),
        nextMaintenanceDate: now.add(const Duration(days: 80)),
        efficiency: 91.8,
        imageUrl: 'https://via.placeholder.com/300x200?text=Grinding+Makinasi',
      ),
      Machine(
        id: '8',
        code: 'M008',
        name: 'Kompresör',
        description: 'Havalı sistem için ana kompresör ünitesi',
        status: 'active',
        location: 'Teknik Oda',
        type: 'Kompresör',
        lastMaintenanceDate: now.subtract(const Duration(days: 5)),
        nextMaintenanceDate: now.add(const Duration(days: 85)),
        efficiency: 96.5,
        imageUrl: 'https://via.placeholder.com/300x200?text=Kompresor',
      ),
    ];
  }

  static Machine? getMachineByCode(String code) {
    try {
      return getMachines().firstWhere((machine) => machine.code == code);
    } catch (e) {
      return null;
    }
  }

  static List<Machine> getActiveMachines() {
    return getMachines().where((machine) => machine.isActive).toList();
  }

  static List<Machine> getMaintenanceMachines() {
    return getMachines().where((machine) => machine.isMaintenance).toList();
  }

  static List<Machine> getInactiveMachines() {
    return getMachines().where((machine) => machine.isInactive).toList();
  }

  static List<Machine> getMachinesNeedingMaintenance() {
    return getMachines().where((machine) => machine.needsMaintenance).toList();
  }

  static List<String> getMachineTypes() {
    final types = getMachines().map((machine) => machine.type).toSet().toList();
    types.sort();
    return types;
  }

  static List<String> getMachineLocations() {
    final locations = getMachines()
        .map((machine) => machine.location)
        .toSet()
        .toList();
    locations.sort();
    return locations;
  }

  // Kontrol öğeleri tanımları
  static List<ControlItem> _getCNCControlItems() {
    final now = DateTime.now();
    return [
      ControlItem(
        id: '1',
        title: 'Güvenlik Sistemi Kontrolü',
        description: 'Acil stop butonu ve güvenlik kapılarının çalışması',
        type: 'safety',
        isRequired: true,
        status: 'completed',
        result: 'pass',
        completedDate: now.subtract(const Duration(hours: 6)),
        completedBy: 'Ahmet Yılmaz',
        notes: 'Tüm güvenlik sistemleri normal çalışıyor.',
      ),
      ControlItem(
        id: '2',
        title: 'Titreşim Ölçümü',
        description: 'Makine titreşim seviyesi ölçümü',
        type: 'measurement',
        isRequired: true,
        status: 'completed',
        result: 'pass',
        value: '2.5',
        unit: 'mm/s',
        minValue: '0',
        maxValue: '5.0',
        completedDate: now.subtract(const Duration(hours: 6)),
        completedBy: 'Ahmet Yılmaz',
      ),
      ControlItem(
        id: '3',
        title: 'Sıcaklık Kontrolü',
        description: 'Motor ve rulman sıcaklık kontrolü',
        type: 'measurement',
        isRequired: true,
        status: 'completed',
        result: 'pass',
        value: '45',
        unit: '°C',
        minValue: '20',
        maxValue: '60',
        completedDate: now.subtract(const Duration(hours: 6)),
        completedBy: 'Ahmet Yılmaz',
      ),
      ControlItem(
        id: '4',
        title: 'Görsel Kontrol',
        description: 'Dış görünüm, yağlama ve temizlik kontrolü',
        type: 'visual',
        isRequired: true,
        status: 'completed',
        result: 'pass',
        completedDate: now.subtract(const Duration(hours: 6)),
        completedBy: 'Ahmet Yılmaz',
        notes: 'Makine temiz, yağlama sistemleri çalışıyor.',
      ),
      ControlItem(
        id: '5',
        title: 'Kalibrasyon Kontrolü',
        description: 'Ölçüm hassasiyeti ve kalibrasyon kontrolü',
        type: 'function',
        isRequired: true,
        status: 'pending',
      ),
      ControlItem(
        id: '6',
        title: 'Ses Seviyesi',
        description: 'Çalışma sırasındaki ses seviyesi ölçümü',
        type: 'measurement',
        isRequired: false,
        status: 'pending',
        unit: 'dB',
        minValue: '50',
        maxValue: '85',
      ),
    ];
  }

  static List<ControlItem> _getWeldingControlItems() {
    final now = DateTime.now();
    return [
      ControlItem(
        id: '1',
        title: 'Gaz Bağlantı Kontrolü',
        description: 'Gaz hortumu ve bağlantı kontrolü',
        type: 'safety',
        isRequired: true,
        status: 'completed',
        result: 'pass',
        completedDate: now.subtract(const Duration(hours: 12)),
        completedBy: 'Mehmet Demir',
      ),
      ControlItem(
        id: '2',
        title: 'Elektrot Kontrolü',
        description: 'Elektrot tutucu ve kabloların durumu',
        type: 'visual',
        isRequired: true,
        status: 'completed',
        result: 'pass',
        completedDate: now.subtract(const Duration(hours: 12)),
        completedBy: 'Mehmet Demir',
      ),
      ControlItem(
        id: '3',
        title: 'Soğutma Sistemi',
        description: 'Su soğutma sistemi kontrolü',
        type: 'function',
        isRequired: true,
        status: 'completed',
        result: 'pass',
        completedDate: now.subtract(const Duration(hours: 12)),
        completedBy: 'Mehmet Demir',
      ),
      ControlItem(
        id: '4',
        title: 'Akım Ayar Kontrolü',
        description: 'Kaynak akımı ayar ve ölçüm kontrolü',
        type: 'measurement',
        isRequired: true,
        status: 'pending',
        unit: 'A',
        minValue: '80',
        maxValue: '400',
      ),
      ControlItem(
        id: '5',
        title: 'Topraklama Kontrolü',
        description: 'Topraklama kablosu ve bağlantı kontrolü',
        type: 'safety',
        isRequired: true,
        status: 'pending',
      ),
    ];
  }

  static List<ControlItem> _getPressControlItems() {
    final now = DateTime.now();
    return [
      ControlItem(
        id: '1',
        title: 'Hidrolik Basınç Kontrolü',
        description: 'Sistem basınç seviyesi ölçümü',
        type: 'measurement',
        isRequired: true,
        status: 'completed',
        result: 'pass',
        value: '180',
        unit: 'bar',
        minValue: '150',
        maxValue: '200',
        completedDate: now.subtract(const Duration(days: 1)),
        completedBy: 'Ali Özkan',
      ),
      ControlItem(
        id: '2',
        title: 'Hidrolik Yağ Seviyesi',
        description: 'Hidrolik yağ seviye ve renk kontrolü',
        type: 'visual',
        isRequired: true,
        status: 'completed',
        result: 'pass',
        completedDate: now.subtract(const Duration(days: 1)),
        completedBy: 'Ali Özkan',
      ),
      ControlItem(
        id: '3',
        title: 'Güvenlik Sensörleri',
        description: 'İki el kumanda ve ışık bariyeri kontrolü',
        type: 'safety',
        isRequired: true,
        status: 'completed',
        result: 'pass',
        completedDate: now.subtract(const Duration(days: 1)),
        completedBy: 'Ali Özkan',
      ),
      ControlItem(
        id: '4',
        title: 'Kalıp Merkezleme',
        description: 'Üst ve alt kalıp hizalama kontrolü',
        type: 'function',
        isRequired: true,
        status: 'pending',
      ),
    ];
  }

  static List<ControlItem> _getGeneralControlItems() {
    final now = DateTime.now();
    return [
      ControlItem(
        id: '1',
        title: 'Genel Görsel Kontrol',
        description: 'Makine dış görünüm ve temizlik kontrolü',
        type: 'visual',
        isRequired: true,
        status: 'completed',
        result: 'pass',
        completedDate: now.subtract(const Duration(hours: 24)),
        completedBy: 'Zeynep Arslan',
      ),
      ControlItem(
        id: '2',
        title: 'Güvenlik Kontrolü',
        description: 'Acil stop ve güvenlik sistemleri kontrolü',
        type: 'safety',
        isRequired: true,
        status: 'completed',
        result: 'pass',
        completedDate: now.subtract(const Duration(hours: 24)),
        completedBy: 'Zeynep Arslan',
      ),
      ControlItem(
        id: '3',
        title: 'Fonksiyon Testi',
        description: 'Temel fonksiyonların çalışma kontrolü',
        type: 'function',
        isRequired: true,
        status: 'completed',
        result: 'pass',
        completedDate: now.subtract(const Duration(hours: 24)),
        completedBy: 'Zeynep Arslan',
      ),
    ];
  }
}
