import { ArrowRight, CheckCircle, Shield, Users, BarChart3, Smartphone } from 'lucide-react';
import Link from 'next/link';

export default function Home() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 to-blue-50">
      {/* Header */}
      <header className="bg-white/80 backdrop-blur-sm border-b border-slate-200 sticky top-0 z-50">
        <div className="container mx-auto px-4 py-4">
          <nav className="flex items-center justify-between">
            <div className="flex items-center space-x-2">
              <Shield className="h-8 w-8 text-blue-600" />
              <span className="text-2xl font-bold text-slate-900">SmartOp</span>
            </div>

            <div className="hidden md:flex items-center space-x-8">
              <Link href="#features" className="text-slate-700 hover:text-blue-600 transition-colors">
                Özellikler
              </Link>
              <Link href="#pricing" className="text-slate-700 hover:text-blue-600 transition-colors">
                Fiyatlandırma
              </Link>
              <Link href="#contact" className="text-slate-700 hover:text-blue-600 transition-colors">
                İletişim
              </Link>
              <Link
                href="/login"
                className="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 transition-colors"
              >
                Giriş Yap
              </Link>
            </div>
          </nav>
        </div>
      </header>

      {/* Hero Section */}
      <section className="py-20">
        <div className="container mx-auto px-4 text-center">
          <h1 className="text-5xl md:text-6xl font-bold text-slate-900 mb-6">
            İş Makineleri için
            <span className="text-blue-600"> Dijital Kontrol</span>
            <br />Sistemi
          </h1>

          <p className="text-xl text-slate-600 mb-8 max-w-3xl mx-auto">
            Operasyon öncesi güvenlik kontrollerini dijitalleştirin.
            Çok katmanlı yetkilendirme sistemi ile iş güvenliğinizi artırın.
          </p>

          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link
              href="/demo"
              className="bg-blue-600 text-white px-8 py-4 rounded-lg text-lg font-semibold hover:bg-blue-700 transition-colors flex items-center justify-center"
            >
              Ücretsiz Demo
              <ArrowRight className="ml-2 h-5 w-5" />
            </Link>

            <Link
              href="/register"
              className="border-2 border-blue-600 text-blue-600 px-8 py-4 rounded-lg text-lg font-semibold hover:bg-blue-50 transition-colors"
            >
              Hemen Başla
            </Link>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section id="features" className="py-20 bg-white">
        <div className="container mx-auto px-4">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold text-slate-900 mb-4">
              Neden SmartOp?
            </h2>
            <p className="text-xl text-slate-600 max-w-2xl mx-auto">
              Modern teknoloji ile iş makinelerinizin güvenliğini sağlayın
            </p>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
            <div className="bg-slate-50 p-8 rounded-xl">
              <div className="bg-blue-100 w-12 h-12 rounded-lg flex items-center justify-center mb-4">
                <Shield className="h-6 w-6 text-blue-600" />
              </div>
              <h3 className="text-xl font-semibold text-slate-900 mb-3">
                Güvenlik Odaklı
              </h3>
              <p className="text-slate-600">
                Operasyon öncesi zorunlu kontrol listeleri ile iş güvenliğinizi maksimize edin.
              </p>
            </div>

            <div className="bg-slate-50 p-8 rounded-xl">
              <div className="bg-green-100 w-12 h-12 rounded-lg flex items-center justify-center mb-4">
                <Users className="h-6 w-6 text-green-600" />
              </div>
              <h3 className="text-xl font-semibold text-slate-900 mb-3">
                Rol Tabanlı Yetkilendirme
              </h3>
              <p className="text-slate-600">
                Admin, Manager ve Operatör rolleri ile tam kontrol ve yetki yönetimi.
              </p>
            </div>

            <div className="bg-slate-50 p-8 rounded-xl">
              <div className="bg-purple-100 w-12 h-12 rounded-lg flex items-center justify-center mb-4">
                <BarChart3 className="h-6 w-6 text-purple-600" />
              </div>
              <h3 className="text-xl font-semibold text-slate-900 mb-3">
                Detaylı Raporlama
              </h3>
              <p className="text-slate-600">
                Kapsamlı analitik ve raporlama ile operasyon performansınızı takip edin.
              </p>
            </div>

            <div className="bg-slate-50 p-8 rounded-xl">
              <div className="bg-orange-100 w-12 h-12 rounded-lg flex items-center justify-center mb-4">
                <Smartphone className="h-6 w-6 text-orange-600" />
              </div>
              <h3 className="text-xl font-semibold text-slate-900 mb-3">
                Mobil Destek
              </h3>
              <p className="text-slate-600">
                iOS ve Android uygulamaları ile sahada kesintisiz kullanım.
              </p>
            </div>

            <div className="bg-slate-50 p-8 rounded-xl">
              <div className="bg-cyan-100 w-12 h-12 rounded-lg flex items-center justify-center mb-4">
                <CheckCircle className="h-6 w-6 text-cyan-600" />
              </div>
              <h3 className="text-xl font-semibold text-slate-900 mb-3">
                Offline Çalışma
              </h3>
              <p className="text-slate-600">
                İnternet bağlantısı olmadan da kontrol listeleri doldurabilirsiniz.
              </p>
            </div>

            <div className="bg-slate-50 p-8 rounded-xl">
              <div className="bg-red-100 w-12 h-12 rounded-lg flex items-center justify-center mb-4">
                <ArrowRight className="h-6 w-6 text-red-600" />
              </div>
              <h3 className="text-xl font-semibold text-slate-900 mb-3">
                Kolay Entegrasyon
              </h3>
              <p className="text-slate-600">
                Mevcut sistemlerinize kolayca entegre olur. API desteği mevcuttur.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Pricing Section */}
      <section id="pricing" className="py-20 bg-slate-50">
        <div className="container mx-auto px-4">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold text-slate-900 mb-4">
              Size Uygun Planı Seçin
            </h2>
            <p className="text-xl text-slate-600">
              İhtiyaçlarınıza göre esnek fiyatlandırma seçenekleri
            </p>
          </div>

          <div className="grid md:grid-cols-3 gap-8 max-w-5xl mx-auto">
            {/* Starter Plan */}
            <div className="bg-white p-8 rounded-xl border border-slate-200">
              <h3 className="text-2xl font-bold text-slate-900 mb-2">Starter</h3>
              <p className="text-slate-600 mb-6">Küçük işletmeler için</p>

              <div className="mb-6">
                <span className="text-4xl font-bold text-slate-900">₺299</span>
                <span className="text-slate-600">/ay</span>
              </div>

              <ul className="space-y-3 mb-8">
                <li className="flex items-center">
                  <CheckCircle className="h-5 w-5 text-green-500 mr-3" />
                  <span className="text-slate-700">10 Makine</span>
                </li>
                <li className="flex items-center">
                  <CheckCircle className="h-5 w-5 text-green-500 mr-3" />
                  <span className="text-slate-700">2 Manager</span>
                </li>
                <li className="flex items-center">
                  <CheckCircle className="h-5 w-5 text-green-500 mr-3" />
                  <span className="text-slate-700">20 Operatör</span>
                </li>
                <li className="flex items-center">
                  <CheckCircle className="h-5 w-5 text-green-500 mr-3" />
                  <span className="text-slate-700">Temel Raporlama</span>
                </li>
                <li className="flex items-center">
                  <CheckCircle className="h-5 w-5 text-green-500 mr-3" />
                  <span className="text-slate-700">Mobil Uygulama</span>
                </li>
              </ul>

              <Link
                href="/register?plan=starter"
                className="w-full bg-slate-900 text-white py-3 rounded-lg text-center font-semibold hover:bg-slate-800 transition-colors block"
              >
                Başla
              </Link>
            </div>

            {/* Professional Plan */}
            <div className="bg-white p-8 rounded-xl border-2 border-blue-600 relative">
              <div className="absolute -top-3 left-1/2 transform -translate-x-1/2">
                <span className="bg-blue-600 text-white px-4 py-1 rounded-full text-sm font-semibold">
                  Popüler
                </span>
              </div>

              <h3 className="text-2xl font-bold text-slate-900 mb-2">Professional</h3>
              <p className="text-slate-600 mb-6">Büyüyen işletmeler için</p>

              <div className="mb-6">
                <span className="text-4xl font-bold text-slate-900">₺799</span>
                <span className="text-slate-600">/ay</span>
              </div>

              <ul className="space-y-3 mb-8">
                <li className="flex items-center">
                  <CheckCircle className="h-5 w-5 text-green-500 mr-3" />
                  <span className="text-slate-700">50 Makine</span>
                </li>
                <li className="flex items-center">
                  <CheckCircle className="h-5 w-5 text-green-500 mr-3" />
                  <span className="text-slate-700">5 Manager</span>
                </li>
                <li className="flex items-center">
                  <CheckCircle className="h-5 w-5 text-green-500 mr-3" />
                  <span className="text-slate-700">100 Operatör</span>
                </li>
                <li className="flex items-center">
                  <CheckCircle className="h-5 w-5 text-green-500 mr-3" />
                  <span className="text-slate-700">Gelişmiş Raporlama</span>
                </li>
                <li className="flex items-center">
                  <CheckCircle className="h-5 w-5 text-green-500 mr-3" />
                  <span className="text-slate-700">API Entegrasyonu</span>
                </li>
              </ul>

              <Link
                href="/register?plan=professional"
                className="w-full bg-blue-600 text-white py-3 rounded-lg text-center font-semibold hover:bg-blue-700 transition-colors block"
              >
                Başla
              </Link>
            </div>

            {/* Enterprise Plan */}
            <div className="bg-white p-8 rounded-xl border border-slate-200">
              <h3 className="text-2xl font-bold text-slate-900 mb-2">Enterprise</h3>
              <p className="text-slate-600 mb-6">Büyük kurumlar için</p>

              <div className="mb-6">
                <span className="text-4xl font-bold text-slate-900">Özel</span>
                <span className="text-slate-600"> fiyat</span>
              </div>

              <ul className="space-y-3 mb-8">
                <li className="flex items-center">
                  <CheckCircle className="h-5 w-5 text-green-500 mr-3" />
                  <span className="text-slate-700">Sınırsız Makine</span>
                </li>
                <li className="flex items-center">
                  <CheckCircle className="h-5 w-5 text-green-500 mr-3" />
                  <span className="text-slate-700">Sınırsız Manager</span>
                </li>
                <li className="flex items-center">
                  <CheckCircle className="h-5 w-5 text-green-500 mr-3" />
                  <span className="text-slate-700">Sınırsız Operatör</span>
                </li>
                <li className="flex items-center">
                  <CheckCircle className="h-5 w-5 text-green-500 mr-3" />
                  <span className="text-slate-700">Özel Özellikler</span>
                </li>
                <li className="flex items-center">
                  <CheckCircle className="h-5 w-5 text-green-500 mr-3" />
                  <span className="text-slate-700">24/7 Destek</span>
                </li>
              </ul>

              <Link
                href="/contact"
                className="w-full bg-slate-900 text-white py-3 rounded-lg text-center font-semibold hover:bg-slate-800 transition-colors block"
              >
                İletişime Geç
              </Link>
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 bg-blue-600">
        <div className="container mx-auto px-4 text-center">
          <h2 className="text-4xl font-bold text-white mb-4">
            Bugün Başlamaya Hazır mısınız?
          </h2>
          <p className="text-xl text-blue-100 mb-8 max-w-2xl mx-auto">
            İş güvenliğinizi artırın, operasyon verimliliğinizi maksimize edin.
          </p>

          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link
              href="/demo"
              className="bg-white text-blue-600 px-8 py-4 rounded-lg text-lg font-semibold hover:bg-blue-50 transition-colors"
            >
              Ücretsiz Demo Al
            </Link>

            <Link
              href="/register"
              className="border-2 border-white text-white px-8 py-4 rounded-lg text-lg font-semibold hover:bg-white hover:text-blue-600 transition-colors"
            >
              Hemen Kayıt Ol
            </Link>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-slate-900 text-white py-12">
        <div className="container mx-auto px-4">
          <div className="grid md:grid-cols-4 gap-8">
            <div>
              <div className="flex items-center space-x-2 mb-4">
                <Shield className="h-6 w-6" />
                <span className="text-xl font-bold">SmartOp</span>
              </div>
              <p className="text-slate-400">
                İş makineleri için dijital kontrol sistemi
              </p>
            </div>

            <div>
              <h4 className="text-lg font-semibold mb-4">Ürün</h4>
              <ul className="space-y-2 text-slate-400">
                <li><Link href="#features" className="hover:text-white transition-colors">Özellikler</Link></li>
                <li><Link href="#pricing" className="hover:text-white transition-colors">Fiyatlandırma</Link></li>
                <li><Link href="/demo" className="hover:text-white transition-colors">Demo</Link></li>
              </ul>
            </div>

            <div>
              <h4 className="text-lg font-semibold mb-4">Şirket</h4>
              <ul className="space-y-2 text-slate-400">
                <li><Link href="/about" className="hover:text-white transition-colors">Hakkımızda</Link></li>
                <li><Link href="/contact" className="hover:text-white transition-colors">İletişim</Link></li>
                <li><Link href="/blog" className="hover:text-white transition-colors">Blog</Link></li>
              </ul>
            </div>

            <div>
              <h4 className="text-lg font-semibold mb-4">Destek</h4>
              <ul className="space-y-2 text-slate-400">
                <li><Link href="/help" className="hover:text-white transition-colors">Yardım</Link></li>
                <li><Link href="/docs" className="hover:text-white transition-colors">Dökümanlar</Link></li>
                <li><Link href="/support" className="hover:text-white transition-colors">Teknik Destek</Link></li>
              </ul>
            </div>
          </div>

          <div className="border-t border-slate-800 mt-8 pt-8 text-center text-slate-400">
            <p>&copy; 2024 SmartOp. Tüm hakları saklıdır.</p>
          </div>
        </div>
      </footer>
    </div>
  );
}
