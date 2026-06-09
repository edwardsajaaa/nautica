import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/constants/app_constants.dart';

class KioskViewModel extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> _schedules = [];
  List<Map<String, dynamic>> get schedules => _schedules;

  Map<String, dynamic>? _selectedSchedule;
  Map<String, dynamic>? get selectedSchedule => _selectedSchedule;

  List<String> _bookedSeats = [];
  List<String> get bookedSeats => _bookedSeats;

  String? _selectedSeat;
  String? get selectedSeat => _selectedSeat;

  String _passengerName = '';
  String get passengerName => _passengerName;

  String _passengerNik = '';
  String get passengerNik => _passengerNik;

  String? _ticketId;
  String? get ticketId => _ticketId;

  Future<void> fetchSchedules() async {
    _isLoading = true;
    notifyListeners();

    try {
      final allSchedules = await _dbHelper.queryAll(AppConstants.tableSchedules);
      // Hanya tampilkan yang belum penuh
      _schedules = allSchedules.where((s) => (s['sold_seats'] as int) < (s['total_seats'] as int)).toList();
    } catch (e) {
      debugPrint('Error fetching schedules: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectSchedule(Map<String, dynamic> schedule) {
    _selectedSchedule = schedule;
    _selectedSeat = null;
    notifyListeners();
    fetchBookedSeats(schedule['id'] as int);
  }

  Future<void> fetchBookedSeats(int scheduleId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        AppConstants.tableManifest,
        columns: ['seat_number'],
        where: 'schedule_id = ?',
        whereArgs: [scheduleId],
      );
      _bookedSeats = result.map((e) => e['seat_number'] as String).toList();
    } catch (e) {
      debugPrint('Error fetching booked seats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectSeat(String seat) {
    if (!_bookedSeats.contains(seat)) {
      _selectedSeat = seat; // Kiosk rule: limit to 1 seat only
      notifyListeners();
    }
  }

  void setPassengerData(String name, String nik) {
    _passengerName = name;
    _passengerNik = nik;
    notifyListeners();
  }

  Future<bool> processPayment() async {
    if (_selectedSchedule == null || _selectedSeat == null || _passengerNik.length != 16) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final scheduleId = _selectedSchedule!['id'] as int;
      final newTicketId = 'TCK-${DateTime.now().millisecondsSinceEpoch}';
      
      await _dbHelper.insert(AppConstants.tableManifest, {
        'schedule_id': scheduleId,
        'passenger_name': _passengerName,
        'passenger_nik': _passengerNik,
        'seat_number': _selectedSeat,
        'purchase_time': DateTime.now().toIso8601String(),
        'ticket_id': newTicketId,
      });

      final db = await _dbHelper.database;
      await db.rawUpdate(
        'UPDATE ${AppConstants.tableSchedules} SET sold_seats = sold_seats + 1 WHERE id = ?',
        [scheduleId],
      );

      _ticketId = newTicketId;
      return true;
    } catch (e) {
      debugPrint('Error processing payment: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetFlow() {
    _selectedSchedule = null;
    _selectedSeat = null;
    _passengerName = '';
    _passengerNik = '';
    _ticketId = null;
    _bookedSeats = [];
    notifyListeners();
  }
}
