import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../viewmodels/kiosk_viewmodel.dart';
import '../../../core/constants/app_theme.dart';

class KioskTicketView extends StatefulWidget {
  const KioskTicketView({super.key});

  @override
  State<KioskTicketView> createState() => _KioskTicketViewState();
}

class _KioskTicketViewState extends State<KioskTicketView> {
  Timer? _timer;
  int _secondsLeft = 15;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        _timer?.cancel();
        _resetToWelcome();
      }
    });
  }

  void _resetToWelcome() {
    if (mounted) {
      context.read<KioskViewModel>().resetFlow();
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<KioskViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 120, color: Colors.green),
            const SizedBox(height: 24),
            const Text(
              'Pembayaran Berhasil!',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 16),
            const Text(
              'Silakan foto QR Code ini untuk ditunjukkan di Gerbang Keberangkatan',
              style: TextStyle(fontSize: 24, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 60),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.grey.shade200, width: 2),
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 40, offset: const Offset(0, 20)),
                ],
              ),
              child: Column(
                children: [
                  QrImageView(
                    data: vm.ticketId ?? 'UNKNOWN-TICKET',
                    version: QrVersions.auto,
                    size: 300.0,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    vm.ticketId ?? '-',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
            Text(
              'Layar akan kembali ke awal dalam $_secondsLeft detik',
              style: const TextStyle(fontSize: 20, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _resetToWelcome,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.grey.shade800,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Kembali Sekarang', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
