import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/database/database_helper.dart';
import '../models/equipment.dart';

/// ViewModel untuk fitur Admin Dashboard.
/// Mengelola state dashboard summary dan CRUD peralatan selam.
class AdminDashboardViewModel extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Equipment> _equipments = [];
  bool _isLoading = false;
  int _totalPackages = 0;
  int _totalBookings = 0;
  int _totalEquipments = 0;

  List<Equipment> get equipments => _equipments;
  bool get isLoading => _isLoading;
  int get totalPackages => _totalPackages;
  int get totalBookings => _totalBookings;
  int get totalEquipments => _totalEquipments;

  /// Memuat data ringkasan dashboard dan daftar equipment.
  Future<void> loadDashboard() async {
    _isLoading = true;
    notifyListeners();

    // Hitung total dari setiap tabel
    _totalPackages = await _db.count(AppConstants.tableTourPackages);
    _totalBookings = await _db.count(AppConstants.tableBookings);
    _totalEquipments = await _db.count(AppConstants.tableEquipments);

    // Ambil semua equipment
    final rows = await _db.queryAll(AppConstants.tableEquipments);
    _equipments = rows.map((row) => Equipment.fromMap(row)).toList();

    _isLoading = false;
    notifyListeners();
  }

  /// Menambah peralatan baru.
  Future<void> addEquipment(Equipment eq) async {
    await _db.insert(AppConstants.tableEquipments, eq.toMap());
    await loadDashboard();
  }

  /// Meng-update peralatan.
  Future<void> updateEquipment(Equipment eq) async {
    if (eq.id == null) return;
    await _db.update(AppConstants.tableEquipments, eq.toMap(), eq.id!);
    await loadDashboard();
  }

  /// Menghapus peralatan.
  Future<void> deleteEquipment(int id) async {
    await _db.delete(AppConstants.tableEquipments, id);
    await loadDashboard();
  }
}
