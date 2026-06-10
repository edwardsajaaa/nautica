import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/constants/app_constants.dart';

class TicketingViewModel extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Map<String, dynamic>> _allSchedules = [];
  List<Map<String, dynamic>> _filteredSchedules = [];
  
  List<Map<String, dynamic>> get schedules => _filteredSchedules;

  Map<String, dynamic>? _selectedSchedule;
  Map<String, dynamic>? get selectedSchedule => _selectedSchedule;

  List<String> _bookedSeats = [];
  List<String> get bookedSeats => _bookedSeats;

  String? _selectedSeat;
  String? get selectedSeat => _selectedSeat;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // --- Metrics ---
  double _totalRevenue = 0;
  double get totalRevenue => _totalRevenue;

  int _totalShips = 0;
  int get totalShips => _totalShips;

  int _remainingSeats = 0;
  int get remainingSeats => _remainingSeats;

  // --- Filter ---
  String _filterStatus = 'Semua'; // Semua, Aktif, Penuh
  String get filterStatus => _filterStatus;

  // --- Notifications ---
  Map<int, int> _unreadCounts = {};
  Map<int, int> get unreadCounts => _unreadCounts;

  int _totalUnread = 0;
  int get totalUnread => _totalUnread;

  int _previousTotalUnread = 0;

  String? _newNotificationMessage;
  String? get newNotificationMessage => _newNotificationMessage;

  Timer? _refreshTimer;

  TicketingViewModel() {
    _startAutoRefresh();
  }

  void clearNotification() {
    if (_newNotificationMessage != null) {
      _newNotificationMessage = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      fetchSchedules(isRefresh: true);
    });
  }

  Future<void> fetchSchedules({bool isRefresh = false}) async {
    if (!isRefresh) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      _allSchedules = await _dbHelper.queryAll(AppConstants.tableSchedules);
      
      // Fetch unread counts
      final db = await _dbHelper.database;
      final unreadResult = await db.rawQuery('''
        SELECT schedule_id, COUNT(*) as cnt 
        FROM ${AppConstants.tableManifest} 
        WHERE is_read = 0 
        GROUP BY schedule_id
      ''');
      
      _unreadCounts.clear();
      int currentTotalUnread = 0;
      for (var row in unreadResult) {
        final sid = row['schedule_id'] as int;
        final count = row['cnt'] as int;
        _unreadCounts[sid] = count;
        currentTotalUnread += count;
      }

      _totalUnread = currentTotalUnread;

      // Trigger notification if there's a new ticket
      if (_totalUnread > _previousTotalUnread && isRefresh) {
        final diff = _totalUnread - _previousTotalUnread;
        _newNotificationMessage = 'Ada $diff pesanan tiket baru!';
      }
      _previousTotalUnread = _totalUnread;

      _calculateMetrics();
      applyFilter(_filterStatus);
    } catch (e) {
      debugPrint('Error fetching schedules: $e');
    } finally {
      if (!isRefresh) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  void _calculateMetrics() {
    _totalShips = _allSchedules.length;
    _totalRevenue = 0;
    _remainingSeats = 0;

    for (var schedule in _allSchedules) {
      final sold = schedule['sold_seats'] as int;
      final total = schedule['total_seats'] as int;
      final price = (schedule['price'] as num).toDouble();

      _remainingSeats += (total - sold);
      _totalRevenue += (sold * price);
    }
  }

  void applyFilter(String status) {
    _filterStatus = status;
    if (status == 'Aktif') {
      _filteredSchedules = _allSchedules.where((s) => (s['sold_seats'] as int) < (s['total_seats'] as int)).toList();
    } else if (status == 'Penuh') {
      _filteredSchedules = _allSchedules.where((s) => (s['sold_seats'] as int) == (s['total_seats'] as int)).toList();
    } else {
      _filteredSchedules = List.from(_allSchedules);
    }
    notifyListeners();
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
    required int userId,
    required String passengerName,
    required String passengerNik,
  }) async {
    if (_selectedSchedule == null || _selectedSeat == null) return null;
    if (passengerNik.length != 16) return null;

    _isLoading = true;
    notifyListeners();

    try {
      final scheduleId = _selectedSchedule!['id'] as int;
      final ticketId = 'TCK-${DateTime.now().millisecondsSinceEpoch}';
      
      await _dbHelper.insert(AppConstants.tableManifest, {
        'schedule_id': scheduleId,
        'passenger_name': passengerName,
        'passenger_nik': passengerNik,
        'gender': 'Laki-laki',
        'birth_place': '-',
        'birth_date': '-',
        'phone_number': '-',
        'passenger_type': 'Dewasa',
        'nationality': 'WNI',
        'special_condition': '-',
        'seat_number': _selectedSeat,
        'final_price': _selectedSchedule!['price'],
        'purchase_time': DateTime.now().toIso8601String(),
        'ticket_id': ticketId,
        'user_id': userId,
      });

      // Update sold seats
      final db = await _dbHelper.database;
      await db.rawUpdate(
        'UPDATE ${AppConstants.tableSchedules} SET sold_seats = sold_seats + 1 WHERE id = ?',
        [scheduleId],
      );

      // Refresh data
      await fetchBookedSeats(scheduleId);
      await fetchSchedules(); // to update dashboard metrics immediately
      
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
