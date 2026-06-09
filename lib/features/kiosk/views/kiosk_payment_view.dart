import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../viewmodels/kiosk_viewmodel.dart';
import 'kiosk_ticket_view.dart';
import '../../../core/constants/app_theme.dart';

class KioskPaymentView extends StatefulWidget {
  const KioskPaymentView({super.key});

  @override
  State<KioskPaymentView> createState() => _KioskPaymentViewState();
}

class _KioskPaymentViewState extends State<KioskPaymentView> with SingleTickerProviderStateMixin {
  bool _isDataValidated = false;
  late AnimationController _animController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _animController, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _validateData() {
    setState(() => _isDataValidated = true);
    _animController.forward();
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
    if (schedule == null) return const Scaffold(body: Center(child: Text('Error')));

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 40, color: AppTheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Konfirmasi & Pembayaran',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Left: Receipt
              Container(
                width: 500,
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Rincian Pesanan', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 40),
                    _buildReceiptRow('Rute', schedule['route']),
                    const Divider(height: 32),
                    _buildReceiptRow('Jam', '${schedule['departure_time']} WITA'),
                    const Divider(height: 32),
                    _buildReceiptRow('Nomor Kursi', vm.selectedSeat ?? '-'),
                    const Divider(height: 32),
                    _buildReceiptRow('Nama Penumpang', vm.passengerName),
                    const Divider(height: 16),
                    _buildReceiptRow('NIK', vm.passengerNik),
                    const Divider(height: 16),
                    _buildReceiptRow('Jenis Penumpang', vm.passengerType),
                    const Divider(height: 16),
                    _buildReceiptRow('Jenis Kelamin', vm.passengerGender),
                    const Divider(height: 16),
                    _buildReceiptRow('Lahir', '${vm.passengerBirthPlace}, ${vm.passengerBirthDate.split('T').first}'),
                    const Divider(height: 16),
                    _buildReceiptRow('Telepon', vm.passengerPhone),
                    const SizedBox(height: 48),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight.withAlpha(50),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Bayar', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                          Text(
                            _formatCurrency(vm.finalPrice),
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.primary),
                          ),
                        ],
                      ),
                    ),
                    
                    if (!_isDataValidated) ...[
                      const SizedBox(height: 40),
                      const Center(
                        child: Text('Data Sudah Benar?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 60,
                              child: ElevatedButton(
                                onPressed: _validateData,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text('Benar', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: SizedBox(
                              height: 60,
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text('Cek Kembali', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              // Right: QRIS Payment
              SizeTransition(
                sizeFactor: CurvedAnimation(parent: _animController, curve: Curves.easeOutQuart),
                axis: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: Container(
                      width: 450,
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 20, offset: const Offset(0, 10)),
                        ],
                      ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Bayar dengan QRIS',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Scan kode QR di bawah ini menggunakan aplikasi e-Wallet atau Mobile Banking Anda.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade200, width: 2),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: QrImageView(
                        data: 'QRIS-SIMULATION-${DateTime.now().millisecondsSinceEpoch}',
                        version: QrVersions.auto,
                        size: 300.0,
                      ),
                    ),
                    const SizedBox(height: 48),
                    vm.isLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            height: 80,
                            child: ElevatedButton(
                              onPressed: () async {
                                final success = await vm.processPayment();
                                if (success && context.mounted) {
                                  Navigator.pushReplacement(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation, secondaryAnimation) => const KioskTicketView(),
                                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                        return FadeTransition(opacity: animation, child: child);
                                      },
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              child: const Text(
                                'Proses Pembayaran',
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
              ),
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 18, color: AppTheme.textSecondary)),
        Expanded(
          child: Text(
            value, 
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
