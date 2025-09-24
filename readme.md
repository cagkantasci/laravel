# İş Makinesi Kontrol Sistemi - Kapsamlı Geliştirme Prompt'u

## 📋 Proje Özeti
Modern iş makinelerinin operasyon öncesi güvenlik kontrollerini dijitalleştiren, çok katmanlı yetkilendirme sistemi ile yönetilen SaaS platformu geliştiriyorsunuz.

## 🎯 Ana İş Akışı
1. **Operatör** → Makineyi kullanmadan önce kontrol listesini doldurur
2. **Sistem** → Kontrol listesini makinenin özelliklerine göre eşleştirir
3. **Manager** → Kontrol listesini onaylar/reddeder
4. **Operatör** → Onay aldıktan sonra işe başlayabilir

## 👥 Rol Yapısı ve Yetkileri

### 🔴 Admin (Sistem Yöneticisi)
- **Tam sistem erişimi** - Tüm modüller üzerinde CRUD işlemleri
- Şirket yönetimi (ekleme, düzenleme, silme, askıya alma)
- Kullanıcı yönetimi (tüm roller için)
- Sistem konfigürasyonları
- Abonelik ve ödeme yönetimi
- Raporlama ve analytics
- Sistem bakımı ve güncellemeler

### 🟡 Manager (Şirket Yöneticisi)
- **Şirket bilgileri yönetimi** (adres, telefon, logo, vb.)
- **Makine havuzu yönetimi**:
  - Mevcut havuzdan makine ekleme
  - Yeni makine tanımlama (otomatik havuza eklenir)
  - Makine bilgileri güncelleme
  - Makine durumu yönetimi (aktif/pasif)
- **Operatör yönetimi**:
  - Operatör ekleme/çıkarma
  - Operatör bilgileri güncelleme
  - Operatör-makine eşleştirme
- **Kontrol listesi onay/red** işlemleri
- Şirket içi raporlar ve istatistikler
- Operatör performans takibi

### 🟢 Operator (Makine Operatörü)
- **Makine kontrol listesi** doldurma
- Atanmış makineler görüntüleme
- Kontrol geçmişi görüntüleme
- Onay durumu takibi
- Basit profil yönetimi

## 🏗️ Teknik Mimari

### Backend - Laravel 10+
```php
// Temel gereksinimler
- PHP 8.2+
- Laravel 10.x
- Laravel Sanctum (API Authentication)
- Laravel Telescope (Development)
- Laravel Horizon (Queue Management)
- Spatie Permission (Role-Permission)
- Laravel Backup
- Laravel Auditing (Activity Log)

// Veritabanı Yapısı
- companies (şirketler)
- users (kullanıcılar - polymorphic roles)
- machines (makineler)
- machine_pool (makine havuzu)
- control_lists (kontrol listeleri)
- control_items (kontrol maddeleri)
- machine_controls (makine-kontrol eşleşmeleri)
- approvals (onay işlemleri)
- audit_logs (denetim kayıtları)
- subscriptions (abonelikler)
- payments (ödemeler)
```

### Database - MySQL 8.0+
```sql
-- Kritik indeksler
- companies: (status, created_at)
- users: (email, role, company_id, status)
- machines: (company_id, status, serial_number)
- control_lists: (machine_id, operator_id, status, created_at)
- approvals: (control_list_id, manager_id, status)

-- Güvenlik
- Soft deletes tüm tablolarda
- UUID primary keys (güvenlik için)
- Encrypted sensitive data
- Regular backups
- Point-in-time recovery
```

### Frontend - Modern Web Stack
```javascript
// Önerilen Stack
Framework: Next.js 14+ (App Router)
Language: TypeScript
UI Library: Tailwind CSS + shadcn/ui
State Management: Zustand / Redux Toolkit
Forms: React Hook Form + Zod validation
HTTP Client: Axios / React Query
Charts: Recharts / Chart.js
Authentication: NextAuth.js

// Alternatif Stack
Framework: React 18+ / Vue 3
Build Tool: Vite
UI Framework: Ant Design / Material-UI
```

### Mobile - Flutter 3.16+
```dart
// Temel dependencies
- flutter_bloc (State Management)
- dio (HTTP Client)
- hive (Local Storage)
- camera (Fotoğraf çekimi)
- geolocator (GPS tracking)
- firebase_messaging (Push notifications)
- flutter_secure_storage (Secure storage)
- permission_handler (İzin yönetimi)

// Mimari
- Clean Architecture
- Repository Pattern
- Dependency Injection (get_it)
- Offline-first approach
```

## 💳 Ödeme Sistemi - PayTR Integration

### PayTR Entegrasyonu
```php
// Laravel PayTR Service
class PayTRService {
    - createPayment() // Ödeme oluşturma
    - verifyCallback() // Callback doğrulama
    - refundPayment() // İade işlemi
    - getPaymentStatus() // Ödeme durumu
}

// Ödeme planları
- Starter: 10 makine, 2 manager, 20 operatör
- Professional: 50 makine, 5 manager, 100 operatör
- Enterprise: Unlimited + özel özellikler
```

## 🌐 Marketing Website

### Teknoloji Stack'i
```javascript
Framework: Next.js 14 (Static Generation)
Styling: Tailwind CSS
CMS: Strapi / Sanity (opsiyonel)
Analytics: Google Analytics 4
SEO: next-seo, sitemap generation
Hosting: Vercel / Netlify

// Sayfalar
- Landing page (hero, features, pricing)
- Özellikler detay sayfaları
- Fiyatlandırma
- Hakkımızda / İletişim
- Blog (SEO için)
- Demo request form
- Kayıt olma / Giriş yap
```

