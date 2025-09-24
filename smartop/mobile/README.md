# SmartOp Mobile - Endüstriyel Makine Kontrol Uygulaması

SmartOp Mobile, endüstriyel makinelerin uzaktan kontrolü ve izlenmesi için geliştirilmiş Flutter tabanlı mobil uygulamasıdır. Laravel backend API'si ile entegre olarak çalışır.

## 🚀 Özellikler

- **🔐 Rol Tabanlı Authentication** - Admin, Manager, Operator rolleri
- **📱 QR Kod Okuma** - Makineleri QR kod ile tanımlama
- **📊 Dashboard** - Rol bazlı istatistikler ve grafikler
- **🤖 Makine Yönetimi** - Makine durumları ve kontrol işlemleri
- **📋 Kontrol Listeleri** - Onay mekanizmalı kontrol süreçleri
- **🔄 Offline Desteği** - İnternet bağlantısı olmadan kritik işlemler
- **📈 Raporlama** - Detaylı performans raporları
- **🎨 Modern UI** - Material 3 tasarım sistemi

## 🛠️ Teknoloji Stack

- **Framework**: Flutter 3.8+
- **State Management**: Bloc/Cubit pattern
- **Local Storage**: Hive + SQLite
- **Network**: HTTP + Dio
- **Navigation**: GoRouter
- **QR Scanner**: qr_code_scanner
- **Charts**: fl_chart
- **Security**: flutter_secure_storage

## 📋 Gereksinimler

- Flutter 3.8.1 veya üstü
- Dart 3.0+
- Android Studio / VS Code
- Android SDK (Android geliştirme için)
- Xcode (iOS geliştirme için)

## 🚦 Kurulum

### 1. Flutter SDK Kurulumu
```bash
# Flutter SDK'yı indirin ve PATH'e ekleyin
# https://docs.flutter.dev/get-started/install

# Kurulumu doğrulayın
flutter doctor
```

### 2. Projeyi İndirin
```bash
git clone https://github.com/cagkantasci/laravel.git
cd laravel/smartop/mobile
```

### 3. Bağımlılıkları Yükleyin
```bash
flutter pub get
```

### 4. Backend Bağlantısını Yapılandırın
`lib/core/constants/app_constants.dart` dosyasında API URL'ini güncelleyin:
```dart
static const String apiBaseUrl = 'http://YOUR_BACKEND_IP:8001/api';
```

### 5. Uygulamayı Çalıştırın
```bash
# Android/iOS Emulator veya gerçek cihazda
flutter run

# Web tarayıcısında
flutter run -d chrome

# Windows Desktop'ta
flutter run -d windows
```

## 📱 Platform Desteği

- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 12+) 
- ✅ **Web** (Chrome, Firefox, Safari, Edge)
- ✅ **Windows** (Windows 10+)
- ✅ **macOS** (macOS 10.14+)
- ✅ **Linux** (Ubuntu 20.04+)

## 🏗️ Proje Yapısı

```
lib/
├── core/                 # Temel servisler ve utilities
│   ├── constants/        # Uygulama sabitleri
│   ├── services/         # API, storage servisleri
│   └── utils/           # Yardımcı fonksiyonlar
├── features/            # Özellik bazlı modüller
│   ├── auth/            # Authentication
│   ├── dashboard/       # Dashboard ve istatistikler
│   ├── machines/        # Makine yönetimi
│   └── control_lists/   # Kontrol listeleri
├── shared/              # Paylaşılan bileşenler
│   ├── models/          # Veri modelleri
│   └── widgets/         # Ortak UI bileşenleri
└── main.dart           # Uygulama giriş noktası
```

## 🔧 Geliştirme

### Build Komutları
```bash
# Debug build
flutter build apk --debug

# Release build  
flutter build apk --release

# iOS build
flutter build ios --release

# Web build
flutter build web

# Windows build
flutter build windows
```

### Test Komutları
```bash
# Unit testler
flutter test

# Widget testleri
flutter test test/widget_test.dart

# Integration testleri
flutter test integration_test/
```

### Code Generation
```bash
# Model sınıfları için
flutter packages pub run build_runner build

# Watch mode için
flutter packages pub run build_runner watch
```

## 🌐 API Entegrasyonu

SmartOp Mobile, Laravel backend ile RESTful API üzerinden iletişim kurar:

- **Base URL**: `http://127.0.0.1:8001/api`
- **Authentication**: JWT Token
- **Endpoints**: Login, Dashboard, Machines, Control Lists, Reports

API dokümantasyonu için backend README.md dosyasına bakın.

## 🔒 Güvenlik

- JWT token tabanlı authentication
- Secure storage ile hassas veri şifreleme
- API request'lerde HTTPS zorunluluğu
- Rol bazlı erişim kontrolü

## 🐛 Sorun Giderme

### Yaygın Sorunlar

**1. Flutter Doctor Hataları**
```bash
flutter doctor
# Eksik bileşenleri yükleyin
```

**2. Build Hataları**
```bash
flutter clean
flutter pub get
flutter pub upgrade
```

**3. API Bağlantı Sorunları**
- Backend servisinin çalıştığından emin olun
- IP adresini kontrol edin
- Firewall ayarlarını kontrol edin

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır.

## 🤝 Katkı Sağlama

1. Fork edin
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Commit edin (`git commit -m 'Add amazing feature'`)
4. Push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## 📞 İletişim

Herhangi bir sorunuz varsa GitHub Issues bölümünden iletişime geçebilirsiniz.
