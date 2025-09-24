# SmartOp Deployment Rehberi

Bu dosya SmartOp sisteminin production ortamına güvenli şekilde deploy edilmesi için gerekli adımları içerir.

## 🔒 Güvenlik Kontrol Listesi

### 1. Environment Ayarları (.env)

Production için kritik ayarlar:

```bash
# Production Environment
APP_ENV=production
APP_DEBUG=false
APP_URL=https://yourdomain.com

# Strong App Key (php artisan key:generate ile oluşturun)
APP_KEY=base64:STRONG_RANDOM_KEY_HERE

# Database - Güçlü şifre kullanın
DB_HOST=your-production-db-host
DB_DATABASE=smartop_production
DB_USERNAME=smartop_user
DB_PASSWORD=very_strong_password_here

# Session Security
SESSION_DRIVER=database
SESSION_LIFETIME=120
SESSION_ENCRYPT=true
SESSION_HTTP_ONLY=true
SESSION_SAME_SITE=strict

# HTTPS Zorunlu
SESSION_SECURE_COOKIE=true

# Cache
CACHE_DRIVER=redis
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=your_redis_password
REDIS_PORT=6379

# Queue (Production için)
QUEUE_CONNECTION=database

# Mail Configuration
MAIL_MAILER=smtp
MAIL_HOST=your-smtp-host
MAIL_PORT=587
MAIL_USERNAME=your-email@domain.com
MAIL_PASSWORD=your-email-password
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=noreply@yourdomain.com
MAIL_FROM_NAME="SmartOp System"
```

### 2. Sunucu Gereksinimleri

#### Minimum Sistem Gereksinimleri:
- **PHP**: 8.1 veya üstü
- **Web Server**: Nginx/Apache
- **Database**: MySQL 8.0+ veya PostgreSQL 13+
- **Memory**: En az 512MB RAM
- **Storage**: En az 1GB disk alanı

#### Gerekli PHP Uzantıları:
```bash
php -m | grep -E "(openssl|pdo|mbstring|tokenizer|xml|ctype|json|bcmath|fileinfo|gd)"
```

### 3. Nginx Konfigürasyonu

`/etc/nginx/sites-available/smartop` dosyası:

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name yourdomain.com www.yourdomain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name yourdomain.com www.yourdomain.com;
    root /var/www/smartop/public;

    index index.php;

    # SSL Configuration
    ssl_certificate /path/to/your/certificate.crt;
    ssl_certificate_key /path/to/your/private.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    # Security Headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }

    # API Rate Limiting
    location /api/ {
        limit_req zone=api burst=10 nodelay;
        try_files $uri $uri/ /index.php?$query_string;
    }
}

# Rate Limiting Zone
http {
    limit_req_zone $binary_remote_addr zone=api:10m rate=60r/m;
}
```

### 4. Deployment Adımları

#### Adım 1: Projeyi Sunucuya Aktarın
```bash
# Git ile
git clone https://github.com/cagkantasci/laravel.git /var/www/smartop
cd /var/www/smartop

# Veya ZIP ile upload
scp smartop.zip user@server:/var/www/
ssh user@server "cd /var/www && unzip smartop.zip"
```

#### Adım 2: Dependencies Kurulumu
```bash
composer install --optimize-autoloader --no-dev
npm install --production
npm run build
```

#### Adım 3: Permissions Ayarları
```bash
sudo chown -R www-data:www-data /var/www/smartop
sudo chmod -R 755 /var/www/smartop
sudo chmod -R 775 /var/www/smartop/storage
sudo chmod -R 775 /var/www/smartop/bootstrap/cache
```

#### Adım 4: Environment ve Key
```bash
cp .env.example .env
# .env dosyasını production ayarları ile düzenleyin
php artisan key:generate
```

#### Adım 5: Database Setup
```bash
php artisan migrate --force
php artisan db:seed --force
```

#### Adım 6: Cache ve Optimization
```bash
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan event:cache
composer dump-autoload --optimize
```

### 5. Monitoring ve Bakım

#### Log Monitoring
```bash
# Laravel logs
tail -f /var/www/smartop/storage/logs/laravel.log

# Nginx logs  
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
```

#### Cron Jobs (Scheduler)
```bash
# /etc/crontab'e ekleyin
* * * * * www-data cd /var/www/smartop && php artisan schedule:run >> /dev/null 2>&1
```

#### Backup Script
```bash
#!/bin/bash
# /opt/smartop-backup.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups/smartop"
PROJECT_DIR="/var/www/smartop"

# Database backup
mysqldump -u DB_USER -p'DB_PASSWORD' smartop_production > $BACKUP_DIR/db_$DATE.sql

# File backup
tar -czf $BACKUP_DIR/files_$DATE.tar.gz $PROJECT_DIR

# Keep only last 7 days
find $BACKUP_DIR -name "*.sql" -mtime +7 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete
```

### 6. SSL Certificate (Let's Encrypt)

```bash
# Certbot kurulumu
sudo apt install certbot python3-certbot-nginx

# Certificate oluşturma
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com

# Auto-renewal test
sudo certbot renew --dry-run
```

### 7. Performance Optimizasyonu

#### PHP-FPM Settings (`/etc/php/8.1/fpm/pool.d/www.conf`)
```ini
pm = dynamic
pm.max_children = 20
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 15
pm.process_idle_timeout = 10s
pm.max_requests = 1000
```

#### MySQL Optimization (`/etc/mysql/mysql.conf.d/mysqld.cnf`)
```ini
innodb_buffer_pool_size = 256M
query_cache_size = 32M
max_connections = 200
```

## 🚀 Production Deployment Checklist

- [ ] .env dosyası production ayarları ile güncellendi
- [ ] APP_DEBUG=false ayarlandı
- [ ] Güçlü APP_KEY oluşturuldu
- [ ] Database bağlantısı test edildi
- [ ] SSL certificate kuruldu ve test edildi
- [ ] Nginx/Apache konfigürasyonu tamamlandı
- [ ] File permissions ayarlandı
- [ ] Cache ve optimization komutları çalıştırıldı
- [ ] Migration ve seed işlemleri tamamlandı
- [ ] API test sayfası üzerinden sistem testi yapıldı
- [ ] Log monitoring kuruldu
- [ ] Backup sistemi kuruldu
- [ ] Cron jobs ayarlandı

## 🆘 Troubleshooting

### Yaygın Sorunlar

**1. 500 Internal Server Error**
```bash
# Log kontrol
tail -f storage/logs/laravel.log
# Permissions kontrol
sudo chmod -R 775 storage bootstrap/cache
```

**2. Database Connection Error**
```bash
# .env ayarları kontrol
php artisan config:clear
# Database user yetkilerini kontrol
mysql -u username -p
```

**3. Route Cache Issues**
```bash
php artisan route:clear
php artisan config:clear
php artisan cache:clear
```

**4. Session Issues**
```bash
# Session driver kontrol (.env)
SESSION_DRIVER=database
# Session tablosunu kontrol
php artisan session:table
php artisan migrate
```

Bu rehber ile SmartOp sisteminizi güvenli şekilde production ortamına deploy edebilirsiniz.