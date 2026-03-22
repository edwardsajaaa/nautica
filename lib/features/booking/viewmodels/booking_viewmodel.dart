import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/database/database_helper.dart';
import '../models/booking.dart';

/// ViewModel untuk fitur Booking.
/// Mengelola state daftar pemesanan (CRUD + update status).
class BookingViewModel extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Booking> _bookings = [];
  bool _isLoading = false;

  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;

  /// Memuat semua booking dari database.
  Future<void> loadBookings() async {
    _isLoading = true;
    notifyListeners();

    final rows = await _db.queryAll(AppConstants.tableBookings);
    _bookings = rows.map((row) => Booking.fromMap(row)).toList();

    _isLoading = false;
    notifyListeners();
  }

  /// Membuat booking baru.
  Future<void> addBooking(Booking booking) async {
    await _db.insert(AppConstants.tableBookings, booking.toMap());
    await loadBookings();
  }

  /// Meng-update status booking (pending → confirmed / cancelled).
  Future<void> updateStatus(int id, String newStatus) async {
    await _db.update(AppConstants.tableBookings, {'status': newStatus}, id);
    await loadBookings();
  }

  /// Menghapus booking.
  Future<void> deleteBooking(int id) async {
    await _db.delete(AppConstants.tableBookings, id);
    await loadBookings();
  }
}
