/// Utility functions untuk Nautica.
///
/// Helper functions (formatting, validasi, dll.).
class AppUtils {
  AppUtils._();

  /// Format angka ke format mata uang Rupiah (contoh: 1.500.000).
  static String formatCurrency(double value) {
    final parts = value.toStringAsFixed(0).split('');
    final buffer = StringBuffer();
    for (var i = 0; i < parts.length; i++) {
      if (i > 0 && (parts.length - i) % 3 == 0) buffer.write('.');
      buffer.write(parts[i]);
    }
    return 'Rp $buffer';
  }

  /// Validasi sederhana format email.
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(email);
  }
}
