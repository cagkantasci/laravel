# SmartOp Sistem Eksiklikleri ve Yapılacaklar Listesi

## 🔴 KRİTİK ÖNCELİK

### 1. Backend API Routes Eksikleri

#### UserController Tamamlanacak
- **Dosya:** `smartop/app/Http/Controllers/Api/UserController.php`
- **Satırlar:** 10-65 (Boş)
- **Yapılacaklar:**
  - [ ] index() - Kullanıcı listesi
  - [ ] store() - Yeni kullanıcı oluştur
  - [ ] show() - Kullanıcı detayı
  - [ ] update() - Kullanıcı güncelle
  - [ ] destroy() - Kullanıcı sil
  - [ ] Company ve role middleware ekle

#### Financial Endpoint'leri Route'lara Ekle
- **Dosya:** `smartop/routes/api.php`
- **Yapılacaklar:**
  - [ ] Financial transactions CRUD routes
  - [ ] Financial summary endpoint
  - [ ] Financial categories endpoint
  - [ ] Dashboard analytics endpoint
  - [ ] Role-based middleware (admin|manager)

**Eklenecek Route'lar:**
```php
Route::middleware(['auth:sanctum', 'company', 'role:admin,manager'])->group(function () {
    // Financial Transactions
    Route::apiResource('financial-transactions', FinancialTransactionController::class);
    Route::get('financial-transactions/summary', [FinancialTransactionController::class, 'summary']);
    Route::get('financial-transactions/categories', [FinancialTransactionController::class, 'categories']);

    // Dashboard Analytics
    Route::get('dashboard/analytics', [DashboardAnalyticsController::class, 'getAnalytics']);
});

// Admin only routes
Route::middleware(['auth:sanctum', 'role:admin'])->prefix('admin')->group(function () {
    Route::apiResource('users', UserController::class);
});
```

### 2. Frontend TypeScript Type Definitions

**Dosya:** `smartop-dashboard/src/lib/api.ts`
**Satır:** 439 (En sona eklenecek)

**Eksik Interface'ler:**
```typescript
export interface FinancialTransaction {
  uuid: string
  company_id: number
  user_id: number
  user?: User
  type: 'income' | 'expense'
  category: string
  title: string
  description?: string
  amount: number
  currency: string
  transaction_date: string
  status: 'pending' | 'completed' | 'cancelled'
  reference_number?: string
  payment_method?: string
  metadata?: any
  created_at: string
  updated_at: string
}

export interface FinancialSummary {
  period: {
    start_date: string
    end_date: string
  }
  summary: {
    total_income: number
    total_expense: number
    net_profit: number
    currency: string
  }
  income_by_category: Record<string, number>
  expense_by_category: Record<string, number>
}

export interface WorkSession {
  id: number
  uuid: string
  operator_id: number
  operator?: User
  machine_id: number
  machine?: Machine
  control_list_id?: number
  start_time: string
  end_time?: string
  total_hours?: number
  location?: string
  start_notes?: string
  end_notes?: string
  status: 'active' | 'completed' | 'approved' | 'rejected'
  approved_by?: number
  approved_at?: string
  created_at: string
  updated_at: string
}
```

**Eksik API Methods:**
```typescript
// Financial Transactions
async getFinancialTransactions(params?: any) {
  const response = await this.client.get('/financial-transactions', { params })
  return response.data
}

async getFinancialTransaction(uuid: string) {
  const response = await this.client.get(`/financial-transactions/${uuid}`)
  return response.data
}

async createFinancialTransaction(data: any) {
  const response = await this.client.post('/financial-transactions', data)
  return response.data
}

async updateFinancialTransaction(uuid: string, data: any) {
  const response = await this.client.put(`/financial-transactions/${uuid}`, data)
  return response.data
}

async deleteFinancialTransaction(uuid: string) {
  const response = await this.client.delete(`/financial-transactions/${uuid}`)
  return response.data
}

async getFinancialSummary(params?: any) {
  const response = await this.client.get('/financial-transactions/summary', { params })
  return response.data
}

async getFinancialCategories() {
  const response = await this.client.get('/financial-transactions/categories')
  return response.data
}

// Dashboard Analytics
async getDashboardAnalytics(params?: any) {
  const response = await this.client.get('/dashboard/analytics', { params })
  return response.data
}
```

### 3. Eksik Frontend Sayfaları

#### Transactions Listing Page
- **Dosya:** `smartop-dashboard/src/app/finances/transactions/page.tsx` (Yeni)
- **Özellikler:**
  - [ ] Transaction listesi (pagination)
  - [ ] Filtreleme (type, category, date range, status)
  - [ ] Arama (title, description, reference)
  - [ ] Sorting
  - [ ] Export özelliği

#### Transaction Detail Page
- **Dosya:** `smartop-dashboard/src/app/finances/transactions/[uuid]/page.tsx` (Yeni)
- **Özellikler:**
  - [ ] Transaction detayları
  - [ ] Edit modal
  - [ ] Delete confirmation
  - [ ] Activity log

