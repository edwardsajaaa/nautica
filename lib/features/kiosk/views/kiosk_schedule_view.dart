import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/kiosk_viewmodel.dart';
import 'kiosk_seat_view.dart';
import '../../../core/constants/app_theme.dart';

class KioskScheduleView extends StatefulWidget {
  const KioskScheduleView({super.key});

  @override
  State<KioskScheduleView> createState() => _KioskScheduleViewState();
}

class _KioskScheduleViewState extends State<KioskScheduleView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<KioskViewModel>().fetchSchedules());
  }

  String _formatCurrency(double amount) {
    String res = amount.toStringAsFixed(0);
    res = res.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.');
    return 'Rp $res';
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<KioskViewModel>();

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
          'Pilih Rute & Jadwal Keberangkatan',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: vm.isLoading
            ? const Center(child: CircularProgressIndicator())
            : vm.schedules.isEmpty
                ? const Center(
                    child: Text(
                      'Maaf, tidak ada jadwal kapal yang tersedia saat ini.',
                      style: TextStyle(fontSize: 24, color: AppTheme.textSecondary),
                    ),
                  )
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 32,
                      mainAxisSpacing: 32,
                    ),
                    itemCount: vm.schedules.length,
                    itemBuilder: (context, index) {
                      final schedule = vm.schedules[index];
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () {
                            vm.selectSchedule(schedule);
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => const KioskSeatView(),
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
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      schedule['route'],
                                      style: const TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.w900,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        const Icon(Icons.directions_boat, size: 28, color: AppTheme.textSecondary),
                                        const SizedBox(width: 12),
                                        Text(
                                          schedule['ship_name'],
                                          style: const TextStyle(fontSize: 24, color: AppTheme.textSecondary),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time, size: 28, color: AppTheme.textSecondary),
                                        const SizedBox(width: 12),
                                        Text(
                                          '${schedule['departure_time']} WITA',
                                          style: const TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryLight.withAlpha(100),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Harga Tiket',
                                        style: TextStyle(fontSize: 20, color: AppTheme.primary),
                                      ),
                                      Text(
                                        _formatCurrency((schedule['price'] as num).toDouble()),
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
