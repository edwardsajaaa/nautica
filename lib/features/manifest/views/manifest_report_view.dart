import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_theme.dart';
import '../viewmodels/manifest_viewmodel.dart';

class ManifestReportView extends StatefulWidget {
  const ManifestReportView({super.key});

  @override
  State<ManifestReportView> createState() => _ManifestReportViewState();
}

class _ManifestReportViewState extends State<ManifestReportView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ManifestViewModel>().fetchSchedules());
  }

  void _exportCSV(ManifestViewModel vm) async {
    final path = await vm.exportToCSV();
    if (mounted) {
      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Laporan berhasil diekspor ke: $path'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengekspor laporan.'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ManifestViewModel>();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Laporan Manifest',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              ElevatedButton.icon(
                onPressed: vm.manifestData.isEmpty ? null : () => _exportCSV(vm),
                icon: const Icon(Icons.file_download),
                label: const Text('Export ke CSV'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Filter Schedule
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.divider),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Map<String, dynamic>>(
                isExpanded: true,
                hint: const Text('Pilih Jadwal Kapal'),
                value: vm.selectedSchedule,
                items: vm.schedules.map((s) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: s,
                    child: Text('${s['ship_name']} (${s['route']}) - ${s['departure_date']}'),
                  );
                }).toList(),
                onChanged: vm.selectSchedule,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          if (vm.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (vm.selectedSchedule == null)
            const Center(child: Text("Silakan pilih jadwal kapal di atas."))
          else if (vm.manifestData.isEmpty)
            const Center(child: Text("Belum ada penumpang pada jadwal ini."))
          else
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(AppTheme.primaryLight),
                      columns: const [
                        DataColumn(label: Text('No', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('ID Tiket', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Nama Penumpang', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('NIK', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Nomor Kursi', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Waktu Beli', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: vm.manifestData.asMap().entries.map((entry) {
                        final index = entry.key;
                        final row = entry.value;
                        return DataRow(
                          cells: [
                            DataCell(Text('${index + 1}')),
                            DataCell(Text(row['ticket_id'])),
                            DataCell(Text(row['passenger_name'])),
                            DataCell(Text(row['passenger_nik'])),
                            DataCell(Text(row['seat_number'])),
                            DataCell(Text(row['purchase_time'].toString().substring(0, 16))), // YYYY-MM-DDTHH:MM
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
