import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/app_theme.dart';
import '../viewmodels/ticketing_viewmodel.dart';

class TicketingView extends StatefulWidget {
  const TicketingView({super.key});

  @override
  State<TicketingView> createState() => _TicketingViewState();
}

class _TicketingViewState extends State<TicketingView> {
  final _nameController = TextEditingController();
  final _nikController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _nikController.dispose();
    super.dispose();
  }

  void _processTicket(TicketingViewModel vm) async {
    final name = _nameController.text.trim();
    final nik = _nikController.text.trim();

    if (name.isEmpty || nik.length != 16) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon isi nama dan NIK dengan benar (16 digit).'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    if (vm.selectedSeat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih kursi terlebih dahulu.'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    final ticketId = await vm.processTicket(passengerName: name, passengerNik: nik);

    if (ticketId != null && mounted) {
      _showETicketDialog(context, ticketId, name, nik, vm.selectedSchedule!['route']);
      _nameController.clear();
      _nikController.clear();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memproses tiket. Silakan coba lagi.'),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  void _showETicketDialog(BuildContext context, String ticketId, String name, String nik, String route) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/logo.png', width: 40, height: 40),
                    const SizedBox(width: 10),
                    const Text(
                      'NAUTICA e-Ticket',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                QrImageView(
                  data: ticketId,
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 24),
                Text(
                  'ID: $ticketId',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                _buildTicketRow('Nama', name),
                _buildTicketRow('NIK', nik),
                _buildTicketRow('Rute', route),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Selesai / Kembali ke Loket'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTicketRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TicketingViewModel>();
    final schedule = vm.selectedSchedule;

    if (schedule == null) {
      return const Scaffold(body: Center(child: Text('Tidak ada jadwal yang dipilih')));
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Loket: ${schedule['ship_name']} (${schedule['route']})',
          style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: Row(
        children: [
          // Kiri: Denah Kursi (70%)
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih Kursi',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Legenda
                  Row(
                    children: [
                      _buildLegend(Colors.green, 'Kosong'),
                      const SizedBox(width: 20),
                      _buildLegend(AppTheme.danger, 'Terisi'),
                      const SizedBox(width: 20),
                      _buildLegend(Colors.amber, 'Dipilih'),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Grid Kursi (5 baris x 4 kolom)
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.5,
                      ),
                      itemCount: schedule['total_seats'] as int,
                      itemBuilder: (context, index) {
                        // Labeling: A1, A2, B1, B2...
                        final rowLetter = String.fromCharCode(65 + (index ~/ 4));
                        final colNum = (index % 4) + 1;
                        final seatLabel = '$rowLetter$colNum';

                        final isBooked = vm.bookedSeats.contains(seatLabel);
                        final isSelected = vm.selectedSeat == seatLabel;

                        Color seatColor;
                        if (isBooked) {
                          seatColor = AppTheme.danger;
                        } else if (isSelected) {
                          seatColor = Colors.amber;
                        } else {
                          seatColor = Colors.green;
                        }

                        return InkWell(
                          onTap: isBooked ? null : () => vm.selectSeat(seatLabel),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: seatColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: seatColor.withAlpha(100),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              seatLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Kanan: Form Manifest (30%)
          Expanded(
            flex: 3,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  left: BorderSide(color: AppTheme.divider, width: 1),
                ),
              ),
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Data Penumpang',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Form Fields
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Penumpang',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _nikController,
                    decoration: InputDecoration(
                      labelText: 'NIK (16 Digit)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.credit_card),
                    ),
                    maxLength: 16,
                    keyboardType: TextInputType.number,
                  ),
                  
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Kursi Dipilih:'),
                        Text(
                          vm.selectedSeat ?? '-',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: vm.isLoading ? null : () => _processTicket(vm),
                      icon: vm.isLoading 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.print),
                      label: Text(vm.isLoading ? 'Memproses...' : 'Proses & Cetak e-Tiket'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
      ],
    );
  }
}
