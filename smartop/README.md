# SmartOp - Endüstriyel Makine Kontrol Sistemi

SmartOp, endüstriyel makinelerin kontrol, izleme ve yönetimini sağlayan kapsamlı bir API sistemidir. Şirket bazlı çok kiracılı (multi-tenant) mimari ile geliştirilmiştir.

## 📋 Özellikler

- **🔐 JWT Authentication** - Laravel Sanctum ile güvenli giriş sistemi
- **👥 Rol Tabanlı Yetkilendirme** - Admin, Manager, Operator rolleri
- **🏢 Multi-Tenant Mimari** - Şirket bazlı veri izolasyonu
- **🤖 Makine Yönetimi** - QR kod ile makine takibi
- **📋 Kontrol Listeleri** - Template bazlı kontrol sistemleri
- **✅ Onay Mekanizması** - Control list onaylama/reddetme
- **📊 Dashboard & Raporlama** - Rol bazlı istatistikler
- **🔍 API Test Arayüzü** - Gelişmiş test paneli

## 🚀 Kurulum

### Gereksinimler
- PHP 8.1+
- Composer
- MySQL 8.0+
- Laravel 10+

### Adım 1: Projeyi İndirin
```bash
git clone https://github.com/cagkantasci/laravel.git
cd smartop
```

### Adım 2: Bağımlılıkları Yükleyin
```bash
composer install
npm install
```

### Adım 3: Environment Ayarları
```bash
cp .env.example .env
php artisan key:generate
```

.env dosyasında veritabanı ayarlarınızı yapın:
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=smartop
DB_USERNAME=root
DB_PASSWORD=
```

### Adım 4: Veritabanı Kurulumu
```bash
php artisan migrate
php artisan db:seed
```

### Adım 5: Serveri Başlatın
```bash
php artisan serve --port=8001
```

## 🧪 Test Arayüzü

Sistem kurulumu sonrasında API testlerinizi gerçekleştirmek için:
```
http://127.0.0.1:8001/api-test.html
```

Test arayüzü 17 farklı API endpoint'i test etmenizi sağlar.

## 👤 Varsayılan Kullanıcılar

Sistem aşağıdaki test kullanıcıları ile gelir:

```
Admin: admin@smartop.com / password
Manager: manager@smartop.com / password  
Operator: operator@smartop.com / password
```

## 📚 API Dokümantasyonu

### Base URL
```
http://127.0.0.1:8001/api
```

### Authentication
Tüm korumalı endpoint'ler için `Authorization: Bearer {token}` header'ı gereklidir.

### 🔐 Authentication Endpoints

#### POST `/register`
Yeni kullanıcı kaydı
```json
{
  "name": "Test User",
  "email": "test@example.com", 
  "password": "password",
  "password_confirmation": "password"
}
```

#### POST `/login`
Kullanıcı girişi
```json
{
  "email": "admin@smartop.com",
  "password": "password"
}
```

#### GET `/profile`
🔒 Kullanıcı profil bilgileri

#### POST `/logout`
🔒 Çıkış yapma

### 🏢 Company Endpoints

#### GET `/companies`
🔒 Şirket listesi (Permission: companies.view)

#### POST `/companies`
🔒 Yeni şirket oluşturma (Permission: companies.create)

#### GET `/companies/{id}`
🔒 Şirket detayları

#### PUT `/companies/{id}`
🔒 Şirket güncelleme (Permission: companies.edit)

#### DELETE `/companies/{id}`
🔒 Şirket silme (Permission: companies.delete)

### 🤖 Machine Endpoints

#### GET `/machines`
🔒 Makine listesi

#### POST `/machines`
🔒 Yeni makine ekleme (Permission: machines.create)

#### GET `/machines/{id}`
🔒 Makine detayları

#### PUT `/machines/{id}`
🔒 Makine güncelleme (Permission: machines.edit)

#### DELETE `/machines/{id}`
🔒 Makine silme (Permission: machines.delete)

#### POST `/machines/{id}/qr-code`
🔒 Makine için QR kod oluşturma

### 📋 Control Template Endpoints

#### GET `/control-templates`
🔒 Kontrol şablonları listesi

#### POST `/control-templates`
🔒 Yeni şablon oluşturma (Permission: control_templates.create)

#### GET `/control-templates/{id}`
🔒 Şablon detayları

#### PUT `/control-templates/{id}`
🔒 Şablon güncelleme (Permission: control_templates.edit)

#### DELETE `/control-templates/{id}`
🔒 Şablon silme (Permission: control_templates.delete)

#### POST `/control-templates/{id}/duplicate`
🔒 Şablon kopyalama

#### POST `/control-templates/{id}/create-control-list`
🔒 Şablondan control list oluşturma
```json
{
  "machine_id": 1
}
```

### ✅ Control List Endpoints

#### GET `/control-lists`
🔒 Kontrol listeleri

#### POST `/control-lists`
🔒 Yeni kontrol listesi (Permission: control_lists.create)

#### GET `/control-lists/{id}`
🔒 Kontrol listesi detayları

#### PUT `/control-lists/{id}`
🔒 Kontrol listesi güncelleme (Permission: control_lists.edit)

#### DELETE `/control-lists/{id}`
🔒 Kontrol listesi silme (Permission: control_lists.delete)

#### POST `/control-lists/{id}/approve`
🔒 Kontrol listesi onaylama (Permission: control_lists.approve)
```json
{
  "comment": "Onay yorumu (opsiyonel)"
}
```

#### POST `/control-lists/{id}/reject`
🔒 Kontrol listesi reddetme (Permission: control_lists.reject)
```json
{
  "comment": "Red yorumu (opsiyonel)"
}
```

### 📊 Dashboard & Reports

#### GET `/dashboard`
🔒 Rol tabanlı dashboard verileri
- **Admin**: Tüm sistem istatistikleri
- **Manager**: Şirket bazlı istatistikler  
- **Operator**: Kişisel istatistikler

#### GET `/reports`
🔒 Detaylı raporlar

### 🔑 Roller ve Yetkiler

#### Roller
- **Admin**: Sistem geneli yönetim
- **Manager**: Şirket düzeyinde yönetim
- **Operator**: Operasyonel işlemler

#### Temel Yetkiler
- `companies.*` - Şirket yönetimi
- `machines.*` - Makine yönetimi
- `control_templates.*` - Şablon yönetimi
- `control_lists.*` - Kontrol listesi yönetimi
- `users.*` - Kullanıcı yönetimi

## 🛠️ Geliştirme

### Test Çalıştırma
```bash
php artisan test
```

### Cache Temizleme
```bash
php artisan cache:clear
php artisan config:clear
php artisan route:clear
```

### Migration Sıfırlama
```bash
php artisan migrate:fresh --seed
```

## 📞 Destek

Herhangi bir sorun yaşarsanız GitHub Issues bölümünden iletişime geçebilirsiniz.

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır.
