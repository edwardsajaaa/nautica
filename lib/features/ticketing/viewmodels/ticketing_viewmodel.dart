import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/constants/app_constants.dart';

class TicketingViewModel extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Map<String, dynamic>> _schedules = [];
  List<Map<String, dynamic>> get schedules => _schedules;

  Map<String, dynamic>? _selectedSchedule;
  Map<String, dynamic>? get selectedSchedule => _selectedSchedule;

  List<String> _bookedSeats = [];
  List<String> get bookedSeats => _bookedSeats;

  String? _selectedSeat;
  String? get selectedSeat => _selectedSeat;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchSchedules() async {
    _isLoading = true;
    notifyListeners();

    try {
      _schedules = await _dbHelper.queryAll(AppConstants.tableSchedules);
    } catch (e) {
      debugPrint('Error fetching schedules: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectSchedule(Map<String, dynamic> schedule) async {
    _selectedSchedule = schedule;
    _selectedSeat = null;
    await fetchBookedSeats(schedule['id'] as int);
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
      _selectedSeat = seat;
      notifyListeners();
    }
  }

  Future<String?> processTicket({
    required String passengerName,
    required String passengerNik,
  }) async {
    if (_selectedSchedule == null || _selectedSeat == null) return null;
    if (passengerNik.length != 16) return null; // Validation

    _isLoading = true;
    notifyListeners();

    try {
      final scheduleId = _selectedSchedule!['id'] as int;
      final ticketId = 'TCK-${DateTime.now().millisecondsSinceEpoch}';
      
      await _dbHelper.insert(AppConstants.tableManifest, {
        'schedule_id': scheduleId,
        'passenger_name': passengerName,
        'passenger_nik': passengerNik,
        'seat_number': _selectedSeat,
        'purchase_time': DateTime.now().toIso8601String(),
        'ticket_id': ticketId,
      });

      // Update sold seats
      final db = await _dbHelper.database;
      await db.rawUpdate(
        'UPDATE ${AppConstants.tableSchedules} SET sold_seats = sold_seats + 1 WHERE id = ?',
        [scheduleId],
      );

      // Refresh data
      await fetchBookedSeats(scheduleId);
      await fetchSchedules(); // to update sold seats in dashboard
      
      _selectedSeat = null;
      return ticketId;
    } catch (e) {
      debugPrint('Error processing ticket: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
