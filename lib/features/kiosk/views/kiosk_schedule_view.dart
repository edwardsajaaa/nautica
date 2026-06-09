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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
      final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
      final dayName = days[date.weekday - 1];
      final monthName = months[date.month - 1];
      return '$dayName, ${date.day.toString().padLeft(2, '0')} $monthName ${date.year}';
    } catch(e) {
      return dateString;
    }
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
        child: Column(
          children: [
            // Sorting / Filter Bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => vm.setSearchQuery(value),
                    decoration: InputDecoration(
                      hintText: 'Cari pelabuhan tujuan...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: vm.sortFilter,
                      items: ['Keberangkatan Terawal', 'Harga Termurah'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          vm.setSortFilter(value);
                        }
                      },
                      icon: const Icon(Icons.filter_list, color: AppTheme.primary),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Schedule List
            Expanded(
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
                            childAspectRatio: 1.05, // Adjusted to fit more content
                            crossAxisSpacing: 32,
                            mainAxisSpacing: 32,
                          ),
                          itemCount: vm.schedules.length,
                          itemBuilder: (context, index) {
                            final schedule = vm.schedules[index];
                            final parts = (schedule['route'] as String).split(' - ');
                            final origin = parts[0];
                            final destination = parts.length > 1 ? parts[1] : '';
                            
                            final int totalSeats = schedule['total_seats'];
                            final int soldSeats = schedule['sold_seats'];
                            final int available = totalSeats - soldSeats;
                            
                            Color badgeColor;
                            String badgeText;
                            if (available <= 0) {
                              badgeColor = Colors.red;
                              badgeText = 'Habis Terjual';
                            } else if (available <= 10) {
                              badgeColor = Colors.orange;
                              badgeText = 'Hampir Penuh — $available sisa';
                            } else {
                              badgeColor = Colors.green;
                              badgeText = '$available Kursi Tersedia';
                            }

                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              color: Colors.white,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(24),
                                onTap: available <= 0 ? null : () {
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
                                    children: [
                                      // Top Header: Badge & Duration
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: badgeColor.withAlpha(30),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              badgeText,
                                              style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Icon(Icons.timer_outlined, color: Colors.grey.shade600, size: 20),
                                              const SizedBox(width: 8),
                                              Text('± 4 jam perjalanan', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                                            ],
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 32),
                                      
                                      // Route Visual
                                      Row(
                                        children: [
                                          Text(origin, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.primary)),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 16),
                                              child: Row(
                                                children: [
                                                  Expanded(child: Container(height: 2, color: Colors.grey.shade300)),
                                                  const Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 12),
                                                    child: Icon(Icons.directions_boat, color: AppTheme.primary, size: 32),
                                                  ),
                                                  Expanded(child: Container(height: 2, color: Colors.grey.shade300)),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Text(destination, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.primary)),
                                        ],
                                      ),
                                      const SizedBox(height: 24),
                                      
                                      // Departure Info
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                                            child: const Icon(Icons.calendar_month, color: AppTheme.primary),
                                          ),
                                          const SizedBox(width: 16),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${_formatDate(schedule['departure_date'])} — ${schedule['departure_time']} WITA',
                                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                schedule['ship_name'],
                                                style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 24),
                                      
                                      // Facilities
                                      Row(
                                        children: [
                                          Icon(Icons.chair, size: 20, color: Colors.grey.shade600),
                                          const SizedBox(width: 8), Text('Ekonomi', style: TextStyle(color: Colors.grey.shade600)),
                                          const SizedBox(width: 16),
                                          Icon(Icons.ac_unit, size: 20, color: Colors.grey.shade600),
                                          const SizedBox(width: 8), Text('AC', style: TextStyle(color: Colors.grey.shade600)),
                                          const SizedBox(width: 16),
                                          Icon(Icons.restaurant, size: 20, color: Colors.grey.shade600),
                                          const SizedBox(width: 8), Text('Kantin', style: TextStyle(color: Colors.grey.shade600)),
                                          const SizedBox(width: 16),
                                          Icon(Icons.wc, size: 20, color: Colors.grey.shade600),
                                          const SizedBox(width: 8), Text('Toilet', style: TextStyle(color: Colors.grey.shade600)),
                                        ],
                                      ),
                                      
                                      const SizedBox(height: 24),
                                      
                                      // Image
                                      Expanded(
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(color: AppTheme.primary, width: 2), // Matching the blue border from screenshot
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(14),
                                            child: Image.asset(
                                              'assets/images/DSCF7155.jpeg',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      
                                      const SizedBox(height: 24),
                                      
                                      // Bottom Action
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('Harga Tiket', style: TextStyle(fontSize: 16, color: AppTheme.textSecondary)),
                                              Text(
                                                _formatCurrency((schedule['price'] as num).toDouble()),
                                                style: TextStyle(
                                                  fontSize: 32,
                                                  fontWeight: FontWeight.bold,
                                                  color: available <= 0 ? Colors.grey : AppTheme.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                          ElevatedButton.icon(
                                            onPressed: available <= 0 ? null : () {
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
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: available <= 0 ? Colors.grey.shade300 : AppTheme.primary,
                                              foregroundColor: available <= 0 ? Colors.grey.shade600 : Colors.white,
                                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                              elevation: available <= 0 ? 0 : 4,
                                            ),
                                            icon: const Icon(Icons.arrow_forward),
                                            label: Text(
                                              available <= 0 ? 'Tiket Habis' : 'Pilih & Beli',
                                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
