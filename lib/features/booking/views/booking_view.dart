import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_theme.dart';
import '../models/booking.dart';
import '../viewmodels/booking_viewmodel.dart';

/// Halaman Booking — desain terinspirasi dari traveloka/tiket.com style.
class BookingView extends StatefulWidget {
  const BookingView({super.key});

  @override
  State<BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends State<BookingView> {
  int _tripType = 0; // 0=Tour, 1=Diving, 2=Boat

  final _originCtrl = TextEditingController(text: 'Fleksibel');
  final _destCtrl = TextEditingController(text: 'Fleksibel');
  DateTime _departDate = DateTime.now().add(const Duration(days: 1));
  DateTime? _returnDate = DateTime.now().add(const Duration(days: 3));
  int _passengers = 1;
  // tourClass removed — class not shown in horizontal bar

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<BookingViewModel>().loadBookings();
    });
  }

  @override
  void dispose() {
    _originCtrl.dispose();
    _destCtrl.dispose();
    super.dispose();
  }

  String _fmt(DateTime dt) =>
      '${dt.day} ${_monthName(dt.month)} ${dt.year}';

  String _monthName(int m) => const [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ][m];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          _buildHeroSection(),
          Expanded(child: _buildBookingList()),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Hero Section
  // ─────────────────────────────────────────────────────────────────
  Widget _buildHeroSection() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ── Background image + overlay ──
        SizedBox(
          height: 320,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/booking_hero.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: const Color(0xFF3A7BD5)),
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xAA1a2a4a), Color(0xCC0d1b2e)],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Content layer ──
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top nav
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
                child: Row(
                  children: [
                    _NavTab(label: 'Packages', selected: false),
                    const SizedBox(width: 24),
                    _NavTab(label: 'Tour Schedule', selected: false),
                    const SizedBox(width: 24),
                    _NavTab(label: 'Manage Booking', selected: true),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: () => _showForm(context),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('New Booking'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white70),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ),

              // Headline
              const Padding(
                padding: EdgeInsets.fromLTRB(32, 18, 32, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hey! Mau kemana\nliburannya?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Kelola semua pemesanan wisata Anda di sini',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),

              // Trip type chips
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 14, 32, 0),
                child: Row(
                  children: [
                    _TripTypeChip(
                      icon: Icons.sailing,
                      label: 'Tour',
                      selected: _tripType == 0,
                      onTap: () => setState(() => _tripType = 0),
                    ),
                    const SizedBox(width: 10),
                    _TripTypeChip(
                      icon: Icons.scuba_diving,
                      label: 'Diving',
                      selected: _tripType == 1,
                      onTap: () => setState(() => _tripType = 1),
                    ),
                    const SizedBox(width: 10),
                    _TripTypeChip(
                      icon: Icons.directions_boat,
                      label: 'Boat',
                      selected: _tripType == 2,
                      onTap: () => setState(() => _tripType = 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Floating Desktop Search Bar (full-width horizontal) ──
        Positioned(
          bottom: -36,
          left: 24,
          right: 24,
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(30),
                  blurRadius: 24,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                // Depart from
                _HoverField(
                  flex: 2,
                  icon: Icons.sailing,
                  label: 'Depart from',
                  value: _originCtrl.text,
                  onTap: () => _editField('origin'),
                ),
                // Swap button
                GestureDetector(
                  onTap: () => setState(() {
                    final t = _originCtrl.text;
                    _originCtrl.text = _destCtrl.text;
                    _destCtrl.text = t;
                  }),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: const Icon(Icons.swap_horiz,
                        size: 16, color: AppTheme.primary),
                  ),
                ),
                // Sail to
                _HoverField(
                  flex: 2,
                  icon: Icons.location_on_outlined,
                  label: 'Sail to',
                  value: _destCtrl.text,
                  onTap: () => _editField('dest'),
                ),
                // Divider
                Container(width: 1, height: 36, color: AppTheme.divider),
                // Date
                _HoverField(
                  flex: 2,
                  icon: Icons.calendar_month_outlined,
                  label: 'Tanggal',
                  value: _returnDate != null
                      ? '${_fmt(_departDate)} – ${_fmt(_returnDate!)}'
                      : _fmt(_departDate),
                  onTap: () => _pickDate(isReturn: false),
                ),
                // Divider
                Container(width: 1, height: 36, color: AppTheme.divider),
                // Passengers
                _HoverField(
                  flex: 2,
                  icon: Icons.people_outline,
                  label: 'Penumpang',
                  value: '$_passengers Dewasa',
                  onTap: () => _pickPassengers(),
                ),
                // Search CTA
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  child: FilledButton(
                    onPressed: () => _showForm(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      minimumSize: const Size(160, 52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Cari Kapal Pesiar',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }


  // ─────────────────────────────────────────────────────────────────
  // Booking List
  // ─────────────────────────────────────────────────────────────────
  Widget _buildBookingList() {
    return Consumer<BookingViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (vm.bookings.isEmpty) {
          return Column(
            children: [
              const SizedBox(height: 60),

              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.event_note_outlined,
                          size: 64, color: AppTheme.textHint),
                      const SizedBox(height: 16),
                      const Text(
                        'Belum ada pemesanan',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () => _showForm(context),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Buat Booking Pertama'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            const SizedBox(height: 190),
            // Quick filters
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 12),
              child: Row(
                children: [
                  const Text('Mencari',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13)),
                  const SizedBox(width: 12),
                  _ChipAction(
                      icon: Icons.wb_sunny_outlined,
                      label: 'Cari inspirasi'),
                  const SizedBox(width: 8),
                  _ChipAction(
                      icon: Icons.notifications_none,
                      label: 'Notifikasi Harga'),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                itemCount: vm.bookings.length,
                itemBuilder: (context, i) {
                  final b = vm.bookings[i];
                  return _BookingCard(
                    booking: b,
                    onTap: () => _showStatusMenu(context, b),
                    onDelete: () => _confirmDelete(context, b),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Dialogs & Pickers
  // ─────────────────────────────────────────────────────────────────
  Future<void> _pickDate({required bool isReturn}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isReturn
          ? (_returnDate ?? _departDate.add(const Duration(days: 1)))
          : _departDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isReturn) {
          _returnDate = picked;
        } else {
          _departDate = picked;
        }
      });
    }
  }

  void _pickPassengers() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Jumlah Penumpang'),
        content: StatefulBuilder(
          builder: (ctx, setLocal) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Dewasa'),
              Row(
                children: [
                  IconButton(
                    onPressed: _passengers > 1
                        ? () => setLocal(() => _passengers--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text('$_passengers'),
                  IconButton(
                    onPressed: () => setLocal(() => _passengers++),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }

  void _editField(String field) {
    final ctrl = field == 'origin' ? _originCtrl : _destCtrl;
    final label = field == 'origin' ? 'Depart From' : 'Sail To';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(label),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(hintText: label),
        ),
        actions: [
          FilledButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showForm(BuildContext context) {
    final nameCtrl = TextEditingController();
    final dateCtrl = TextEditingController(text: _fmt(_departDate));
    final priceCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Booking Baru'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration:
                    const InputDecoration(labelText: 'Nama Pelanggan'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: dateCtrl,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Tur',
                  suffixIcon: Icon(Icons.calendar_today,
                      color: AppTheme.primary, size: 20),
                ),
                onTap: () async {
                  final p = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate:
                        DateTime.now().add(const Duration(days: 365)),
                  );
                  if (p != null) {
                    dateCtrl.text =
                        '${p.year}-${p.month.toString().padLeft(2, '0')}-${p.day.toString().padLeft(2, '0')}';
                  }
                },
              ),
              const SizedBox(height: 14),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Total Harga (Rp)',
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
              final date = dateCtrl.text.trim();
              final price =
                  double.tryParse(priceCtrl.text.trim()) ?? 0;
              if (name.isEmpty || date.isEmpty || price <= 0) return;
              context.read<BookingViewModel>().addBooking(Booking(
                    customerName: name,
                    tourDate: date,
                    totalPrice: price,
                  ));
              Navigator.pop(context);
            },
            child: const Text('Buat Booking'),
          ),
        ],
      ),
    );
  }

  void _showStatusMenu(BuildContext context, Booking booking) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(booking.customerName,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('Tanggal: ${booking.tourDate}',
                style: const TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 20),
            const Text('Ubah Status:',
                style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            Row(
              children: [
                _statusBtn(context, booking, 'pending', AppTheme.warning),
                const SizedBox(width: 10),
                _statusBtn(
                    context, booking, 'confirmed', AppTheme.success),
                const SizedBox(width: 10),
                _statusBtn(
                    context, booking, 'cancelled', AppTheme.danger),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBtn(
      BuildContext ctx, Booking booking, String status, Color color) {
    final isActive = booking.status == status;
    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: isActive ? color : Colors.transparent,
          foregroundColor: isActive ? Colors.white : color,
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        onPressed: () {
          ctx.read<BookingViewModel>().updateStatus(booking.id!, status);
          Navigator.pop(ctx);
        },
        child: Text(status[0].toUpperCase() + status.substring(1),
            style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Booking booking) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Booking?'),
        content: Text('Hapus booking "${booking.customerName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            style:
                FilledButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () {
              context
                  .read<BookingViewModel>()
                  .deleteBooking(booking.id!);
              Navigator.pop(context);
            },
            child: const Text('Hapus',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────

class _NavTab extends StatelessWidget {
  final String label;
  final bool selected;
  const _NavTab({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : Colors.white70,
          fontWeight:
              selected ? FontWeight.w600 : FontWeight.w400,
          fontSize: 14,
          decoration:
              selected ? TextDecoration.underline : TextDecoration.none,
          decorationColor: Colors.white,
        ),
      );
}

class _TripTypeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TripTypeChip(
      {required this.icon,
      required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.white24,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 15,
                  color: selected ? AppTheme.primary : Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: selected ? AppTheme.primary : Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
}

/// Desktop-style interactive hover field for the search bar
class _HoverField extends StatefulWidget {
  final int flex;
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  const _HoverField({
    required this.flex,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  State<_HoverField> createState() => _HoverFieldState();
}

class _HoverFieldState extends State<_HoverField> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: widget.flex,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: _hovered
                  ? AppTheme.primaryLight
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textHint,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(widget.icon,
                        size: 16,
                        color: _hovered
                            ? AppTheme.primary
                            : AppTheme.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.value,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChipAction extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ChipAction({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppTheme.textSecondary),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textSecondary)),
          ],
        ),
      );
}

// ── Booking Card ──
class _BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _BookingCard(
      {required this.booking,
      required this.onTap,
      required this.onDelete});

  Color _statusColor(String s) => switch (s) {
        'confirmed' => AppTheme.success,
        'cancelled' => AppTheme.danger,
        _ => AppTheme.warning,
      };

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(booking.status);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  booking.status == 'confirmed'
                      ? Icons.check_circle
                      : booking.status == 'cancelled'
                          ? Icons.cancel
                          : Icons.schedule,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.customerName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(booking.tourDate,
                        style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rp ${_fmtPrice(booking.totalPrice)}',
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withAlpha(20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      booking.status.toUpperCase(),
                      style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: 20, color: AppTheme.danger),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmtPrice(double v) {
    final p = v.toStringAsFixed(0).split('');
    final b = StringBuffer();
    for (var i = 0; i < p.length; i++) {
      if (i > 0 && (p.length - i) % 3 == 0) b.write('.');
      b.write(p[i]);
    }
    return b.toString();
  }
}
