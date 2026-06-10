import 'package:flutter/foundation.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/database/database_helper.dart';
import '../models/user.dart';

/// ViewModel untuk autentikasi (login / logout).
class AuthViewModel extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.username == 'admin';
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> _lokets = [];
  List<Map<String, dynamic>> get lokets => _lokets;

  /// Inisialisasi — buat akun admin default jika belum ada.
  Future<void> initialize() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(AppConstants.tableUsers);
    if (rows.isEmpty) {
      await db.insert(AppConstants.tableUsers, const User(
        username: 'admin',
        password: 'admin123',
        fullName: 'Administrator',
        isActive: 1,
      ).toMap());
    }
  }

  /// Mengambil daftar semua loket (semua user kecuali admin)
  Future<void> fetchAllLokets() async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await DatabaseHelper.instance.database;
      final results = await db.query(
        AppConstants.tableUsers,
        where: 'username != ?',
        whereArgs: ['admin'],
      );

      _lokets = results;
    } catch (e) {
      debugPrint('Error fetching lokets: $e');
      _lokets = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login dengan [username] dan [password].
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final db = await DatabaseHelper.instance.database;
      final results = await db.query(
        AppConstants.tableUsers,
        where: 'username = ? AND password = ?',
        whereArgs: [username, password],
      );

      if (results.isNotEmpty) {
        final user = User.fromMap(results.first);
        if (user.isActive == 0 && user.username != 'admin') {
          _errorMessage = 'Akun loket ini telah dinonaktifkan oleh Admin.';
          _isLoading = false;
          notifyListeners();
          return false;
        }
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Username atau password salah';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Register akun baru.
  Future<bool> register(
      String username, String password, String fullName, {String? location}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final db = await DatabaseHelper.instance.database;

      // Cek apakah username sudah ada
      final existing = await db.query(
        AppConstants.tableUsers,
        where: 'username = ?',
        whereArgs: [username],
      );
      if (existing.isNotEmpty) {
        _errorMessage = 'Username sudah digunakan';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await db.insert(
        AppConstants.tableUsers,
        User(
          username: username, 
          password: password, 
          fullName: fullName, 
          location: location,
        ).toMap(),
      );
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mendaftar: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout — reset state.
  void logout() {
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Toggle status aktif/nonaktif sebuah loket (hanya untuk Admin).
  Future<bool> toggleLoketStatus(int userId, int newStatus) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.update(
        AppConstants.tableUsers,
        {'is_active': newStatus},
        where: 'id = ?',
        whereArgs: [userId],
      );
      // Refresh list loket setelah update
      await fetchAllLokets();
      return true;
    } catch (e) {
      debugPrint('Error toggle status: $e');
      return false;
    }
  }

  /// Mengambil statistik pemesanan loket berdasarkan userId
  Future<List<Map<String, dynamic>>> fetchLoketStatistics(int userId) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.rawQuery('''
        SELECT DATE(purchase_time) as date, COUNT(*) as total_tickets
        FROM ${AppConstants.tableManifest}
        WHERE user_id = ?
        GROUP BY DATE(purchase_time)
        ORDER BY DATE(purchase_time) DESC
      ''', [userId]);
      return result;
    } catch (e) {
      debugPrint('Error fetching loket stats: $e');
      return [];
    }
  }
}
