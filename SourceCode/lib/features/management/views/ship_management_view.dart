import 'dart:io';
import 'package:file_picker/file_picker.dart';
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
    String currentImagePath = 'assets/images/DSCF7155.jpeg';
    
    bool facEkonomi = true;
    bool facAc = true;
    bool facKantin = true;
    bool facToilet = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateBuilder) => AlertDialog(
          title: const Text('Tambah Jadwal Kapal'),
          content: Form(
            key: formKey,
            child: SizedBox(
              width: 800,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(controller: shipNameCtrl, decoration: const InputDecoration(labelText: 'Nama Kapal'), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                          const SizedBox(height: 12),
                          TextFormField(controller: routeCtrl, decoration: const InputDecoration(labelText: 'Rute'), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                          const SizedBox(height: 12),
                          TextFormField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'Tanggal (YYYY-MM-DD)'), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                          const SizedBox(height: 12),
                          TextFormField(controller: timeCtrl, decoration: const InputDecoration(labelText: 'Waktu (HH:MM)'), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                          const SizedBox(height: 12),
                          TextFormField(controller: seatsCtrl, decoration: const InputDecoration(labelText: 'Total Kursi'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                          const SizedBox(height: 12),
                          TextFormField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Harga Tiket'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    flex: 2,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Gambar Kapal:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Container(
                            height: 160,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: currentImagePath.startsWith('assets/')
                                ? Image.asset(currentImagePath, fit: BoxFit.cover)
                                : Image.file(File(currentImagePath), fit: BoxFit.cover),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final result = await FilePicker.pickFiles(type: FileType.image);
                                if (result != null && result.files.single.path != null) {
                                  setStateBuilder(() => currentImagePath = result.files.single.path!);
                                }
                              },
                              icon: const Icon(Icons.upload_file),
                              label: const Text('Pilih File Gambar'),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text('Fasilitas Kapal:', style: TextStyle(fontWeight: FontWeight.bold)),
                          SwitchListTile(title: const Text('Ekonomi'), value: facEkonomi, onChanged: (val) => setStateBuilder(() => facEkonomi = val), contentPadding: EdgeInsets.zero),
                          SwitchListTile(title: const Text('AC'), value: facAc, onChanged: (val) => setStateBuilder(() => facAc = val), contentPadding: EdgeInsets.zero),
                          SwitchListTile(title: const Text('Kantin'), value: facKantin, onChanged: (val) => setStateBuilder(() => facKantin = val), contentPadding: EdgeInsets.zero),
                          SwitchListTile(title: const Text('Toilet'), value: facToilet, onChanged: (val) => setStateBuilder(() => facToilet = val), contentPadding: EdgeInsets.zero),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            FilledButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final vm = context.read<ManagementViewModel>();
                  final success = await vm.addSchedule(
                    shipName: shipNameCtrl.text, route: routeCtrl.text, departureDate: dateCtrl.text, departureTime: timeCtrl.text,
                    totalSeats: int.parse(seatsCtrl.text), price: double.parse(priceCtrl.text), imagePath: currentImagePath,
                    facilityEkonomi: facEkonomi ? 1 : 0, facilityAc: facAc ? 1 : 0, facilityKantin: facKantin ? 1 : 0, facilityToilet: facToilet ? 1 : 0,
                  );
                  if (success && mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jadwal berhasil ditambahkan')));
                  }
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> schedule) {
    final formKey = GlobalKey<FormState>();
    final shipNameCtrl = TextEditingController(text: schedule['ship_name'] as String);
    final routeCtrl = TextEditingController(text: schedule['route'] as String);
    final dateCtrl = TextEditingController(text: schedule['departure_date'] as String);
    final timeCtrl = TextEditingController(text: schedule['departure_time'] as String);
    final seatsCtrl = TextEditingController(text: (schedule['total_seats'] as int).toString());
    final priceCtrl = TextEditingController(text: (schedule['price'] as num).toString());
    String currentImagePath = schedule['image_path'] as String? ?? 'assets/images/DSCF7155.jpeg';
    
    bool facEkonomi = (schedule['facility_ekonomi'] as int? ?? 0) == 1;
    bool facAc = (schedule['facility_ac'] as int? ?? 0) == 1;
    bool facKantin = (schedule['facility_kantin'] as int? ?? 0) == 1;
    bool facToilet = (schedule['facility_toilet'] as int? ?? 0) == 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateBuilder) => AlertDialog(
          title: const Text('Edit Jadwal Kapal'),
          content: Form(
            key: formKey,
            child: SizedBox(
              width: 800,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(controller: shipNameCtrl, decoration: const InputDecoration(labelText: 'Nama Kapal'), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                          const SizedBox(height: 12),
                          TextFormField(controller: routeCtrl, decoration: const InputDecoration(labelText: 'Rute'), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                          const SizedBox(height: 12),
                          TextFormField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'Tanggal (YYYY-MM-DD)'), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                          const SizedBox(height: 12),
                          TextFormField(controller: timeCtrl, decoration: const InputDecoration(labelText: 'Waktu (HH:MM)'), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                          const SizedBox(height: 12),
                          TextFormField(controller: seatsCtrl, decoration: const InputDecoration(labelText: 'Total Kursi'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                          const SizedBox(height: 12),
                          TextFormField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Harga Tiket'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    flex: 2,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Gambar Kapal:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Container(
                            height: 160,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: currentImagePath.startsWith('assets/')
                                ? Image.asset(currentImagePath, fit: BoxFit.cover)
                                : Image.file(File(currentImagePath), fit: BoxFit.cover),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final result = await FilePicker.pickFiles(type: FileType.image);
                                if (result != null && result.files.single.path != null) {
                                  setStateBuilder(() => currentImagePath = result.files.single.path!);
                                }
                              },
                              icon: const Icon(Icons.upload_file),
                              label: const Text('Pilih File Gambar'),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text('Fasilitas Kapal:', style: TextStyle(fontWeight: FontWeight.bold)),
                          SwitchListTile(title: const Text('Ekonomi'), value: facEkonomi, onChanged: (val) => setStateBuilder(() => facEkonomi = val), contentPadding: EdgeInsets.zero),
                          SwitchListTile(title: const Text('AC'), value: facAc, onChanged: (val) => setStateBuilder(() => facAc = val), contentPadding: EdgeInsets.zero),
                          SwitchListTile(title: const Text('Kantin'), value: facKantin, onChanged: (val) => setStateBuilder(() => facKantin = val), contentPadding: EdgeInsets.zero),
                          SwitchListTile(title: const Text('Toilet'), value: facToilet, onChanged: (val) => setStateBuilder(() => facToilet = val), contentPadding: EdgeInsets.zero),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            FilledButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final vm = context.read<ManagementViewModel>();
                  final success = await vm.updateSchedule(
                    id: schedule['id'] as int,
                    shipName: shipNameCtrl.text, route: routeCtrl.text, departureDate: dateCtrl.text, departureTime: timeCtrl.text,
                    totalSeats: int.parse(seatsCtrl.text), price: double.parse(priceCtrl.text), imagePath: currentImagePath,
                    facilityEkonomi: facEkonomi ? 1 : 0, facilityAc: facAc ? 1 : 0, facilityKantin: facKantin ? 1 : 0, facilityToilet: facToilet ? 1 : 0,
                  );
                  if (success && mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jadwal berhasil diperbarui')));
                  }
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
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
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => _showEditDialog(schedule),
                  child: Row(
                    children: [
                      // Thumbnail
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: ((schedule['image_path'] as String?) ?? 'assets/images/DSCF7155.jpeg').startsWith('assets/')
                            ? Image.asset(
                                schedule['image_path'] as String? ?? 'assets/images/DSCF7155.jpeg',
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                File(schedule['image_path'] as String),
                                fit: BoxFit.cover,
                              ),
                      ),
                      const SizedBox(width: 16),
                      // Details
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                schedule['ship_name'] as String,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${schedule['route']} • ${schedule['departure_date']} ${schedule['departure_time']}',
                                style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryLight.withAlpha(50),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Kursi: ${schedule['sold_seats']}/${schedule['total_seats']}',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _currencyFormat.format(schedule['price']),
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                                  ),
                                  const Spacer(),
                                  // Facilities
                                  if ((schedule['facility_ekonomi'] as int? ?? 0) == 1) const Padding(padding: EdgeInsets.only(right: 6), child: Icon(Icons.chair, size: 18, color: Colors.grey)),
                                  if ((schedule['facility_ac'] as int? ?? 0) == 1) const Padding(padding: EdgeInsets.only(right: 6), child: Icon(Icons.ac_unit, size: 18, color: Colors.grey)),
                                  if ((schedule['facility_kantin'] as int? ?? 0) == 1) const Padding(padding: EdgeInsets.only(right: 6), child: Icon(Icons.restaurant, size: 18, color: Colors.grey)),
                                  if ((schedule['facility_toilet'] as int? ?? 0) == 1) const Padding(padding: EdgeInsets.only(right: 6), child: Icon(Icons.wc, size: 18, color: Colors.grey)),
                                  const SizedBox(width: 16),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Actions
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: AppTheme.primary),
                            onPressed: () => _showEditDialog(schedule),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: AppTheme.danger),
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
                          const SizedBox(width: 8),
                        ],
                      ),
                    ],
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
