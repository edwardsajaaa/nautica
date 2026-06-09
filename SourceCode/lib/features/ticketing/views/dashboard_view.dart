import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_theme.dart';
import '../viewmodels/ticketing_viewmodel.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
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
    Future.microtask(() {
      context.read<TicketingViewModel>().fetchSchedules();
      context.read<AuthViewModel>().fetchAllLokets();
    });
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
                onPressed: () {
                  context.read<TicketingViewModel>().fetchSchedules(isRefresh: true);
                  context.read<AuthViewModel>().fetchAllLokets();
                },
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
                child: Consumer<AuthViewModel>(
                  builder: (context, auth, _) => _buildSummaryCard(
                    title: 'Total Loket',
                    value: '${auth.lokets.length}',
                    icon: Icons.storefront,
                    color: Colors.blueGrey,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Total Kapal',
                  value: '${vm.totalShips}',
                  icon: Icons.directions_boat,
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
                'Daftar Loket Terdaftar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Content / Empty State
          Consumer<AuthViewModel>(
            builder: (context, authVm, _) {
              if (authVm.isLoading) {
                return const Expanded(child: Center(child: CircularProgressIndicator()));
              }
              if (authVm.lokets.isEmpty) {
                return Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 80, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          "Belum ada akun Loket (Customer) yang terdaftar.",
                          style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Expanded(
                child: ListView.builder(
                  itemCount: authVm.lokets.length,
                  itemBuilder: (context, index) {
                    final loket = authVm.lokets[index];
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
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.storefront, 
                                color: AppTheme.primary, 
                                size: 32
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    loket['full_name'] ?? 'Unknown Name',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.person, size: 16, color: AppTheme.textSecondary),
                                      const SizedBox(width: 4),
                                      Text(
                                        loket['username'] ?? '',
                                        style: const TextStyle(color: AppTheme.textSecondary),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            // Badge Active
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green.shade200),
                              ),
                              child: Text(
                                'Aktif',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
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
