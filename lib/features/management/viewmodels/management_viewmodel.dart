import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/constants/app_constants.dart';

class ManagementViewModel extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Map<String, dynamic>> _schedules = [];
  List<Map<String, dynamic>> get schedules => _schedules;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ManagementViewModel() {
    fetchSchedules();
  }

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

  Future<bool> addSchedule({
    required String shipName,
    required String route,
    required String departureDate,
    required String departureTime,
    required int totalSeats,
    required double price,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _dbHelper.insert(AppConstants.tableSchedules, {
        'ship_name': shipName,
        'route': route,
        'departure_date': departureDate,
        'departure_time': departureTime,
        'total_seats': totalSeats,
        'sold_seats': 0,
        'price': price,
      });
      await fetchSchedules();
      return true;
    } catch (e) {
      debugPrint('Error adding schedule: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteSchedule(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _dbHelper.delete(AppConstants.tableSchedules, id);
      await fetchSchedules();
      return true;
    } catch (e) {
      debugPrint('Error deleting schedule: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
