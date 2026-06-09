import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_theme.dart';
import '../viewmodels/management_viewmodel.dart';

class ShipManagementView extends StatefulWidget {
  const ShipManagementView({super.key});

  @override
  State<ShipManagementView> createState() => _ShipManagementViewState();
}

class _ShipManagementViewState extends State<ShipManagementView> {
  final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ManagementViewModel>().fetchSchedules());
  }

  void _showAddDialog() {
    final formKey = GlobalKey<FormState>();
    final shipNameCtrl = TextEditingController();
    final routeCtrl = TextEditingController();
    final dateCtrl = TextEditingController();
    final timeCtrl = TextEditingController();
    final seatsCtrl = TextEditingController();
    final priceCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Jadwal Kapal'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: shipNameCtrl,
                  decoration: const InputDecoration(labelText: 'Nama Kapal'),
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: routeCtrl,
                  decoration: const InputDecoration(labelText: 'Rute'),
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: dateCtrl,
                  decoration: const InputDecoration(labelText: 'Tanggal (YYYY-MM-DD)'),
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: timeCtrl,
                  decoration: const InputDecoration(labelText: 'Waktu (HH:MM)'),
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: seatsCtrl,
                  decoration: const InputDecoration(labelText: 'Total Kursi'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: priceCtrl,
                  decoration: const InputDecoration(labelText: 'Harga Tiket'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final vm = context.read<ManagementViewModel>();
                final success = await vm.addSchedule(
                  shipName: shipNameCtrl.text,
                  route: routeCtrl.text,
                  departureDate: dateCtrl.text,
                  departureTime: timeCtrl.text,
                  totalSeats: int.parse(seatsCtrl.text),
                  price: double.parse(priceCtrl.text),
                );

                if (success && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Jadwal berhasil ditambahkan')),
                  );
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Manajemen Kapal'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: FilledButton.icon(
              onPressed: _showAddDialog,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Tambah Jadwal'),
            ),
          ),
        ],
      ),
      body: Consumer<ManagementViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading && vm.schedules.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.schedules.isEmpty) {
            return const Center(child: Text('Belum ada jadwal kapal'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vm.schedules.length,
            itemBuilder: (context, index) {
              final schedule = vm.schedules[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppTheme.primaryLight,
                    child: Icon(Icons.directions_boat, color: AppTheme.primary),
                  ),
                  title: Text(
                    schedule['ship_name'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${schedule['route']} • ${schedule['departure_date']} ${schedule['departure_time']}\n'
                    'Kursi: ${schedule['sold_seats']}/${schedule['total_seats']} • ${_currencyFormat.format(schedule['price'])}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppTheme.danger),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Hapus Jadwal'),
                          content: Text('Yakin ingin menghapus jadwal ${schedule['ship_name']}?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Batal'),
                            ),
                            FilledButton(
                              style: FilledButton.styleFrom(backgroundColor: AppTheme.danger),
                              onPressed: () async {
                                final success = await vm.deleteSchedule(schedule['id'] as int);
                                if (success && mounted) {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Jadwal berhasil dihapus')),
                                  );
                                }
                              },
                              child: const Text('Hapus'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