#### Analytics Dashboard
- **Dosya:** `smartop-dashboard/src/app/dashboard/analytics/page.tsx` (Yeni)
- **Özellikler:**
  - [ ] Financial summary cards
  - [ ] Revenue trends chart (12 months)
  - [ ] Subscription breakdown chart
  - [ ] Customer metrics
  - [ ] Monthly comparison

## 🟡 ORTA ÖNCELİK

### 4. Eksik Model Dosyaları

#### Payment Model
- **Dosya:** `smartop/app/Models/Payment.php` (Yeni)
- Migration var: `2025_09_24_192440_create_payments_table.php`
- **İlişkiler:**
  - [ ] belongsTo Company
  - [ ] belongsTo Subscription
  - [ ] belongsTo User

#### AuditLog Model
- **Dosya:** `smartop/app/Models/AuditLog.php` (Yeni)
- Migration var: `2025_09_24_192506_create_audit_logs_table.php`
- **İlişkiler:**
  - [ ] belongsTo User
  - [ ] morphTo auditable

### 5. Model İlişkileri Güncellemeleri

#### Subscription Model
- **Dosya:** `smartop/app/Models/Subscription.php`
- **Eklenecek İlişkiler:**
  - [ ] hasMany Payment
  - [ ] hasMany AuditLog (morphMany)

#### Company Model
- **Eklenecek İlişkiler:**
  - [ ] hasMany FinancialTransaction
  - [ ] hasMany Subscription
  - [ ] hasMany Payment

### 6. Seeder'ları DatabaseSeeder'a Ekle

**Dosya:** `smartop/database/seeders/DatabaseSeeder.php`

**Eklenecek:**
```php
$this->call([
    RolePermissionSeeder::class,
    AdminUserSeeder::class,
    DemoDataSeeder::class,
    SubscriptionSeeder::class,
    FinancialTransactionSeeder::class,
]);
```

### 7. Mobile App - Backend Integration

#### Control List Filling API
- Backend'de mevcut endpoint'ler mobile app'e tam entegre değil
- **Kontrol Edilecek:**
  - [ ] `/control-lists/{id}/items/{itemId}` - PUT request
  - [ ] `/control-lists/{id}/start` - POST request
  - [ ] `/control-lists/{id}/complete` - POST request
  - [ ] Photo upload endpoint

#### Permission Checks
- Mobile app'te permission_helper.dart var
- Backend'de rol bazlı kontrolller eksik
- **Eklenecek:**
  - [ ] Can create control list
  - [ ] Can start work session
  - [ ] Can approve/reject

## 🟢 DÜŞÜK ÖNCELİK

### 8. Testing

#### Backend Tests
- **Klasör:** `smartop/tests/Feature/`
- **Oluşturulacak:**
  - [ ] AuthControllerTest
  - [ ] MachineControllerTest
  - [ ] ControlListControllerTest
  - [ ] WorkSessionControllerTest
  - [ ] FinancialTransactionControllerTest
  - [ ] UserControllerTest

#### Frontend Tests
- **Klasör:** `smartop-dashboard/__tests__/`
- **Oluşturulacak:**
  - [ ] Login page test
  - [ ] Dashboard test
  - [ ] API client test

### 9. Documentation

#### API Documentation
- **Dosya:** `smartop/README.md` (Yeni)
- **İçerik:**
  - [ ] API endpoint listesi
  - [ ] Authentication açıklaması
  - [ ] Request/Response örnekleri
  - [ ] Error codes

#### Installation Guide
- **Dosya:** `INSTALLATION.md` (Yeni)
- **İçerik:**
  - [ ] Backend kurulum adımları
  - [ ] Frontend kurulum adımları
  - [ ] Mobile app kurulum adımları
  - [ ] Environment variables

### 10. Code Quality Improvements

#### Error Handling
- [ ] Global exception handler
- [ ] Validation rules consistency
- [ ] API response standardization

#### Security
- [ ] Rate limiting
- [ ] CORS configuration review
- [ ] Input sanitization
- [ ] SQL injection prevention checks

#### Performance
- [ ] Database query optimization (N+1 problem)
- [ ] API response caching
- [ ] Eager loading review

## 📱 MOBİL UYGULAMA EKSİKLERİ

### Control Lists
- [ ] Fill control list backend entegrasyonu
- [ ] Photo upload işlevi
- [ ] Offline mode data sync

### Work Sessions
- [ ] Backend ile tam entegrasyon
- [ ] Real-time session tracking
- [ ] Approval notification

### Dashboard
- [ ] Real-time statistics
- [ ] Chart/Graph components

### User Management
- [ ] Admin panel integration
- [ ] Role management

---

## 📝 NOTLAR

- UserController tamamen boş, önce bu tamamlanmalı
- Financial ve Analytics endpoint'leri route'larda tanımlı değil
- Frontend'de kullanılan bazı API method'ları backend'de yok
- Mobile app temel yapısı hazır, backend entegrasyonu eksik
- Test coverage %0, mutlaka testler yazılmalı

**Son Güncelleme:** 2025-10-04
