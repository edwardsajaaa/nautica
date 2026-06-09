import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:path/path.dart' as p;
import '../constants/app_constants.dart';

/// Singleton helper untuk mengelola koneksi database SQLite (FFI).
///
/// Menggunakan pola Singleton agar hanya ada satu instance [Database]
/// sepanjang lifecycle aplikasi.
class DatabaseHelper {
  // ── Singleton Pattern ──────────────────────────────────────────────
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() => instance;

  /// Referensi tunggal ke database yang sudah dibuka.
  Database? _database;

  /// Mengembalikan instance [Database]. Jika belum dibuka, akan
  /// menginisialisasi terlebih dahulu.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // ── Inisialisasi Database ──────────────────────────────────────────
  Future<Database> _initDatabase() async {
    // Gunakan databaseFactoryFfi karena ini aplikasi desktop (Windows).
    final dbFactory = databaseFactoryFfi;

    // Tentukan path database di folder default sqflite.
    final dbPath = await dbFactory.getDatabasesPath();
    final path = p.join(dbPath, AppConstants.dbName);

    return dbFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: AppConstants.dbVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );
  }

  // ── Pembuatan Tabel ────────────────────────────────────────────────
  /// Dipanggil saat database pertama kali dibuat.
  Future<void> _onCreate(Database db, int version) async {
    // Tabel users (autentikasi)
    await db.execute('''
      CREATE TABLE ${AppConstants.tableUsers} (
        id        INTEGER PRIMARY KEY AUTOINCREMENT,
        username  TEXT    NOT NULL UNIQUE,
        password  TEXT    NOT NULL,
        full_name TEXT    NOT NULL
      )
    ''');

    // Tabel jadwal kapal
    await db.execute('''
      CREATE TABLE ${AppConstants.tableSchedules} (
        id             INTEGER PRIMARY KEY AUTOINCREMENT,
        ship_name      TEXT    NOT NULL,
        route          TEXT    NOT NULL,
        departure_date TEXT    NOT NULL,
        departure_time TEXT    NOT NULL,
        total_seats    INTEGER NOT NULL,
        sold_seats     INTEGER NOT NULL DEFAULT 0,
        price          REAL    NOT NULL
      )
    ''');

    // Tabel manifest penumpang
    await db.execute('''
      CREATE TABLE ${AppConstants.tableManifest} (
        id                INTEGER PRIMARY KEY AUTOINCREMENT,
        schedule_id       INTEGER NOT NULL,
        passenger_name    TEXT    NOT NULL,
        passenger_nik     TEXT    NOT NULL,
        gender            TEXT    NOT NULL,
        birth_place       TEXT    NOT NULL,
        birth_date        TEXT    NOT NULL,
        phone_number      TEXT    NOT NULL,
        passenger_type    TEXT    NOT NULL,
        nationality       TEXT    NOT NULL,
        special_condition TEXT    NOT NULL,
        seat_number       TEXT    NOT NULL,
        final_price       REAL    NOT NULL,
        purchase_time     TEXT    NOT NULL,
        ticket_id         TEXT    NOT NULL UNIQUE
      )
    ''');

    // Insert Dummy Schedules
    await _insertDummySchedules(db);
  }

  Future<void> _insertDummySchedules(Database db) async {
    final now = DateTime.now();
    final today = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    
    await db.insert(AppConstants.tableSchedules, {
      'ship_name': 'KM Karya Indah',
      'route': 'Manado - Ternate',
      'departure_date': today,
      'departure_time': '14:00',
      'total_seats': 100, // 10 rows x 10 cols
      'sold_seats': 0,
      'price': 250000.0,
    });
    
    await db.insert(AppConstants.tableSchedules, {
      'ship_name': 'KM Marina Bahari',
      'route': 'Manado - Siau',
      'departure_date': today,
      'departure_time': '17:30',
      'total_seats': 100, // 10 rows x 10 cols
      'sold_seats': 0,
      'price': 150000.0,
    });
  }

  // ── Migrasi Database ───────────────────────────────────────────────
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 7) {
      // Drop old tables
      await db.execute('DROP TABLE IF EXISTS tour_packages');
      await db.execute('DROP TABLE IF EXISTS bookings');
      await db.execute('DROP TABLE IF EXISTS equipments');
      await db.execute('DROP TABLE IF EXISTS ${AppConstants.tableSchedules}');
      await db.execute('DROP TABLE IF EXISTS ${AppConstants.tableManifest}');
      
      // Create new tables (if users table doesn't exist, it will be handled. But we assume it exists)
      await db.execute('''
        CREATE TABLE IF NOT EXISTS ${AppConstants.tableSchedules} (
          id             INTEGER PRIMARY KEY AUTOINCREMENT,
          ship_name      TEXT    NOT NULL,
          route          TEXT    NOT NULL,
          departure_date TEXT    NOT NULL,
          departure_time TEXT    NOT NULL,
          total_seats    INTEGER NOT NULL,
          sold_seats     INTEGER NOT NULL DEFAULT 0,
          price          REAL    NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS ${AppConstants.tableManifest} (
          id                INTEGER PRIMARY KEY AUTOINCREMENT,
          schedule_id       INTEGER NOT NULL,
          passenger_name    TEXT    NOT NULL,
          passenger_nik     TEXT    NOT NULL,
          gender            TEXT    NOT NULL,
          birth_place       TEXT    NOT NULL,
          birth_date        TEXT    NOT NULL,
          phone_number      TEXT    NOT NULL,
          passenger_type    TEXT    NOT NULL,
          nationality       TEXT    NOT NULL,
          special_condition TEXT    NOT NULL,
          seat_number       TEXT    NOT NULL,
          final_price       REAL    NOT NULL,
          purchase_time     TEXT    NOT NULL,
          ticket_id         TEXT    NOT NULL UNIQUE
        )
      ''');

      await _insertDummySchedules(db);
    }
  }

  // ── Operasi CRUD Generik ───────────────────────────────────────────

  /// Menyisipkan data ke [table]. Mengembalikan id baris baru.
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return db.insert(table, data);
  }

  /// Mengambil semua baris dari [table].
  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await database;
    return db.query(table, orderBy: 'id DESC');
  }

  /// Meng-update baris di [table] berdasarkan [id].
  Future<int> update(String table, Map<String, dynamic> data, int id) async {
    final db = await database;
    return db.update(table, data, where: 'id = ?', whereArgs: [id]);
  }

  /// Menghapus baris dari [table] berdasarkan [id].
  Future<int> delete(String table, int id) async {
    final db = await database;
    return db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  /// Menghitung jumlah baris di [table].
  Future<int> count(String table) async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as cnt FROM $table');
    if (result.isNotEmpty) {
      return (result.first['cnt'] as int?) ?? 0;
    }
    return 0;
  }

  /// Menutup koneksi database.
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
