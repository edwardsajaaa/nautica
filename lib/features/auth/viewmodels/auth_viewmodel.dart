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
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Inisialisasi — buat akun admin default jika belum ada.
  Future<void> initialize() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(AppConstants.tableUsers);
    if (rows.isEmpty) {
      await db.insert(AppConstants.tableUsers, const User(
        username: 'admin',
        password: 'admin123',
        fullName: 'Administrator',
      ).toMap());
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
        _currentUser = User.fromMap(results.first);
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
      String username, String password, String fullName) async {
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
        User(username: username, password: password, fullName: fullName)
            .toMap(),
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
}
