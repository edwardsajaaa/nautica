import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/kiosk_viewmodel.dart';
import 'kiosk_form_view.dart';
import '../../../core/constants/app_theme.dart';

class KioskSeatView extends StatelessWidget {
  const KioskSeatView({super.key});

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
      final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
      final dayName = days[date.weekday - 1];
      final monthName = months[date.month - 1];
      return '$dayName, ${date.day.toString().padLeft(2, '0')} $monthName ${date.year}';
    } catch(e) {
      return dateString;
    }
  }

  String _formatCurrency(double amount) {
    String res = amount.toStringAsFixed(0);
    res = res.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.');
    return 'Rp $res';
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<KioskViewModel>();
    final schedule = vm.selectedSchedule;
    if (schedule == null) return const Scaffold(body: Center(child: Text('Error: No schedule selected')));

    final totalSeats = schedule['total_seats'] as int;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 40, color: AppTheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pilih Tempat Duduk - ${schedule['ship_name']}',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
        centerTitle: true,
      ),
      body: Row(
        children: [
          // Left: Seat Grid
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey.shade50,
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegend(Colors.green, 'Kosong'),
                      const SizedBox(width: 32),
                      _buildLegend(Colors.grey, 'Terjual'),
                      const SizedBox(width: 32),
                      _buildLegend(Colors.blue, 'Pilihan Anda'),
                    ],
                  ),
                  const SizedBox(height: 48),
                  Expanded(
                    child: Center(
                      child: vm.isLoading
                          ? const CircularProgressIndicator()
                          : SingleChildScrollView(
                              padding: const EdgeInsets.only(bottom: 40),
                              child: Column(
                                children: List.generate((totalSeats / 10).ceil(), (rowIndex) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 24),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        // Block 1 (3 seats)
                                        _buildSeat(rowIndex, 0, totalSeats, vm),
                                        const SizedBox(width: 8),
                                        _buildSeat(rowIndex, 1, totalSeats, vm),
                                        const SizedBox(width: 8),
                                        _buildSeat(rowIndex, 2, totalSeats, vm),
                                        const SizedBox(width: 32), // Aisle
                                        
                                        // Block 2 (2 seats)
                                        _buildSeat(rowIndex, 3, totalSeats, vm),
                                        const SizedBox(width: 8),
                                        _buildSeat(rowIndex, 4, totalSeats, vm),
                                        const SizedBox(width: 64), // Main Center Aisle
                                        
                                        // Block 3 (2 seats)
                                        _buildSeat(rowIndex, 5, totalSeats, vm),
                                        const SizedBox(width: 8),
                                        _buildSeat(rowIndex, 6, totalSeats, vm),
                                        const SizedBox(width: 32), // Aisle
                                        
                                        // Block 4 (3 seats)
                                        _buildSeat(rowIndex, 7, totalSeats, vm),
                                        const SizedBox(width: 8),
                                        _buildSeat(rowIndex, 8, totalSeats, vm),
                                        const SizedBox(width: 8),
                                        _buildSeat(rowIndex, 9, totalSeats, vm),
                                      ],
                                    ),
                                  );
                                }),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Right: Summary & Action
          Container(
            width: 450,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(left: BorderSide(color: Colors.grey.shade200)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rincian Pilihan',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  
                  // Route Visual
                  Builder(
                    builder: (context) {
                      final parts = (schedule['route'] as String).split(' - ');
                      final origin = parts[0];
                      final destination = parts.length > 1 ? parts[1] : '';
                      return Row(
                        children: [
                          Text(origin, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.primary)),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                children: [
                                  Expanded(child: Container(height: 2, color: Colors.grey.shade300)),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8),
                                    child: Icon(Icons.directions_boat, color: AppTheme.primary, size: 24),
                                  ),
                                  Expanded(child: Container(height: 2, color: Colors.grey.shade300)),
                                ],
                              ),
                            ),
                          ),
                          Text(destination, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.primary)),
                        ],
                      );
                    }
                  ),
                  const SizedBox(height: 24),
                  
                  // Date and Duration
                  Row(
                    children: [
                      const Icon(Icons.calendar_month, color: AppTheme.textSecondary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${_formatDate(schedule['departure_date'])} — ${schedule['departure_time']} WITA',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, color: AppTheme.textSecondary, size: 20),
                      const SizedBox(width: 8),
                      const Text('± 4 jam perjalanan', style: TextStyle(fontSize: 16, color: AppTheme.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Facilities
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.chair, size: 16, color: Colors.grey.shade600), const SizedBox(width: 4), Text('Ekonomi', style: TextStyle(color: Colors.grey.shade600))]),
                      Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.ac_unit, size: 16, color: Colors.grey.shade600), const SizedBox(width: 4), Text('AC', style: TextStyle(color: Colors.grey.shade600))]),
                      Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.restaurant, size: 16, color: Colors.grey.shade600), const SizedBox(width: 4), Text('Kantin', style: TextStyle(color: Colors.grey.shade600))]),
                      Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.wc, size: 16, color: Colors.grey.shade600), const SizedBox(width: 4), Text('Toilet', style: TextStyle(color: Colors.grey.shade600))]),
                    ],
                  ),
                  const SizedBox(height: 40),
                  const Divider(),
                  const SizedBox(height: 24),

                  const Text('Kursi Terpilih:', style: TextStyle(fontSize: 16, color: AppTheme.textSecondary)),
                  const SizedBox(height: 8),
                  Text(
                    vm.selectedSeat ?? 'Belum memilih',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: vm.selectedSeat != null ? AppTheme.primary : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  const Text('Total Harga:', style: TextStyle(fontSize: 16, color: AppTheme.textSecondary)),
                  Text(
                    vm.selectedSeat != null ? _formatCurrency(vm.finalPrice) : 'Rp 0',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: vm.selectedSeat != null ? AppTheme.primary : Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 80,
                    child: ElevatedButton(
                      onPressed: vm.selectedSeat == null
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => const KioskFormView(),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    return SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(1.0, 0.0),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: child,
                                    );
                                  },
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text(
                        'Lanjut Isi Data',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
      ],
    );
  }

  Widget _buildSeat(int rowIndex, int colIndex, int totalSeats, KioskViewModel vm) {
    final seatIndex = rowIndex * 10 + colIndex;
    if (seatIndex >= totalSeats) return const SizedBox(width: 50, height: 50);

    final seatLabel = '${String.fromCharCode(65 + rowIndex)}${colIndex + 1}';
    final isBooked = vm.bookedSeats.contains(seatLabel);
    final isSelected = vm.selectedSeat == seatLabel;

    Color bgColor = Colors.green;
    if (isBooked) bgColor = Colors.grey;
    if (isSelected) bgColor = Colors.blue;

    return InkWell(
      onTap: isBooked ? null : () => vm.selectSeat(seatLabel),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: bgColor.withAlpha(100),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            seatLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
