import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../viewmodels/kiosk_viewmodel.dart';
import '../../../core/constants/app_theme.dart';

class KioskTicketView extends StatelessWidget {
  const KioskTicketView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<KioskViewModel>();
    final schedule = vm.selectedSchedule;

    if (schedule == null) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final routeStr = schedule['route'] as String? ?? ' - ';
    final routeParts = routeStr.split('-');
    final origin = routeParts.isNotEmpty ? routeParts[0].trim() : '-';
    final destination = routeParts.length > 1 ? routeParts[1].trim() : '-';

    final shipName = schedule['ship_name'] as String? ?? '-';
    final date = schedule['departure_date'] as String? ?? '-';
    
    // Format date manually if it matches YYYY-MM-DD
    String displayDate = date;
    try {
      if (date.contains('-')) {
        final parts = date.split('-');
        if (parts.length == 3) {
          final year = parts[0];
          final monthStr = parts[1];
          final day = parts[2];
          final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
          final monthIdx = int.tryParse(monthStr) ?? 1;
          displayDate = '$day ${months[monthIdx - 1]} $year';
        }
      }
    } catch (_) {}

    final time = schedule['departure_time'] as String? ?? '-';
    final seat = vm.selectedSeat ?? '-';
    final passengerType = vm.passengerType;
    final passengerName = vm.passengerName;
    final passengerNik = vm.passengerNik;
    final maskedNik = passengerNik.length >= 16 
        ? '${passengerNik.substring(0, 4)} ${passengerNik.substring(4, 8)} **** **${passengerNik.substring(14)}'
        : passengerNik;

    final initial = passengerName.isNotEmpty 
        ? passengerName.substring(0, passengerName.length > 1 ? 2 : 1).toUpperCase() 
        : 'P';

    final price = vm.finalPrice;
    final priceStr = 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 80, color: AppTheme.success),
              const SizedBox(height: 16),
              const Text(
                'Pembayaran Berhasil!',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                'Silakan foto QR Code ini untuk ditunjukkan di Gerbang Keberangkatan',
                style: TextStyle(fontSize: 18, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 40),
              
              // Ticket Card
              Container(
                width: 850,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.divider, width: 2),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 40, offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  children: [
                    // Route Info Header
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(origin, style: const TextStyle(color: AppTheme.primary, fontSize: 24, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('Pelabuhan $origin', style: const TextStyle(color: AppTheme.primary, fontSize: 14)),
                            ],
                          ),
                          Column(
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.directions_boat, color: AppTheme.primary, size: 24),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, color: AppTheme.primary, size: 24),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text('Nautica e-Tiket', style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(destination, style: const TextStyle(color: AppTheme.primary, fontSize: 24, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('Pelabuhan $destination', style: const TextStyle(color: AppTheme.primary, fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Details 1
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('KAPAL', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(shipName, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('TANGGAL', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(displayDate, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('JAM BERANGKAT', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text('$time WITA', style: const TextStyle(color: AppTheme.primary, fontSize: 16, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const Divider(color: AppTheme.divider, height: 1, thickness: 1.5),

                    // Details 2
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('NOMOR KURSI', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(seat, style: const TextStyle(color: AppTheme.primary, fontSize: 24, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('KELAS', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text('Ekonomi $passengerType', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const Divider(color: AppTheme.divider, height: 1, thickness: 1.5),

                    // Passenger Info
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppTheme.primaryLight,
                            foregroundColor: AppTheme.primary,
                            radius: 24,
                            child: Text(initial, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(passengerName, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text('NIK: $maskedNik', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(passengerType, style: const TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
                    ),

                    // Dashed Divider
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final boxWidth = constraints.constrainWidth();
                          const dashWidth = 6.0;
                          const dashSpace = 4.0;
                          final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
                          return Flex(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            direction: Axis.horizontal,
                            children: List.generate(dashCount, (_) {
                              return const SizedBox(
                                width: dashWidth,
                                height: 1,
                                child: DecoratedBox(decoration: BoxDecoration(color: AppTheme.divider)),
                              );
                            }),
                          );
                        },
                      ),
                    ),

                    // QR Code Section
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.divider, width: 2),
                            ),
                            child: QrImageView(
                              data: vm.ticketId ?? 'UNKNOWN',
                              version: QrVersions.auto,
                              size: 120.0,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tiket ID:',
                                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.background,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    vm.ticketId ?? 'UNKNOWN',
                                    style: const TextStyle(color: AppTheme.textPrimary, fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppTheme.success, shape: BoxShape.circle)),
                                    const SizedBox(width: 8),
                                    const Text('Tiket Valid & Siap Digunakan', style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const Divider(color: AppTheme.divider, height: 1, thickness: 1.5),

                    // Footer Price
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total dibayar', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
                          Text(priceStr, style: const TextStyle(color: AppTheme.primary, fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Buttons
              SizedBox(
                width: 850,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.qr_code_scanner, size: 64, color: AppTheme.primary),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Download e-Tiket ke HP',
                                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Scan QR Code di bawah ini menggunakan kamera HP Anda\nuntuk mengunduh dan menyimpan e-Tiket.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
                                    ),
                                    const SizedBox(height: 32),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: AppTheme.divider, width: 2),
                                      ),
                                      child: QrImageView(
                                        data: 'https://nautica-app.com/ticket/download?id=${vm.ticketId}',
                                        version: QrVersions.auto,
                                        size: 240.0,
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    SizedBox(
                                      width: 240,
                                      child: ElevatedButton(
                                        onPressed: () => Navigator.pop(context),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.primary,
                                          padding: const EdgeInsets.symmetric(vertical: 20),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                          elevation: 0,
                                        ),
                                        child: const Text('Tutup', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.download, color: AppTheme.primary),
                        label: const Text('Download e-Tiket', style: TextStyle(color: AppTheme.primary, fontSize: 18, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.primary, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.read<KioskViewModel>().resetFlow();
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        icon: const Icon(Icons.home, color: Colors.white),
                        label: const Text('Kembali ke Beranda', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              RichText(
                text: const TextSpan(
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                  children: [
                    TextSpan(text: 'Tiket tersimpan otomatis ke dalam sistem. '),
                    TextSpan(text: 'Tidak ada auto-redirect.', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