## 📱 Özellik Detayları

### Kontrol Listesi Sistemi
```typescript
interface ControlList {
  id: string;
  machineId: string;
  operatorId: string;
  items: ControlItem[];
  photos: string[]; // Fotoğraf URL'leri
  location: GPS_Location;
  status: 'pending' | 'approved' | 'rejected';
  submittedAt: Date;
  approvedAt?: Date;
  approvedBy?: string;
  notes?: string;
}

interface ControlItem {
  id: string;
  title: string;
  description: string;
  required: boolean;
  type: 'checkbox' | 'text' | 'number' | 'photo';
  checked?: boolean;
  value?: string;
  photoRequired?: boolean;
}
```

### Real-time Bildirimler
```dart
// Flutter Push Notifications
- Yeni kontrol listesi (Manager'a)
- Onay/Red bildirimi (Operatör'e)
- Sistem bildirimleri
- Bakım hatırlatmaları
```

### Offline Destek
```dart
// Mobile offline capabilities
- Kontrol listelerini offline doldurma
- Fotoğraf çekme ve local kaydetme
- İnternet bağlantısı geldiğinde senkronizasyon
- Conflict resolution
```

## 🔒 Güvenlik Gereksinimleri

### Authentication & Authorization
```php
// Laravel Security
- JWT token authentication
- Rate limiting
- CSRF protection
- XSS filtering
- SQL injection prevention
- Password hashing (bcrypt)
- Two-factor authentication (opsiyonel)
```

### Data Privacy
```php
// KVKK Compliance
- Kişisel veri maskeleme
- Veri silinme hakkı
- Audit logging
- Data encryption at rest
- Secure file upload
- Access logging
```

## 📊 Raporlama ve Analytics

### Dashboard Metrikleri
```typescript
// Admin Dashboard
- Toplam şirket sayısı
- Aktif kullanıcılar
- Günlük kontrol sayısı
- Sistem uptime
- Revenue analytics

// Manager Dashboard
- Bekleyen onaylar
- Operatör performansı
- Makine kullanım oranları
- Güvenlik ihlalleri
- Trend analizi

// Operator Dashboard
- Bugünkü kontrollerim
- Geçmiş performans
- Onay süreleri
- Makine durumları
```

### Export Özellikleri
```php
// Report formats
- PDF reports
- Excel export
- CSV data export
- Automated email reports
- API endpoints for BI tools
```

## 🚀 Deployment ve DevOps

### Production Environment
```yaml
# Docker Compose
services:
  app: Laravel (PHP-FPM + Nginx)
  database: MySQL 8.0
  redis: Redis (caching + queues)
  nginx: Load balancer
  certbot: SSL certificates

# Cloud Services
- AWS/Google Cloud/DigitalOcean
- CDN for static assets
- Automated backups
- Monitoring (New Relic/DataDog)
- Error tracking (Sentry)
```

### CI/CD Pipeline
```yaml
# GitHub Actions / GitLab CI
- Automated testing
- Code quality checks (PHPStan, ESLint)
- Security scanning
- Database migrations
- Zero-downtime deployment
- Rollback capabilities
```

## 🔧 Genişletilebilirlik

### API Architecture
```php
// RESTful API Design
- Versioned APIs (/api/v1/)
- Rate limiting
- API documentation (OpenAPI/Swagger)
- Webhook support
- Third-party integrations
- SDK development (PHP, JavaScript)
```

### Plugin System
```php
// Modüler yapı
- Custom control items
- Integration modules
- Reporting plugins
- Custom workflows
- White-label options
```

### Multi-tenancy
```php
// Tenant isolation
- Database per tenant
- Shared database with tenant_id
- Custom domain support
- Tenant-specific configurations
- Resource quotas
```

## 📋 Geliştirme Roadmap'i

### Faz 1 (MVP - 2-3 ay)
- [ ] Temel kullanıcı yönetimi
- [ ] Makine ve kontrol listesi CRUD
- [ ] Basit onay sistemi
- [ ] Web dashboard (responsive)
- [ ] Mobile app (temel özellikler)

### Faz 2 (Beta - 1-2 ay)
- [ ] PayTR ödeme entegrasyonu
- [ ] Marketing website
- [ ] Push notifications
- [ ] Offline mobile support
- [ ] Temel raporlama

### Faz 3 (Production - 1-2 ay)
- [ ] Gelişmiş raporlama
- [ ] API documentation
- [ ] Performance optimizasyonu
- [ ] Security audit
- [ ] Load testing

### Faz 4 (Scale - Ongoing)
- [ ] Multi-tenant support
- [ ] Plugin system
- [ ] Advanced analytics
- [ ] Mobile app advanced features
- [ ] Third-party integrations

## 💡 Önemli Notlar

### Performance Considerations
- Database query optimization
- Image compression and CDN
- Caching strategies (Redis)
- API response pagination
- Mobile app bundle optimization

### User Experience
- Progressive web app (PWA) support
- Dark/light theme toggle
- Multi-language support (TR, EN)
- Accessibility compliance
- Mobile-first design

### Business Logic
- Flexible control list templates
- Machine type categorization
- Approval workflow customization
- Integration with existing systems
- Data migration tools

Bu prompt, projenizin tüm teknik ve işlevsel gereksinimlerini kapsar. Geliştirme ekibiniz bu dokümana göre modüler bir yaklaşım benimseyerek projeyi adım adım geliştirebilir. Her faz sonunda test edilebilir bir ürün ortaya çıkacak şekilde planlanmıştır.