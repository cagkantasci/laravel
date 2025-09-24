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
        efficiency: 92.5,
        imageUrl: 'https://via.placeholder.com/300x200?text=CNC+Torna',
        controlItems: _getCNCControlItems(),
        lastControlDate: now.subtract(const Duration(hours: 6)),
        lastControlBy: 'Ahmet Yılmaz',
        controlCompletionRate: 85.0,
      ),
      Machine(
        id: '2',
        code: 'M002',
        name: 'Kaynak Makinası',
        description: 'Endüstriyel kaynak işlemleri için özel kaynak makinası',
        status: 'active',
        location: 'B Blok - Zemin Kat',
        type: 'Kaynak',
        lastMaintenanceDate: now.subtract(const Duration(days: 8)),
        nextMaintenanceDate: now.add(const Duration(days: 82)),
        efficiency: 87.3,
        imageUrl: 'https://via.placeholder.com/300x200?text=Kaynak+Makinasi',
      ),
      Machine(
        id: '3',
        code: 'M003',
        name: 'Freze Tezgahı',
        description: 'Metal işleme için kullanılan hassas freze tezgahı',
        status: 'maintenance',
        location: 'A Blok - 2. Kat',
        type: 'Freze',
        lastMaintenanceDate: now.subtract(const Duration(days: 2)),
        nextMaintenanceDate: now.add(const Duration(days: 88)),
        efficiency: 0.0, // Bakımda olduğu için 0
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
}
