import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/kiosk_viewmodel.dart';
import 'kiosk_form_view.dart';
import '../../../core/constants/app_theme.dart';

class KioskSeatView extends StatelessWidget {
  const KioskSeatView({super.key});

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
                          : Wrap(
                              spacing: 24,
                              runSpacing: 24,
                              alignment: WrapAlignment.center,
                              children: List.generate(totalSeats, (index) {
                                final row = index ~/ 4;
                                final col = index % 4;
                                final seatLabel = '${String.fromCharCode(65 + row)}${col + 1}';
                                
                                final isBooked = vm.bookedSeats.contains(seatLabel);
                                final isSelected = vm.selectedSeat == seatLabel;

                                Color bgColor = Colors.green;
                                if (isBooked) bgColor = Colors.grey;
                                if (isSelected) bgColor = Colors.blue;

                                return InkWell(
                                  onTap: isBooked ? null : () => vm.selectSeat(seatLabel),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    width: 80,
                                    height: 80,
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
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Right: Summary & Action
          Container(
            width: 400,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(left: BorderSide(color: Colors.grey.shade200)),
            ),
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rincian Pilihan',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                _buildSummaryRow('Rute', schedule['route']),
                const SizedBox(height: 16),
                _buildSummaryRow('Jam Berangkat', '${schedule['departure_time']} WITA'),
                const SizedBox(height: 48),
                const Text('Kursi Terpilih:', style: TextStyle(fontSize: 18, color: AppTheme.textSecondary)),
                const SizedBox(height: 8),
                Text(
                  vm.selectedSeat ?? 'Belum memilih kursi',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: vm.selectedSeat != null ? AppTheme.primary : Colors.grey,
                  ),
                ),
                const Spacer(),
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
}
