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
  /// Membuat tiga tabel utama: tour_packages, bookings, equipments.
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

    // Tabel paket wisata tur
    await db.execute('''
      CREATE TABLE ${AppConstants.tableTourPackages} (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        title       TEXT    NOT NULL,
        description TEXT    NOT NULL,
        price       REAL    NOT NULL,
        image_path  TEXT
      )
    ''');

    // Tabel pemesanan (booking)
    await db.execute('''
      CREATE TABLE ${AppConstants.tableBookings} (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_name TEXT    NOT NULL,
        tour_date     TEXT    NOT NULL,
        total_price   REAL    NOT NULL,
        status        TEXT    NOT NULL DEFAULT 'pending'
      )
    ''');

    // Tabel peralatan selam (equipment)
    await db.execute('''
      CREATE TABLE ${AppConstants.tableEquipments} (
        id             INTEGER PRIMARY KEY AUTOINCREMENT,
        name           TEXT    NOT NULL,
        stock          INTEGER NOT NULL DEFAULT 0,
        price_per_item REAL    NOT NULL
      )
    ''');
  }

  // ── Migrasi Database ───────────────────────────────────────────────
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS ${AppConstants.tableUsers} (
          id        INTEGER PRIMARY KEY AUTOINCREMENT,
          username  TEXT    NOT NULL UNIQUE,
          password  TEXT    NOT NULL,
          full_name TEXT    NOT NULL
        )
      ''');
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
