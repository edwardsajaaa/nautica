import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/constants/app_constants.dart';

class BoardingViewModel extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Map<String, dynamic>? _scanResult;
  Map<String, dynamic>? get scanResult => _scanResult;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> scanTicket(String ticketId) async {
    _isLoading = true;
    _scanResult = null;
    _errorMessage = null;
    notifyListeners();

    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        AppConstants.tableManifest,
        where: 'ticket_id = ?',
        whereArgs: [ticketId.trim()],
      );

      if (result.isNotEmpty) {
        _scanResult = result.first;
      } else {
        _errorMessage = "Tiket Tidak Ditemukan!";
      }
    } catch (e) {
      _errorMessage = "Error scanning ticket: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void clearResult() {
    _scanResult = null;
    _errorMessage = null;
    notifyListeners();
  }
}
