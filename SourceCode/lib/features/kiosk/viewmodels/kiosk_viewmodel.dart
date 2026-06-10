import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/constants/app_constants.dart';

class KioskViewModel extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  Timer? _refreshTimer;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> _allSchedules = [];
  
  List<Map<String, dynamic>> _schedules = [];
  List<Map<String, dynamic>> get schedules => _schedules;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _sortFilter = 'Keberangkatan Terawal';
  String get sortFilter => _sortFilter;

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

  String _passengerGender = 'Laki-laki';
  String get passengerGender => _passengerGender;

  String _passengerBirthPlace = '';
  String get passengerBirthPlace => _passengerBirthPlace;

  String _passengerBirthDate = '';
  String get passengerBirthDate => _passengerBirthDate;

  String _passengerPhone = '';
  String get passengerPhone => _passengerPhone;

  String _passengerType = 'Dewasa';
  String get passengerType => _passengerType;

  String _passengerNationality = 'WNI';
  String get passengerNationality => _passengerNationality;

  String _passengerSpecialCondition = 'Tidak Ada';
  String get passengerSpecialCondition => _passengerSpecialCondition;

  double _finalPrice = 0.0;
  double get finalPrice => _finalPrice;

  String? _ticketId;
  String? get ticketId => _ticketId;

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void setSortFilter(String filter) {
    _sortFilter = filter;
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = _allSchedules.where((s) {
      final route = (s['route'] as String).toLowerCase();
      final ship = (s['ship_name'] as String).toLowerCase();
      final q = _searchQuery.toLowerCase();
      return route.contains(q) || ship.contains(q);
    }).toList();

    if (_sortFilter == 'Keberangkatan Terawal') {
      filtered.sort((a, b) => (a['departure_time'] as String).compareTo(b['departure_time'] as String));
    } else if (_sortFilter == 'Harga Termurah') {
      filtered.sort((a, b) => (a['price'] as num).compareTo(b['price'] as num));
    }
    
    _schedules = filtered;
    notifyListeners();
  }

  Future<void> fetchSchedules({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final allSchedules = await _dbHelper.queryAll(AppConstants.tableSchedules);
      _allSchedules = allSchedules;
      _applyFilters();
    } catch (e) {
      debugPrint('Error fetching schedules: $e');
    } finally {
      if (!silent) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchSchedules(silent: true);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void selectSchedule(Map<String, dynamic> schedule) {
    _selectedSchedule = schedule;
    _selectedSeat = null;
    _calculateFinalPrice();
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

  void setPassengerData({
    required String name,
    required String nik,
    required String gender,
    required String birthPlace,
    required String birthDate,
    required String phone,
    required String type,
    required String nationality,
    required String condition,
  }) {
    _passengerName = name;
    _passengerNik = nik;
    _passengerGender = gender;
    _passengerBirthPlace = birthPlace;
    _passengerBirthDate = birthDate;
    _passengerPhone = phone;
    _passengerType = type;
    _passengerNationality = nationality;
    _passengerSpecialCondition = condition;
    
    _calculateFinalPrice();
    notifyListeners();
  }

  void _calculateFinalPrice() {
    if (_selectedSchedule == null) {
      _finalPrice = 0.0;
      return;
    }
    double basePrice = (_selectedSchedule!['price'] as num).toDouble();
    if (_passengerType == 'Anak (2-12 tahun)') {
      _finalPrice = basePrice * 0.5;
    } else if (_passengerType == 'Bayi (< 2 tahun)') {
      _finalPrice = basePrice * 0.1;
    } else {
      _finalPrice = basePrice;
    }
  }

  Future<bool> processPayment(int userId) async {
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
        'gender': _passengerGender,
        'birth_place': _passengerBirthPlace,
        'birth_date': _passengerBirthDate,
        'phone_number': _passengerPhone,
        'passenger_type': _passengerType,
        'nationality': _passengerNationality,
        'special_condition': _passengerSpecialCondition,
        'seat_number': _selectedSeat,
        'final_price': _finalPrice,
        'purchase_time': DateTime.now().toIso8601String(),
        'ticket_id': newTicketId,
        'user_id': userId,
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
    _passengerGender = 'Laki-laki';
    _passengerBirthPlace = '';
    _passengerBirthDate = '';
    _passengerPhone = '';
    _passengerType = 'Dewasa';
    _passengerNationality = 'WNI';
    _passengerSpecialCondition = 'Tidak Ada';
    _finalPrice = 0.0;
    _ticketId = null;
    _bookedSeats = [];
    notifyListeners();
  }
}
