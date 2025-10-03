# SmartOp Frontend Projeleri

Bu repository iki ayrı frontend projesi içermektedir:
1. **Marketing Website** - Müşterilere yönelik tanıtım sitesi
2. **Admin Dashboard** - Yönetim paneli

## 🚀 Hızlı Başlangıç

### Gereksinimler
- Node.js 18+
- npm veya yarn
- Laravel Backend API'nin çalışıyor olması

### 1. Marketing Website

**Dizin:** `smartop-website/`
**Port:** `3000`
**URL:** http://localhost:3000

```bash
cd smartop-website
npm install
npm run dev
```

#### Özellikler:
- ✅ Responsive landing page
- ✅ Fiyatlandırma sayfası
- ✅ Modern UI/UX (Tailwind CSS)
- ✅ SEO optimized
- ✅ Mobile-first design

### 2. Admin Dashboard

**Dizin:** `smartop-dashboard/`
**Port:** `3001`
**URL:** http://localhost:3001

```bash
cd smartop-dashboard
npm install
npm run dev -- --port 3001
```

#### Özellikler:
- ✅ Multi-role dashboard (Admin/Manager/Operator)
- ✅ Real-time API entegrasyonu
- ✅ Modern UI bileşenleri (shadcn/ui)
- ✅ State management (React Query)
- ✅ Responsive tasarım
- ✅ Fiyatlandırma yönetimi
- ✅ Dashboard istatistikleri
- ✅ Sidebar navigasyon

## 🛠️ Teknoloji Stack

### Her İki Proje İçin Ortak:
- **Framework:** Next.js 14 (App Router)
- **Language:** TypeScript
- **Styling:** Tailwind CSS
- **Icons:** Lucide React

### Marketing Website:
- **Deployment:** Vercel/Netlify ready
- **SEO:** next-seo optimized

### Admin Dashboard:
- **UI Components:** shadcn/ui + Radix UI
- **State Management:** TanStack React Query
- **API Client:** Axios
- **Charts:** Recharts
- **Form Handling:** React Hook Form ready

## 🔗 API Entegrasyonu

Dashboard Laravel backend API'leri ile entegre çalışacak şekilde tasarlandı:

### API Base URL:
```
http://127.0.0.1:8001/api
```

### Desteklenen Endpoints:
- `/auth/*` - Authentication
- `/dashboard` - Dashboard istatistikleri
- `/companies` - Şirket yönetimi
- `/users` - Kullanıcı yönetimi
- `/machines` - Makine yönetimi
- `/control-lists` - Kontrol listeleri
- `/control-templates` - Kontrol şablonları

### Environment Variables (.env.local):
```bash
NEXT_PUBLIC_API_URL=http://127.0.0.1:8001/api
```

## 📱 Responsive Design

Her iki proje de mobile-first yaklaşımla tasarlandı:
- **Mobile:** 320px+
- **Tablet:** 768px+
- **Desktop:** 1024px+

## 🎨 UI/UX Özellikleri

### Marketing Website:
- Hero section with CTA
- Features showcase
- Pricing cards
- Testimonials ready
- Footer with links

### Admin Dashboard:
- Sidebar navigation
- Role-based menu items
- Search functionality
- User dropdown menu
- Stats cards
- Charts (Bar, Pie)
- Data tables ready
- Modal dialogs ready

## 🚀 Production Deployment

### Marketing Website:
```bash
cd smartop-website
npm run build
npm start
```

### Admin Dashboard:
```bash
cd smartop-dashboard
npm run build
npm start
```

## 🧪 Development

### Hot Reload:
Her iki proje de hot reload destekler. Değişiklikler anında görünür.

### Development URLs:
- Marketing: http://localhost:3000
- Dashboard: http://localhost:3001
- Backend API: http://127.0.0.1:8001

## 📋 Todo / Gelecek Özellikler

### Marketing Website:
- [ ] Blog sayfası
- [ ] Demo booking formu
- [ ] Çoklu dil desteği
- [ ] A/B testing
- [ ] Analytics entegrasyonu

### Admin Dashboard:
- [ ] Real-time bildirimler
- [ ] Bulk operations
- [ ] Advanced filters
- [ ] Export functionality
- [ ] Dark/Light theme toggle
- [ ] User permissions UI
- [ ] Audit log viewer
- [ ] Advanced reporting

## 🔒 Security

- ✅ CSRF protection ready
- ✅ XSS protection
- ✅ JWT token handling
- ✅ Role-based access control
- ✅ Secure API client

## 🐛 Troubleshooting

### Port Conflicts:
Eğer portlar kullanımda ise:
```bash
# Marketing website için
npm run dev -- --port 3002

# Dashboard için
npm run dev -- --port 3003
```

### API Connection Issues:
- Backend API'nin çalıştığından emin olun
- CORS ayarlarını kontrol edin
- Environment variables'ları kontrol edin

## 📞 Destek

Bu projeler SmartOp sisteminin frontend kısmını oluşturur. Backend API ile birlikte tam fonksiyonel bir sistem sağlar.

**Not:** Her iki proje de production-ready state'te olup, deploy edilebilir durumdadır.