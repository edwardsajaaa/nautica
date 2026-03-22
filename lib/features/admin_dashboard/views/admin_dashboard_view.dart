import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_theme.dart';
import '../models/equipment.dart';
import '../viewmodels/admin_dashboard_viewmodel.dart';

/// Halaman Admin Dashboard — tampilan light, warna solid.
class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<AdminDashboardViewModel>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Consumer<AdminDashboardViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──
                const Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Ringkasan data bisnis Anda',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Summary Cards ──
                Row(
                  children: [
                    _StatCard(
                      icon: Icons.sailing,
                      label: 'Paket Tur',
                      value: vm.totalPackages.toString(),
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 16),
                    _StatCard(
                      icon: Icons.event_available,
                      label: 'Booking',
                      value: vm.totalBookings.toString(),
                      color: AppTheme.info,
                    ),
                    const SizedBox(width: 16),
                    _StatCard(
                      icon: Icons.scuba_diving,
                      label: 'Alat Selam',
                      value: vm.totalEquipments.toString(),
                      color: AppTheme.success,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // ── Equipment Section ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Peralatan Selam',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    FilledButton.icon(
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Tambah'),
                      onPressed: () => _showEquipmentForm(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (vm.equipments.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 48,
                          color: AppTheme.textHint,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Belum ada peralatan',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          AppTheme.background,
                        ),
                        columns: const [
                          DataColumn(
                            label: Text(
                              'Nama',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Stok',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            numeric: true,
                          ),
                          DataColumn(
                            label: Text(
                              'Harga/Item',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            numeric: true,
                          ),
                          DataColumn(
                            label: Text(
                              'Aksi',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                        rows: vm.equipments.map((eq) {
                          final stockColor = eq.stock > 5
                              ? AppTheme.success
                              : eq.stock > 0
                                  ? AppTheme.warning
                                  : AppTheme.danger;
                          return DataRow(cells: [
                            DataCell(Text(eq.name)),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: stockColor.withAlpha(20),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${eq.stock}',
                                  style: TextStyle(
                                    color: stockColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(Text('Rp ${_fmt(eq.pricePerItem)}')),
                            DataCell(Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 18,
                                    color: AppTheme.primary,
                                  ),
                                  onPressed: () => _showEquipmentForm(
                                    context,
                                    equipment: eq,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                    color: AppTheme.danger,
                                  ),
                                  onPressed: () =>
                                      _confirmDelete(context, eq),
                                ),
                              ],
                            )),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEquipmentForm(BuildContext context, {Equipment? equipment}) {
    final nameCtrl = TextEditingController(text: equipment?.name ?? '');
    final stockCtrl = TextEditingController(
      text: equipment?.stock.toString() ?? '',
    );
    final priceCtrl = TextEditingController(
      text: equipment?.pricePerItem.toStringAsFixed(0) ?? '',
    );
    final isEditing = equipment != null;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEditing ? 'Edit Peralatan' : 'Tambah Peralatan'),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama Peralatan',
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: stockCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Stok',
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga per Item (Rp)',
                  prefixText: 'Rp ',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final stock = int.tryParse(stockCtrl.text.trim()) ?? 0;
              final price = double.tryParse(priceCtrl.text.trim()) ?? 0;
              if (name.isEmpty || price <= 0) return;
              final vm = context.read<AdminDashboardViewModel>();
              final eq = Equipment(
                id: equipment?.id,
                name: name,
                stock: stock,
                pricePerItem: price,
              );
              isEditing ? vm.updateEquipment(eq) : vm.addEquipment(eq);
              Navigator.pop(context);
            },
            child: Text(isEditing ? 'Simpan' : 'Tambah'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Equipment eq) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Peralatan?'),
        content: Text('Hapus "${eq.name}" dari inventaris?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () {
              context
                  .read<AdminDashboardViewModel>()
                  .deleteEquipment(eq.id!);
              Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _fmt(double v) {
    final p = v.toStringAsFixed(0).split('');
    final b = StringBuffer();
    for (var i = 0; i < p.length; i++) {
      if (i > 0 && (p.length - i) % 3 == 0) b.write('.');
      b.write(p[i]);
    }
    return b.toString();
  }
}

// ── Summary Card (solid color) ──
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
