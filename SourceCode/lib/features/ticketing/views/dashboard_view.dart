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
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          // Header
          SliverToBoxAdapter(
            child: Row(
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
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
          
          // 4 Summary Cards
          SliverToBoxAdapter(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = constraints.maxWidth < 800 
                    ? (constraints.maxWidth - 16) / 2 
                    : (constraints.maxWidth - 48) / 4;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: cardWidth,
                      child: _buildSummaryCard(
                        title: 'Total Tiket Terjual',
                        value: '${vm.schedules.fold<int>(0, (prev, s) => prev + (s['sold_seats'] as int))}',
                        icon: Icons.confirmation_num,
                        color: AppTheme.primary,
                        isPrimary: true,
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: Consumer<AuthViewModel>(
                        builder: (context, auth, _) => _buildSummaryCard(
                          title: 'Total Loket',
                          value: '${auth.lokets.length}',
                          icon: Icons.storefront,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: _buildSummaryCard(
                        title: 'Total Kapal',
                        value: '${vm.totalShips}',
                        icon: Icons.directions_boat,
                        color: Colors.teal,
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: _buildSummaryCard(
                        title: 'Pendapatan Hari Ini',
                        value: _formatCurrency(vm.totalRevenue),
                        icon: Icons.account_balance_wallet,
                        color: Colors.green,
                      ),
                    ),
                  ],
                );
              }
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
          
          // Filter Tabs & Title
          SliverToBoxAdapter(
            child: Row(
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
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          
          // Content / Empty State
          Consumer<AuthViewModel>(
            builder: (context, authVm, _) {
              if (authVm.isLoading) {
                return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
              }
              if (authVm.lokets.isEmpty) {
                return SliverFillRemaining(
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
              return SliverPadding(
                padding: const EdgeInsets.only(bottom: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final loket = authVm.lokets[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: InkWell(
                          onTap: () => _showLoketStatistics(context, loket),
                          borderRadius: BorderRadius.circular(16),
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
                                  if (loket['location'] != null && loket['location'].toString().isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on, size: 16, color: AppTheme.textSecondary),
                                        const SizedBox(width: 4),
                                        Text(
                                          loket['location'],
                                          style: const TextStyle(color: AppTheme.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            // Badge Active / Inactive
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: (loket['is_active'] == 1 || loket['is_active'] == null) ? Colors.green.shade50 : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: (loket['is_active'] == 1 || loket['is_active'] == null) ? Colors.green.shade200 : Colors.red.shade200),
                              ),
                              child: Text(
                                (loket['is_active'] == 1 || loket['is_active'] == null) ? 'Aktif' : 'Nonaktif',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: (loket['is_active'] == 1 || loket['is_active'] == null) ? Colors.green.shade700 : Colors.red.shade700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                              PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (value) async {
                                if (value == 'view_credentials') {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Kredensial Loket'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Username: ${loket['username']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 8),
                                          Text('Password: ${loket['password']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text('Tutup'),
                                        ),
                                      ],
                                    ),
                                  );
                                } else if (value == 'toggle') {
                                  final currentStatus = (loket['is_active'] == 1 || loket['is_active'] == null) ? 1 : 0;
                                  final newStatus = currentStatus == 1 ? 0 : 1;
                                  final userId = loket['id'] as int;
                                  final success = await context.read<AuthViewModel>().toggleLoketStatus(userId, newStatus);
                                  if (success && mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Status loket berhasil diubah')),
                                    );
                                  }
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'view_credentials',
                                  child: Row(
                                    children: [
                                      Icon(Icons.visibility_outlined, color: Colors.blueGrey),
                                      SizedBox(width: 8),
                                      Text('Lihat Password'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'toggle',
                                  child: Row(
                                    children: [
                                      Icon(
                                        (loket['is_active'] == 1 || loket['is_active'] == null) ? Icons.block : Icons.check_circle_outline,
                                        color: (loket['is_active'] == 1 || loket['is_active'] == null) ? Colors.red : Colors.green,
                                      ),
                                      const SizedBox(width: 8),
                                      Text((loket['is_active'] == 1 || loket['is_active'] == null) ? 'Nonaktifkan' : 'Aktifkan'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            ],
                          ),
                        ),
                        ),
                      );
                    },
                    childCount: authVm.lokets.length,
                  ),
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

  void _showLoketStatistics(BuildContext context, Map<String, dynamic> loket) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withAlpha(50),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.analytics, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Statistik: ${loket['full_name']}',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Username: ${loket['username']}',
                            style: const TextStyle(color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: context.read<AuthViewModel>().fetchLoketStatistics(loket['id'] as int),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final stats = snapshot.data ?? [];
                    if (stats.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bar_chart, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada tiket yang dijual oleh loket ini.',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(24),
                      itemCount: stats.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final stat = stats[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.calendar_month, color: Colors.green.shade700),
                          ),
                          title: Text(
                            stat['date'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${stat['total_tickets']} Tiket',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
