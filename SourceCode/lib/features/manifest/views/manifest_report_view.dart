import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_theme.dart';
import '../viewmodels/manifest_viewmodel.dart';
import '../../ticketing/viewmodels/ticketing_viewmodel.dart';

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
          Consumer2<ManifestViewModel, TicketingViewModel>(
            builder: (context, vm, ticketingVm, _) {
              return DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.divider),
                  ),
                ),
                hint: const Text('Pilih Jadwal Kapal'),
                value: vm.selectedSchedule?['id'] as int?,
                items: vm.schedules.map((schedule) {
                  final sid = schedule['id'] as int;
                  final unreadCount = ticketingVm.unreadCounts[sid] ?? 0;
                  String label = '${schedule['ship_name']} (${schedule['route']}) - ${schedule['departure_date']}';
                  if (unreadCount > 0) {
                    label += ' ($unreadCount Baru!)';
                  }
                  return DropdownMenuItem<int>(
                    value: sid,
                    child: Text(
                      label,
                      style: TextStyle(
                        color: unreadCount > 0 ? AppTheme.danger : AppTheme.textPrimary,
                        fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (valId) async {
                  if (valId == null) return;
                  final selectedMap = vm.schedules.firstWhere((s) => s['id'] == valId);
                  await vm.selectSchedule(selectedMap);
                  // Refresh ticketing metrics to update the sidebar badge immediately
                  if (context.mounted) {
                    context.read<TicketingViewModel>().fetchSchedules(isRefresh: true);
                  }
                },
              );
            },
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
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    // Table Header
                    Container(
                      color: AppTheme.primaryLight,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Row(
                        children: const [
                          Expanded(flex: 1, child: Text('No', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary))),
                          Expanded(flex: 3, child: Text('ID Tiket', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary))),
                          Expanded(flex: 3, child: Text('Nama Penumpang', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary))),
                          Expanded(flex: 3, child: Text('NIK', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary))),
                          Expanded(flex: 2, child: Text('Nomor Kursi', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary))),
                          Expanded(flex: 3, child: Text('Waktu Beli', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary))),
                        ],
                      ),
                    ),
                    // Table Body
                    Expanded(
                      child: ListView.separated(
                        itemCount: vm.manifestData.length,
                        separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade100),
                        itemBuilder: (context, index) {
                          final row = vm.manifestData[index];
                          final purchaseTime = row['purchase_time']?.toString() ?? '';
                          final displayTime = purchaseTime.length >= 16 ? purchaseTime.substring(0, 16) : purchaseTime;
                          
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            child: Row(
                              children: [
                                Expanded(flex: 1, child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.w600))),
                                Expanded(flex: 3, child: Text(row['ticket_id']?.toString() ?? '', style: const TextStyle(fontFamily: 'monospace'))),
                                Expanded(flex: 3, child: Text(row['passenger_name']?.toString() ?? '')),
                                Expanded(flex: 3, child: Text(row['passenger_nik']?.toString() ?? '')),
                                Expanded(flex: 2, child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.amber.shade200),
                                  ),
                                  child: Text(
                                    row['seat_number']?.toString() ?? '', 
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                                    textAlign: TextAlign.center,
                                  ),
                                )),
                                const SizedBox(width: 16),
                                Expanded(flex: 3, child: Text(displayTime.replaceFirst('T', ' '))),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
