import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_theme.dart';
import '../viewmodels/ticketing_viewmodel.dart';
import 'ticketing_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<TicketingViewModel>().fetchSchedules());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TicketingViewModel>();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard & Jadwal Kapal',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          
          // Summary Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.confirmation_num, size: 48, color: Colors.white),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Tiket Terjual Hari Ini',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${vm.schedules.fold<int>(0, (prev, s) => prev + (s['sold_seats'] as int))} Tiket',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          const Text(
            'Jadwal Keberangkatan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          if (vm.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (vm.schedules.isEmpty)
            const Center(child: Text("Belum ada jadwal hari ini"))
          else
            Expanded(
              child: ListView.builder(
                itemCount: vm.schedules.length,
                itemBuilder: (context, index) {
                  final schedule = vm.schedules[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.directions_boat, color: AppTheme.primary, size: 32),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  schedule['ship_name'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  schedule['route'],
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.event, size: 16, color: AppTheme.textSecondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      schedule['departure_date'],
                                      style: const TextStyle(color: AppTheme.textSecondary),
                                    ),
                                    const SizedBox(width: 16),
                                    const Icon(Icons.event_seat, size: 16, color: AppTheme.textSecondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${schedule['sold_seats']}/${schedule['total_seats']} Terisi',
                                      style: const TextStyle(color: AppTheme.textSecondary),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              vm.selectSchedule(schedule);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const TicketingView(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.storefront),
                            label: const Text('Buka Loket'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
