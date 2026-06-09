import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/boarding_viewmodel.dart';
import '../../../core/constants/app_theme.dart';

class BoardingSimulationView extends StatefulWidget {
  const BoardingSimulationView({super.key});

  @override
  State<BoardingSimulationView> createState() => _BoardingSimulationViewState();
}

class _BoardingSimulationViewState extends State<BoardingSimulationView> {
  final _focusNode = FocusNode();
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _focusNode.requestFocus();
      context.read<BoardingViewModel>().clearResult();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onSubmitted(String value, BoardingViewModel vm) async {
    if (value.isNotEmpty) {
      await vm.scanTicket(value);
      _controller.clear();
      _focusNode.requestFocus(); // Kembalikan fokus ke input setelah scan
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BoardingViewModel>();

    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.qr_code_scanner,
              size: 100,
              color: Colors.white54,
            ),
            const SizedBox(height: 24),
            const Text(
              'SIMULASI GATE BOARDING',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 48),

            // Text Input Tersembunyi (digunakan scanner)
            SizedBox(
              width: 300,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Scan Barcode Tiket di Sini',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (val) => _onSubmitted(val, vm),
              ),
            ),

            const SizedBox(height: 48),

            if (vm.isLoading)
              const CircularProgressIndicator(color: Colors.white)
            else if (vm.errorMessage != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                decoration: BoxDecoration(
                  color: AppTheme.danger,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      vm.errorMessage!,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            else if (vm.scanResult != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withAlpha(100),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle_outline, size: 80, color: Colors.white),
                    const SizedBox(height: 24),
                    Text(
                      'PENUMPANG ${vm.scanResult!['seat_number']} (${vm.scanResult!['passenger_name']})',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'BOARDING SUKSES',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
