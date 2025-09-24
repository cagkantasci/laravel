import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/todo.dart';

class DatabaseHelper {
  static const _databaseName = "todo_tracker.db";
  static const _databaseVersion = 1;

  static const table = 'todos';

  static const columnId = 'id';
  static const columnTitle = 'title';
  static const columnDescription = 'description';
  static const columnCategory = 'category';
  static const columnPriority = 'priority';
  static const columnDueDate = 'due_date';
  static const columnIsCompleted = 'is_completed';
  static const columnCreatedAt = 'created_at';
  static const columnUpdatedAt = 'updated_at';

  static Database? _database;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnTitle TEXT NOT NULL,
        $columnDescription TEXT,
        $columnCategory TEXT NOT NULL,
        $columnPriority INTEGER NOT NULL DEFAULT 1,
        $columnDueDate TEXT,
        $columnIsCompleted INTEGER NOT NULL DEFAULT 0,
        $columnCreatedAt TEXT NOT NULL,
        $columnUpdatedAt TEXT NOT NULL
      )
    ''');

    // Insert sample data for Laravel project
    await _insertSampleData(db);
  }

  Future _insertSampleData(Database db) async {
    final now = DateTime.now().toIso8601String();

    // Laravel İş Makinesi Kontrol Sistemi - Tüm TODO Listesi
    final laravelProjectTodos = [
      // FAZ 1: TEMEL ALTYAPI (2-3 Hafta) - URGENT/HIGH Priority
      {
        columnTitle: 'Proje Kurulumu ve Temel Yapı',
        columnDescription:
            'Laravel projesi oluşturma, temel paketlerin kurulumu, veritabanı yapılandırması',
        columnCategory: 'Backend',
        columnPriority: Priority.urgent.index,
        columnDueDate: DateTime.now().add(Duration(days: 3)).toIso8601String(),
        columnIsCompleted: 0,
        columnCreatedAt: now,
        columnUpdatedAt: now,
      },
      {
        columnTitle: 'Veritabanı Tasarımı ve Migration\'lar',
        columnDescription:
            'Tüm tabloların oluşturulması: companies, users, machines, control_lists, approvals vb.',
        columnCategory: 'Database',
        columnPriority: Priority.urgent.index,
        columnDueDate: DateTime.now().add(Duration(days: 5)).toIso8601String(),
        columnIsCompleted: 0,
        columnCreatedAt: now,
        columnUpdatedAt: now,
      },
      {
        columnTitle: 'Authentication Sistemi',
        columnDescription:
            'Laravel Sanctum entegrasyonu, JWT token authentication, rol tabanlı yetkilendirme',
        columnCategory: 'Backend',
        columnPriority: Priority.urgent.index,
        columnDueDate: DateTime.now().add(Duration(days: 7)).toIso8601String(),
        columnIsCompleted: 0,
        columnCreatedAt: now,
        columnUpdatedAt: now,
      },
      {
        columnTitle: 'Rol ve Yetki Sistemi',
        columnDescription:
            'Spatie Permission paketi ile Admin, Manager, Operator rollerini ve yetkilerini tanımlama',
        columnCategory: 'Backend',
        columnPriority: Priority.high.index,
        columnDueDate: DateTime.now().add(Duration(days: 10)).toIso8601String(),
        columnIsCompleted: 0,
        columnCreatedAt: now,
        columnUpdatedAt: now,
      },

      // FAZ 2: CORE MODÜLLER (3-4 Hafta) - HIGH/MEDIUM Priority
      {
        columnTitle: 'Şirket Yönetimi Modülü',
        columnDescription:
            'Şirket CRUD işlemleri, şirket bilgileri yönetimi, multi-tenant yapı hazırlığı',
        columnCategory: 'Backend',
        columnPriority: Priority.high.index,
        columnDueDate: DateTime.now().add(Duration(days: 12)).toIso8601String(),
        columnIsCompleted: 0,
        columnCreatedAt: now,
        columnUpdatedAt: now,
      },
      {
        columnTitle: 'Makine Yönetimi Sistemi',
        columnDescription:
            'Makine havuzu, makine ekleme/düzenleme, makine-şirket eşleştirme işlemleri',
        columnCategory: 'Backend',
        columnPriority: Priority.high.index,
        columnDueDate: DateTime.now().add(Duration(days: 14)).toIso8601String(),
        columnIsCompleted: 0,
        columnCreatedAt: now,
        columnUpdatedAt: now,
      },
      {
        columnTitle: 'Kontrol Listesi Sistemi',
        columnDescription:
            'Dinamik kontrol listeleri, kontrol maddeleri, operatör kontrol doldurma arayüzü',
        columnCategory: 'Backend',
        columnPriority: Priority.high.index,
        columnDueDate: DateTime.now().add(Duration(days: 16)).toIso8601String(),
        columnIsCompleted: 0,
        columnCreatedAt: now,
        columnUpdatedAt: now,
      },
      {
        columnTitle: 'Onay Sistemi (Workflow)',
        columnDescription:
            'Manager onay/red işlemleri, onay geçmişi, notification sistemi temel yapısı',
        columnCategory: 'Backend',
        columnPriority: Priority.high.index,
        columnDueDate: DateTime.now().add(Duration(days: 18)).toIso8601String(),
        columnIsCompleted: 0,
        columnCreatedAt: now,
        columnUpdatedAt: now,
      },

      // FAZ 3: KULLANICI ARAYÜZÜ (2-3 Hafta) - MEDIUM Priority
      {
        columnTitle: 'Admin Dashboard',
        columnDescription:
            'Sistem geneli yönetim paneli, kullanıcı yönetimi, sistem metrikleri',
        columnCategory: 'Frontend',
        columnPriority: Priority.medium.index,
        columnDueDate: DateTime.now().add(Duration(days: 21)).toIso8601String(),
        columnIsCompleted: 0,
        columnCreatedAt: now,
        columnUpdatedAt: now,
      },
      {
        columnTitle: 'Manager Dashboard',
        columnDescription:
            'Şirket yönetim paneli, bekleyen onaylar, operatör performansı görüntüleme',
        columnCategory: 'Frontend',
        columnPriority: Priority.medium.index,
        columnDueDate: DateTime.now().add(Duration(days: 23)).toIso8601String(),
        columnIsCompleted: 0,
        columnCreatedAt: now,
        columnUpdatedAt: now,
      },
      {
        columnTitle: 'Operator Dashboard',
        columnDescription:
            'Operatör kontrol doldurma arayüzü, geçmiş kontroller, onay durumu takibi',
        columnCategory: 'Frontend',
        columnPriority: Priority.medium.index,
        columnDueDate: DateTime.now().add(Duration(days: 25)).toIso8601String(),
        columnIsCompleted: 0,
        columnCreatedAt: now,
        columnUpdatedAt: now,
      },
      {
        columnTitle: 'API Endpoints',
        columnDescription:
            'RESTful API tasarımı, mobile app için endpoint\'ler, API dokumentasyonu',
        columnCategory: 'Backend',
        columnPriority: Priority.medium.index,
        columnDueDate: DateTime.now().add(Duration(days: 27)).toIso8601String(),
        columnIsCompleted: 0,
        columnCreatedAt: now,
        columnUpdatedAt: now,
      },

      // FAZ 4: İŞ LOJİĞİ (2-3 Hafta) - MEDIUM/LOW Priority
      {
        columnTitle: 'PayTR Ödeme Entegrasyonu',
        columnDescription:
            'Ödeme sistemi, abonelik planları, fatura yönetimi, ödeme callback işlemleri',
        columnCategory: 'Backend',
        columnPriority: Priority.medium.index,
        columnDueDate: DateTime.now().add(Duration(days: 30)).toIso8601String(),
        columnIsCompleted: 0,
        columnCreatedAt: now,
        columnUpdatedAt: now,
      },
      {
        columnTitle: 'Bildirim Sistemi',
        columnDescription:
            'Email notifications, push notifications altyapısı, notification templates',
        columnCategory: 'Backend',
        columnPriority: Priority.medium.index,
        columnDueDate: DateTime.now().add(Duration(days: 32)).toIso8601String(),
        columnIsCompleted: 0,
        columnCreatedAt: now,
        columnUpdatedAt: now,
      },
      {
        columnTitle: 'Raporlama Modülü',
        columnDescription:
            'Temel raporlar, PDF export, Excel export, dashboard charts ve grafikler',
        columnCategory: 'Backend',
        columnPriority: Priority.medium.index,
        columnDueDate: DateTime.now().add(Duration(days: 35)).toIso8601String(),
        columnIsCompleted: 0,
        columnCreatedAt: now,
        columnUpdatedAt: now,
      },
      {
        columnTitle: 'Güvenlik ve Validasyon',
        columnDescription:
            'Input validation, CSRF protection, rate limiting, security headers',
        columnCategory: 'Backend',
        columnPriority: Priority.high.index,
        columnDueDate: DateTime.now().add(Duration(days: 37)).toIso8601String(),
        columnIsCompleted: 0,
        columnCreatedAt: now,
        columnUpdatedAt: now,
      },

      // FAZ 5: FRONTEND/MOBILE (4-6 Hafta) - LOW/MEDIUM Priority
      {
        columnTitle: 'Frontend (Web Dashboard)',
        columnDescription:
            'React/Next.js frontend uygulaması, responsive design, Tailwind CSS',
        columnCategory: 'Frontend',
        columnPriority: Priority.low.index,
        columnDueDate: DateTime.now().add(Duration(days: 45)).toIso8601String(),
        columnIsCompleted: 0,
        columnCreatedAt: now,
        columnUpdatedAt: now,
      },
      {
        columnTitle: 'Mobile App (Flutter)',
        columnDescription:
            'Flutter mobile app, offline support, kamera entegrasyonu, GPS tracking',
        columnCategory: 'Mobile',
        columnPriority: Priority.low.index,
        columnDueDate: DateTime.now().add(Duration(days: 50)).toIso8601String(),
        columnIsCompleted: 0,
        columnCreatedAt: now,
        columnUpdatedAt: now,
      },
      {
        columnTitle: 'Marketing Website',
        columnDescription:
            'Landing page, özellik sayfaları, fiyatlandırma, blog, demo request form',
        columnCategory: 'Frontend',
        columnPriority: Priority.low.index,
        columnDueDate: DateTime.now().add(Duration(days: 55)).toIso8601String(),
        columnIsCompleted: 0,
        columnCreatedAt: now,
        columnUpdatedAt: now,
      },
      {
        columnTitle: 'Testing ve Quality Assurance',
        columnDescription:
            'Unit testler, integration testler, performance testleri, security audit',
        columnCategory: 'Testing',
        columnPriority: Priority.medium.index,
        columnDueDate: DateTime.now().add(Duration(days: 60)).toIso8601String(),
        columnIsCompleted: 0,
        columnCreatedAt: now,
        columnUpdatedAt: now,
      },
    ];

    for (var todo in laravelProjectTodos) {
      await db.insert(table, todo);
    }
  }

  // CRUD Operations
  Future<int> insert(Todo todo) async {
    Database db = await instance.database;
    return await db.insert(table, todo.toMap());
  }

  Future<List<Todo>> queryAllTodos() async {
    Database db = await instance.database;
    final result = await db.query(table, orderBy: '$columnCreatedAt DESC');
    return result.map((map) => Todo.fromMap(map)).toList();
  }

  Future<List<Todo>> queryTodosByCategory(String category) async {
    Database db = await instance.database;
    final result = await db.query(
      table,
      where: '$columnCategory = ?',
      whereArgs: [category],
      orderBy: '$columnCreatedAt DESC',
    );
    return result.map((map) => Todo.fromMap(map)).toList();
  }

  Future<List<Todo>> queryCompletedTodos() async {
    Database db = await instance.database;
    final result = await db.query(
      table,
      where: '$columnIsCompleted = ?',
      whereArgs: [1],
      orderBy: '$columnUpdatedAt DESC',
    );
    return result.map((map) => Todo.fromMap(map)).toList();
  }

  Future<List<Todo>> queryPendingTodos() async {
    Database db = await instance.database;
    final result = await db.query(
      table,
      where: '$columnIsCompleted = ?',
      whereArgs: [0],
      orderBy: '$columnDueDate ASC',
    );
    return result.map((map) => Todo.fromMap(map)).toList();
  }

  Future<int> update(Todo todo) async {
    Database db = await instance.database;
    return await db.update(
      table,
      todo.toMap(),
      where: '$columnId = ?',
      whereArgs: [todo.id],
    );
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> toggleCompleted(int id) async {
    Database db = await instance.database;
    final todo = await db.query(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (todo.isNotEmpty) {
      final isCompleted = todo.first[columnIsCompleted] == 1;
      return await db.update(
        table,
        {
          columnIsCompleted: isCompleted ? 0 : 1,
          columnUpdatedAt: DateTime.now().toIso8601String(),
        },
        where: '$columnId = ?',
        whereArgs: [id],
      );
    }
    return 0;
  }

  Future<List<String>> getCategories() async {
    Database db = await instance.database;
    final result = await db.query(
      table,
      columns: [columnCategory],
      distinct: true,
      orderBy: columnCategory,
    );
    return result.map((map) => map[columnCategory] as String).toList();
  }

  // Database'i sıfırla ve yeni Laravel todo'larını ekle
  Future<void> resetDatabaseWithLaravelTodos() async {
    Database db = await instance.database;

    // Tüm mevcut todo'ları sil
    await db.delete(table);

    // Yeni Laravel todo'larını ekle
    await _insertSampleData(db);
  }
}
