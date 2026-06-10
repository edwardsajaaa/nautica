import 'dart:io';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/constants/app_constants.dart';

class ManifestViewModel extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Map<String, dynamic>> _schedules = [];
  List<Map<String, dynamic>> get schedules => _schedules;

  Map<String, dynamic>? _selectedSchedule;
  Map<String, dynamic>? get selectedSchedule => _selectedSchedule;

  List<Map<String, dynamic>> _manifestData = [];
  List<Map<String, dynamic>> get manifestData => _manifestData;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchSchedules() async {
    _isLoading = true;
    notifyListeners();
    try {
      _schedules = await _dbHelper.queryAll(AppConstants.tableSchedules);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectSchedule(Map<String, dynamic>? schedule) async {
    _selectedSchedule = schedule;
    if (schedule != null) {
      final scheduleId = schedule['id'] as int;
      await _markScheduleAsRead(scheduleId);
      await fetchManifest(scheduleId);
    } else {
      _manifestData = [];
      notifyListeners();
    }
  }

  Future<void> _markScheduleAsRead(int scheduleId) async {
    try {
      final db = await _dbHelper.database;
      await db.rawUpdate('''
        UPDATE ${AppConstants.tableManifest}
        SET is_read = 1
        WHERE schedule_id = ? AND is_read = 0
      ''', [scheduleId]);
    } catch (e) {
      debugPrint('Error marking as read: $e');
    }
  }

  Future<void> fetchManifest(int scheduleId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final db = await _dbHelper.database;
      _manifestData = await db.query(
        AppConstants.tableManifest,
        where: 'schedule_id = ?',
        whereArgs: [scheduleId],
        orderBy: 'seat_number ASC',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> exportToCSV() async {
    if (_manifestData.isEmpty || _selectedSchedule == null) return null;
    _isLoading = true;
    notifyListeners();

    try {
      List<List<dynamic>> rows = [];
      rows.add(["No", "Ticket ID", "Passenger Name", "NIK", "Seat", "Time"]);
      for (int i = 0; i < _manifestData.length; i++) {
        final row = _manifestData[i];
        rows.add([
          i + 1,
          row['ticket_id'],
          row['passenger_name'],
          row['passenger_nik'],
          row['seat_number'],
          row['purchase_time'],
        ]);
      }
      String csvData = const ListToCsvConverter().convert(rows);
      
      final shipName = _selectedSchedule!['ship_name'].toString().replaceAll(' ', '_');
      final fileName = 'Manifest_${shipName}_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File(fileName);
      await file.writeAsString(csvData);
      
      return file.absolute.path;
    } catch (e) {
      debugPrint('Error export CSV: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
