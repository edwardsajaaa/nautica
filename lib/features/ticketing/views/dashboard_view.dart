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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return '${days[now.weekday - 1]}, ${now.day.toString().padLeft(2, '0')} ${months[now.month - 1]} ${now.year}';
  }

  String _formatCurrency(double amount) {
    String res = amount.toStringAsFixed(0);
    res = res.replaceAllMapped(RegExp(r'\\B(?=(\\d{3})+(?!\\d))'), (match) => '.');
    return 'Rp $res';
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TicketingViewModel>();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_getGreeting()}, Administrator',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getFormattedDate(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              // Optional: Add some action buttons or refresh button here
              IconButton(
                icon: const Icon(Icons.refresh, color: AppTheme.primary),
                tooltip: 'Refresh Data',
                onPressed: () => vm.fetchSchedules(isRefresh: true),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // 4 Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Total Tiket Terjual',
                  value: '${vm.schedules.fold<int>(0, (prev, s) => prev + (s['sold_seats'] as int))}',
                  icon: Icons.confirmation_num,
                  color: AppTheme.primary,
                  isPrimary: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Total Kapal',
                  value: '${vm.totalShips}',
                  icon: Icons.directions_boat,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Kursi Tersisa',
                  value: '${vm.remainingSeats}',
                  icon: Icons.event_seat,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Pendapatan Hari Ini',
                  value: _formatCurrency(vm.totalRevenue),
                  icon: Icons.account_balance_wallet,
                  color: Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),
          
          // Filter Tabs & Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Jadwal Keberangkatan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Semua', label: Text('Semua')),
                  ButtonSegment(value: 'Aktif', label: Text('Aktif')),
                  ButtonSegment(value: 'Penuh', label: Text('Penuh')),
                ],
                selected: {vm.filterStatus},
                onSelectionChanged: (Set<String> newSelection) {
                  vm.applyFilter(newSelection.first);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Content / Empty State
          if (vm.isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (vm.schedules.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_busy, size: 80, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      "Belum ada jadwal keberangkatan hari ini.",
                      style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: vm.schedules.length,
                itemBuilder: (context, index) {
                  final schedule = vm.schedules[index];
                  final sold = schedule['sold_seats'] as int;
                  final total = schedule['total_seats'] as int;
                  final isFull = sold == total;
                  final isActive = sold > 0 && !isFull;
                  final progress = total > 0 ? (sold / total) : 0.0;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          // Ship Icon Container
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isFull ? Colors.grey.shade100 : AppTheme.primaryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.directions_boat, 
                              color: isFull ? Colors.grey.shade400 : AppTheme.primary, 
                              size: 32
                            ),
                          ),
                          const SizedBox(width: 20),
                          
                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      schedule['ship_name'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Status Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isFull ? Colors.red.shade50 : Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: isFull ? Colors.red.shade200 : Colors.green.shade200,
                                        ),
                                      ),
                                      child: Text(
                                        isFull ? 'Penuh' : 'Loket Buka',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isFull ? Colors.red.shade700 : Colors.green.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.map, size: 16, color: AppTheme.textSecondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      schedule['route'],
                                      style: const TextStyle(color: AppTheme.textSecondary),
                                    ),
                                    const SizedBox(width: 16),
                                    const Icon(Icons.access_time, size: 16, color: AppTheme.textSecondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${schedule['departure_time']} WITA',
                                      style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                
                                // Progress Bar
                                Row(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: progress,
                                          minHeight: 8,
                                          backgroundColor: Colors.grey.shade200,
                                          color: isFull 
                                              ? AppTheme.danger 
                                              : (progress > 0.8 ? Colors.amber : AppTheme.primary),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '$sold/$total Terisi',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isFull ? AppTheme.danger : AppTheme.textSecondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          
                          // Action Button
                          SizedBox(
                            width: 160,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: isFull ? null : () {
                                vm.selectSchedule(schedule);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const TicketingView(),
                                  ),
                                );
                              },
                              icon: Icon(isFull ? Icons.block : (isActive ? Icons.settings : Icons.storefront)),
                              label: Text(
                                isFull ? 'Penuh' : (isActive ? 'Kelola Loket' : 'Buka Loket')
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isActive ? Colors.green.shade600 : AppTheme.primary,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.grey.shade300,
                                disabledForegroundColor: Colors.grey.shade500,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
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

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool isPrimary = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isPrimary ? color : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isPrimary ? null : Border.all(color: Colors.grey.shade200),
        boxShadow: isPrimary
            ? [BoxShadow(color: color.withAlpha(100), blurRadius: 10, offset: const Offset(0, 4))]
            : [BoxShadow(color: Colors.grey.withAlpha(20), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isPrimary ? Colors.white.withAlpha(50) : color.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 32, color: isPrimary ? Colors.white : color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: isPrimary ? Colors.white70 : AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isPrimary ? Colors.white : AppTheme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
