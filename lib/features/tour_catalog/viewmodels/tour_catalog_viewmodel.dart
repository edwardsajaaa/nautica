import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/database/database_helper.dart';
import '../models/tour_package.dart';

/// ViewModel untuk fitur Tour Catalog.
/// Mengelola state daftar paket wisata tur (CRUD).
class TourCatalogViewModel extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<TourPackage> _packages = [];
  bool _isLoading = false;

  List<TourPackage> get packages => _packages;
  bool get isLoading => _isLoading;

  /// Memuat semua paket tur dari database.
  Future<void> loadPackages() async {
    _isLoading = true;
    notifyListeners();

    final rows = await _db.queryAll(AppConstants.tableTourPackages);
    _packages = rows.map((row) => TourPackage.fromMap(row)).toList();

    _isLoading = false;
    notifyListeners();
  }

  /// Menambah paket baru ke database.
  Future<void> addPackage(TourPackage pkg) async {
    await _db.insert(AppConstants.tableTourPackages, pkg.toMap());
    await loadPackages();
  }

  /// Meng-update paket di database.
  Future<void> updatePackage(TourPackage pkg) async {
    if (pkg.id == null) return;
    await _db.update(AppConstants.tableTourPackages, pkg.toMap(), pkg.id!);
    await loadPackages();
  }

  /// Menghapus paket dari database.
  Future<void> deletePackage(int id) async {
    await _db.delete(AppConstants.tableTourPackages, id);
    await loadPackages();
  }
}
